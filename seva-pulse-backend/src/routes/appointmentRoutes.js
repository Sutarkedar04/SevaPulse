const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');
const Patient = require('../models/Patient');
const User = require('../models/User');
const Notification = require('../models/Notification'); // ✅ ADD THIS

// Helper function to send appointment notification
async function sendAppointmentNotification(appointment, action, io) {
  try {
    console.log(`📢 Sending ${action} notification for appointment: ${appointment._id}`);
    
    const patient = await Patient.findById(appointment.patient).populate('user', 'name');
    const doctor = await Doctor.findById(appointment.doctor).populate('user', 'name');
    
    const patientUserId = patient?.user?._id;
    const doctorUserId = doctor?.user?._id;
    
    if (!patientUserId) {
      console.log('⚠️ No patient user ID found');
      return null;
    }

    // Determine recipients based on action
    let recipients = [];
    let title = '';
    let message = '';
    
    const appointmentDate = new Date(appointment.date).toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });

    if (action === 'BOOKED') {
      // Send to patient only
      recipients = [patientUserId];
      title = '✅ Appointment Booked Successfully';
      message = `Your appointment with Dr. ${doctor?.user?.name || 'Doctor'} has been booked for ${appointmentDate} at ${appointment.timeSlot?.start || 'scheduled time'}. Please arrive 10 minutes before your appointment.`;
    } else if (action === 'CONFIRMED') {
      // Send to both patient and doctor
      recipients = [patientUserId];
      if (doctorUserId) recipients.push(doctorUserId);
      title = '✅ Appointment Confirmed';
      message = `Appointment with Dr. ${doctor?.user?.name || 'Doctor'} on ${appointmentDate} at ${appointment.timeSlot?.start || 'scheduled time'} has been confirmed.`;
    } else if (action === 'CANCELLED') {
      // Send to both patient and doctor
      recipients = [patientUserId];
      if (doctorUserId) recipients.push(doctorUserId);
      title = '❌ Appointment Cancelled';
      message = `Appointment with Dr. ${doctor?.user?.name || 'Doctor'} on ${appointmentDate} at ${appointment.timeSlot?.start || 'scheduled time'} has been cancelled.`;
    }

    if (recipients.length === 0) return null;

    const notificationData = {
      title,
      message,
      type: `APPOINTMENT_${action}`,
      appointmentId: appointment._id,
      appointmentData: {
        doctorName: doctor?.user?.name || 'Doctor',
        patientName: patient?.user?.name || 'Patient',
        date: appointment.date,
        time: appointment.timeSlot?.start || '10:00 AM',
        status: appointment.status,
        type: appointment.type
      },
      recipients,
      createdAt: new Date()
    };

    const notification = await Notification.create(notificationData);
    console.log(`✅ Notification saved: ${notification._id}`);

    // Emit via WebSocket
    if (io) {
      recipients.forEach(recipientId => {
        io.to(`patient_${recipientId}`).emit('notification', {
          id: notification._id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          appointmentId: appointment._id,
          appointmentData: notification.appointmentData,
          createdAt: notification.createdAt
        });
        
        if (doctorUserId) {
          io.to(`doctor_${doctorUserId}`).emit('notification', {
            id: notification._id,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            appointmentId: appointment._id,
            appointmentData: notification.appointmentData,
            createdAt: notification.createdAt
          });
        }
      });
      console.log(`📡 WebSocket notification emitted`);
    }

    return notification;
  } catch (error) {
    console.error('❌ Error sending appointment notification:', error);
    return null;
  }
}

// Get all appointments
router.get('/', protect, async (req, res, next) => {
  try {
    console.log('📋 Getting appointments for user:', req.user.id);
    
    let query = {};
    
    if (req.user.role === 'patient') {
      const patient = await Patient.findOne({ user: req.user.id });
      if (patient) {
        query.patient = patient._id;
      } else {
        const newPatient = await Patient.create({
          user: req.user.id,
          dateOfBirth: new Date('1990-01-01'),
          gender: 'Not specified'
        });
        query.patient = newPatient._id;
        console.log('✅ Created missing patient profile for user:', req.user.id);
      }
    } else if (req.user.role === 'doctor') {
      const doctor = await Doctor.findOne({ user: req.user.id });
      if (doctor) {
        query.doctor = doctor._id;
      }
    }
    
    const appointments = await Appointment.find(query)
      .populate({
        path: 'doctor',
        populate: { path: 'user', select: 'name email' }
      })
      .populate({
        path: 'patient',
        populate: { path: 'user', select: 'name email' }
      })
      .sort('-date');
    
    const formattedAppointments = appointments.map(apt => ({
      id: apt._id,
      patientId: apt.patient?.user?._id?.toString(),
      doctorId: apt.doctor?._id?.toString(),
      patientName: apt.patient?.user?.name || 'Unknown',
      doctorName: apt.doctor?.user?.name || 'Unknown',
      patientEmail: apt.patient?.user?.email || '',
      date: apt.date,
      time: apt.timeSlot?.start || '10:00 AM',
      status: apt.status,
      type: apt.type,
      symptoms: apt.symptoms || '',
      notes: apt.notes
    }));
    
    console.log(`✅ Found ${formattedAppointments.length} appointments`);
    
    res.status(200).json({ 
      success: true, 
      count: formattedAppointments.length, 
      data: formattedAppointments 
    });
  } catch (error) {
    console.error('❌ Error in getAppointments:', error);
    next(error);
  }
});

// Create appointment
router.post('/', protect, async (req, res, next) => {
  try {
    console.log('📝 Creating appointment for user:', req.user.id);
    
    let patient = await Patient.findOne({ user: req.user.id });
    if (!patient) {
      patient = await Patient.create({
        user: req.user.id,
        dateOfBirth: new Date('1990-01-01'),
        gender: 'Not specified'
      });
      console.log('✅ Created new patient profile for user:', req.user.id);
    }
    
    const doctor = await Doctor.findById(req.body.doctorId).populate('user');
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Doctor not found' });
    }
    
    const appointmentData = {
      doctor: doctor._id,
      patient: patient._id,
      date: new Date(req.body.date),
      timeSlot: { start: req.body.time },
      status: 'pending',
      type: req.body.type || 'consultation',
      symptoms: req.body.symptoms || '',
      notes: req.body.notes || ''
    };
    
    const appointment = await Appointment.create(appointmentData);
    
    // ✅ SEND NOTIFICATION FOR NEW APPOINTMENT
    await sendAppointmentNotification(appointment, 'BOOKED', global.io);
    
    const populatedAppointment = await Appointment.findById(appointment._id)
      .populate({
        path: 'doctor',
        populate: { path: 'user', select: 'name email' }
      })
      .populate({
        path: 'patient',
        populate: { path: 'user', select: 'name email' }
      });
    
    res.status(201).json({ 
      success: true, 
      data: {
        id: populatedAppointment._id,
        patientId: populatedAppointment.patient?.user?._id?.toString(),
        doctorId: populatedAppointment.doctor?._id?.toString(),
        patientName: populatedAppointment.patient?.user?.name || 'Patient',
        doctorName: populatedAppointment.doctor?.user?.name || 'Doctor',
        patientEmail: populatedAppointment.patient?.user?.email || '',
        date: populatedAppointment.date,
        time: populatedAppointment.timeSlot.start,
        status: populatedAppointment.status,
        type: populatedAppointment.type,
        symptoms: populatedAppointment.symptoms
      }
    });
  } catch (error) {
    console.error('❌ Error in createAppointment:', error);
    next(error);
  }
});

// Update appointment status
router.put('/:id', protect, async (req, res, next) => {
  try {
    const { status } = req.body;
    const oldAppointment = await Appointment.findById(req.params.id);
    
    const appointment = await Appointment.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    )
    .populate({
      path: 'doctor',
      populate: { path: 'user', select: 'name email' }
    })
    .populate({
      path: 'patient',
      populate: { path: 'user', select: 'name email' }
    });
    
    if (!appointment) {
      return res.status(404).json({ success: false, message: 'Appointment not found' });
    }
    
    // ✅ SEND NOTIFICATION WHEN STATUS CHANGES TO CONFIRMED
    if (oldAppointment.status !== 'confirmed' && status === 'confirmed') {
      await sendAppointmentNotification(appointment, 'CONFIRMED', global.io);
    }
    
    // ✅ SEND NOTIFICATION WHEN STATUS CHANGES TO CANCELLED
    if (oldAppointment.status !== 'cancelled' && status === 'cancelled') {
      await sendAppointmentNotification(appointment, 'CANCELLED', global.io);
    }
    
    res.status(200).json({ 
      success: true, 
      data: {
        id: appointment._id,
        patientId: appointment.patient?.user?._id?.toString(),
        doctorId: appointment.doctor?._id?.toString(),
        patientName: appointment.patient?.user?.name || 'Patient',
        doctorName: appointment.doctor?.user?.name || 'Doctor',
        patientEmail: appointment.patient?.user?.email || '',
        date: appointment.date,
        time: appointment.timeSlot?.start || '10:00 AM',
        status: appointment.status,
        type: appointment.type,
        symptoms: appointment.symptoms
      }
    });
  } catch (error) {
    console.error('❌ Error in updateAppointment:', error);
    next(error);
  }
});

// Delete appointment
router.delete('/:id', protect, async (req, res, next) => {
  try {
    const appointment = await Appointment.findById(req.params.id)
      .populate({
        path: 'doctor',
        populate: { path: 'user', select: 'name email' }
      })
      .populate({
        path: 'patient',
        populate: { path: 'user', select: 'name email' }
      });
    
    if (!appointment) {
      return res.status(404).json({ success: false, message: 'Appointment not found' });
    }
    
    // ✅ SEND NOTIFICATION FOR CANCELLATION
    await sendAppointmentNotification(appointment, 'CANCELLED', global.io);
    
    await Appointment.findByIdAndDelete(req.params.id);
    
    res.status(200).json({ success: true, message: 'Appointment deleted' });
  } catch (error) {
    console.error('❌ Error in deleteAppointment:', error);
    next(error);
  }
});

module.exports = router;
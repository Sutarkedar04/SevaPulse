const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');
const Patient = require('../models/Patient');

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
    next(error); // Pass error to error handler
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
    const appointment = await Appointment.findByIdAndDelete(req.params.id);
    if (!appointment) {
      return res.status(404).json({ success: false, message: 'Appointment not found' });
    }
    res.status(200).json({ success: true, message: 'Appointment deleted' });
  } catch (error) {
    console.error('❌ Error in deleteAppointment:', error);
    next(error);
  }
});

module.exports = router;
// src/controllers/appointmentController.js
const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');
const Patient = require('../models/Patient');
const User = require('../models/User');

exports.getAppointments = async (req, res) => {
  try {
    console.log('Getting appointments for user:', req.user.id);
    console.log('User role:', req.user.role);
    
    let query;
    let userRole = req.user.role;
    
    if (userRole === 'patient') {
      // Find patient profile for this user
      const patient = await Patient.findOne({ user: req.user.id });
      if (patient) {
        query = { patient: patient._id };
        console.log('Querying appointments for patient:', patient._id);
      } else {
        return res.status(200).json({ success: true, count: 0, data: [] });
      }
    } else if (userRole === 'doctor') {
      // Find doctor profile for this user
      const doctor = await Doctor.findOne({ user: req.user.id });
      if (doctor) {
        query = { doctor: doctor._id };
        console.log('Querying appointments for doctor:', doctor._id);
      } else {
        return res.status(200).json({ success: true, count: 0, data: [] });
      }
    } else {
      query = {};
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
      // CRITICAL: Return the USER ID for patient, not the patient collection ID
      patientId: apt.patient?.user?._id?.toString(),
      // CRITICAL: Return the USER ID for doctor, not the doctor collection ID  
      doctorId: apt.doctor?.user?._id?.toString(),
      patientName: apt.patient?.user?.name || 'Unknown',
      doctorName: apt.doctor?.user?.name || 'Unknown',
      patientEmail: apt.patient?.user?.email || '',
      date: apt.date,
      time: apt.timeSlot?.start || '10:00 AM',
      status: apt.status,
      type: apt.type,
      symptoms: apt.symptoms || '',
      notes: apt.notes,
      specialty: apt.doctor?.specialization || 'General'
    }));
    
    console.log('Returning appointments count:', formattedAppointments.length);
    if (formattedAppointments.length > 0) {
      console.log('First appointment doctor ID:', formattedAppointments[0].doctorId);
      console.log('First appointment patient ID:', formattedAppointments[0].patientId);
    }
    
    res.status(200).json({ 
      success: true, 
      count: formattedAppointments.length, 
      data: formattedAppointments 
    });
  } catch (error) {
    console.error('Error in getAppointments:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.createAppointment = async (req, res) => {
  try {
    console.log('Creating appointment for user:', req.user.id);
    console.log('Request body:', req.body);
    
    // Find patient profile for this user
    let patient = await Patient.findOne({ user: req.user.id });
    
    if (!patient) {
      patient = await Patient.create({
        user: req.user.id,
        dateOfBirth: new Date('1990-01-01'),
        gender: 'Not specified'
      });
      console.log('Created new patient profile:', patient._id);
    }
    
    // Find doctor by USER ID (not doctor collection ID)
    let doctor = await Doctor.findOne({ user: req.body.doctorId });
    
    if (!doctor) {
      // If not found by user ID, try by doctor collection ID
      doctor = await Doctor.findById(req.body.doctorId);
    }
    
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Doctor not found' });
    }
    
    console.log('Found doctor:', doctor._id);
    console.log('Doctor user ID:', doctor.user);
    
    const appointmentData = {
      doctor: doctor._id, // Store doctor collection ID
      patient: patient._id, // Store patient collection ID
      date: new Date(req.body.date),
      timeSlot: { start: req.body.time },
      status: 'pending',
      type: req.body.type || 'consultation',
      symptoms: req.body.symptoms || '',
      notes: req.body.notes || ''
    };
    
    const appointment = await Appointment.create(appointmentData);
    console.log('Appointment created with ID:', appointment._id);
    
    // Populate the appointment
    const populatedAppointment = await Appointment.findById(appointment._id)
      .populate({
        path: 'doctor',
        populate: { path: 'user', select: 'name email' }
      })
      .populate({
        path: 'patient',
        populate: { path: 'user', select: 'name email' }
      });
    
    // Return with USER IDs, not collection IDs
    res.status(201).json({ 
      success: true, 
      data: {
        id: populatedAppointment._id,
        patientId: populatedAppointment.patient?.user?._id?.toString(),
        doctorId: populatedAppointment.doctor?.user?._id?.toString(),
        patientName: populatedAppointment.patient?.user?.name || 'Patient',
        doctorName: populatedAppointment.doctor?.user?.name || 'Doctor',
        patientEmail: populatedAppointment.patient?.user?.email || '',
        date: populatedAppointment.date,
        time: populatedAppointment.timeSlot.start,
        status: populatedAppointment.status,
        type: populatedAppointment.type,
        symptoms: populatedAppointment.symptoms,
        specialty: populatedAppointment.doctor?.specialization || 'General'
      }
    });
  } catch (error) {
    console.error('Error in createAppointment:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};
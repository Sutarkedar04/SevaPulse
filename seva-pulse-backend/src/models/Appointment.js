const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  doctor: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctor', required: true },
  patient: { type: mongoose.Schema.Types.ObjectId, ref: 'Patient', required: true },
  date: { type: Date, required: true },
  timeSlot: { start: String, end: String },
  status: { type: String, enum: ['pending', 'confirmed', 'cancelled', 'completed', 'no-show'], default: 'pending' },
  type: { type: String, enum: ['general', 'follow-up', 'emergency', 'consultation'], default: 'general' },
  symptoms: String,
  notes: String,
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Appointment', appointmentSchema);
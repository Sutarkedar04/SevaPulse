// src/models/Patient.js
const mongoose = require('mongoose');

const patientSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  dateOfBirth: { type: Date, default: Date.now },
  gender: { type: String, enum: ['Male', 'Female', 'Other', 'Not specified'], default: 'Not specified' },
  bloodGroup: { type: String, default: '' },
  emergencyContact: {
    name: String,
    relationship: String,
    phone: String
  },
  address: {
    street: String,
    city: String,
    state: String,
    zipCode: String
  },
  medicalHistory: [{
    condition: String,
    diagnosedDate: Date,
    notes: String
  }],
  allergies: [String],
  currentMedications: [{
    name: String,
    dosage: String,
    frequency: String
  }],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Patient', patientSchema);
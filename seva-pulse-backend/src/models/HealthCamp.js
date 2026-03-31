const mongoose = require('mongoose');

const healthCampSchema = new mongoose.Schema({
  title: { type: String, required: true },
  organization: { type: String, required: true },
  date: { type: Date, required: true },
  time: { type: String, required: true },
  location: { type: String, required: true },
  description: { type: String, required: true },
  imageUrl: { type: String },
  availableSlots: { type: Number, required: true },
  registeredParticipants: { type: Number, default: 0 },
  services: [{ type: String }],
  contact: { type: String, required: true },
  isFree: { type: Boolean, default: true },
  fee: { type: Number },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('HealthCamp', healthCampSchema);
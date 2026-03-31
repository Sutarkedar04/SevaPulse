const mongoose = require('mongoose');

const medicineSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: true },
  dosage: { type: String, required: true },
  schedule: { type: String, required: true },
  times: [{ type: String }],
  taken: [{ type: Boolean, default: false }],
  startDate: { type: String, default: 'Not set' },
  endDate: { type: String, default: 'Not set' },
  remaining: { type: String, default: 'Ongoing' },
  instructions: { type: String, default: 'No special instructions' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Medicine', medicineSchema);
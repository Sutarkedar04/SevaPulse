const mongoose = require('mongoose');

const billSchema = new mongoose.Schema({
  patient: { type: mongoose.Schema.Types.ObjectId, ref: 'Patient', required: true },
  appointment: { type: mongoose.Schema.Types.ObjectId, ref: 'Appointment' },
  items: [{
    description: String,
    quantity: Number,
    unitPrice: Number,
    total: Number,
    type: { type: String, enum: ['consultation', 'medicine', 'test', 'procedure', 'other'] }
  }],
  subtotal: { type: Number, required: true },
  tax: { type: Number, default: 0 },
  discount: { type: Number, default: 0 },
  total: { type: Number, required: true },
  status: { type: String, enum: ['pending', 'paid', 'cancelled', 'refunded'], default: 'pending' },
  paymentMethod: { type: String, enum: ['cash', 'card', 'insurance', 'online'] },
  paymentDate: Date,
  dueDate: Date,
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Bill', billSchema);
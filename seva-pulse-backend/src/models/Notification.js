const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  title: { type: String, required: true },
  message: { type: String, required: true },
  type: { 
    type: String, 
    enum: [
      'HEALTH_CAMP_CREATE', 
      'HEALTH_CAMP_UPDATE', 
      'HEALTH_CAMP_DELETE',
      'APPOINTMENT_BOOKED',      // ✅ NEW
      'APPOINTMENT_CONFIRMED',   // ✅ NEW
      'APPOINTMENT_CANCELLED'    // ✅ NEW
    ], 
    required: true 
  },
  campId: { type: mongoose.Schema.Types.ObjectId, ref: 'HealthCamp' },
  campData: { type: Object },
  appointmentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Appointment' }, // ✅ NEW
  appointmentData: { type: Object }, // ✅ NEW
  recipients: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  readBy: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  createdAt: { type: Date, default: Date.now }
});

notificationSchema.index({ createdAt: -1 });
notificationSchema.index({ recipients: 1 });

module.exports = mongoose.model('Notification', notificationSchema);
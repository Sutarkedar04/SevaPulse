const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const healthFeedController = require('../controllers/healthFeedController');

// Get all health camps
router.get('/', protect, healthFeedController.getHealthCamps);

// Get single health camp
router.get('/:id', protect, healthFeedController.getHealthCamp);

// Create health camp
router.post('/', protect, healthFeedController.createHealthCamp);

// Update health camp
router.put('/:id', protect, healthFeedController.updateHealthCamp);

// Delete health camp
router.delete('/:id', protect, healthFeedController.deleteHealthCamp);

// Register for health camp
router.post('/:id/register', protect, healthFeedController.registerForCamp);

// ✅ TEST ENDPOINT - Remove in production
router.get('/test-notification', protect, async (req, res) => {
  try {
    const Notification = require('../models/Notification');
    const User = require('../models/User');
    
    const patients = await User.find({ userType: 'patient' }).select('_id');
    
    const testNotif = await Notification.create({
      title: 'Test Notification',
      message: 'This is a test notification from server',
      type: 'TEST',
      recipients: patients.map(p => p._id),
      createdAt: new Date()
    });
    
    // Emit via socket if available
    if (global.io) {
      global.io.to('all_patients').emit('health_camp_notification', {
        id: testNotif._id,
        title: 'Test Notification',
        message: 'This is a test notification from server',
        type: 'TEST',
        createdAt: new Date()
      });
      console.log('✅ Test notification emitted to all_patients');
    }
    
    res.json({ 
      success: true, 
      message: 'Test notification sent', 
      count: patients.length,
      notificationId: testNotif._id
    });
  } catch (error) {
    console.error('Error sending test notification:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
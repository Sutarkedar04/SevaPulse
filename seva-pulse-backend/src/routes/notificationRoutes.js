const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const Notification = require('../models/Notification');

// Get user's notifications
router.get('/', protect, async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit = 50, skip = 0 } = req.query;

    const notifications = await Notification.find({
      recipients: userId
    })
    .sort({ createdAt: -1 })
    .limit(parseInt(limit))
    .skip(parseInt(skip));

    const unreadCount = await Notification.countDocuments({
      recipients: userId,
      readBy: { $ne: userId }
    });

    // Format notifications for frontend
    const formattedNotifications = notifications.map(notif => ({
      id: notif._id,
      title: notif.title,
      message: notif.message,
      type: notif.type,
      campId: notif.campId,
      campData: notif.campData,
      appointmentId: notif.appointmentId,  // ✅ Include appointment data
      appointmentData: notif.appointmentData, // ✅ Include appointment data
      isRead: notif.readBy.includes(userId),
      createdAt: notif.createdAt
    }));

    res.status(200).json({
      success: true,
      data: formattedNotifications,
      unreadCount: unreadCount,
      total: formattedNotifications.length
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Mark notification as read
router.put('/:id/read', protect, async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);
    
    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    if (!notification.readBy.includes(req.user.id)) {
      notification.readBy.push(req.user.id);
      await notification.save();
    }

    res.status(200).json({ success: true, message: 'Marked as read' });
  } catch (error) {
    console.error('Error marking as read:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Mark all notifications as read
router.put('/mark-all-read', protect, async (req, res) => {
  try {
    await Notification.updateMany(
      { recipients: req.user.id, readBy: { $ne: req.user.id } },
      { $addToSet: { readBy: req.user.id } }
    );

    res.status(200).json({ success: true, message: 'All notifications marked as read' });
  } catch (error) {
    console.error('Error marking all as read:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
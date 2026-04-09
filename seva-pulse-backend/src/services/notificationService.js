const Notification = require('../models/Notification');
const User = require('../models/User');

class NotificationService {
  constructor(io) {
    this.io = io;
  }

  async notifyHealthCampAction(camp, action, userId) {
    try {
      // Get all patient users
      const patients = await User.find({ userType: 'patient' }).select('_id');
      const patientIds = patients.map(p => p._id);

      // Create notification message
      const notificationData = {
        title: this.getNotificationTitle(action, camp.title),
        message: this.getNotificationMessage(action, camp),
        type: `HEALTH_CAMP_${action}`,
        campId: camp._id,
        campData: {
          title: camp.title,
          date: camp.date,
          location: camp.location,
          time: camp.time,
          availableSlots: camp.availableSlots,
          isFree: camp.isFree
        },
        recipients: patientIds,
        createdAt: new Date()
      };

      // Save to database
      const notification = await Notification.create(notificationData);

      // Emit real-time notification via Socket.IO
      if (this.io) {
        this.io.to('all_patients').emit('health_camp_notification', {
          id: notification._id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          campId: camp._id,
          campData: notification.campData,
          createdAt: notification.createdAt
        });
      }

      console.log(`📢 Notification sent for ${action} camp: ${camp.title}`);
      return notification;
    } catch (error) {
      console.error('❌ Error sending notification:', error);
      return null;
    }
  }

  getNotificationTitle(action, campTitle) {
    switch(action) {
      case 'CREATE':
        return `🆕 New Health Camp: ${campTitle}`;
      case 'UPDATE':
        return `📝 Health Camp Updated: ${campTitle}`;
      case 'DELETE':
        return `❌ Health Camp Cancelled: ${campTitle}`;
      default:
        return `Health Camp Update`;
    }
  }

  getNotificationMessage(action, camp) {
    switch(action) {
      case 'CREATE':
        return `A new health camp "${camp.title}" has been scheduled on ${new Date(camp.date).toLocaleDateString()} at ${camp.location}. ${camp.availableSlots} slots available!`;
      case 'UPDATE':
        return `The health camp "${camp.title}" has been updated. Please check the new details for ${new Date(camp.date).toLocaleDateString()}.`;
      case 'DELETE':
        return `The health camp "${camp.title}" scheduled on ${new Date(camp.date).toLocaleDateString()} has been cancelled. We apologize for the inconvenience.`;
      default:
        return `Health camp "${camp.title}" has been updated.`;
    }
  }

  async getUserNotifications(userId, limit = 50, skip = 0) {
    try {
      const notifications = await Notification.find({
        recipients: userId
      })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

      const unreadCount = await Notification.countDocuments({
        recipients: userId,
        isRead: false,
        readBy: { $ne: userId }
      });

      return { notifications, unreadCount };
    } catch (error) {
      console.error('Error getting notifications:', error);
      return { notifications: [], unreadCount: 0 };
    }
  }

  async markAsRead(notificationId, userId) {
    try {
      const notification = await Notification.findById(notificationId);
      if (notification && !notification.readBy.includes(userId)) {
        notification.readBy.push(userId);
        await notification.save();
      }
      return true;
    } catch (error) {
      console.error('Error marking as read:', error);
      return false;
    }
  }

  async markAllAsRead(userId) {
    try {
      await Notification.updateMany(
        { recipients: userId, readBy: { $ne: userId } },
        { $addToSet: { readBy: userId } }
      );
      return true;
    } catch (error) {
      console.error('Error marking all as read:', error);
      return false;
    }
  }
}

module.exports = NotificationService;
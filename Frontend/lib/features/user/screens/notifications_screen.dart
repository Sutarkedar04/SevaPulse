// lib/features/user/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      notificationProvider.setToken(authProvider.token!);
      await notificationProvider.fetchNotifications();
    }
  }

  Future<void> _markAllAsRead() async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.markAllAsRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: Color(0xFF27ae60),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return TextButton.icon(
                  onPressed: _markAllAsRead,
                  icon: const Icon(Icons.done_all, color: Colors.white, size: 20),
                  label: const Text(
                    'Mark all read',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll be notified about health camps and appointments here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return _buildNotificationCard(notification, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationProvider provider) {
    final isUnread = !notification.isRead;
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(notification.createdAt);
    
    // Get icon and color based on notification type
    IconData iconData;
    Color iconColor;
    
    // ✅ Check notification type and set appropriate icon
    if (notification.isHealthCampNotification) {
      if (notification.type.contains('CREATE')) {
        iconData = Icons.add_circle_outline;
        iconColor = const Color(0xFF27ae60);
      } else if (notification.type.contains('UPDATE')) {
        iconData = Icons.edit_outlined;
        iconColor = const Color(0xFF3498db);
      } else if (notification.type.contains('DELETE')) {
        iconData = Icons.delete_outline;
        iconColor = Colors.red;
      } else {
        iconData = Icons.medical_services;
        iconColor = const Color(0xFF3498db);
      }
    } else if (notification.isAppointmentNotification) {
      if (notification.type.contains('BOOKED')) {
        iconData = Icons.calendar_today;
        iconColor = const Color(0xFF3498db);
      } else if (notification.type.contains('CONFIRMED')) {
        iconData = Icons.check_circle_outline;
        iconColor = const Color(0xFF27ae60);
      } else if (notification.type.contains('CANCELLED')) {
        iconData = Icons.cancel_outlined;
        iconColor = Colors.red;
      } else {
        iconData = Icons.event_note;
        iconColor = const Color(0xFF3498db);
      }
    } else {
      // Fallback for other notification types
      iconData = Icons.notifications;
      iconColor = const Color(0xFF3498db);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnread ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnread 
            ? BorderSide.none 
            : BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            provider.markAsRead(notification.id);
          }
          _showNotificationDetails(notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFe8f4fd) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                          fontSize: 15,
                          color: const Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: isUnread ? const Color(0xFF5d6d7e) : const Color(0xFF95a5a6),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3498db),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetails(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification Title
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Divider(height: 24),
                    
                    // Notification Message
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5d6d7e),
                        height: 1.5,
                      ),
                    ),
                    
                    // ✅ Health Camp Details Section
                    if (notification.isHealthCampNotification && notification.campData != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf8f9fa),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFe0e0e0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  color: const Color(0xFF27ae60),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Camp Details:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF2c3e50),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow('📅 Date', _formatDate(notification.campData!['date'])),
                            _buildDetailRow('📍 Location', notification.campData!['location']?.toString()),
                            _buildDetailRow('⏰ Time', notification.campData!['time']?.toString()),
                            _buildDetailRow('🎟️ Available Slots', notification.campData!['availableSlots']?.toString()),
                            _buildDetailRow('💰 Price', notification.campData!['isFree'] == true 
                                ? 'Free' 
                                : '₹${notification.campData!['fee']}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // View Health Camps Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/health-feed');
                          },
                          icon: const Icon(Icons.medical_services),
                          label: const Text('View Health Camps'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27ae60),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                    
                    // ✅ Appointment Details Section
                    if (notification.isAppointmentNotification && notification.appointmentData != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf8f9fa),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFe0e0e0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.event_note,
                                  color: const Color(0xFF3498db),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Appointment Details:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF2c3e50),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow('👨‍⚕️ Doctor', notification.appointmentData!['doctorName']?.toString()),
                            _buildDetailRow('👤 Patient', notification.appointmentData!['patientName']?.toString()),
                            _buildDetailRow('📅 Date', _formatDate(notification.appointmentData!['date'])),
                            _buildDetailRow('⏰ Time', notification.appointmentData!['time']?.toString()),
                            _buildDetailRow('📋 Status', notification.appointmentData!['status']?.toString()?.toUpperCase()),
                            _buildDetailRow('🏥 Type', notification.appointmentData!['type']?.toString()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // View Appointments Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/appointments');
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('View My Appointments'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498db),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFF3498db)),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16, color: Color(0xFF3498db)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format date strings
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Not specified';
    
    try {
      if (dateValue is String) {
        final date = DateTime.parse(dateValue);
        return DateFormat('EEEE, MMMM d, yyyy').format(date);
      } else if (dateValue is DateTime) {
        return DateFormat('EEEE, MMMM d, yyyy').format(dateValue);
      }
      return dateValue.toString();
    } catch (e) {
      return dateValue.toString();
    }
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7f8c8d),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2c3e50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
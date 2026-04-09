import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../../data/providers/notification_provider.dart';
import '../screens/notifications_screen.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return badges.Badge(
          showBadge: provider.unreadCount > 0,
          badgeContent: Text(
            '${provider.unreadCount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          badgeStyle: const badges.BadgeStyle(
            badgeColor: Colors.red,
            padding: EdgeInsets.all(4),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
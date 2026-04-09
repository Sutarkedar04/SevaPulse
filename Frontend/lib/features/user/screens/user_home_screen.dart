// lib/features/user/screens/user_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seva_pulse/data/providers/medicine_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/appointment_provider.dart';
import '../../../presentation/common/widgets/bottom_nav_bar.dart';
import '../widgets/home_content.dart';
import 'my_medicine_screen.dart';
import 'prescriptions_screen.dart';
import 'profile_screen.dart';
import '../widgets/notification_bell.dart'; // ✅ ADD THIS
import '../../../../core/services/socket_service.dart'; // ✅ ADD THIS
import '../../../data/providers/notification_provider.dart'; // ✅ ADD THIS

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final SocketService _socketService = SocketService(); // ✅ ADD THIS

  // Pages for bottom navigation
  final List<Widget> _pages = [
    const HomeContent(),
    const MyMedicineScreen(),
    const PrescriptionsScreen(),
    const ProfileScreen(),
  ];

  // Navigation items with icons and labels
  final List<Map<String, dynamic>> _navItems = const [
    {
      'icon': Icons.home,
      'label': 'Home',
    },
    {
      'icon': Icons.medical_services,
      'label': 'My Medicine',
    },
    {
      'icon': Icons.medication,
      'label': 'Prescriptions',
    },
    {
      'icon': Icons.person,
      'label': 'Profile',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      
      print('=== USER HOME SCREEN INIT ===');
      print('Token exists: ${authProvider.token != null}');
      print('Token value: ${authProvider.token}');
      print('User ID: ${authProvider.user?.id}');
      print('User Name: ${authProvider.user?.name}');
      
      if (authProvider.token != null && authProvider.token!.isNotEmpty) {
        print('Setting token in providers...');
        appointmentProvider.setToken(authProvider.token!);
        medicineProvider.setToken(authProvider.token!);
        notificationProvider.setToken(authProvider.token!);
        
        print('Calling loadAppointments...');
        appointmentProvider.loadAppointments();
        notificationProvider.fetchNotifications(); // ✅ ADD THIS
        
        // ✅ Connect WebSocket for real-time notifications
        _setupWebSocketConnection(authProvider, notificationProvider);
      } else {
        print('No token available!');
      }
    });
  }

  // ✅ ADD THIS METHOD
  void _setupWebSocketConnection(AuthProvider authProvider, NotificationProvider notificationProvider) {
    if (authProvider.user != null) {
      _socketService.connect(authProvider.user!.id, authProvider.user!.userType);
      
      // Listen to real-time notifications
      _socketService.notificationStream.listen((notification) {
        print('📢 Received real-time notification in HomeScreen: $notification');
        notificationProvider.addRealtimeNotification(notification);
        
        // Show in-app snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification['title'] ?? 'New Notification',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(notification['message'] ?? ''),
                ],
              ),
              backgroundColor: const Color(0xFF3498db),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      });
    }
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from Seva Pulse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    _socketService.disconnect(); // ✅ ADD THIS - Clean up socket
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _openChatbot(BuildContext context) {
    Navigator.pushNamed(context, '/chatbot');
  }

  void _contactUs(BuildContext context) {
    Navigator.pushNamed(context, '/contact-us');
  }

  @override
  void dispose() {
    _socketService.dispose(); // ✅ ADD THIS
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: AppBar(
        title: const Text(
          'SEVA PULSE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: _currentIndex == 0 ? [
          const NotificationBell(), // ✅ REPLACE existing IconButton with this
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              } else if (value == 'profile') {
                setState(() {
                  _currentIndex = 3; // Switch to Profile tab
                });
              } else if (value == 'contact') {
                _contactUs(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20, color: Color(0xFF3498db)),
                    SizedBox(width: 12),
                    Text('My Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'contact',
                child: Row(
                  children: [
                    Icon(Icons.contact_support, size: 20, color: Color(0xFF3498db)),
                    SizedBox(width: 12),
                    Text('Contact Us'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ] : null,
      ),
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openChatbot(context),
        backgroundColor: const Color(0xFF3498db),
        child: const Icon(Icons.chat, color: Colors.white),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: _navItems,
      ),
    );
  }
}
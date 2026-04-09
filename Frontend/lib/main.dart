import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/api_constants.dart';
//import 'core/services/push_notification_service.dart'; // ✅ ADD THIS
import 'data/providers/auth_provider.dart';
import 'data/providers/appointment_provider.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/medicine_provider.dart';
import 'data/providers/notification_provider.dart';
import 'features/auth/SevaPulseSplashScreen.dart';
import 'features/user/screens/user_home_screen.dart';
import 'features/auth/user_login_screen.dart';
import 'features/auth/user_register_screen.dart';
import 'features/auth/doctor_login_screen.dart';
import 'features/doctor/screens/doctor_home_screen.dart';
import 'features/user/screens/specialties_screen.dart';
import 'features/user/screens/health_tips.dart';
import 'features/user/screens/health_feed_screen.dart';
import 'features/user/screens/canteen_menu_screen.dart';
import 'features/user/screens/chatbot_screen.dart';
import 'features/user/screens/contact_us_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting Seva Pulse App...');
  print('📡 Using backend URL: ${ApiConstants.baseUrl}');
  
  // ✅ Initialize push notifications
  //await PushNotificationService().initialize();
  //print('✅ Push Notification Service initialized');
  
  final prefs = await SharedPreferences.getInstance();
  print('✅ SharedPreferences initialized');
  
  final existingToken = prefs.getString('auth_token');
  print('🔐 Existing token: ${existingToken != null ? "YES" : "NO"}');
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider.withPreferences(prefs),
        ),
        ChangeNotifierProvider<AppointmentProvider>(
          create: (context) => AppointmentProvider(),
        ),
        ChangeNotifierProvider<MedicineProvider>(
          create: (context) => MedicineProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (context) => NotificationProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SEVA PULSE',
            theme: themeProvider.currentTheme,
            initialRoute: '/',
            debugShowCheckedModeBanner: false,
            home: const AuthWrapper(),
            routes: {
              '/user-home': (context) => const UserHomeScreen(),
              '/user-login': (context) => const UserLoginScreen(),
              '/user-register': (context) => const UserRegisterScreen(),
              '/doctor-login': (context) => const DoctorLoginScreen(),
              '/doctor-home': (context) => const DoctorHomeScreen(),
              '/specialties': (context) => const SpecialtiesScreen(),
              '/health-tips': (context) => const HealthTipsScreen(),
              '/health-feed': (context) => const HealthFeedScreen(),
              '/canteen-menu': (context) => const CanteenMenuScreen(),
              '/chatbot': (context) => const ChatbotScreen(),
              '/contact-us': (context) => const ContactUsScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      
      print('🔐 AuthWrapper init - isAuthenticated: ${authProvider.isAuthenticated}');
      print('🔐 AuthWrapper init - user: ${authProvider.user?.name}');
      
      if (authProvider.isAuthenticated && authProvider.user != null) {
        // Set token for API calls
        if (authProvider.token != null) {
          notificationProvider.setToken(authProvider.token!);
          notificationProvider.fetchNotifications();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isInitializing) {
      print('⏳ AuthProvider initializing...');
      return Scaffold(
        backgroundColor: const Color(0xFF3498db),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'SEVA PULSE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Checking saved session...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                ApiConstants.baseUrl,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (authProvider.isAuthenticated) {
      print('✅ User is authenticated: ${authProvider.user?.name} (${authProvider.user?.userType})');
      if (authProvider.isDoctor) {
        return const DoctorHomeScreen();
      } else {
        return const UserHomeScreen();
      }
    } else {
      print('❌ No authenticated user, showing splash screen');
      return const SevaPulseSplashScreen();
    }
  }
}
// lib/config/routes/app_routes.dart
class AppRoutes {
  static const String splash = '/';
  static const String userSelection = '/user-selection';
  
  // Auth
  static const String userLogin = '/user-login';
  static const String userRegister = '/user-register';
  static const String doctorLogin = '/doctor-login';
  static const String doctorRegister = '/doctor-register';
  
  // User Features
  static const String userHome = '/user-home';
  static const String specialties = '/specialties';
  static const String doctorList = '/doctor-list';
  static const String bookAppointment = '/book-appointment';
  static const String appointments = '/appointments';
  static const String myMedicine = '/my-medicine';
  static const String prescriptions = '/prescriptions';
  static const String healthFeed = '/health-feed';
  static const String healthTips = '/health-tips';
  static const String canteenMenu = '/canteen-menu';
  static const String chatbot = '/chatbot';
  static const String contactUs = '/contact-us';
  static const String userProfile = '/user-profile';
  
  // Doctor Features
  static const String doctorHome = '/doctor-home';
  static const String patients = '/patients';
  static const String events = '/events';
  static const String doctorProfile = '/doctor-profile';
  
  // Helper method to get route name with parameters
  static String doctorListWithParams(String specialty, String specialtyId, String department) {
    return '$doctorList?specialty=$specialty&specialtyId=$specialtyId&department=$department';
  }
  
  static String bookAppointmentWithParams(Map<String, dynamic> doctor, String specialty) {
    // Encode parameters for URL
    final doctorJson = Uri.encodeComponent(doctor.toString());
    return '$bookAppointment?doctor=$doctorJson&specialty=$specialty';
  }
}
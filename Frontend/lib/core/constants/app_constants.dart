// lib/core/constants/app_constants.dart
class AppConstants {
  // App Info
  static const String appName = 'Seva Pulse';
  static const String appVersion = '1.0.0';
  
  // SharedPreferences Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserType = 'user_type';
  static const String keyRememberMe = 'remember_me';
  static const String keySavedEmail = 'saved_email';
  static const String keySavedPassword = 'saved_password';
  static const String keyThemeMode = 'theme_mode';
  
  // Date Formats
  static const String dateFormatDisplay = 'MMM dd, yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String timeFormatDisplay = 'h:mm a';
  static const String timeFormatApi = 'HH:mm';
  static const String dateTimeFormatApi = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int phoneNumberLength = 10;
  
  // Appointment
  static const int maxDaysInAdvance = 60;
  static const int minNoticeDays = 1;
  static const List<String> appointmentTimeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
    '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
    '04:00 PM', '04:30 PM', '05:00 PM'
  ];
  
  // User Types
  static const String userTypePatient = 'patient';
  static const String userTypeDoctor = 'doctor';
  static const String userTypeAdmin = 'admin';
  
  // Appointment Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusRescheduled = 'rescheduled';
}
// lib/core/constants/api_constants.dart
import '../helpers/network_helper.dart';

class ApiConstants {
  // Use the IP shown in your server output: 192.168.56.1
  static String _baseUrl = 'http://192.168.56.1:5000/api';
  
  static String get baseUrl => _baseUrl;
  
  static Future<void> setBaseUrl(String ip) async {
    _baseUrl = 'http://$ip:5000/api';
    print('📡 API Base URL set to: $_baseUrl');
  }
  
  // Auto-detect server on the network
  static Future<void> autoDetectServer() async {
    print('🔍 Auto-detecting server...');
    
    // Check internet first
    final hasInternet = await NetworkHelper.hasInternetConnection();
    if (!hasInternet) {
      print('⚠️ No internet connection!');
      return;
    }
    
    print('✅ Internet connection available');
    print('📱 Connection type: ${await NetworkHelper.getConnectionType()}');
    
    // Try the IP from your server first
    final serverIps = [
      '192.168.56.1',   // Your server's actual IP
      '192.168.29.63',  // Previous IP
      '192.168.1.100',
      '192.168.0.100',
      'localhost',
      '10.0.2.2',       // Android emulator
    ];
    
    for (final ip in serverIps) {
      print('🔍 Testing IP: $ip');
      if (await NetworkHelper.isServerReachable(ip, 5000)) {
        print('✅ Server found at: $ip');
        await setBaseUrl(ip);
        return;
      }
    }
    
    // If none works, try to auto-detect by scanning subnet
    try {
      final deviceIp = await NetworkHelper.getLocalIpAddress();
      print('📱 Device IP: $deviceIp');
      
      // Extract the subnet (first three octets)
      final lastDotIndex = deviceIp.lastIndexOf('.');
      final subnet = deviceIp.substring(0, lastDotIndex);
      print('🌐 Scanning subnet: $subnet.x');
      
      // Scan common IPs in the subnet
      const commonEndings = [1, 56, 63, 100, 101, 254];
      for (final ending in commonEndings) {
        final ip = '$subnet.$ending';
        print('🔍 Scanning IP: $ip');
        if (await NetworkHelper.isServerReachable(ip, 5000)) {
          print('✅ Server found at: $ip');
          await setBaseUrl(ip);
          return;
        }
      }
    } catch (e) {
      print('⚠️ Auto-detection failed: $e');
    }
    
    // Keep default if nothing works
    print('⚠️ No server found, using default IP: 192.168.56.1');
    await setBaseUrl('192.168.56.1');
  }
  
  // Auth endpoints
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get getProfile => '$baseUrl/auth/me';
  
  // Appointments
  static String get appointments => '$baseUrl/appointments';
  
  // Doctors
  static String get doctors => '$baseUrl/doctors';
  static String get doctorDetails => '$baseUrl/doctors';
  
  // Patients
  static String get patients => '$baseUrl/patients';
  static String get patientDetails => '$baseUrl/patients';
  
  // Prescriptions
  static String get prescriptions => '$baseUrl/prescriptions';
  static String get patientPrescriptions => '$baseUrl/prescriptions/patient';
  
  // Bills
  static String get bills => '$baseUrl/bills';
  
  // Medicines
  static String get medicines => '$baseUrl/medicines';
  
  // Health Feed
  static String get healthCamps => '$baseUrl/health-feed';
  static String get registerCamp => '$baseUrl/health-feed';
  
  // Canteen
  static String get canteenMenu => '$baseUrl/canteen/menu';
}
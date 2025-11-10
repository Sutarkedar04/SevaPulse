import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isInitializing = true; // Add initialization state
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing; // Getter for initialization state
  String? get error => _error;

  final AuthService _authService = AuthService();
  final SharedPreferences? _prefs;

  AuthProvider() : _prefs = null {
    _initialize();
  }

  // For testing or dependency injection
  AuthProvider.withPreferences(this._prefs) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      
      // Check if user data exists in shared preferences
      final userJson = prefs.getString('user_data');
      if (userJson != null) {
        // Parse user data from stored JSON
        // You'll need to implement fromJson in your User model
        // _user = User.fromJson(userJson);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing auth: $e');
      }
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password, String userType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(email, password, userType);
      
      // Save user data to shared preferences
      if (_user != null) {
        // Removed unused variable 'prefs'
        // You'll need to implement toJson in your User model
        // await prefs.setString('user_data', _user!.toJson());
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(User user, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(user, password);
      
      // Save user data to shared preferences
      if (_user != null) {
        // final prefs = _prefs ?? await SharedPreferences.getInstance();
        // await prefs.setString('user_data', _user!.toJson());
        // await prefs.setString('user_data', _user!.toJson());
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _error = null;
    
    // Clear stored user data
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing user data: $e');
      }
    }
    
    _authService.logout();
    notifyListeners();
  }

  // Additional helper methods
  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get isPatient => _user?.userType == 'patient';
  bool get isDoctor => _user?.userType == 'doctor';
  
  // Check if user is authenticated
  bool get isAuthenticated => _user != null;
}
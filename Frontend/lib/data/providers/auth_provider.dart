// lib/data/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  String? get token => _token;

  final AuthService _authService = AuthService();
  final SharedPreferences? _prefs;

  AuthProvider() : _prefs = null {
    _initialize();
  }

  AuthProvider.withPreferences(this._prefs) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      debugPrint('Initialized token from storage: $_token');
      
      // Clear any dummy token that might be stored
      if (_token == 'dummy_token' || (_token != null && !_token!.startsWith('eyJ'))) {
        debugPrint('Invalid token found, clearing it...');
        await prefs.remove('auth_token');
        _token = null;
      }
      
      if (_token != null && _token!.isNotEmpty) {
        await _loadUserProfile();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    if (_token == null || _token!.isEmpty) return;
    
    try {
      _user = await _authService.getProfile(_token!);
      debugPrint('User profile loaded: ${_user?.name}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
      _token = null;
      // Clear invalid token
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }
  }

  // lib/data/providers/auth_provider.dart - make sure user ID is stored
Future<bool> login(String email, String password, String userType) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final response = await _authService.login(email, password, userType);
    _user = response['user'];
    _token = response['token'];
    debugPrint('Login successful, user ID: ${_user?.id}');
    debugPrint('Login successful, user name: ${_user?.name}');
    
    // Store token
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString('auth_token', _token!);
    await prefs.setString('user_id', _user!.id);
    
    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    _error = e.toString().replaceFirst('Exception: ', '');
    debugPrint('Login error: $_error');
    _isLoading = false;
    notifyListeners();
    return false;
  }
}

  // lib/data/providers/auth_provider.dart
// Replace the register method with this:

Future<bool> register(User user, String password) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final userData = {
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'userType': user.userType,
      'specialization': user.specialization,
      'experience': user.experience,
      'dateOfBirth': user.dateOfBirth?.toIso8601String(),
      'address': user.address,
      'gender': user.gender,
    };
    
    // Get the response which should include token
    final result = await _authService.register(userData, password);
    
    // The result should contain user and token
    if (result.containsKey('token') && result.containsKey('user')) {
      _user = result['user'];
      _token = result['token'];
      
      debugPrint('✅ Registration successful, user ID: ${_user?.id}');
      debugPrint('✅ Token received: ${_token?.substring(0, 20)}...');
      
      // Store token in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_id', _user!.id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      throw Exception('No token received from server');
    }
  } catch (e) {
    _error = e.toString().replaceFirst('Exception: ', '');
    debugPrint('❌ Registration error: $_error');
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
  Future<void> logout() async {
    _user = null;
    _error = null;
    _token = null;
    
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      debugPrint('Logged out, token removed');
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
    
    await _authService.logout();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get isPatient => _user?.userType == 'patient';
  bool get isDoctor => _user?.userType == 'doctor';
  bool get isAuthenticated => _user != null && _token != null && _token!.isNotEmpty;
}
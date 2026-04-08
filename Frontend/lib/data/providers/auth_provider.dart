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
      
      debugPrint('🔐 _initialize: Token from storage = ${_token != null ? '${_token!.substring(0, _token!.length > 20 ? 20 : _token!.length)}...' : 'null'}');
      
      // Clear any invalid token that might be stored
      if (_token == 'dummy_token' || (_token != null && !_token!.startsWith('eyJ'))) {
        debugPrint('⚠️ Invalid token found, clearing it...');
        await prefs.remove('auth_token');
        _token = null;
      }
      
      if (_token != null && _token!.isNotEmpty) {
        debugPrint('✅ Valid token found, loading user profile...');
        await _loadUserProfile();
        debugPrint('✅ User profile loaded: ${_user?.name}');
      } else {
        debugPrint('⚠️ No valid token found');
      }
    } catch (e) {
      debugPrint('❌ Error initializing auth: $e');
      _token = null;
      _user = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
      debugPrint('🔐 _initialize complete: isAuthenticated = ${isAuthenticated}');
    }
  }

  Future<void> _loadUserProfile() async {
    if (_token == null || _token!.isEmpty) return;
    
    try {
      _user = await _authService.getProfile(_token!);
      debugPrint('✅ Profile loaded: ${_user?.name} (${_user?.userType})');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
      _token = null;
      _user = null;
      // Clear invalid token
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password, String userType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔐 Login attempt for: $email as $userType');
      final response = await _authService.login(email, password, userType);
      _user = response['user'];
      _token = response['token'];
      
      debugPrint('✅ Login successful, user: ${_user?.name} (${_user?.userType})');
      debugPrint('✅ Token received: ${_token!.substring(0, _token!.length > 20 ? 20 : _token!.length)}...');
      
      // Store token
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_id', _user!.id);
      await prefs.setString('user_type', _user!.userType);
      
      // Verify it was saved
      final savedToken = prefs.getString('auth_token');
      debugPrint('✅ Token saved verification: ${savedToken != null}');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Login error: $_error');
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
      
      debugPrint('📝 Registration attempt for: ${user.email} as ${user.userType}');
      final result = await _authService.register(userData, password);
      
      if (result.containsKey('token') && result.containsKey('user')) {
        _user = result['user'];
        _token = result['token'];
        
        debugPrint('✅ Registration successful, user: ${_user?.name}');
        debugPrint('✅ Token received: ${_token!.substring(0, _token!.length > 20 ? 20 : _token!.length)}...');
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_id', _user!.id);
        await prefs.setString('user_type', _user!.userType);
        
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
    debugPrint('🔐 Logging out...');
    _user = null;
    _error = null;
    _token = null;
    
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_type');
      debugPrint('✅ Logged out, token removed');
    } catch (e) {
      debugPrint('❌ Error clearing user data: $e');
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
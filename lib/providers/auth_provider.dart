import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _userType;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get userType => _userType;
  bool get isAuthenticated => _isAuthenticated;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setUserType(String type) {
    _userType = type;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      setAuthenticated(true);
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signup(Map<String, String> userData) async {
    setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      setAuthenticated(true);
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  void logout() {
    _isAuthenticated = false;
    _userType = null;
    notifyListeners();
  }
}

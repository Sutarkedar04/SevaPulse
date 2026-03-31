// lib/core/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../data/models/user_model.dart';

class AuthService {
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final data = json.decode(response.body);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Something went wrong');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password, String userType) async {
    try {
      print('Attempting login to: ${ApiConstants.login}');
      print('With email: $email, userType: $userType');
      
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'userType': userType,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = await _handleResponse(response);
      
      if (data['success'] && data['user'] != null && data['token'] != null) {
        return {
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<User> register(Map<String, dynamic> userData, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          ...userData,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = await _handleResponse(response);
      
      if (data['success'] && data['user'] != null) {
        return User.fromJson(data['user']);
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<User> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = await _handleResponse(response);
      
      if (data['success'] && data['data'] != null && data['data']['user'] != null) {
        return User.fromJson(data['data']['user']);
      } else {
        throw Exception(data['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      print('GetProfile error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
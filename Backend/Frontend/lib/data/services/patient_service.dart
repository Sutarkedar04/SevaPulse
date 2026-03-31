// lib/core/services/patient_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class PatientService {
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final data = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Something went wrong');
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<Map<String, dynamic>> getPatientProfile() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.patients),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      final data = await _handleResponse(response);
      
      if (data['success'] && data['data'] != null && data['data'].isNotEmpty) {
        // Return the first patient profile (should be the logged-in user's)
        return data['data'][0];
      }
      return {};
    } catch (e) {
      print('Error getting patient profile: $e');
      return {};
    }
  }
}
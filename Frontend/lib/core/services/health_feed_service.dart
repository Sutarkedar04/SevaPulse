import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class HealthFeedService {
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

  Future<List<Map<String, dynamic>>> getHealthCamps() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.healthCamps),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      final data = await _handleResponse(response);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> registerForCamp(String campId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.registerCamp}/$campId/register'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      final data = await _handleResponse(response);
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
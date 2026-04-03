// lib/core/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiClient {
  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  void clearAuthToken() {
    _authToken = null;
  }
  
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  Future<Map<String, dynamic>> get(String url) async {
    try {
      print('📡 GET: $url');
      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(ApiConstants.connectionTimeout);
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ GET Error: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> post(String url, {dynamic body}) async {
    try {
      print('📡 POST: $url');
      print('📦 Body: $body');
      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ POST Error: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> put(String url, {dynamic body}) async {
    try {
      print('📡 PUT: $url');
      final response = await http
          .put(
            Uri.parse(url),
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ PUT Error: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> delete(String url) async {
    try {
      print('📡 DELETE: $url');
      final response = await http
          .delete(Uri.parse(url), headers: _headers)
          .timeout(ApiConstants.connectionTimeout);
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ DELETE Error: $e');
      rethrow;
    }
  }
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(response.body);
    print('📡 Response Status: ${response.statusCode}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final message = data['message'] ?? 'Something went wrong';
      throw Exception(message);
    }
  }
}
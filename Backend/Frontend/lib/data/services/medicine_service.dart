// lib/core/services/medicine_service.dart
import 'dart:convert';
// Add this import for debugPrint
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class MedicineService {
  String? _token;

  void setToken(String token) {
    debugPrint('MedicineService token set: $token');
    _token = token;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final data = json.decode(response.body);
    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Something went wrong');
    }
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
      debugPrint('Adding Authorization header');
    } else {
      debugPrint('No token available!');
    }
    
    return headers;
  }

  Future<List<Map<String, dynamic>>> getMedicines() async {
    try {
      debugPrint('Fetching medicines from: ${ApiConstants.medicines}');
      final response = await http.get(
        Uri.parse(ApiConstants.medicines),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      final data = await _handleResponse(response);
      
      if (data['success'] && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      debugPrint('Error in getMedicines: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createMedicine(Map<String, dynamic> medicineData) async {
    try {
      debugPrint('Creating medicine at: ${ApiConstants.medicines}');
      debugPrint('Request body: ${json.encode(medicineData)}');
      
      final response = await http.post(
        Uri.parse(ApiConstants.medicines),
        headers: _getHeaders(),
        body: json.encode(medicineData),
      ).timeout(const Duration(seconds: 30));

      final data = await _handleResponse(response);
      return data['data'];
    } catch (e) {
      debugPrint('Error in createMedicine: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateMedicine(String id, Map<String, dynamic> medicineData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.medicines}/$id'),
        headers: _getHeaders(),
        body: json.encode(medicineData),
      ).timeout(const Duration(seconds: 30));

      final data = await _handleResponse(response);
      return data['data'];
    } catch (e) {
      debugPrint('Error in updateMedicine: $e');
      rethrow;
    }
  }

  Future<void> deleteMedicine(String id) async {
    try {
      debugPrint('Deleting medicine at: ${ApiConstants.medicines}/$id');
      final response = await http.delete(
        Uri.parse('${ApiConstants.medicines}/$id'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      await _handleResponse(response);
      debugPrint('Medicine deleted successfully from server');
    } catch (e) {
      debugPrint('Error in deleteMedicine: $e');
      rethrow;
    }
  }

  Future<void> toggleDose(String id, int doseIndex) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.medicines}/$id/toggle/$doseIndex'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      await _handleResponse(response);
    } catch (e) {
      debugPrint('Error in toggleDose: $e');
      rethrow;
    }
  }
}
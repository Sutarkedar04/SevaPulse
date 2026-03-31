// lib/data/providers/appointment_provider.dart
import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final AppointmentService _appointmentService = AppointmentService();

  void setToken(String token) {
    _appointmentService.setToken(token);
  }

  // lib/data/providers/appointment_provider.dart
Future<void> loadAppointments() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    print('🔵 AppointmentProvider: Loading appointments...');
    _appointments = await _appointmentService.getAppointments();
    print('🟢 AppointmentProvider: Loaded ${_appointments.length} appointments');
    print('🟢 AppointmentProvider: Appointments: ${_appointments.map((a) => a.id).toList()}');
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString().replaceFirst('Exception: ', '');
    print('🔴 AppointmentProvider: Error loading appointments: $_error');
    _isLoading = false;
    notifyListeners();
  }
}
  Future<bool> bookAppointmentWithData(Map<String, dynamic> appointmentData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Booking appointment with data: $appointmentData');
      final newAppointment = await _appointmentService.bookAppointment(appointmentData);
      print('Appointment booked successfully: ${newAppointment.id}');
      _appointments.add(newAppointment);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      print('Error booking appointment: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAppointmentStatus(String id, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedAppointment = await _appointmentService.updateAppointmentStatusAPI(id, status);
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _appointments[index] = updatedAppointment;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelAppointment(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _appointmentService.cancelAppointment(id);
      _appointments.removeWhere((a) => a.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
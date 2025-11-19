import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadAppointments() async {
    setLoading(true);
    
    // Mock data for simulation
    await Future.delayed(const Duration(seconds: 2));
    
    _appointments = [
      Appointment(
        id: '1',
        patientId: '1',
        doctorId: '1',
        patientName: 'John Patient',
        doctorName: 'Dr. Sarah Johnson',
        date: DateTime.now().add(const Duration(days: 1)),
        time: '10:00 AM',
        status: 'confirmed',
        type: 'Consultation',
        symptoms: 'Chest pain and shortness of breath',
      ),
      Appointment(
        id: '2',
        patientId: '1',
        doctorId: '2',
        patientName: 'John Patient',
        doctorName: 'Dr. Michael Chen',
        date: DateTime.now().add(const Duration(days: 3)),
        time: '2:30 PM',
        status: 'upcoming',
        type: 'Follow-up',
        symptoms: 'Headache and dizziness',
      ),
    ];
    
    setLoading(false);
  }

  Future<bool> bookAppointment(Appointment appointment) async {
    setLoading(true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    _appointments.add(appointment);
    setLoading(false);
    notifyListeners();
    
    return true;
  }
}
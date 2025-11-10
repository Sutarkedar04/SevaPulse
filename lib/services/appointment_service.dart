// lib/services/appointment_service.dart
class AppointmentService {
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  final List<Map<String, dynamic>> _appointments = [
    {
      'id': 1,
      'patientName': 'Namesh Patil',
      'time': '10:00 AM',
      'date': '2025-09-23',
      'type': 'Follow-up',
      'status': 'confirmed',
      'patientId': 'P001',
      'patientEmail': 'namesh@example.com',
      'symptoms': 'Chest pain, shortness of breath',
      'priority': 'high',
      'doctorId': 'doctor1',
      'doctorName': 'Dr. Isha Tapekar',
      'specialty': 'Cardiology',
    },
    {
      'id': 2,
      'patientName': 'Ramesh Mane',
      'time': '2:30 PM',
      'date': '2025-09-23',
      'type': 'New Patient',
      'status': 'confirmed',
      'patientId': 'P002',
      'patientEmail': 'ramesh@example.com',
      'symptoms': 'Headache, dizziness',
      'priority': 'medium',
      'doctorId': 'doctor1',
      'doctorName': 'Dr. Isha Tapekar',
      'specialty': 'Cardiology',
    },
  ];

  List<Map<String, dynamic>> getAppointmentsForDoctor(String doctorId) {
    // Filter appointments for today and for this specific doctor
    final today = DateTime.now();
    final todayFormatted = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    return _appointments.where((appointment) {
      return appointment['date'] == todayFormatted && 
             appointment['doctorId'] == doctorId;
    }).toList();
  }

  List<Map<String, dynamic>> getAllPatientsForDoctor(String doctorId) {
    // Get all unique patients who have appointments with this doctor
    final patientIds = <String>{};
    final patients = <Map<String, dynamic>>[];
    
    for (final appointment in _appointments) {
      if (appointment['doctorId'] == doctorId && 
          !patientIds.contains(appointment['patientId'])) {
        patientIds.add(appointment['patientId']);
        patients.add({
          'id': appointment['patientId'],
          'name': appointment['patientName'],
          'email': appointment['patientEmail'],
          'lastVisit': appointment['date'],
          'condition': appointment['symptoms'],
          'emergencyContact': true,
        });
      }
    }
    
    return patients;
  }

  void addAppointment(Map<String, dynamic> appointment) {
    // Generate unique ID
    final newId = _appointments.isNotEmpty 
        ? _appointments.map((a) => a['id'] as int).reduce((a, b) => a > b ? a : b) + 1
        : 1;
    
    _appointments.add({
      ...appointment,
      'id': newId,
      'status': 'pending', // Default status for new appointments
    });
    
    print('New appointment booked: ${appointment['patientName']} with Dr. ${appointment['doctorName']}');
  }

  void updateAppointmentStatus(int appointmentId, String status) {
    final index = _appointments.indexWhere((a) => a['id'] == appointmentId);
    if (index != -1) {
      _appointments[index]['status'] = status;
    }
  }

  List<Map<String, dynamic>> getAppointmentsForPatient(String patientId) {
    return _appointments.where((a) => a['patientId'] == patientId).toList();
  }

  List<Map<String, dynamic>> getAllAppointments() {
    return List.from(_appointments);
  }
}
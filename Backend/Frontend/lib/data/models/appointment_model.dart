// lib/data/models/appointment_model.dart
class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final DateTime date;
  final String time;
  final String status;
  final String type;
  final String symptoms;
  final String? prescription;
  final String? notes;
  final String? patientEmail;
  final String? specialty;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.status,
    required this.type,
    required this.symptoms,
    this.prescription,
    this.notes,
    this.patientEmail,
    this.specialty,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing appointment: ${json['id']}');
    
    return Appointment(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      doctorId: json['doctorId']?.toString() ?? '',
      patientName: json['patientName'] ?? 'Unknown',
      doctorName: json['doctorName'] ?? 'Unknown',
      date: json['date'] is DateTime 
          ? json['date'] 
          : DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      time: json['time'] ?? '',
      status: json['status'] ?? 'pending',
      type: json['type'] ?? 'Consultation',
      symptoms: json['symptoms'] ?? '',
      prescription: json['prescription'],
      notes: json['notes'],
      patientEmail: json['patientEmail'],
      specialty: json['specialty'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'date': date.toIso8601String(),
      'time': time,
      'type': type,
      'symptoms': symptoms,
      'patientId': patientId,
      'patientName': patientName,
      'doctorName': doctorName,
      'status': status,
      'patientEmail': patientEmail,
      'specialty': specialty,
    };
  }
}
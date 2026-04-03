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

  // lib/data/models/appointment_model.dart
// Update the fromJson method to handle dates correctly

factory Appointment.fromJson(Map<String, dynamic> json) {
  print('🔍 Parsing appointment: ${json['id']}');
  
  DateTime parseDate(dynamic dateValue) {
    if (dateValue is DateTime) return dateValue;
    
    String dateString = dateValue.toString();
    // Parse the date and convert to local timezone
    DateTime utcDate = DateTime.parse(dateString);
    // Convert to local timezone
    return utcDate.toLocal();
  }
  
  return Appointment(
    id: json['id']?.toString() ?? '',
    patientId: json['patientId']?.toString() ?? '',
    doctorId: json['doctorId']?.toString() ?? '',
    patientName: json['patientName'] ?? 'Unknown',
    doctorName: json['doctorName'] ?? 'Unknown',
    date: parseDate(json['date']),
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
}
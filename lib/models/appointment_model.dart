class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final DateTime date;
  final String time;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String type;
  final String symptoms;
  final String? prescription;
  final String? notes;

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
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      patientName: json['patientName'] ?? '',
      doctorName: json['doctorName'] ?? '',
      date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
      status: json['status'] ?? 'pending',
      type: json['type'] ?? 'consultation',
      symptoms: json['symptoms'] ?? '',
      prescription: json['prescription'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'patientName': patientName,
      'doctorName': doctorName,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
      'type': type,
      'symptoms': symptoms,
      'prescription': prescription,
      'notes': notes,
    };
  }

  Appointment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? patientName,
    String? doctorName,
    DateTime? date,
    String? time,
    String? status,
    String? type,
    String? symptoms,
    String? prescription,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      type: type ?? this.type,
      symptoms: symptoms ?? this.symptoms,
      prescription: prescription ?? this.prescription,
      notes: notes ?? this.notes,
    );
  }
}
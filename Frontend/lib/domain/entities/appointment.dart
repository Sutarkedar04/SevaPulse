// lib/domain/entities/appointment.dart
class AppointmentEntity {
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

  const AppointmentEntity({
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

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  bool get isUpcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(date.year, date.month, date.day);
    return appointmentDate.isAtSameMomentAs(today) || appointmentDate.isAfter(today);
  }
  
  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(date.year, date.month, date.day);
    return appointmentDate.isBefore(today);
  }

  AppointmentEntity copyWith({
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
    String? patientEmail,
    String? specialty,
  }) {
    return AppointmentEntity(
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
      patientEmail: patientEmail ?? this.patientEmail,
      specialty: specialty ?? this.specialty,
    );
  }
}
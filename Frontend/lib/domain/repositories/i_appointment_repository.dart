// lib/domain/repositories/i_appointment_repository.dart
import '../entities/appointment.dart';

abstract class IAppointmentRepository {
  Future<List<AppointmentEntity>> getAppointments();
  
  Future<AppointmentEntity> bookAppointment(Map<String, dynamic> data);
  
  Future<AppointmentEntity> updateAppointmentStatus(String id, String status);
  
  Future<void> cancelAppointment(String id);
  
  List<AppointmentEntity> getAppointmentsForDoctor(String doctorId);
  
  List<AppointmentEntity> getAppointmentsForPatient(String patientId);
  
  List<AppointmentEntity> getUpcomingAppointmentsForPatient(String patientId);
}
// lib/domain/usecases/appointment/get_appointments_usecase.dart
import '../../entities/appointment.dart';
import '../../repositories/i_appointment_repository.dart';

class GetAppointmentsUseCase {
  final IAppointmentRepository repository;
  
  GetAppointmentsUseCase(this.repository);
  
  Future<List<AppointmentEntity>> execute() async {
    return await repository.getAppointments();
  }
}
// lib/shared/widgets/appointment_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/appointment_model.dart';

class AppointmentItem extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;

  const AppointmentItem({
    Key? key,
    required this.appointment,
    this.onTap,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final appointmentDate = DateTime(
      date.year,
      date.month,
      date.day,
    );
    
    if (appointmentDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (appointmentDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF27ae60);
      case 'pending':
        return const Color(0xFFf39c12);
      case 'completed':
        return const Color(0xFF3498db);
      case 'cancelled':
        return const Color(0xFFe74c3c);
      default:
        return const Color(0xFF7f8c8d);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFecf0f1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(appointment.status),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${appointment.doctorName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment.specialty ?? 'General',
                    style: const TextStyle(
                      color: Color(0xFF7f8c8d),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: const Color(0xFF7f8c8d).withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(appointment.date),
                        style: const TextStyle(
                          color: Color(0xFF7f8c8d),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: const Color(0xFF7f8c8d).withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment.time,
                        style: const TextStyle(
                          color: Color(0xFF7f8c8d),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(appointment.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          appointment.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getStatusColor(appointment.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
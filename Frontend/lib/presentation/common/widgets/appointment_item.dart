import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/providers/appointment_provider.dart';

class AppointmentItem extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final bool showCancelButton;

  const AppointmentItem({
    Key? key,
    required this.appointment,
    this.onTap,
    this.showCancelButton = true,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    // Convert UTC to local time
    final localDate = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final appointmentDate = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );
    
    if (appointmentDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (appointmentDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      return DateFormat('dd MMM yyyy').format(localDate);
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

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  // lib/shared/widgets/appointment_item.dart
// Replace the _cancelAppointment method with this:

Future<void> _cancelAppointment(BuildContext context) async {
  // Show confirmation dialog
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancel Appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you sure you want to cancel your appointment with:'),
          const SizedBox(height: 8),
          Text(
            'Dr. ${appointment.doctorName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Date: ${DateFormat('EEEE, MMMM d, yyyy').format(appointment.date.toLocal())}'),
          Text('Time: ${appointment.time}'),
          const SizedBox(height: 8),
          const Text(
            'This action cannot be undone.',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No, Keep It'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Yes, Cancel'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  // Check if context is still mounted before showing SnackBar
  if (!context.mounted) return;

  // Show loading indicator
  final snackBar = SnackBar(
    content: Row(
      children: [
        const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text('Cancelling appointment with Dr. ${appointment.doctorName}...'),
      ],
    ),
    backgroundColor: Colors.orange,
    duration: const Duration(seconds: 5),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);

  try {
    final appointmentProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );
    
    print('🔄 Attempting to cancel appointment with ID: ${appointment.id}');
    final success = await appointmentProvider.cancelAppointment(appointment.id);
    
    // Check if context is still mounted before showing result
    if (!context.mounted) return;
    
    // Clear the loading snackbar
    ScaffoldMessenger.of(context).clearSnackBars();
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment with Dr. ${appointment.doctorName} cancelled successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appointmentProvider.error ?? 'Failed to cancel appointment'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final localDate = appointment.date.toLocal();
    final isPast = localDate.isBefore(DateTime.now());
    final statusColor = _getStatusColor(appointment.status);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isPast ? const Color(0xFFecf0f1) : statusColor.withOpacity(0.3),
            width: isPast ? 1 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left colored indicator
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            
            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor name and specialty
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dr. ${appointment.doctorName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2c3e50),
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(appointment.status),
                          style: TextStyle(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.specialty ?? 'General',
                    style: const TextStyle(
                      color: Color(0xFF7f8c8d),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Date and time row
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
                    ],
                  ),
                  
                  // Symptoms (if any)
                  if (appointment.symptoms.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.medical_information,
                          size: 12,
                          color: const Color(0xFF7f8c8d).withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            appointment.symptoms,
                            style: const TextStyle(
                              color: Color(0xFF7f8c8d),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Cancel button (only for pending appointments)
            if (showCancelButton && appointment.status == 'pending' && !isPast)
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 22),
                onPressed: () => _cancelAppointment(context),
                tooltip: 'Cancel Appointment',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            
            // Chevron for details
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: const Color(0xFFbdc3c7),
              ),
          ],
        ),
      ),
    );
  }
}
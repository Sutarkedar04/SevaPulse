import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/providers/appointment_provider.dart';
import 'appointment_item.dart';

class UpcomingVisitsCard extends StatelessWidget {
  final List<Appointment> upcomingAppointments;
  final VoidCallback? onBookAppointment;

  const UpcomingVisitsCard({
    Key? key,
    required this.upcomingAppointments,
    this.onBookAppointment,
  }) : super(key: key);

  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor: Dr. ${appointment.doctorName}'),
            Text('Specialty: ${appointment.specialty ?? 'General'}'),
            Text('Date: ${DateFormat('EEEE, MMMM d, yyyy').format(appointment.date.toLocal())}'),
            Text('Time: ${appointment.time}'),
            Text('Status: ${appointment.status.toUpperCase()}'),
            Text('Type: ${appointment.type}'),
            if (appointment.symptoms.isNotEmpty)
              Text('Symptoms: ${appointment.symptoms}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (appointment.status == 'pending')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelAppointment(context, appointment);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Future<void> _cancelAppointment(BuildContext context, Appointment appointment) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Text(
          'Are you sure you want to cancel your appointment with Dr. ${appointment.doctorName} on ${DateFormat('MMM dd, yyyy').format(appointment.date)} at ${appointment.time}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Check if context is still mounted before showing SnackBar
    if (!context.mounted) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Cancelling appointment...'),
          ],
        ),
        backgroundColor: Colors.orange,
      ),
    );

    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(
        context,
        listen: false,
      );
      
      final success = await appointmentProvider.cancelAppointment(appointment.id);
      
      // Check if context is still mounted before showing result
      if (!context.mounted) return;
      
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
    // Get current date in local timezone
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Convert appointment dates to local and compare dates
    final upcoming = upcomingAppointments.where((apt) {
      // Convert UTC to local and get date only
      final localDate = apt.date.toLocal();
      final aptDate = DateTime(localDate.year, localDate.month, localDate.day);
      return aptDate.isAtSameMomentAs(today) || aptDate.isAfter(today);
    }).toList();
    
    final past = upcomingAppointments.where((apt) {
      final localDate = apt.date.toLocal();
      final aptDate = DateTime(localDate.year, localDate.month, localDate.day);
      return aptDate.isBefore(today);
    }).toList();

    // Sort upcoming appointments by date
    final sortedUpcoming = [...upcoming]..sort((a, b) => a.date.compareTo(b.date));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.upcoming, color: Color(0xFF3498db)),
                SizedBox(width: 8),
                Text(
                  'My Appointments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Upcoming Appointments Section
            if (sortedUpcoming.isNotEmpty) ...[
              const Text(
                'Upcoming',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF27ae60),
                ),
              ),
              const SizedBox(height: 8),
              ...sortedUpcoming.map((appointment) => 
                AppointmentItem(
                  appointment: appointment,
                  onTap: () => _showAppointmentDetails(context, appointment),
                )
              ),
              const SizedBox(height: 16),
            ],
            
            // Past Appointments Section
            if (past.isNotEmpty) ...[
              const Text(
                'Past Appointments',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7f8c8d),
                ),
              ),
              const SizedBox(height: 8),
              ...past.map((appointment) => 
                AppointmentItem(
                  appointment: appointment,
                  onTap: () => _showAppointmentDetails(context, appointment),
                  showCancelButton: false, // Don't show cancel for past appointments
                )
              ),
            ],
            
            // Empty State
            if (upcomingAppointments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48,
                        color: Color(0xFFbdc3c7),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No appointments found',
                        style: TextStyle(
                          color: Color(0xFF7f8c8d),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Book an appointment to see it here',
                        style: TextStyle(
                          color: Color(0xFF95a5a6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            if (upcomingAppointments.isEmpty && onBookAppointment != null)
              const SizedBox(height: 16),
            if (upcomingAppointments.isEmpty && onBookAppointment != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onBookAppointment,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF3498db)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(color: Color(0xFF3498db)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
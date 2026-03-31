// lib/shared/widgets/upcoming_visits_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/appointment_model.dart';
import 'appointment_item.dart';

class UpcomingVisitsCard extends StatelessWidget {
  final List<Appointment> upcomingAppointments;
  final VoidCallback? onBookAppointment;

  const UpcomingVisitsCard({
    Key? key,
    required this.upcomingAppointments,
    this.onBookAppointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  'Upcoming Visits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                        'No upcoming appointments',
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
              )
            else
              ...upcomingAppointments.map((appointment) => 
                AppointmentItem(
                  appointment: appointment,
                  onTap: () => _showAppointmentDetails(context, appointment),
                )
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

  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Appointment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor: Dr. ${appointment.doctorName}'),
            Text('Specialty: ${appointment.specialty ?? 'General'}'),
            Text('Date: ${DateFormat('EEEE, MMMM d, yyyy').format(appointment.date)}'),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cancelling appointment...'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
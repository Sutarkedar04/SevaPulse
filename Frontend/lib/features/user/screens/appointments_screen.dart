// lib/features/user/screens/appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/appointment_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../presentation/common/widgets/appointment_item.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
// upcoming, past, all

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      appointmentProvider.setToken(authProvider.token!);
      await appointmentProvider.loadAppointments();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          final authProvider = Provider.of<AuthProvider>(context);
          final userId = authProvider.user?.id ?? '';
          
          // Filter out cancelled appointments
          final activeAppointments = appointmentProvider.appointments
              .where((a) => a.patientId == userId && a.status.toLowerCase() != 'cancelled')
              .toList();
          
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          final upcoming = activeAppointments
              .where((a) {
                final localDate = a.date.toLocal();
                final aptDate = DateTime(localDate.year, localDate.month, localDate.day);
                return aptDate.isAtSameMomentAs(today) || aptDate.isAfter(today);
              })
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
          
          final past = activeAppointments
              .where((a) {
                final localDate = a.date.toLocal();
                final aptDate = DateTime(localDate.year, localDate.month, localDate.day);
                return aptDate.isBefore(today);
              })
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          
          if (appointmentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (appointmentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(appointmentProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAppointments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Upcoming Tab
              _buildAppointmentList(upcoming, showCancelButton: true),
              
              // Past Tab
              _buildAppointmentList(past, showCancelButton: false),
              
              // All Tab (upcoming + past)
              _buildAppointmentList([...upcoming, ...past], showCancelButton: true),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildAppointmentList(List list, {required bool showCancelButton}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: const Color(0xFFbdc3c7),
            ),
            const SizedBox(height: 16),
            const Text(
              'No appointments found',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF7f8c8d),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Book an appointment to see it here',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF95a5a6),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/specialties');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498db),
              ),
              child: const Text('Book Appointment'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final appointment = list[index];
        return AppointmentItem(
          appointment: appointment,
          showCancelButton: showCancelButton && appointment.status == 'pending',
          onTap: () => _showAppointmentDetails(appointment),
        );
      },
    );
  }
  
  void _showAppointmentDetails(appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Dr. ${appointment.doctorName}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              appointment.specialty ?? 'General',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF3498db),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Date', DateFormat('EEEE, MMMM d, yyyy').format(appointment.date.toLocal())),
            _buildDetailRow('Time', appointment.time),
            _buildDetailRow('Status', appointment.status.toUpperCase()),
            _buildDetailRow('Type', appointment.type),
            if (appointment.symptoms.isNotEmpty)
              _buildDetailRow('Symptoms', appointment.symptoms),
            if (appointment.prescription != null)
              _buildDetailRow('Prescription', appointment.prescription!),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498db),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF7f8c8d)),
            ),
          ),
        ],
      ),
    );
  }
}
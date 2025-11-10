import 'package:flutter/material.dart';
import 'patients_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';
import '../auth/user_selection_screen.dart';
import '../../services/appointment_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isInitialized = false;
  final AppointmentService _appointmentService = AppointmentService();
  late List<Map<String, dynamic>> _todayAppointments;
  late List<Map<String, dynamic>> _patients;

  final List<Map<String, dynamic>> medicalEvents = [
    {
      'title': 'Free Diabetes Screening Camp',
      'date': '2025-10-15',
      'time': '9:00 AM - 4:00 PM',
      'location': 'Hospital Campus',
      'registeredPatients': 45,
    },
    {
      'title': 'Heart Health Awareness Workshop',
      'date': '2025-10-20',
      'time': '2:00 PM - 5:00 PM',
      'location': 'Conference Hall',
      'registeredPatients': 23,
    },
  ];

  Map<String, dynamic> doctorProfile = {
    'name': 'Dr. Isha Tapekar',
    'specialization': 'Cardiologist',
    'experience': '12 years',
    'qualification': 'MD, DM Cardiology',
    'hospital': 'City Heart Center',
    'rating': 4.8,
    'patientsCount': 1250,
    'contact': '+1 555-0123',
    'email': 'dr.sarah@cityheart.com',
    'bio': 'Specialized in interventional cardiology with extensive experience in angioplasty and heart disease management.',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isInitialized) {
      // Reset state when app comes back to foreground
      _resetToDashboard();
    }
  }

  void _initializeScreen() {
    // Always start with dashboard
    _currentIndex = 0;
    _refreshAppointments();
    _refreshPatients();
    _isInitialized = true;
    
    // Force rebuild to ensure UI is consistent
    if (mounted) {
      setState(() {});
    }
  }

  void _refreshAppointments() {
    // Get today's appointments from the service
    _todayAppointments = _appointmentService.getAppointmentsForDoctor('doctor1');
    if (mounted) {
      setState(() {});
    }
  }

  void _refreshPatients() {
    // Get all patients for this doctor
    _patients = _appointmentService.getAllPatientsForDoctor('doctor1');
    if (mounted) {
      setState(() {});
    }
  }

  void _resetToDashboard() {
    if (mounted) {
      setState(() {
        _currentIndex = 0;
        _refreshAppointments();
        _refreshPatients();
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    // Clear navigation stack completely and redirect to UserSelectionScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const UserSelectionScreen()),
      (route) => false,
    );
  }

  void _showPrescriptionDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Write Prescription for ${patient['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Diagnosis',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Medicines',
                  border: OutlineInputBorder(),
                  hintText: 'Enter medicines with dosage and timing...',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tests Recommended',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Follow-up Date',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () {
                  // Show date picker
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Prescription sent to ${patient['name']}'),
                  backgroundColor: const Color(0xFF27ae60),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
            ),
            child: const Text('Send Prescription'),
          ),
        ],
      ),
    );
  }

  void _showEventCreationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Medical Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () {
                  // Show date picker
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () {
                  // Show time picker
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event created and notifications sent to patients'),
                  backgroundColor: Color(0xFF27ae60),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27ae60),
            ),
            child: const Text('Create Event'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    Color priorityColor = const Color(0xFF27ae60);
    if (appointment['priority'] == 'high') priorityColor = const Color(0xFFe74c3c);
    if (appointment['priority'] == 'medium') priorityColor = const Color(0xFFf39c12);

    Color statusColor = const Color(0xFFf39c12); // pending - orange
    if (appointment['status'] == 'confirmed') statusColor = const Color(0xFF27ae60); // confirmed - green
    if (appointment['status'] == 'cancelled') statusColor = const Color(0xFFe74c3c); // cancelled - red

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['patientName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${appointment['patientId']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Email: ${appointment['patientEmail'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appointment['priority'].toString().toUpperCase(),
                        style: TextStyle(
                          color: priorityColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        appointment['status'].toString().toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${appointment['time']} • ${appointment['date']} • ${appointment['type']}',
              style: const TextStyle(color: Color(0xFF7f8c8d)),
            ),
            const SizedBox(height: 8),
            Text(
              'Symptoms: ${appointment['symptoms']}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF2c3e50)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (appointment['status'] == 'pending') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _appointmentService.updateAppointmentStatus(appointment['id'], 'confirmed');
                        _refreshAppointments();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Appointment with ${appointment['patientName']} confirmed'),
                            backgroundColor: const Color(0xFF27ae60),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _appointmentService.updateAppointmentStatus(appointment['id'], 'cancelled');
                        _refreshAppointments();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Appointment with ${appointment['patientName']} cancelled'),
                            backgroundColor: const Color(0xFFe74c3c),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFe74c3c),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ] else if (appointment['status'] == 'confirmed') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showRescheduleDialog(appointment);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reschedule'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _startConsultation(appointment);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498db),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Start Consult'),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final patient = _patients.firstWhere(
                      (p) => p['id'] == appointment['patientId'],
                      orElse: () => {
                        'id': appointment['patientId'],
                        'name': appointment['patientName'],
                        'email': appointment['patientEmail'],
                        'age': 'Unknown',
                        'gender': 'Unknown',
                      },
                    );
                    _showPrescriptionDialog(patient);
                  },
                  icon: const Icon(Icons.medical_services, color: Color(0xFF27ae60)),
                  tooltip: 'Write Prescription',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRescheduleDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reschedule ${appointment['patientName']}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reschedule functionality would go here...'),
            SizedBox(height: 16),
            Text('Date picker, time selection, etc.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Appointment with ${appointment['patientName']} rescheduled'),
                  backgroundColor: const Color(0xFF27ae60),
                ),
              );
            },
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
  }

  void _startConsultation(Map<String, dynamic> appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting consultation with ${appointment['patientName']}'),
        backgroundColor: const Color(0xFF27ae60),
        duration: const Duration(seconds: 2),
      ),
    );
    // Navigate to consultation screen or start video call
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image below navbar and above welcome text
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/images/userfirstimg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Welcome Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF3498db).withValues(alpha: 0.1),
                    child: const Icon(Icons.medical_services, color: Color(0xFF3498db), size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${doctorProfile['name']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        Text(
                          doctorProfile['specialization'],
                          style: const TextStyle(color: Color(0xFF7f8c8d)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_todayAppointments.length} appointments today',
                          style: const TextStyle(
                            color: Color(0xFF3498db),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Today's Appointments Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Appointments",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF3498db)),
                onPressed: _refreshAppointments,
                tooltip: 'Refresh Appointments',
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_todayAppointments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.event_available, size: 64, color: Color(0xFFbdc3c7)),
                    SizedBox(height: 16),
                    Text(
                      'No appointments for today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7f8c8d),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Appointments booked by patients will appear here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF95a5a6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._todayAppointments.map((appointment) => _buildAppointmentCard(appointment)),
        ],
      ),
    );
  }

  Widget _getCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return PatientsScreen(
          patients: _patients,
          onPrescriptionPressed: _showPrescriptionDialog,
        );
      case 2:
        return EventsScreen(
          medicalEvents: medicalEvents,
          onCreateEventPressed: _showEventCreationDialog,
        );
      case 3:
        return ProfileScreen(
          doctorProfile: doctorProfile,
          onLogoutPressed: _showLogoutDialog,
        );
      default:
        return _buildDashboardTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: AppBar(
        title: const Text(
          'SEVA PULSE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        actions: _currentIndex == 0 ? [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  backgroundColor: Color(0xFF27ae60),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('My Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              } else if (value == 'profile') {
                setState(() {
                  _currentIndex = 3;
                });
              }
            },
          ),
        ] : null,
      ),
      body: _getCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3498db),
        unselectedItemColor: const Color(0xFF7f8c8d),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          // Quick action - Create prescription or start consultation
        },
        backgroundColor: const Color(0xFF3498db),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}
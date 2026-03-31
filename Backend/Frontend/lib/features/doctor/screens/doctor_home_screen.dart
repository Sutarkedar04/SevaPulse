// lib/features/doctor/screens/doctor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seva_pulse/features/auth/SevaPulseSplashScreen.dart';
import 'patients_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';
import '../../../data/services/appointment_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

class DoctorHomeScreen extends StatefulWidget {
  final User? doctorData;
  
  const DoctorHomeScreen({Key? key, this.doctorData}) : super(key: key);

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isInitialized = false;
  final AppointmentService _appointmentService = AppointmentService();
  List<Map<String, dynamic>> _todayAppointments = [];
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;

  Map<String, dynamic> doctorProfile = {};

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

  // Helper to normalize IDs
  String _normalizeId(String? id) {
    if (id == null) return '';
    String normalized = id.trim();
    if (normalized.startsWith('ObjectId(')) {
      normalized = normalized.replaceAll('ObjectId(', '').replaceAll(')', '');
    }
    normalized = normalized.replaceAll('"', '').replaceAll("'", '');
    return normalized;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _loadDoctorProfile();
    _initializeScreen();
  }

  void _loadDoctorProfile() {
    if (widget.doctorData != null) {
      print('\n📋 Loading doctor data from widget:');
      print('   Name: ${widget.doctorData!.name}');
      print('   ID: ${widget.doctorData!.id}');
      print('   Specialization: ${widget.doctorData!.specialization}');
      
      doctorProfile = {
        'name': widget.doctorData!.name,
        'specialization': widget.doctorData!.specialization ?? 'General Physician',
        'experience': widget.doctorData!.experience ?? '5 years',
        'qualification': widget.doctorData!.qualification ?? 'MBBS',
        'hospital': widget.doctorData!.hospital ?? 'City Hospital',
        'rating': widget.doctorData!.rating ?? 4.5,
        'patientsCount': 0,
        'contact': widget.doctorData!.phone,
        'email': widget.doctorData!.email,
        'bio': widget.doctorData!.bio ?? 'Experienced doctor dedicated to patient care.',
      };
    } else {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null && authProvider.user!.userType == 'doctor') {
        print('\n📋 Loading doctor data from AuthProvider:');
        print('   Name: ${authProvider.user!.name}');
        print('   ID: ${authProvider.user!.id}');
        
        doctorProfile = {
          'name': authProvider.user!.name,
          'specialization': authProvider.user!.specialization ?? 'General Physician',
          'experience': authProvider.user!.experience ?? '5 years',
          'qualification': authProvider.user!.qualification ?? 'MBBS',
          'hospital': authProvider.user!.hospital ?? 'City Hospital',
          'rating': 4.5,
          'patientsCount': 0,
          'contact': authProvider.user!.phone,
          'email': authProvider.user!.email,
          'bio': 'Experienced doctor dedicated to patient care.',
        };
      } else {
        print('⚠️ No doctor data found, using default');
        doctorProfile = {
          'name': 'Doctor',
          'specialization': 'General Physician',
          'experience': '5 years',
          'qualification': 'MBBS',
          'hospital': 'City Hospital',
          'rating': 4.5,
          'patientsCount': 0,
          'contact': '',
          'email': '',
          'bio': 'Experienced doctor dedicated to patient care.',
        };
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isInitialized) {
      _resetToDashboard();
    }
  }

  void _initializeScreen() async {
    setState(() => _isLoading = true);
    _currentIndex = 0;
    await _loadAppointments();
    _isInitialized = true;
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAppointments() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      
      if (token != null && token.isNotEmpty) {
        print('\n🔐 Setting token in AppointmentService');
        _appointmentService.setToken(token);
        
        print('📡 Fetching appointments from API...');
        await _appointmentService.getAppointments();
        
        print('🔄 Refreshing doctor appointments...');
        _refreshAppointments();
        _refreshPatients();
      } else {
        print('⚠️ No token available to load appointments');
      }
    } catch (e) {
      print('❌ Error loading appointments: $e');
      _todayAppointments = [];
      _patients = [];
      if (mounted) {
        setState(() {});
      }
    }
  }

 // In doctor_home_screen.dart, update _refreshAppointments:

void _refreshAppointments() {
  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final doctorUserId = authProvider.user?.id;
    
    print('\n=== 🔍 DOCTOR APPOINTMENT DEBUG ===');
    print('Doctor User ID from Auth: "$doctorUserId"');
    print('Doctor Name: ${authProvider.user?.name}');
    
    if (doctorUserId == null || doctorUserId.isEmpty) {
      print('❌ No doctor ID found!');
      _todayAppointments = [];
      if (mounted) setState(() {});
      return;
    }
    
    // Get all appointments
    final allAppointments = _appointmentService.getAllAppointments();
    print('Total appointments in system: ${allAppointments.length}');
    
    // Debug: Print all appointments
    for (var apt in allAppointments) {
      print('   Appointment: ${apt.id}');
      print('      Doctor ID in appointment: "${apt.doctorId}"');
      print('      Doctor Name: ${apt.doctorName}');
      print('      Patient: ${apt.patientName}');
      print('      Date: ${apt.date}');
      print('      Time: ${apt.time}');
    }
    
    // Filter appointments where doctor ID matches the logged-in user's ID
    final doctorAppointments = allAppointments.where((apt) {
      return apt.doctorId == doctorUserId;
    }).toList();
    
    print('Appointments for this doctor: ${doctorAppointments.length}');
    
    // Get today's date
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    
    // Filter today's appointments
    final todayAppointments = doctorAppointments.where((apt) {
      final aptDate = DateTime(apt.date.year, apt.date.month, apt.date.day);
      return aptDate.isAtSameMomentAs(todayDate);
    }).toList();
    
    print('Today\'s appointments: ${todayAppointments.length}');
    
    // Convert to map format
    _todayAppointments = todayAppointments.map((apt) => {
      'id': apt.id,
      'patientId': apt.patientId,
      'name': apt.patientName,
      'patientName': apt.patientName,
      'email': apt.patientEmail,
      'patientEmail': apt.patientEmail,
      'date': apt.date.toIso8601String().split('T')[0],
      'time': apt.time,
      'status': apt.status,
      'type': apt.type,
      'symptoms': apt.symptoms,
      'priority': apt.status == 'confirmed' ? 'normal' : 'normal',
    }).toList();
    
    if (mounted) {
      setState(() {});
    }
  } catch (e) {
    print('❌ Error refreshing appointments: $e');
    _todayAppointments = [];
    if (mounted) {
      setState(() {});
    }
  }
}

  void _refreshPatients() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final doctorId = authProvider.user?.id;
      
      if (doctorId != null && doctorId.isNotEmpty) {
        final patients = _appointmentService.getAllPatientsForDoctor(doctorId);
        _patients = List<Map<String, dynamic>>.from(patients);
        doctorProfile['patientsCount'] = _patients.length;
        print('\n📋 Found ${_patients.length} patients for Dr. ${doctorProfile['name']}');
      }
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('❌ Error refreshing patients: $e');
      _patients = [];
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _resetToDashboard() {
    if (mounted) {
      setState(() {
        _currentIndex = 0;
      });
      _refreshAppointments();
      _refreshPatients();
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SevaPulseSplashScreen()),
      (route) => false,
    );
  }

  void _showPrescriptionDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Write Prescription for ${patient['name'] ?? 'Patient'}'),
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
                onTap: () {},
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
                  content: Text('Prescription sent to ${patient['name'] ?? 'Patient'}'),
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
                onTap: () {},
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () {},
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

  Widget _buildDashboardTab() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading appointments...'),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    backgroundColor: const Color(0xFF3498db).withOpacity(0.1),
                    child: const Icon(Icons.medical_services, color: Color(0xFF3498db), size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${doctorProfile['name'] ?? 'Doctor'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        Text(
                          doctorProfile['specialization'] ?? 'Specialist',
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

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    Color priorityColor = const Color(0xFF27ae60);
    Color statusColor = const Color(0xFFf39c12);
    
    final priority = appointment['priority']?.toString() ?? 'normal';
    if (priority == 'high') priorityColor = const Color(0xFFe74c3c);
    if (priority == 'medium') priorityColor = const Color(0xFFf39c12);
    
    final status = appointment['status']?.toString() ?? 'pending';
    if (status == 'confirmed') statusColor = const Color(0xFF27ae60);
    if (status == 'cancelled') statusColor = const Color(0xFFe74c3c);
    if (status == 'completed') statusColor = const Color(0xFF3498db);

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
                        appointment['name'] ?? appointment['patientName'] ?? 'Patient',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${appointment['id'] ?? appointment['patientId'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Email: ${appointment['email'] ?? appointment['patientEmail'] ?? 'N/A'}',
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
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        priority.toUpperCase(),
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
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
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
              '${appointment['time'] ?? 'Time TBD'} • ${appointment['date'] ?? 'Date TBD'} • ${appointment['type'] ?? 'Consultation'}',
              style: const TextStyle(color: Color(0xFF7f8c8d)),
            ),
            const SizedBox(height: 8),
            Text(
              'Symptoms: ${appointment['symptoms'] ?? 'Not specified'}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF2c3e50)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (status == 'pending') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _appointmentService.updateAppointmentStatus(
                          appointment['id']?.toString() ?? appointment['patientId']?.toString() ?? '',
                          'confirmed'
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Appointment with ${appointment['name'] ?? appointment['patientName'] ?? 'Patient'} confirmed'),
                            backgroundColor: const Color(0xFF27ae60),
                          ),
                        );
                        _refreshAppointments();
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
                        _appointmentService.updateAppointmentStatus(
                          appointment['id']?.toString() ?? appointment['patientId']?.toString() ?? '',
                          'cancelled'
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Appointment with ${appointment['name'] ?? appointment['patientName'] ?? 'Patient'} cancelled'),
                            backgroundColor: const Color(0xFFe74c3c),
                          ),
                        );
                        _refreshAppointments();
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
                ] else if (status == 'confirmed') ...[
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
                      (p) => p['id'] == (appointment['patientId'] ?? appointment['id']),
                      orElse: () => {
                        'id': appointment['patientId'] ?? appointment['id'],
                        'name': appointment['name'] ?? appointment['patientName'],
                        'email': appointment['email'] ?? appointment['patientEmail'],
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
        title: Text('Reschedule ${appointment['name'] ?? appointment['patientName'] ?? 'Patient'}'),
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
                  content: Text('Appointment with ${appointment['name'] ?? appointment['patientName'] ?? 'Patient'} rescheduled'),
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
        content: Text('Starting consultation with ${appointment['name'] ?? appointment['patientName'] ?? 'Patient'}'),
        backgroundColor: const Color(0xFF27ae60),
        duration: const Duration(seconds: 2),
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
    );
  }
}
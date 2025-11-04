import 'package:flutter/material.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> appointments = [
    {
      'id': 1,
      'patientName': 'Namesh Patil',
      'time': '10:00 AM',
      'date': '2025-09-23',
      'type': 'Follow-up',
      'status': 'confirmed',
      'patientId': 'P001',
      'symptoms': 'Chest pain, shortness of breath',
      'priority': 'high',
    },
    {
      'id': 2,
      'patientName': 'Ramesh Mane',
      'time': '2:30 PM',
      'date': '2025-09-23',
      'type': 'New Patient',
      'status': 'confirmed',
      'patientId': 'P002',
      'symptoms': 'Headache, dizziness',
      'priority': 'medium',
    },
    {
      'id': 3,
      'patientName': 'Govind Panchal',
      'time': '4:00 PM',
      'date': '2025-09-23',
      'type': 'Consultation',
      'status': 'pending',
      'patientId': 'P003',
      'symptoms': 'Fever, cough',
      'priority': 'low',
    },
  ];

  final List<Map<String, dynamic>> patients = [
    {
      'id': 'P001',
      'name': 'Namesh Patil',
      'age': 45,
      'gender': 'Male',
      'lastVisit': '2025-08-15',
      'condition': 'Hypertension',
      'emergencyContact': true,
    },
    {
      'id': 'P002',
      'name': 'Ramesh Mane',
      'age': 32,
      'gender': 'Female',
      'lastVisit': '2025-09-10',
      'condition': 'Migraine',
      'emergencyContact': false,
    },
    {
      'id': 'P003',
      'name': 'Govind Panchal',
      'age': 28,
      'gender': 'Male',
      'lastVisit': '2025-08-20',
      'condition': 'Seasonal Flu',
      'emergencyContact': true,
    },
  ];

  final List<Map<String, dynamic>> emergencies = [
    {
      'id': 1,
      'patientName': 'Namesh Patil',
      'time': '09:15 AM',
      'condition': 'Severe Chest Pain',
      'priority': 'critical',
      'location': 'Emergency Ward',
    },
    {
      'id': 2,
      'patientName': 'Ramesh Mane',
      'time': '10:30 AM',
      'condition': 'Breathing Difficulty',
      'priority': 'high',
      'location': 'ICU',
    },
  ];

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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              // Implement logout logic
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
                Text(
                  appointment['patientName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha:0.1),
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
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${appointment['time']} • ${appointment['date']}',
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
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Reschedule appointment
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
                      // Start consultation
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
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final patient = patients.firstWhere((p) => p['id'] == appointment['patientId']);
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

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF3498db).withValues(alpha:0.1),
              radius: 25,
              child: Text(
                patient['name'][0],
                style: const TextStyle(
                  color: Color(0xFF3498db),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  Text(
                    '${patient['age']} years • ${patient['gender']}',
                    style: const TextStyle(color: Color(0xFF7f8c8d)),
                  ),
                  Text(
                    'Condition: ${patient['condition']}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF2c3e50)),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    _showPrescriptionDialog(patient);
                  },
                  icon: const Icon(Icons.medical_services, color: Color(0xFF27ae60)),
                  tooltip: 'Write Prescription',
                ),
                IconButton(
                  onPressed: () {
                    // Start chat with patient
                  },
                  icon: const Icon(Icons.chat, color: Color(0xFF3498db)),
                  tooltip: 'Chat with Patient',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(Map<String, dynamic> emergency) {
    Color priorityColor = const Color(0xFFe74c3c);
    IconData priorityIcon = Icons.warning_amber;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: priorityColor.withValues(alpha:0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(priorityIcon, color: priorityColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emergency['patientName'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    emergency['condition'],
                    style: const TextStyle(color: Color(0xFF2c3e50)),
                  ),
                  Text(
                    'Location: ${emergency['location']}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d)),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle emergency
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: priorityColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Attend', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF7f8c8d)),
                const SizedBox(width: 4),
                Text('${event['date']} at ${event['time']}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Color(0xFF7f8c8d)),
                const SizedBox(width: 4),
                Text(event['location']),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${event['registeredPatients']} patients registered',
                  style: const TextStyle(color: Color(0xFF3498db)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Send reminder to patients
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reminders sent to all registered patients'),
                        backgroundColor: Color(0xFF27ae60),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498db),
                  ),
                  child: const Text('Send Reminder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF7f8c8d),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF2c3e50),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: AppBar(
        title: const Text(
          'Doctor Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {},
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('My Profile'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people), text: 'Patients'),
            Tab(icon: Icon(Icons.event), text: 'Events'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Dashboard Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          backgroundColor: const Color(0xFF3498db).withValues(alpha:0.1),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Stats Overview
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildStatCard('Today\'s Appointments', appointments.length.toString(), Icons.calendar_today, const Color(0xFF3498db)),
                    _buildStatCard('Total Patients', patients.length.toString(), Icons.people, const Color(0xFF27ae60)),
                    _buildStatCard('Medical Events', medicalEvents.length.toString(), Icons.event, const Color(0xFFf39c12)),
                    _buildStatCard('Emergencies', emergencies.length.toString(), Icons.warning, const Color(0xFFe74c3c)),
                  ],
                ),
                const SizedBox(height: 20),

                // Emergencies Section
                if (emergencies.isNotEmpty) ...[
                  const Text(
                    'Emergency Cases',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...emergencies.map((emergency) => _buildEmergencyCard(emergency)),
                  const SizedBox(height: 20),
                ],

                // Today's Appointments
                const Text(
                  "Today's Appointments",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 12),
                ...appointments.map((appointment) => _buildAppointmentCard(appointment)),
              ],
            ),
          ),

          // Patients Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Patients',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Add new patient
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Patient'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498db),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: patients.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, size: 64, color: Color(0xFFbdc3c7)),
                            SizedBox(height: 16),
                            Text(
                              'No Patients',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF7f8c8d),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Patients will appear here',
                              style: TextStyle(
                                color: Color(0xFFbdc3c7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: patients.length,
                        itemBuilder: (context, index) => _buildPatientCard(patients[index]),
                      ),
              ),
            ],
          ),

          // Events Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Medical Events & Camps',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showEventCreationDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Event'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27ae60),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: medicalEvents.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event, size: 64, color: Color(0xFFbdc3c7)),
                            SizedBox(height: 16),
                            Text(
                              'No Events',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF7f8c8d),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Create your first medical event',
                              style: TextStyle(
                                color: Color(0xFFbdc3c7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: medicalEvents.length,
                        itemBuilder: (context, index) => _buildEventCard(medicalEvents[index]),
                      ),
              ),
            ],
          ),

          // Profile Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF3498db).withValues(alpha:0.1),
                          child: const Icon(Icons.medical_services, size: 40, color: Color(0xFF3498db)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          doctorProfile['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        Text(
                          doctorProfile['specialization'],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF3498db),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doctorProfile['hospital'],
                          style: const TextStyle(color: Color(0xFF7f8c8d)),
                        ),
                      ],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Professional Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileDetail('Experience', doctorProfile['experience']),
                        _buildProfileDetail('Qualification', doctorProfile['qualification']),
                        _buildProfileDetail('Rating', '${doctorProfile['rating']} ⭐'),
                        _buildProfileDetail('Patients Treated', doctorProfile['patientsCount'].toString()),
                        _buildProfileDetail('Contact', doctorProfile['contact']),
                        _buildProfileDetail('Email', doctorProfile['email']),
                      ],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doctorProfile['bio'],
                          style: const TextStyle(color: Color(0xFF7f8c8d), height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quick action - Create prescription or start consultation
        },
        backgroundColor: const Color(0xFF3498db),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
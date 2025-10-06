import 'package:flutter/material.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<Map<String, dynamic>> doctors = [
    {
      'id': 1,
      'name': 'Dr. Isha Tapekar',
      'specialty': 'Cardiologist',
      'rating': 4.8,
      'experience': '12 years',
      'hospital': 'City Heart Center',
      'image': '👩‍⚕️',
      'available': true,
    },
    {
      'id': 2,
      'name': 'Dr. Omkar Taralkar',
      'specialty': 'Neurologist',
      'rating': 4.9,
      'experience': '15 years',
      'hospital': 'Neuro Care Institute',
      'image': '👨‍⚕️',
      'available': true,
    },
    {
      'id': 3,
      'name': 'Dr. Pratik Thorat',
      'specialty': 'Pediatrician',
      'rating': 4.7,
      'experience': '8 years',
      'hospital': 'Children Health Center',
      'image': '👨‍⚕️',
      'available': false,
    },
  ];

  final List<Map<String, dynamic>> appointments = [
    {
      'id': 1,
      'doctor': 'Dr. Isha Tapekar',
      'specialty': 'Cardiologist',
      'date': '2024-01-15',
      'time': '10:00 AM',
      'status': 'Upcoming',
    },
    {
      'id': 2,
      'doctor': 'Dr. Omkar Taralkar',
      'specialty': 'Neurologist',
      'date': '2024-01-20',
      'time': '2:30 PM',
      'status': 'Confirmed',
    },
  ];

  final List<Map<String, dynamic>> healthAlerts = [
    {
      'title': 'Flu Season Alert',
      'description': 'Increased flu cases reported in your area',
      'level': 'medium',
      'date': '2 hours ago',
    },
    {
      'title': 'COVID-19 Update',
      'description': 'New variant detected, maintain precautions',
      'level': 'high',
      'date': '1 day ago',
    },
  ];

  final List<Map<String, dynamic>> medicalEvents = [
    {
      'title': 'Free Health Checkup Camp',
      'date': '2024-01-25',
      'location': 'City Central Park',
      'organizer': 'City Health Department',
    },
    {
      'title': 'Diabetes Awareness Workshop',
      'date': '2024-02-10',
      'location': 'Community Health Center',
      'organizer': 'Diabetes Association',
    },
  ];

  final List<Map<String, dynamic>> medicines = [
    {
      'name': 'Metformin',
      'dosage': '500mg',
      'time': '08:00 AM',
      'taken': true,
    },
    {
      'name': 'Aspirin',
      'dosage': '75mg',
      'time': '02:00 PM',
      'taken': false,
    },
    {
      'name': 'Vitamin D',
      'dosage': '1000IU',
      'time': '08:00 PM',
      'taken': false,
    },
  ];

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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete account logic
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498db), Color(0xFF2980b9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem('❤️', '72 BPM', 'Heart Rate'),
          _buildMetricItem('💨', '16', 'Respiration'),
          _buildMetricItem('🩸', '120/80', 'BP'),
          _buildMetricItem('🔥', '98.6°F', 'Temp'),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF3498db).withOpacity(0.1),
              radius: 30,
              child: Text(
                doctor['image'],
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['specialty'],
                    style: const TextStyle(color: Color(0xFF7f8c8d)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.work_outline, size: 14, color: Color(0xFF7f8c8d)),
                      const SizedBox(width: 4),
                      Text(
                        doctor['experience'],
                        style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        doctor['rating'].toString(),
                        style: const TextStyle(color: Color(0xFFf39c12)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: doctor['available'] ? const Color(0xFF27ae60).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          doctor['available'] ? 'Available' : 'Offline',
                          style: TextStyle(
                            color: doctor['available'] ? const Color(0xFF27ae60) : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showBookingDialog(doctor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27ae60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Book'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _showDoctorProfile(doctor);
                  },
                  child: const Text(
                    'Profile',
                    style: TextStyle(color: Color(0xFF3498db)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Appointment with ${doctor['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Preferred Date'),
              readOnly: true,
              onTap: () {
                // Show date picker
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Preferred Time'),
              readOnly: true,
              onTap: () {
                // Show time picker
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Symptoms/Reason'),
              maxLines: 3,
            ),
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
                  content: Text('Appointment requested with ${doctor['name']}'),
                  backgroundColor: const Color(0xFF27ae60),
                ),
              );
            },
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }

  void _showDoctorProfile(Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundColor: const Color(0xFF3498db).withOpacity(0.1),
                radius: 40,
                child: Text(
                  doctor['image'],
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                doctor['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ),
            Center(
              child: Text(
                doctor['specialty'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF3498db),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileItem('🏥', doctor['hospital']),
            _buildProfileItem('⭐', '${doctor['rating']} Rating'),
            _buildProfileItem('💼', doctor['experience']),
            _buildProfileItem('🎓', 'MD in ${doctor['specialty']}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showBookingDialog(doctor);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27ae60),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
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
          'SEVA PULSE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
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
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Account', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'logout':
                  _showLogoutDialog();
                  break;
                case 'delete':
                  _showDeleteAccountDialog();
                  break;
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Home'),
            Tab(text: 'Appointments'),
            Tab(text: 'Medicines'),
            Tab(text: 'Health'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Home Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health Metrics
                _buildHealthMetrics(),
                const SizedBox(height: 20),

                // Health Alerts
                if (healthAlerts.isNotEmpty) ...[
                  const Text(
                    'Health Alerts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...healthAlerts.map((alert) => _buildHealthAlert(alert)),
                  const SizedBox(height: 20),
                ],

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildQuickAction('📅', 'Appointments', const Color(0xFF3498db)),
                    _buildQuickAction('💊', 'Medicines', const Color(0xFFe74c3c)),
                    _buildQuickAction('📊', 'Health Data', const Color(0xFF27ae60)),
                    _buildQuickAction('🏥', 'Find Doctors', const Color(0xFFf39c12)),
                  ],
                ),
                const SizedBox(height: 20),

                // Upcoming Events
                const Text(
                  'Medical Events & Camps',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 12),
                ...medicalEvents.map((event) => _buildEventCard(event)),
              ],
            ),
          ),

          // Appointments Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) => _buildAppointmentCard(appointments[index]),
          ),

          // Medicines Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Medicine Reminders',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Add medicine
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Medicine'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498db),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: medicines.length,
                  itemBuilder: (context, index) => _buildMedicineCard(medicines[index]),
                ),
              ),
            ],
          ),

          // Health Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Health Monitoring',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connect Health Devices',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          leading: const Icon(Icons.watch, color: Color(0xFF3498db)),
                          title: const Text('Smart Watch'),
                          subtitle: const Text('Connect to monitor heart rate, steps, etc.'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Connect Bluetooth device
                            },
                            child: const Text('Connect'),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.monitor_heart, color: Color(0xFFe74c3c)),
                          title: const Text('BP Monitor'),
                          subtitle: const Text('Sync blood pressure data'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Connect Bluetooth device
                            },
                            child: const Text('Connect'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Medical Records',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.receipt_long, color: Color(0xFF27ae60)),
                          title: const Text('Prescriptions'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // View prescriptions
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.assignment, color: Color(0xFF3498db)),
                          title: const Text('Lab Reports'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // View lab reports
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library, color: Color(0xFFf39c12)),
                          title: const Text('Scan & Store Receipts'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Scan receipts
                          },
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
          // Emergency contact or quick action
        },
        backgroundColor: const Color(0xFFe74c3c),
        child: const Icon(Icons.emergency, color: Colors.white),
      ),
    );
  }

  Widget _buildHealthAlert(Map<String, dynamic> alert) {
    Color color = const Color(0xFFf39c12);
    if (alert['level'] == 'high') color = const Color(0xFFe74c3c);
    if (alert['level'] == 'medium') color = const Color(0xFFf39c12);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    alert['description'],
                    style: const TextStyle(color: Color(0xFF2c3e50)),
                  ),
                  Text(
                    alert['date'],
                    style: TextStyle(color: color.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String emoji, String title, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Handle quick action
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF3498db).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event, color: Color(0xFF3498db)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Date: ${event['date']}'),
                  Text('Location: ${event['location']}'),
                  Text('By: ${event['organizer']}'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Color(0xFF3498db)),
              onPressed: () {
                // Add to calendar
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment['doctor'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498db).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment['status'],
                    style: const TextStyle(
                      color: Color(0xFF3498db),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(appointment['specialty']),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF7f8c8d)),
                const SizedBox(width: 4),
                Text('${appointment['date']} at ${appointment['time']}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Reschedule
                    },
                    child: const Text('Reschedule'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Start video call or chat
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27ae60),
                    ),
                    child: const Text('Join Call'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: medicine['taken'],
              onChanged: (value) {
                setState(() {
                  // Update medicine status
                });
              },
              activeColor: const Color(0xFF27ae60),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  Text(
                    'Dosage: ${medicine['dosage']}',
                    style: const TextStyle(color: Color(0xFF7f8c8d)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF3498db).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                medicine['time'],
                style: const TextStyle(
                  color: Color(0xFF3498db),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
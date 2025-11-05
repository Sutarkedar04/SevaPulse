import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment_model.dart';
import 'book_appointment_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> doctors = [
    {
      'id': '1',
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Cardiologist',
      'rating': 4.8,
      'experience': '12 years',
      'hospital': 'City Heart Center',
      'image': '👩‍⚕️',
      'available': true,
    },
    {
      'id': '2',
      'name': 'Dr. Michael Chen',
      'specialty': 'Neurologist',
      'rating': 4.9,
      'experience': '15 years',
      'hospital': 'Neuro Care Institute',
      'image': '👨‍⚕️',
      'available': true,
    },
    {
      'id': '3',
      'name': 'Dr. Emily Davis',
      'specialty': 'Pediatrician',
      'rating': 4.7,
      'experience': '8 years',
      'hospital': 'Children Health Center',
      'image': '👩‍⚕️',
      'available': false,
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
      'title': 'Health Tips',
      'description': 'Stay hydrated and maintain regular exercise',
      'level': 'low',
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
      'title': 'Heart Health Workshop',
      'date': '2024-02-10',
      'location': 'Community Health Center',
      'organizer': 'Heart Care Foundation',
    },
  ];

  final List<Map<String, dynamic>> medicines = [
    {
      'id': '1',
      'name': 'Metformin',
      'dosage': '500mg',
      'time': '08:00 AM',
      'taken': true,
    },
    {
      'id': '2',
      'name': 'Aspirin',
      'dosage': '75mg',
      'time': '02:00 PM',
      'taken': false,
    },
    {
      'id': '3',
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
    _loadData();
  }

  void _loadData() {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appointmentProvider.loadAppointments();
    });
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
              _logout();
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

  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _bookAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentScreen(doctors: doctors),
      ),
    );
  }

  void _bookWithDoctor(Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentScreen(
          doctors: doctors,
          selectedDoctor: doctor,
        ),
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498db).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  onPressed: doctor['available'] ? () => _bookWithDoctor(doctor) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27ae60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
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
              decoration: const InputDecoration(
                labelText: 'Preferred Date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () {
                _selectDate(context);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Preferred Time',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () {
                _selectTime(context);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Symptoms/Reason',
                border: OutlineInputBorder(),
              ),
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
              _bookWithDoctor(doctor);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
            ),
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected date: ${DateFormat('yyyy-MM-dd').format(picked)}'),
          backgroundColor: const Color(0xFF27ae60),
        ),
      );
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected time: ${picked.format(context)}'),
          backgroundColor: const Color(0xFF27ae60),
        ),
      );
    }
  }

  void _showDoctorProfile(Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
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
                  fontWeight: FontWeight.w500,
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
                  _bookWithDoctor(doctor);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27ae60),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
          Text(
            text,
            style: const TextStyle(fontSize: 16, color: Color(0xFF2c3e50)),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAlert(Map<String, dynamic> alert) {
    Color color = const Color(0xFFf39c12);
    if (alert['level'] == 'high') color = const Color(0xFFe74c3c);
    if (alert['level'] == 'medium') color = const Color(0xFFf39c12);
    if (alert['level'] == 'low') color = const Color(0xFF27ae60);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert['description'],
                    style: const TextStyle(color: Color(0xFF2c3e50)),
                  ),
                  const SizedBox(height: 4),
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

  Widget _buildQuickAction(String emoji, String title, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
              child: const Icon(Icons.event, color: Color(0xFF3498db), size: 30),
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Color(0xFF7f8c8d)),
                      const SizedBox(width: 4),
                      Text(
                        event['date'],
                        style: const TextStyle(color: Color(0xFF7f8c8d)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF7f8c8d)),
                      const SizedBox(width: 4),
                      Text(
                        event['location'],
                        style: const TextStyle(color: Color(0xFF7f8c8d)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Color(0xFF3498db)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added to calendar: ${event['title']}'),
                    backgroundColor: const Color(0xFF27ae60),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    Color statusColor = const Color(0xFFf39c12);
    if (appointment.status == 'confirmed') statusColor = const Color(0xFF27ae60);
    if (appointment.status == 'completed') statusColor = const Color(0xFF3498db);
    if (appointment.status == 'cancelled') statusColor = const Color(0xFFe74c3c);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment.doctorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment.type,
              style: const TextStyle(color: Color(0xFF7f8c8d)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF7f8c8d)),
                const SizedBox(width: 4),
                Text(
                  '${_formatAppointmentDate(appointment.date)} at ${appointment.time}',
                  style: const TextStyle(color: Color(0xFF2c3e50)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _rescheduleAppointment(appointment);
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
                    onPressed: appointment.status == 'confirmed' ? () {
                      _joinConsultation(appointment);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27ae60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  String _formatAppointmentDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(date.year, date.month, date.day);
    
    if (appointmentDay == today) {
      return 'Today';
    } else if (appointmentDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  void _rescheduleAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'New Date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'New Time',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () => _selectTime(context),
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
                const SnackBar(
                  content: Text('Appointment rescheduled successfully'),
                  backgroundColor: Color(0xFF27ae60),
                ),
              );
            },
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
  }

  void _joinConsultation(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Consultation'),
        content: Text('Start video call with ${appointment.doctorName}?'),
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
                  content: Text('Connecting to ${appointment.doctorName}...'),
                  backgroundColor: const Color(0xFF27ae60),
                ),
              );
            },
            child: const Text('Join Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: medicine['taken'],
              onChanged: (value) {
                setState(() {
                  medicine['taken'] = value;
                });
                if (value == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Marked ${medicine['name']} as taken'),
                      backgroundColor: const Color(0xFF27ae60),
                    ),
                  );
                }
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
                      fontSize: 16,
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

  void _addMedicine() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medicine Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Dosage',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () => _selectTime(context),
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
                const SnackBar(
                  content: Text('Medicine reminder added'),
                  backgroundColor: Color(0xFF27ae60),
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: AppBar(
        title: const Text(
          'SKY HEALTH',
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  backgroundColor: Color(0xFF27ae60),
                ),
              );
            },
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
              if (value == 'logout') {
                _showLogoutDialog();
              } else if (value == 'profile') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile page coming soon'),
                    backgroundColor: Color(0xFF27ae60),
                  ),
                );
              } else if (value == 'settings') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings page coming soon'),
                    backgroundColor: Color(0xFF27ae60),
                  ),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3498db),
          unselectedLabelColor: const Color(0xFF7f8c8d),
          indicatorColor: const Color(0xFF3498db),
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Appointments'),
            Tab(icon: Icon(Icons.medication), text: 'Medicines'),
            Tab(icon: Icon(Icons.monitor_heart), text: 'Health'),
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
                // Welcome Section
                Text(
                  'Welcome Back, ${authProvider.user?.name.split(' ')[0] ?? ''}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'How can we help you today?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7f8c8d),
                  ),
                ),
                const SizedBox(height: 20),

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
                    _buildQuickAction('📅', 'Appointments', const Color(0xFF3498db), _bookAppointment),
                    _buildQuickAction('💊', 'Medicines', const Color(0xFFe74c3c), _addMedicine),
                    _buildQuickAction('📊', 'Health Data', const Color(0xFF27ae60), () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Health data feature coming soon'),
                          backgroundColor: Color(0xFF27ae60),
                        ),
                      );
                    }),
                    _buildQuickAction('🏥', 'Find Doctors', const Color(0xFFf39c12), () {
                      _tabController.animateTo(0);
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // Available Doctors
                const Text(
                  'Available Doctors',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 12),
                ...doctors.map((doctor) => _buildDoctorCard(doctor)),
                const SizedBox(height: 20),

                // Medical Events
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
          Consumer<AppointmentProvider>(
            builder: (context, appointmentProvider, child) {
              if (appointmentProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final appointments = appointmentProvider.appointments;
              
              return appointments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, size: 64, color: Color(0xFFbdc3c7)),
                          const SizedBox(height: 16),
                          const Text(
                            'No Appointments',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF7f8c8d),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Book your first appointment',
                            style: TextStyle(
                              color: Color(0xFFbdc3c7),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _bookAppointment,
                            child: const Text('Book Appointment'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => appointmentProvider.loadAppointments(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) => _buildAppointmentCard(appointments[index]),
                      ),
                    );
            },
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
                      onPressed: _addMedicine,
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
                child: medicines.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.medication, size: 64, color: Color(0xFFbdc3c7)),
                            const SizedBox(height: 16),
                            const Text(
                              'No Medicines',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF7f8c8d),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add your first medicine reminder',
                              style: TextStyle(
                                color: Color(0xFFbdc3c7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          leading: const Icon(Icons.watch, color: Color(0xFF3498db)),
                          title: const Text('Smart Watch'),
                          subtitle: const Text('Connect to monitor heart rate, steps, etc.'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Connecting to smart watch...'),
                                  backgroundColor: Color(0xFF27ae60),
                                ),
                              );
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Connecting to BP monitor...'),
                                  backgroundColor: Color(0xFF27ae60),
                                ),
                              );
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.receipt_long, color: Color(0xFF27ae60)),
                          title: const Text('Prescriptions'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Prescriptions page coming soon'),
                                backgroundColor: Color(0xFF27ae60),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.assignment, color: Color(0xFF3498db)),
                          title: const Text('Lab Reports'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lab reports page coming soon'),
                                backgroundColor: Color(0xFF27ae60),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library, color: Color(0xFFf39c12)),
                          title: const Text('Scan & Store Receipts'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Receipt scanner coming soon'),
                                backgroundColor: Color(0xFF27ae60),
                              ),
                            );
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
        onPressed: _bookAppointment,
        backgroundColor: const Color(0xFF3498db),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'book_appointment_screen.dart';

class DoctorListScreen extends StatelessWidget {
  final String specialty;

  const DoctorListScreen({Key? key, required this.specialty}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> doctors = [
      {
        'name': 'Dr. Evelyn Reed',
        'title': 'Senior Cardiologist',
        'experience': '15+ Years of Experience',
        'available': true,
      },
      {
        'name': 'Dr. Marcus Chen',
        'title': 'Cardiologist, MD, FACC',
        'experience': '12+ Years of Experience',
        'available': true,
      },
      {
        'name': 'Dr. Sofia Alvarez',
        'title': 'Pediatric Cardiologist',
        'experience': '10+ Years of Experience',
        'available': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(specialty),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by doctor\'s name',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Filter'),
                    const SizedBox(width: 16),
                    FilterChip(
                      label: const Text('Available today'),
                      onSelected: (bool value) {},
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Top rated'),
                      onSelected: (bool value) {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),

          // Doctors List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return _buildDoctorCard(doctor, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctor['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doctor['title'],
              style: const TextStyle(
                color: Color(0xFF3498db),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doctor['experience'],
              style: const TextStyle(
                color: Color(0xFF7f8c8d),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showDoctorProfile(doctor, context);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookAppointmentScreen(
                            doctor: doctor,
                            specialty: specialty, doctors: const [], selectedDoctor: const {},
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498db),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Book Appointment'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorProfile(Map<String, dynamic> doctor, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doctor['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctor['title']),
            const SizedBox(height: 8),
            Text(doctor['experience']),
            const SizedBox(height: 16),
            const Text(
              'About Doctor:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Specialized in cardiac care with extensive experience...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookAppointmentScreen(
                    doctor: doctor,
                    specialty: specialty, doctors: const [], selectedDoctor: const {},
                  ),
                ),
              );
            },
            child: const Text('Book Appointment'),
          ),
        ],
      ),
    );
  }
}
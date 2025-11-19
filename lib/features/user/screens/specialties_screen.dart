import 'package:flutter/material.dart';
import 'doctor_list_screen.dart';

class SpecialtiesScreen extends StatelessWidget {
  const SpecialtiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> specialties = [
      {'name': 'Cardiology', 'icon': Icons.favorite},
      {'name': 'Dermatology', 'icon': Icons.medical_services},
      {'name': 'Pediatrics', 'icon': Icons.child_care},
      {'name': 'Neurology', 'icon': Icons.psychology},
      {'name': 'Orthopedics', 'icon': Icons.accessible},
      {'name': 'Oncology', 'icon': Icons.medical_services},
      {'name': 'Gastroenterology', 'icon': Icons.health_and_safety},
      {'name': 'Pulmonology', 'icon': Icons.air},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Specialties'),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search specialties...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          final specialty = specialties[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorListScreen(specialty: specialty['name']),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    specialty['icon'],
                    size: 40,
                    color: const Color(0xFF3498db),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    specialty['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
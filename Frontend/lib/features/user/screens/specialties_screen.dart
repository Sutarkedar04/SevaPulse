import 'package:flutter/material.dart';
import 'doctor_list_screen.dart';

class SpecialtiesScreen extends StatelessWidget {
  const SpecialtiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> specialties = [
      {'name': 'Cardiology', 'icon': Icons.favorite, 'id': 'cardiology'},
      {'name': 'Dermatology', 'icon': Icons.medical_services, 'id': 'dermatology'},
      {'name': 'Pediatrics', 'icon': Icons.child_care, 'id': 'pediatrics'},
      {'name': 'Neurology', 'icon': Icons.psychology, 'id': 'neurology'},
      {'name': 'Orthopedics', 'icon': Icons.accessible, 'id': 'orthopedics'},
      {'name': 'Oncology', 'icon': Icons.medical_services, 'id': 'oncology'},
      {'name': 'Gastroenterology', 'icon': Icons.health_and_safety, 'id': 'gastroenterology'},
      {'name': 'Pulmonology', 'icon': Icons.air, 'id': 'pulmonology'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Specialties'),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search specialties...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
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
                          builder: (context) => DoctorListScreen(
                            specialty: specialty['name'],
                            specialtyId: specialty['id'],
                          ),
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
          ),
        ],
      ),
    );
  }
}
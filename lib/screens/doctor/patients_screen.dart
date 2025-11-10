import 'package:flutter/material.dart';

class PatientsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> patients;
  final Function(Map<String, dynamic>) onPrescriptionPressed;

  const PatientsScreen({
    Key? key,
    required this.patients,
    required this.onPrescriptionPressed,
  }) : super(key: key);

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      body: Column(
        children: [
          // Header
          Container(
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
          
          // Patients List
          Expanded(
            child: widget.patients.isEmpty
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
                    itemCount: widget.patients.length,
                    itemBuilder: (context, index) => _buildPatientCard(widget.patients[index]),
                  ),
          ),
        ],
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
              backgroundColor: const Color(0xFF3498db).withOpacity(0.1),
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
                  const SizedBox(height: 4),
                  Text(
                    'Last Visit: ${patient['lastVisit']}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF7f8c8d)),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    widget.onPrescriptionPressed(patient);
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
}
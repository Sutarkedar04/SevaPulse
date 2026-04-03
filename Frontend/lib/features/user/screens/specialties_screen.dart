import 'package:flutter/material.dart';
import 'doctor_list_screen.dart';

class SpecialtiesScreen extends StatelessWidget {
  const SpecialtiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> specialties = [
      {'name': 'Orthopaedic Surgeons', 'icon': Icons.accessible, 'id': 'orthopaedic', 'department': 'Orthopaedics'},
      {'name': 'General Surgeons', 'icon': Icons.medical_services, 'id': 'general_surgery', 'department': 'General Surgery'},
      {'name': 'Physicians/Internal Medicine', 'icon': Icons.health_and_safety, 'id': 'internal_medicine', 'department': 'Internal Medicine'},
      {'name': 'Nephrologists', 'icon': Icons.water_drop, 'id': 'nephrology', 'department': 'Nephrology'},
      {'name': 'Paediatricians', 'icon': Icons.child_care, 'id': 'pediatrics', 'department': 'Pediatrics'},
      {'name': 'Neuro-Spine Surgeons', 'icon': Icons.psychology, 'id': 'neuro_spine', 'department': 'Neurosurgery'},
      {'name': 'Cancer Specialist', 'icon': Icons.medical_services, 'id': 'oncology', 'department': 'Oncology'},
      {'name': 'Cardiologists', 'icon': Icons.favorite, 'id': 'cardiology', 'department': 'Cardiology'},
      {'name': 'Dermatologists', 'icon': Icons.medical_services, 'id': 'dermatology', 'department': 'Dermatology'},
      {'name': 'Neurologists', 'icon': Icons.psychology, 'id': 'neurology', 'department': 'Neurology'},
      {'name': 'Ophthalmologists', 'icon': Icons.visibility, 'id': 'ophthalmology', 'department': 'Ophthalmology'},
      {'name': 'Psychiatrists', 'icon': Icons.psychology, 'id': 'psychiatry', 'department': 'Psychiatry'},
      {'name': 'Radiologists', 'icon': Icons.image, 'id': 'radiology', 'department': 'Radiology'},
      {'name': 'Urologists', 'icon': Icons.water, 'id': 'urology', 'department': 'Urology'},
      {'name': 'Gastroenterologists', 'icon': Icons.restaurant, 'id': 'gastroenterology', 'department': 'Gastroenterology'},
      {'name': 'Endocrinologists', 'icon': Icons.biotech, 'id': 'endocrinology', 'department': 'Endocrinology'},
    ];

    String _searchQuery = '';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Specialties'),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
      ),
      body: StatefulBuilder(
        builder: (context, setState) {
          final filteredSpecialties = _searchQuery.isEmpty 
              ? specialties 
              : specialties.where((s) => 
                  s['name'].toLowerCase().contains(_searchQuery.toLowerCase())
              ).toList();
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search specialties...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
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
                  itemCount: filteredSpecialties.length,
                  itemBuilder: (context, index) {
                    final specialty = filteredSpecialties[index];
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
                                department: specialty['department'],
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                specialty['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2c3e50),
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
          );
        },
      ),
    );
  }
}
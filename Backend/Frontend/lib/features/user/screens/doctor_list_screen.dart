import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/providers/auth_provider.dart';
import 'book_appointment_screen.dart';

class DoctorListScreen extends StatefulWidget {
  final String specialty;
  final String specialtyId;

  const DoctorListScreen({
    Key? key, 
    required this.specialty,
    required this.specialtyId,
  }) : super(key: key);

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Please login to view doctors';
          _isLoading = false;
        });
        return;
      }

      print('Fetching doctors from: ${ApiConstants.doctors}');
      print('Using token: $token');

      final response = await http.get(
        Uri.parse(ApiConstants.doctors),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null) {
          final allDoctors = List<Map<String, dynamic>>.from(data['data']);
          
          print('All doctors count: ${allDoctors.length}');
          
          // Filter doctors by specialty/department
          setState(() {
            _doctors = allDoctors.where((doctor) {
              final dept = doctor['department']?.toString().toLowerCase() ?? '';
              final spec = doctor['specialization']?.toString().toLowerCase() ?? '';
              final specialtyLower = widget.specialty.toLowerCase();
              final specialtyIdLower = widget.specialtyId.toLowerCase();
              
              return dept.contains(specialtyIdLower) ||
                     spec.contains(specialtyLower) ||
                     dept.contains(specialtyLower);
            }).toList();
            
            print('Filtered doctors count: ${_doctors.length}');
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'No doctors found';
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _error = 'Session expired. Please login again.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load doctors. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.specialty),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchDoctors,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _doctors.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services, size: 64, color: Color(0xFFbdc3c7)),
                          SizedBox(height: 16),
                          Text('No doctors found for this specialty'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = _doctors[index];
                        return _buildDoctorCard(doctor);
                      },
                    ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final user = doctor['user'] ?? {};
    
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
              user['name'] ?? 'Doctor',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doctor['specialization'] ?? widget.specialty,
              style: const TextStyle(
                color: Color(0xFF3498db),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${doctor['experience'] ?? 'N/A'} years experience',
              style: const TextStyle(
                color: Color(0xFF7f8c8d),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Consultation Fee: ₹${doctor['consultationFee'] ?? '500'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF27ae60),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showDoctorProfile(doctor);
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
                            doctor: {
                              'id': doctor['_id'],
                              'name': user['name'],
                              'specialization': doctor['specialization'],
                              'hospital': user['address']?['city'] ?? 'City Hospital',
                            },
                            specialty: widget.specialty,
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

  void _showDoctorProfile(Map<String, dynamic> doctor) {
    final user = doctor['user'] ?? {};
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['name'] ?? 'Doctor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Specialization: ${doctor['specialization'] ?? widget.specialty}'),
            const SizedBox(height: 8),
            Text('Experience: ${doctor['experience'] ?? 'N/A'} years'),
            const SizedBox(height: 8),
            Text('Consultation Fee: ₹${doctor['consultationFee'] ?? '500'}'),
            const SizedBox(height: 8),
            Text('Department: ${doctor['department'] ?? widget.specialty}'),
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
                    doctor: {
                      'id': doctor['_id'],
                      'name': user['name'],
                      'specialization': doctor['specialization'],
                      'hospital': user['address']?['city'] ?? 'City Hospital',
                    },
                    specialty: widget.specialty,
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
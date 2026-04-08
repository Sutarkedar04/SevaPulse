// lib/features/user/screens/health_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../data/providers/auth_provider.dart';

class HealthFeedScreen extends StatefulWidget {
  const HealthFeedScreen({Key? key}) : super(key: key);

  @override
  State<HealthFeedScreen> createState() => _HealthFeedScreenState();
}

class _HealthFeedScreenState extends State<HealthFeedScreen> {
  List<HealthCamp> _upcomingCamps = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHealthCamps();
  }

  Future<void> _fetchHealthCamps() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Please login to view health camps';
          _isLoading = false;
        });
        return;
      }

      print('📡 Fetching health camps from: ${ApiConstants.healthCamps}');

      final response = await http.get(
        Uri.parse(ApiConstants.healthCamps),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null) {
          final camps = List<Map<String, dynamic>>.from(data['data']);
          
          setState(() {
            _upcomingCamps = camps.map((camp) => HealthCamp.fromJson(camp)).toList();
            _isLoading = false;
          });
          
          print('✅ Loaded ${_upcomingCamps.length} health camps');
        } else {
          setState(() {
            _error = data['message'] ?? 'No health camps found';
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
          _error = 'Failed to load health camps. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching health camps: $e');
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _registerForCamp(HealthCamp camp) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to register'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('📝 Registering for camp: ${camp.id}');

      final response = await http.post(
        Uri.parse('${ApiConstants.registerCamp}/${camp.id}/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          await _fetchHealthCamps();
          _showRegistrationSuccess(camp);
        } else {
          throw Exception(data['message'] ?? 'Registration failed');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Error registering for camp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showRegistrationSuccess(HealthCamp camp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Registration Successful!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You have registered for ${camp.title}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF27ae60),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: AppBar(
        title: const Text(
          'Health Feed & Camps',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHealthCamps,
            tooltip: 'Refresh',
          ),
        ],
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
                        onPressed: _fetchHealthCamps,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _upcomingCamps.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services, size: 64, color: Color(0xFFbdc3c7)),
                          SizedBox(height: 16),
                          Text(
                            'No health camps available',
                            style: TextStyle(fontSize: 16, color: Color(0xFF7f8c8d)),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Check back later for upcoming health camps',
                            style: TextStyle(fontSize: 14, color: Color(0xFF95a5a6)),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        _buildHeaderStats(),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _upcomingCamps.length,
                            itemBuilder: (context, index) {
                              return _buildCampCard(_upcomingCamps[index]);
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildHeaderStats() {
    int freeCamps = _upcomingCamps.where((camp) => camp.isFree).length;
    int totalSlots = _upcomingCamps.fold(0, (sum, camp) => sum + camp.availableSlots);
    int registered = _upcomingCamps.fold(0, (sum, camp) => sum + camp.registeredParticipants);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF3498db),
            Color(0xFF2980b9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Health Camps',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join our community health initiatives and wellness programs',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('$freeCamps', 'Free Camps', Icons.medical_services),
              _buildStatItem('$totalSlots', 'Total Slots', Icons.people),
              _buildStatItem('$registered', 'Registered', Icons.how_to_reg),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
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

  Widget _buildCampCard(HealthCamp camp) {
    final daysLeft = camp.date.difference(DateTime.now()).inDays;
    final percentageFilled = (camp.registeredParticipants / camp.availableSlots) * 100;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: const Color(0xFF3498db).withOpacity(0.1),
                ),
                child: camp.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          camp.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFecf0f1),
                              child: const Icon(
                                Icons.medical_services,
                                color: Color(0xFFbdc3c7),
                                size: 50,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        color: const Color(0xFFecf0f1),
                        child: const Icon(
                          Icons.medical_services,
                          color: Color(0xFFbdc3c7),
                          size: 50,
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: camp.isFree ? const Color(0xFF27ae60) : const Color(0xFFe74c3c),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    camp.isFree ? 'FREE' : '₹${camp.fee}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$daysLeft days left',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  camp.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'by ${camp.organization}',
                  style: const TextStyle(
                    color: Color(0xFF7f8c8d),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildCampDetail(Icons.calendar_today, 
                  DateFormat('MMM dd, yyyy').format(camp.date)),
                const SizedBox(height: 8),
                _buildCampDetail(Icons.access_time, camp.time),
                const SizedBox(height: 8),
                _buildCampDetail(Icons.location_on, camp.location),
                const SizedBox(height: 12),
                
                Text(
                  camp.description,
                  style: const TextStyle(
                    color: Color(0xFF5d6d7e),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: camp.services.take(3).map((service) => 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498db).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF3498db).withOpacity(0.3)),
                      ),
                      child: Text(
                        service,
                        style: const TextStyle(
                          color: Color(0xFF3498db),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ).toList(),
                ),
                const SizedBox(height: 12),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${camp.registeredParticipants}/${camp.availableSlots} registered',
                          style: const TextStyle(
                            color: Color(0xFF7f8c8d),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${percentageFilled.toStringAsFixed(0)}% filled',
                          style: TextStyle(
                            color: percentageFilled > 80 ? const Color(0xFFe74c3c) : const Color(0xFF27ae60),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentageFilled / 100,
                      backgroundColor: const Color(0xFFecf0f1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentageFilled > 80 ? const Color(0xFFe74c3c) : const Color(0xFF27ae60),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showCampDetails(camp),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3498db),
                          side: const BorderSide(color: Color(0xFF3498db)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _registerForCamp(camp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27ae60),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Register Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF3498db)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5d6d7e),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showCampDetails(HealthCamp camp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCampDetailsSheet(camp),
    );
  }

  Widget _buildCampDetailsSheet(HealthCamp camp) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF3498db).withOpacity(0.1),
                    ),
                    child: camp.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              camp.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFecf0f1),
                                  child: const Icon(
                                    Icons.medical_services,
                                    color: Color(0xFFbdc3c7),
                                    size: 60,
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            color: const Color(0xFFecf0f1),
                            child: const Icon(
                              Icons.medical_services,
                              color: Color(0xFFbdc3c7),
                              size: 60,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    camp.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organized by ${camp.organization}',
                    style: const TextStyle(
                      color: Color(0xFF3498db),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3,
                    children: [
                      _buildDetailCard(Icons.calendar_today, 'Date', 
                        DateFormat('MMM dd, yyyy').format(camp.date)),
                      _buildDetailCard(Icons.access_time, 'Time', camp.time),
                      _buildDetailCard(Icons.location_on, 'Venue', camp.location),
                      _buildDetailCard(Icons.people, 'Slots', 
                        '${camp.registeredParticipants}/${camp.availableSlots}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'About this Camp',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    camp.description,
                    style: const TextStyle(
                      color: Color(0xFF5d6d7e),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Services Offered',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: camp.services.map((service) => 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3498db).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF3498db).withOpacity(0.3)),
                        ),
                        child: Text(
                          service,
                          style: const TextStyle(
                            color: Color(0xFF3498db),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactInfo(camp.contact),
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _registerForCamp(camp);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27ae60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        camp.isFree ? 'Register for Free' : 'Register - ₹${camp.fee}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFecf0f1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3498db)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF7f8c8d),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2c3e50),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String contact) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFecf0f1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.contact_phone, color: Color(0xFF3498db)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'For Registration & Queries',
                  style: TextStyle(
                    color: Color(0xFF2c3e50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact,
                  style: const TextStyle(
                    color: Color(0xFF3498db),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// HealthCamp model with fromJson
class HealthCamp {
  final String id;
  final String title;
  final String organization;
  final DateTime date;
  final String time;
  final String location;
  final String description;
  final String imageUrl;
  final int availableSlots;
  final int registeredParticipants;
  final List<String> services;
  final String contact;
  final bool isFree;
  final int? fee;

  HealthCamp({
    required this.id,
    required this.title,
    required this.organization,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.availableSlots,
    required this.registeredParticipants,
    required this.services,
    required this.contact,
    required this.isFree,
    this.fee,
  });

  factory HealthCamp.fromJson(Map<String, dynamic> json) {
    return HealthCamp(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      organization: json['organization'] ?? '',
      date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      availableSlots: json['availableSlots'] ?? 0,
      registeredParticipants: json['registeredParticipants'] ?? 0,
      services: List<String>.from(json['services'] ?? []),
      contact: json['contact'] ?? '',
      isFree: json['isFree'] ?? true,
      fee: json['fee'],
    );
  }
}
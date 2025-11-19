import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HealthFeedScreen extends StatefulWidget {
  const HealthFeedScreen({Key? key}) : super(key: key);

  @override
  State<HealthFeedScreen> createState() => _HealthFeedScreenState();
}

class _HealthFeedScreenState extends State<HealthFeedScreen> {
  final List<HealthCamp> _upcomingCamps = [
    HealthCamp(
      id: '1',
      title: 'Free Heart Checkup Camp',
      organization: 'Seva Pulse Hospital',
      date: DateTime(2024, 12, 20),
      time: '9:00 AM - 4:00 PM',
      location: 'Main Hospital Campus, Ground Floor',
      description: 'Comprehensive heart health screening including ECG, blood pressure, cholesterol check, and cardiologist consultation.',
      imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aGVhcnQlMjBjaGVja3VwfGVufDB8fDB8fHww&w=1000&q=80',
      availableSlots: 150,
      registeredParticipants: 89,
      services: ['ECG', 'BP Check', 'Cholesterol Test', 'Cardiologist Consultation'],
      contact: '+91-9876543210',
      isFree: true,
    ),
    HealthCamp(
      id: '2',
      title: 'Diabetes Awareness & Screening',
      organization: 'Diabetes Care Foundation',
      date: DateTime(2024, 12, 22),
      time: '10:00 AM - 3:00 PM',
      location: 'Community Health Center, Sector 15',
      description: 'Free diabetes screening and awareness program with nutritionist consultation and lifestyle guidance.',
      imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8ZGlhYmV0ZXMlMjB0ZXN0fGVufDB8fDB8fHww&w=1000&q=80',
      availableSlots: 200,
      registeredParticipants: 156,
      services: ['Blood Sugar Test', 'HbA1c Test', 'Nutritionist Consultation', 'Diet Plan'],
      contact: 'diabetescare@example.com',
      isFree: true,
    ),
    HealthCamp(
      id: '3',
      title: 'Pediatric Health Camp',
      organization: 'Child Health Initiative',
      date: DateTime(2024, 12, 25),
      time: '8:00 AM - 2:00 PM',
      location: 'Children\'s Wing, Seva Pulse Hospital',
      description: 'Special health camp for children including vaccination, growth monitoring, and pediatric consultation.',
      imageUrl: 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cGVkaWF0cmljfGVufDB8fDB8fHww&w=1000&q=80',
      availableSlots: 100,
      registeredParticipants: 45,
      services: ['Vaccination', 'Growth Monitoring', 'Pediatric Consultation', 'Nutrition Assessment'],
      contact: '+91-9876543211',
      isFree: false,
      fee: 200,
    ),
    HealthCamp(
      id: '4',
      title: 'Eye Care Camp',
      organization: 'Vision Care Trust',
      date: DateTime(2024, 12, 28),
      time: '9:30 AM - 5:00 PM',
      location: 'Ophthalmology Department, 3rd Floor',
      description: 'Free eye checkup camp including vision testing, cataract screening, and free spectacles for eligible patients.',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8ZXllJTIwY2hlY2t1cHxlbnwwfHwwfHx8MA%3D%3D&w=1000&q=80',
      availableSlots: 300,
      registeredParticipants: 234,
      services: ['Vision Testing', 'Cataract Screening', 'Glaucoma Test', 'Free Spectacles'],
      contact: '+91-9876543212',
      isFree: true,
    ),
    HealthCamp(
      id: '5',
      title: 'Mental Wellness Workshop',
      organization: 'Mind Care Foundation',
      date: DateTime(2024, 12, 30),
      time: '2:00 PM - 6:00 PM',
      location: 'Conference Hall, Main Building',
      description: 'Interactive workshop on mental health awareness, stress management, and mindfulness techniques.',
      imageUrl: 'https://images.unsplash.com/photo-1593811167562-9cef47bfa4d9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bWVudGFsJTIwaGVhbHRofGVufDB8fDB8fHww&w=1000&q=80',
      availableSlots: 80,
      registeredParticipants: 62,
      services: ['Counseling Session', 'Stress Management', 'Mindfulness Training', 'Therapist Consultation'],
      contact: 'mindcare@example.com',
      isFree: false,
      fee: 500,
    ),
  ];

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
      ),
      body: Column(
        children: [
          // Header Stats
          _buildHeaderStats(),
          
          // Camps List
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
            color: Colors.white.withValues(alpha: 0.2),
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
          // Camp Image with error handling
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
                  color: const Color(0xFF3498db).withValues(alpha: 0.1),
                ),
                child: ClipRRect(
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
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFFecf0f1),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498db)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Free/Paid Badge
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
              // Days Left Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
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
                // Title and Organization
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
                
                // Date, Time, Location
                _buildCampDetail(Icons.calendar_today, 
                  DateFormat('MMM dd, yyyy').format(camp.date)),
                const SizedBox(height: 8),
                _buildCampDetail(Icons.access_time, camp.time),
                const SizedBox(height: 8),
                _buildCampDetail(Icons.location_on, camp.location),
                const SizedBox(height: 12),
                
                // Description
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
                
                // Services
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: camp.services.take(3).map((service) => 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498db).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF3498db).withValues(alpha: 0.3)),
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
                
                // Registration Progress
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
                
                // Action Buttons
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
          // Draggable handle
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
                  // Camp Image with error handling
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF3498db).withValues(alpha: 0.1),
                    ),
                    child: ClipRRect(
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
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title and Organization
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
                  
                  // Camp Details Grid
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
                  
                  // Description
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
                  
                  // Services Offered
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
                          color: const Color(0xFF3498db).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF3498db).withValues(alpha: 0.3)),
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
                  
                  // Contact Information
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
                  
                  // Register Button
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

  void _registerForCamp(HealthCamp camp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register for Camp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              camp.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat('MMM dd, yyyy').format(camp.date)}',
              style: const TextStyle(color: Color(0xFF7f8c8d)),
            ),
            Text(
              'Time: ${camp.time}',
              style: const TextStyle(color: Color(0xFF7f8c8d)),
            ),
            const SizedBox(height: 16),
            const Text('Would you like to register for this health camp?'),
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
              _showRegistrationSuccess(camp);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27ae60),
            ),
            child: const Text('Confirm Registration'),
          ),
        ],
      ),
    );
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
}

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
}
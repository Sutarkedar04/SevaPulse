import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredPatients {
    List<Map<String, dynamic>> filtered = widget.patients.where((patient) {
      final nameMatches = patient['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final emailMatches = patient['email']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      
      return nameMatches || emailMatches;
    }).toList();

    // Sort by last visit date (most recent first)
    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(a['lastVisit'] ?? '');
      final dateB = DateTime.tryParse(b['lastVisit'] ?? '');
      
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA);
    });

    return filtered;
  }

  void _showPatientDetails(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(patient['name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient ID', patient['id']),
              _buildDetailRow('Email', patient['email']),
              _buildDetailRow('Last Visit', _formatDate(patient['lastVisit'])),
              _buildDetailRow('Condition', patient['condition']),
              _buildDetailRow('Emergency Contact', 
                  patient['emergencyContact'] == true ? 'Available' : 'Not Available'),
              const SizedBox(height: 16),
              const Text(
                'Medical History:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Regular checkups and follow-ups\n'
                '• Prescribed medications as needed\n'
                '• Routine blood tests and examinations',
                style: TextStyle(color: Color(0xFF7f8c8d)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPrescriptionPressed(patient);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
            ),
            child: const Text('Write Prescription'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2c3e50),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF7f8c8d)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getConditionColor(String condition) {
    if (condition.toLowerCase().contains('hypertension') || 
        condition.toLowerCase().contains('chest')) {
      return const Color(0xFFe74c3c);
    } else if (condition.toLowerCase().contains('migraine') ||
               condition.toLowerCase().contains('headache')) {
      return const Color(0xFFf39c12);
    } else if (condition.toLowerCase().contains('flu') ||
               condition.toLowerCase().contains('fever')) {
      return const Color(0xFF3498db);
    }
    return const Color(0xFF27ae60);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search patients by name or email...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF7f8c8d)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFecf0f1),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Patient Stats
                Row(
                  children: [
                    _buildStatCard('Total Patients', widget.patients.length, 
                        const Color(0xFF3498db)),
                    const SizedBox(width: 12),
                    _buildStatCard('New Today', 
                        widget.patients.where((p) => 
                          p['lastVisit'] == DateFormat('yyyy-MM-dd').format(DateTime.now())
                        ).length, 
                        const Color(0xFF27ae60)),
                  ],
                ),
              ],
            ),
          ),

          // Patients List
          Expanded(
            child: _filteredPatients.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = _filteredPatients[index];
                      return _buildPatientCard(patient);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498db).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF3498db),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Patient Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patient['email'] ?? 'No email',
                        style: const TextStyle(
                          color: Color(0xFF7f8c8d),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getConditionColor(patient['condition']).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              patient['condition'],
                              style: TextStyle(
                                color: _getConditionColor(patient['condition']),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (patient['emergencyContact'] == true)
                            const Icon(
                              Icons.emergency,
                              color: Color(0xFFe74c3c),
                              size: 16,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Additional Info and Actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Visit: ${_formatDate(patient['lastVisit'])}',
                        style: const TextStyle(
                          color: Color(0xFF7f8c8d),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Patient ID: ${patient['id']}',
                        style: const TextStyle(
                          color: Color(0xFF7f8c8d),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Action Buttons
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _showPatientDetails(patient),
                      icon: const Icon(Icons.visibility, size: 20),
                      color: const Color(0xFF3498db),
                      tooltip: 'View Details',
                    ),
                    IconButton(
                      onPressed: () => widget.onPrescriptionPressed(patient),
                      icon: const Icon(Icons.medical_services, size: 20),
                      color: const Color(0xFF27ae60),
                      tooltip: 'Write Prescription',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: const Color(0xFFbdc3c7).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Patients Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7f8c8d),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _searchQuery.isEmpty
                  ? 'Patients who book appointments with you will appear here.'
                  : 'No patients found for "$_searchQuery". Try a different search term.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF95a5a6),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_searchQuery.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498db),
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Search'),
            ),
        ],
      ),
    );
  }
}

// Add DateFormat import at the top of the file


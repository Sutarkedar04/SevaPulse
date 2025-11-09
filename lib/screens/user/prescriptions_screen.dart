import 'package:flutter/material.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({Key? key}) : super(key: key);

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  final List<Map<String, dynamic>> _prescriptions = [
    {
      'id': '1',
      'medication': 'Amoxicillin 500mg',
      'doctor': 'Dr. Emily Carter',
      'date': 'Oct 26, 2023',
      'status': 'Active',
      'statusColor': Colors.green,
      'dosage': 'Take one capsule three times daily for 7 days',
      'refills': '2 refills remaining',
      'pharmacy': 'City Pharmacy',
      'type': 'active',
    },
    {
      'id': '2',
      'medication': 'Lisinopril 10mg',
      'doctor': 'Dr. Ben Adams',
      'date': 'Sep 15, 2023',
      'status': 'Expiring Soon',
      'statusColor': Colors.orange,
      'dosage': 'Take one tablet daily',
      'refills': 'No refills',
      'pharmacy': 'MediCare Pharmacy',
      'type': 'active',
    },
    {
      'id': '3',
      'medication': 'Metformin 1000mg',
      'doctor': 'Dr. Emily Carter',
      'date': 'Aug 02, 2023',
      'status': 'Fulfilled',
      'statusColor': Colors.blue,
      'dosage': 'Take one tablet twice daily with meals',
      'refills': 'Completed',
      'pharmacy': 'Health Plus Pharmacy',
      'type': 'archived',
    },
    {
      'id': '4',
      'medication': 'Atorvastatin 20mg',
      'doctor': 'Dr. Sarah Johnson',
      'date': 'Nov 15, 2023',
      'status': 'Active',
      'statusColor': Colors.green,
      'dosage': 'Take one tablet at bedtime',
      'refills': '3 refills remaining',
      'pharmacy': 'Wellness Pharmacy',
      'type': 'active',
    },
  ];

  String _selectedTab = 'Active';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get _filteredPrescriptions {
    List<Map<String, dynamic>> filtered = _prescriptions;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((prescription) {
        final medication = prescription['medication'].toString().toLowerCase();
        final doctor = prescription['doctor'].toString().toLowerCase();
        return medication.contains(_searchQuery.toLowerCase()) ||
            doctor.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by selected tab
    switch (_selectedTab) {
      case 'Active':
        filtered = filtered.where((p) => p['type'] == 'active').toList();
        break;
      case 'Archived':
        filtered = filtered.where((p) => p['type'] == 'archived').toList();
        break;
      case 'All':
      default:
        break;
    }

    return filtered;
  }

  void _onTabSelected(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _scanPrescription() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Prescription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 60, color: Color(0xFF3498db)),
            const SizedBox(height: 16),
            const Text(
              'Position the prescription within the camera frame for best results',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showScanResult();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498db),
                    ),
                    child: const Text(
                      'Scan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showScanResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription scanned successfully!'),
        backgroundColor: Color(0xFF27ae60),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate adding a new prescription from scan
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _prescriptions.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'medication': 'Ibuprofen 400mg',
          'doctor': 'Dr. Scan Result',
          'date': 'Now',
          'status': 'Active',
          'statusColor': Colors.green,
          'dosage': 'Take one tablet as needed for pain',
          'refills': '1 refill remaining',
          'pharmacy': 'Scan Pharmacy',
          'type': 'active',
        });
      });
    });
  }

  void _uploadPrescription() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Prescription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload_file, size: 60, color: Color(0xFF3498db)),
            const SizedBox(height: 16),
            const Text(
              'Choose prescription file from your device',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showUploadResult('gallery');
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showUploadResult('files');
                    },
                    icon: const Icon(Icons.folder),
                    label: const Text('Files'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadResult(String source) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prescription uploaded from $source!'),
        backgroundColor: const Color(0xFF27ae60),
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate adding a new prescription from upload
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _prescriptions.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'medication': 'Vitamin D3 2000IU',
          'doctor': 'Dr. Upload Result',
          'date': 'Now',
          'status': 'Active',
          'statusColor': Colors.green,
          'dosage': 'Take one capsule daily',
          'refills': 'No refills',
          'pharmacy': 'Upload Pharmacy',
          'type': 'active',
        });
      });
    });
  }

  void _viewPrescriptionDetails(Map<String, dynamic> prescription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              prescription['medication'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prescribed by: ${prescription['doctor']}',
              style: const TextStyle(
                color: Color(0xFF7f8c8d),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Issued Date', prescription['date']),
            _buildDetailRow('Dosage Instructions', prescription['dosage']),
            _buildDetailRow('Refills', prescription['refills']),
            _buildDetailRow('Pharmacy', prescription['pharmacy']),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _sharePrescription(prescription);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498db),
                    ),
                    child: const Text(
                      'Share',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF7f8c8d),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sharePrescription(Map<String, dynamic> prescription) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${prescription['medication']} prescription...'),
        backgroundColor: const Color(0xFF3498db),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _archivePrescription(int index) {
    setState(() {
      _prescriptions[index]['type'] = 'archived';
      _prescriptions[index]['status'] = 'Archived';
      _prescriptions[index]['statusColor'] = Colors.grey;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_prescriptions[index]['medication']} archived'),
        backgroundColor: const Color(0xFF7f8c8d),
      ),
    );
  }

  void _deletePrescription(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prescription'),
        content: Text('Are you sure you want to delete ${_prescriptions[index]['medication']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _prescriptions.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prescription deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prescriptions'),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Scan and Upload Section
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFf8f9fa),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: _scanPrescription,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: Color(0xFF3498db)),
                            SizedBox(height: 8),
                            Text(
                              'Scan Prescription',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2c3e50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: _uploadPrescription,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.upload_file, size: 40, color: Color(0xFF3498db)),
                            SizedBox(height: 8),
                            Text(
                              'Upload from Device',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2c3e50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search medication or doctor',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTab('Active', _selectedTab == 'Active'),
                _buildTab('Archived', _selectedTab == 'Archived'),
                _buildTab('All', _selectedTab == 'All'),
              ],
            ),
          ),

          // Prescriptions Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredPrescriptions.length} prescriptions',
                  style: const TextStyle(
                    color: Color(0xFF7f8c8d),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Prescriptions List
          Expanded(
            child: _filteredPrescriptions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description, size: 64, color: Color(0xFFbdc3c7)),
                        SizedBox(height: 16),
                        Text(
                          'No prescriptions found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try scanning or uploading a prescription',
                          style: TextStyle(
                            color: Color(0xFFbdc3c7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPrescriptions.length,
                    itemBuilder: (context, index) {
                      final prescription = _filteredPrescriptions[index];
                      return _buildPrescriptionItem(prescription, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isActive) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3498db) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFF3498db),
          ),
        ),
        child: TextButton(
          onPressed: () => _onTabSelected(text),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF3498db),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionItem(Map<String, dynamic> prescription, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prescription['medication'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prescription['doctor'],
                        style: const TextStyle(
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF7f8c8d)),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('View Details')),
                    if (prescription['type'] == 'active')
                      const PopupMenuItem(value: 'archive', child: Text('Archive')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        _viewPrescriptionDetails(prescription);
                        break;
                      case 'archive':
                        _archivePrescription(_prescriptions.indexWhere((p) => p['id'] == prescription['id']));
                        break;
                      case 'delete':
                        _deletePrescription(_prescriptions.indexWhere((p) => p['id'] == prescription['id']));
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Issued: ${prescription['date']}',
                  style: const TextStyle(
                    color: Color(0xFF7f8c8d),
                    fontSize: 12,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: prescription['statusColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    prescription['status'],
                    style: TextStyle(
                      color: prescription['statusColor'],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({Key? key}) : super(key: key);

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  final List<Map<String, dynamic>> _prescriptions = [];
  String _selectedTab = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  void _loadPrescriptions() {
    // Load prescriptions from local storage
    setState(() {
      // Empty list - user will add their own
    });
  }

  List<Map<String, dynamic>> get _filteredPrescriptions {
    List<Map<String, dynamic>> filtered = _prescriptions;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((prescription) {
        final medication = prescription['medication'].toString().toLowerCase();
        final doctor = prescription['doctor'].toString().toLowerCase();
        return medication.contains(_searchQuery.toLowerCase()) ||
            doctor.contains(_searchQuery.toLowerCase());
      }).toList();
    }

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

  Future<void> _scanPrescription() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        _showPrescriptionDialog(image.path, 'Scanned Prescription');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  Future<void> _uploadFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        _showPrescriptionDialog(image.path, 'Uploaded Prescription');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  Future<void> _uploadFromFiles() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        _showPrescriptionDialog(image.path, 'Uploaded Prescription');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload Prescription',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUploadOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _uploadFromGallery();
                  },
                ),
                const SizedBox(width: 20),
                _buildUploadOption(
                  icon: Icons.folder,
                  label: 'Files',
                  onTap: () {
                    Navigator.pop(context);
                    _uploadFromFiles();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFf8f9fa),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFecf0f1)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF3498db)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2c3e50),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrescriptionDialog(String imagePath, String source) {
    final TextEditingController _medicationController = TextEditingController();
    final TextEditingController _doctorController = TextEditingController();
    final TextEditingController _dosageController = TextEditingController();
    final TextEditingController _pharmacyController = TextEditingController();
    String selectedStatus = 'Active';
    Color statusColor = Colors.green;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.medical_information, color: const Color(0xFF3498db)),
            const SizedBox(width: 8),
            const Text('Prescription Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Preview
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFecf0f1)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Medication Name
              TextFormField(
                controller: _medicationController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
              ),
              const SizedBox(height: 12),
              // Doctor Name
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              // Dosage
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage Instructions',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              // Pharmacy
              TextFormField(
                controller: _pharmacyController,
                decoration: const InputDecoration(
                  labelText: 'Pharmacy',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_pharmacy),
                ),
              ),
              const SizedBox(height: 12),
              // Status Dropdown
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Expiring Soon', child: Text('Expiring Soon')),
                  DropdownMenuItem(value: 'Fulfilled', child: Text('Fulfilled')),
                  DropdownMenuItem(value: 'Archived', child: Text('Archived')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedStatus = value;
                    switch (value) {
                      case 'Active':
                        statusColor = Colors.green;
                        break;
                      case 'Expiring Soon':
                        statusColor = Colors.orange;
                        break;
                      case 'Fulfilled':
                        statusColor = Colors.blue;
                        break;
                      case 'Archived':
                        statusColor = Colors.grey;
                        break;
                    }
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_medicationController.text.isEmpty) {
                _showSnackBar('Please enter medication name', Colors.red);
                return;
              }
              if (_doctorController.text.isEmpty) {
                _showSnackBar('Please enter doctor name', Colors.red);
                return;
              }

              final newPrescription = {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'medication': _medicationController.text,
                'doctor': _doctorController.text,
                'date': DateFormat('MMM dd, yyyy').format(DateTime.now()),
                'status': selectedStatus,
                'statusColor': statusColor,
                'dosage': _dosageController.text.isEmpty ? 'No instructions' : _dosageController.text,
                'refills': 'No refills',
                'pharmacy': _pharmacyController.text.isEmpty ? 'Not specified' : _pharmacyController.text,
                'type': selectedStatus == 'Archived' ? 'archived' : 'active',
                'imagePath': imagePath,
              };

              setState(() {
                _prescriptions.insert(0, newPrescription);
              });

              Navigator.pop(context);
              _showSnackBar('Prescription added successfully', Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27ae60),
            ),
            child: const Text('Save Prescription'),
          ),
        ],
      ),
    );
  }

  void _viewPrescriptionDetails(Map<String, dynamic> prescription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 20),
            // Prescription Image
            if (prescription['imagePath'] != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFecf0f1)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(prescription['imagePath']),
                    fit: BoxFit.contain,
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
                    child: const Text('Share'),
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
    _showSnackBar('Sharing ${prescription['medication']} prescription...', const Color(0xFF3498db));
  }

  void _archivePrescription(int index) {
    setState(() {
      _prescriptions[index]['type'] = 'archived';
      _prescriptions[index]['status'] = 'Archived';
      _prescriptions[index]['statusColor'] = Colors.grey;
    });
    
    _showSnackBar('${_prescriptions[index]['medication']} archived', const Color(0xFF7f8c8d));
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
              _showSnackBar('Prescription deleted', Colors.red);
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
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
        elevation: 2,
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
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: _scanPrescription,
                      borderRadius: BorderRadius.circular(12),
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
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: _showUploadOptions,
                      borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFecf0f1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFecf0f1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3498db), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTab('All', _selectedTab == 'All'),
                _buildTab('Active', _selectedTab == 'Active'),
                _buildTab('Archived', _selectedTab == 'Archived'),
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description, size: 80, color: const Color(0xFFbdc3c7)),
                        const SizedBox(height: 16),
                        const Text(
                          'No prescriptions found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Scan or upload a prescription to get started',
                          style: TextStyle(
                            color: Color(0xFF95a5a6),
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
                      return _buildPrescriptionItem(prescription, _prescriptions.indexOf(prescription));
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF3498db),
          ),
        ),
        child: TextButton(
          onPressed: () => _onTabSelected(text),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewPrescriptionDetails(prescription),
        borderRadius: BorderRadius.circular(12),
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
                          _archivePrescription(index);
                          break;
                        case 'delete':
                          _deletePrescription(index);
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
                      color: (prescription['statusColor'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      prescription['status'],
                      style: TextStyle(
                        color: prescription['statusColor'] as Color,
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
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
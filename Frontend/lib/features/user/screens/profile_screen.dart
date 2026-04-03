import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/patient_service.dart';
import '../../../core/constants/api_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic> _userProfile = {
    'personalInfo': {
      'name': '',
      'email': '',
      'phone': '',
      'dateOfBirth': 'Not set',
      'gender': 'Not set',
      'bloodType': 'Not set',
      'address': 'Not set',
    },
    'medicalInfo': {
      'allergies': 'No allergies recorded',
      'medicalConditions': 'No conditions recorded',
      'currentMedications': 'No medications recorded',
      'surgeries': 'No surgeries recorded',
      'familyHistory': 'No family history recorded',
    },
  };

  final PatientService _patientService = PatientService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user != null) {
        // Set token for patient service
        if (authProvider.token != null) {
          _patientService.setToken(authProvider.token!);
        }
        
        // Fetch patient details from backend
        final patientDetails = await _getPatientDetails(authProvider.token);
        
        setState(() {
          _userProfile = {
            'personalInfo': {
              'name': user.name,
              'email': user.email,
              'phone': user.phone,
              'dateOfBirth': patientDetails['dateOfBirth'] ?? user.dateOfBirth?.toString().split('T')[0] ?? 'Not set',
              'gender': patientDetails['gender'] ?? user.gender ?? 'Not set',
              'bloodType': patientDetails['bloodGroup'] ?? 'Not set',
              'address': patientDetails['address']?['city'] ?? user.address ?? 'Not set',
            },
            'medicalInfo': {
              'allergies': patientDetails['allergies']?.isNotEmpty == true 
                  ? patientDetails['allergies'].join(', ') 
                  : 'No allergies recorded',
              'medicalConditions': patientDetails['medicalHistory']?.isNotEmpty == true
                  ? patientDetails['medicalHistory'].map((h) => h['condition']).join(', ')
                  : 'No conditions recorded',
              'currentMedications': patientDetails['currentMedications']?.isNotEmpty == true
                  ? patientDetails['currentMedications'].map((m) => '${m['name']} ${m['dosage']}').join(', ')
                  : 'No medications recorded',
              'surgeries': 'No surgeries recorded',
              'familyHistory': 'No family history recorded',
            },
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getPatientDetails(String? token) async {
    if (token == null) return {};
    
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.patients),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0];
        }
      }
      return {};
    } catch (e) {
      print('Error fetching patient details: $e');
      return {};
    }
  }

  // In _ProfileScreenState class

Future<void> _updateProfile(Map<String, dynamic> newProfile) async {
  setState(() {
    _isSaving = true;
  });
  
  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    print('🔄 Updating profile with token: $token');
    
    _patientService.setToken(token);
    
    // Prepare update data - ONLY send fields that have changed
    final updateData = <String, dynamic>{};
    
    // Personal info
    if (newProfile['personalInfo']['name'] != _userProfile['personalInfo']['name']) {
      updateData['name'] = newProfile['personalInfo']['name'];
    }
    if (newProfile['personalInfo']['email'] != _userProfile['personalInfo']['email']) {
      updateData['email'] = newProfile['personalInfo']['email'];
    }
    if (newProfile['personalInfo']['phone'] != _userProfile['personalInfo']['phone']) {
      updateData['phone'] = newProfile['personalInfo']['phone'];
    }
    if (newProfile['personalInfo']['dateOfBirth'] != _userProfile['personalInfo']['dateOfBirth'] &&
        newProfile['personalInfo']['dateOfBirth'] != 'Not set') {
      updateData['dateOfBirth'] = newProfile['personalInfo']['dateOfBirth'];
    }
    if (newProfile['personalInfo']['gender'] != _userProfile['personalInfo']['gender'] &&
        newProfile['personalInfo']['gender'] != 'Not set') {
      updateData['gender'] = newProfile['personalInfo']['gender'];
    }
    if (newProfile['personalInfo']['bloodType'] != _userProfile['personalInfo']['bloodType'] &&
        newProfile['personalInfo']['bloodType'] != 'Not set') {
      updateData['bloodGroup'] = newProfile['personalInfo']['bloodType'];
    }
    if (newProfile['personalInfo']['address'] != _userProfile['personalInfo']['address'] &&
        newProfile['personalInfo']['address'] != 'Not set') {
      updateData['address'] = {'city': newProfile['personalInfo']['address']};
    }
    
    // Medical info
    if (newProfile['medicalInfo']['allergies'] != _userProfile['medicalInfo']['allergies'] &&
        newProfile['medicalInfo']['allergies'] != 'No allergies recorded') {
      updateData['allergies'] = newProfile['medicalInfo']['allergies']
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    
    print('📤 Sending update data: $updateData');
    
    if (updateData.isNotEmpty) {
      await _patientService.updatePatientProfile(updateData);
      
      // Update local profile
      setState(() {
        _userProfile = newProfile;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No changes to update'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  } catch (e) {
    print('❌ Error updating profile: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: const Color(0xFF3498db),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498db)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.edit),
            onPressed: _isSaving ? null : () {
              _showEditProfileDialog(context, authProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(_userProfile['personalInfo']),
            const SizedBox(height: 24),
            
            // Personal Information
            _buildPersonalInfoSection(_userProfile['personalInfo']),
            const SizedBox(height: 24),
            
            // Medical Information
            _buildMedicalInfoSection(_userProfile['medicalInfo']),
            const SizedBox(height: 24),
            
            // Settings
            _buildSettingsSection(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> personalInfo) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF3498db).withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color(0xFF3498db),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    personalInfo['name'] ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    personalInfo['email'] ?? 'user@example.com',
                    style: const TextStyle(
                      color: Color(0xFF7f8c8d),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27ae60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Seva Pulse Member',
                      style: TextStyle(
                        color: Color(0xFF27ae60),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(Map<String, dynamic> personalInfo) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline, color: Color(0xFF3498db)),
                SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Full Name', personalInfo['name'] ?? 'Not set'),
            _buildInfoRow('Email', personalInfo['email'] ?? 'Not set'),
            _buildInfoRow('Phone', personalInfo['phone'] ?? 'Not set'),
            _buildInfoRow('Date of Birth', personalInfo['dateOfBirth'] ?? 'Not set'),
            _buildInfoRow('Gender', personalInfo['gender'] ?? 'Not set'),
            _buildInfoRow('Blood Type', personalInfo['bloodType'] ?? 'Not set'),
            _buildInfoRow('Address', personalInfo['address'] ?? 'Not set'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
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

  Widget _buildMedicalInfoSection(Map<String, dynamic> medicalInfo) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.medical_services, color: Color(0xFF3498db)),
                SizedBox(width: 8),
                Text(
                  'Medical Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMedicalItem('Allergies', medicalInfo['allergies'] ?? 'Not set'),
            _buildMedicalItem('Medical Conditions', medicalInfo['medicalConditions'] ?? 'Not set'),
            _buildMedicalItem('Current Medications', medicalInfo['currentMedications'] ?? 'Not set'),
            _buildMedicalItem('Surgeries', medicalInfo['surgeries'] ?? 'Not set'),
            _buildMedicalItem('Family History', medicalInfo['familyHistory'] ?? 'Not set'),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF7f8c8d),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthProvider authProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: Color(0xFF3498db)),
                SizedBox(width: 8),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(Icons.notifications, 'Notifications', true),
            _buildSettingsItem(Icons.security, 'Privacy & Security', false),
            _buildSettingsItem(Icons.medical_information, 'Health Data Sharing', false),
            _buildSettingsItem(Icons.language, 'Language', false),
            _buildSettingsItem(Icons.help, 'Help & Support', false),
            _buildSettingsItem(Icons.info, 'About Seva Pulse', false),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog(context, authProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe74c3c).withOpacity(0.1),
                  foregroundColor: const Color(0xFFe74c3c),
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, bool hasSwitch) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3498db)),
      title: Text(title),
      trailing: hasSwitch
          ? Switch(
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFF3498db),
            )
          : const Icon(Icons.chevron_right, color: Color(0xFF7f8c8d)),
      onTap: () {},
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        authProvider: authProvider,
        currentProfile: _userProfile,
        onProfileUpdated: _updateProfile,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from Seva Pulse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              authProvider.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// EditProfileDialog remains the same as before
class EditProfileDialog extends StatefulWidget {
  final AuthProvider authProvider;
  final Map<String, dynamic> currentProfile;
  final Function(Map<String, dynamic>) onProfileUpdated;

  const EditProfileDialog({
    Key? key,
    required this.authProvider,
    required this.currentProfile,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _addressController;
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;
  late TextEditingController _medicationsController;
  late TextEditingController _surgeriesController;
  late TextEditingController _familyHistoryController;

  @override
  void initState() {
    super.initState();
    final personalInfo = widget.currentProfile['personalInfo'];
    final medicalInfo = widget.currentProfile['medicalInfo'];
    
    _nameController = TextEditingController(text: personalInfo['name'] ?? '');
    _emailController = TextEditingController(text: personalInfo['email'] ?? '');
    _phoneController = TextEditingController(text: personalInfo['phone'] ?? '');
    _dobController = TextEditingController(text: personalInfo['dateOfBirth'] != 'Not set' ? personalInfo['dateOfBirth'] : '');
    _genderController = TextEditingController(text: personalInfo['gender'] != 'Not set' ? personalInfo['gender'] : '');
    _bloodTypeController = TextEditingController(text: personalInfo['bloodType'] != 'Not set' ? personalInfo['bloodType'] : '');
    _addressController = TextEditingController(text: personalInfo['address'] != 'Not set' ? personalInfo['address'] : '');
    
    _allergiesController = TextEditingController(text: medicalInfo['allergies'] != 'No allergies recorded' ? medicalInfo['allergies'] : '');
    _conditionsController = TextEditingController(text: medicalInfo['medicalConditions'] != 'No conditions recorded' ? medicalInfo['medicalConditions'] : '');
    _medicationsController = TextEditingController(text: medicalInfo['currentMedications'] != 'No medications recorded' ? medicalInfo['currentMedications'] : '');
    _surgeriesController = TextEditingController(text: medicalInfo['surgeries'] != 'No surgeries recorded' ? medicalInfo['surgeries'] : '');
    _familyHistoryController = TextEditingController(text: medicalInfo['familyHistory'] != 'No family history recorded' ? medicalInfo['familyHistory'] : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _bloodTypeController.dispose();
    _addressController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _surgeriesController.dispose();
    _familyHistoryController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = {
        'personalInfo': {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'dateOfBirth': _dobController.text.isEmpty ? 'Not set' : _dobController.text,
          'gender': _genderController.text.isEmpty ? 'Not set' : _genderController.text,
          'bloodType': _bloodTypeController.text.isEmpty ? 'Not set' : _bloodTypeController.text,
          'address': _addressController.text.isEmpty ? 'Not set' : _addressController.text,
        },
        'medicalInfo': {
          'allergies': _allergiesController.text.isEmpty ? 'No allergies recorded' : _allergiesController.text,
          'medicalConditions': _conditionsController.text.isEmpty ? 'No conditions recorded' : _conditionsController.text,
          'currentMedications': _medicationsController.text.isEmpty ? 'No medications recorded' : _medicationsController.text,
          'surgeries': _surgeriesController.text.isEmpty ? 'No surgeries recorded' : _surgeriesController.text,
          'familyHistory': _familyHistoryController.text.isEmpty ? 'No family history recorded' : _familyHistoryController.text,
        },
      };

      widget.onProfileUpdated(updatedProfile);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3498db),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Full Name', _nameController),
                      _buildTextField('Email', _emailController),
                      _buildTextField('Phone', _phoneController),
                      _buildTextField('Date of Birth (YYYY-MM-DD)', _dobController),
                      _buildTextField('Gender', _genderController),
                      _buildTextField('Blood Type', _bloodTypeController),
                      _buildTextField('Address', _addressController, maxLines: 2),
                      const SizedBox(height: 24),
                      const Text(
                        'Medical Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3498db),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Allergies (comma separated)', _allergiesController),
                      _buildTextField('Medical Conditions', _conditionsController),
                      _buildTextField('Current Medications', _medicationsController),
                      _buildTextField('Surgeries', _surgeriesController),
                      _buildTextField('Family History', _familyHistoryController),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498db),
                      ),
                      child: const Text('Save'),
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

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        validator: (value) {
          if (label.contains('Name') && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          if (label.contains('Email') && value != null && value.isNotEmpty) {
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
          }
          return null;
        },
      ),
    );
  }
}
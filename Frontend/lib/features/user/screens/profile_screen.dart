import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/patient_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
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
        final patientDetails = await _patientService.getPatientProfile();
        
        setState(() {
          _userProfile = {
            'personalInfo': {
              'name': user.name,
              'email': user.email,
              'phone': user.phone,
              'dateOfBirth': patientDetails['dateOfBirth'] ?? 'Not set',
              'gender': patientDetails['gender'] ?? 'Not set',
              'bloodType': patientDetails['bloodGroup'] ?? 'Not set',
              'address': patientDetails['address']?['city'] ?? 'Not set',
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
              'surgeries': 'No surgeries recorded', // This would come from medicalHistory with type 'surgery'
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

  void _updateProfile(Map<String, dynamic> newProfile) async {
    setState(() {
      _userProfile = newProfile;
    });
    
    // Here you would call API to update profile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
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
            icon: const Icon(Icons.edit),
            onPressed: () {
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
    _dobController = TextEditingController(text: personalInfo['dateOfBirth'] ?? '');
    _genderController = TextEditingController(text: personalInfo['gender'] ?? '');
    _bloodTypeController = TextEditingController(text: personalInfo['bloodType'] ?? '');
    _addressController = TextEditingController(text: personalInfo['address'] ?? '');
    
    _allergiesController = TextEditingController(text: medicalInfo['allergies'] ?? '');
    _conditionsController = TextEditingController(text: medicalInfo['medicalConditions'] ?? '');
    _medicationsController = TextEditingController(text: medicalInfo['currentMedications'] ?? '');
    _surgeriesController = TextEditingController(text: medicalInfo['surgeries'] ?? '');
    _familyHistoryController = TextEditingController(text: medicalInfo['familyHistory'] ?? '');
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
          'dateOfBirth': _dobController.text,
          'gender': _genderController.text,
          'bloodType': _bloodTypeController.text,
          'address': _addressController.text,
        },
        'medicalInfo': {
          'allergies': _allergiesController.text,
          'medicalConditions': _conditionsController.text,
          'currentMedications': _medicationsController.text,
          'surgeries': _surgeriesController.text,
          'familyHistory': _familyHistoryController.text,
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
                      _buildTextField('Date of Birth', _dobController),
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
                      _buildTextField('Allergies', _allergiesController),
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
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
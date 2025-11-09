import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

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
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            
            // Personal Information
            _buildPersonalInfoSection(user),
            const SizedBox(height: 24),
            
            // Medical Information
            _buildMedicalInfoSection(),
            const SizedBox(height: 24),
            
            // Settings
            _buildSettingsSection(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
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
              backgroundColor: const Color(0xFF3498db).withValues(alpha: 0.1),
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
                    user?.name ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'user@example.com',
                    style: const TextStyle(
                      color: Color(0xFF7f8c8d),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27ae60).withValues(alpha: 0.1),
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

  Widget _buildPersonalInfoSection(dynamic user) {
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
            _buildInfoRow('Full Name', user?.name ?? 'Not set'),
            _buildInfoRow('Email', user?.email ?? 'Not set'),
            _buildInfoRow('Phone', '+1 (555) 123-4567'),
            _buildInfoRow('Date of Birth', 'January 15, 1985'),
            _buildInfoRow('Gender', 'Male'),
            _buildInfoRow('Blood Type', 'O+'),
            _buildInfoRow('Address', '123 Health St, Medical City, MC 12345'),
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

  Widget _buildMedicalInfoSection() {
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
            
            // Allergies
            _buildMedicalItem('Allergies', 'Penicillin, Peanuts'),
            
            // Conditions
            _buildMedicalItem('Medical Conditions', 'Hypertension, Asthma'),
            
            // Medications
            _buildMedicalItem('Current Medications', 'Lisinopril 10mg, Albuterol Inhaler'),
            
            // Surgeries
            _buildMedicalItem('Surgeries', 'Appendectomy (2015)'),
            
            // Family History
            _buildMedicalItem('Family History', 'Heart Disease, Diabetes'),
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
                  backgroundColor: const Color(0xFFe74c3c).withValues(alpha: 0.1),
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
              activeThumbColor: const Color(0xFF3498db),
            )
          : const Icon(Icons.chevron_right, color: Color(0xFF7f8c8d)),
      onTap: () {},
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(authProvider: authProvider),
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

  const EditProfileDialog({Key? key, required this.authProvider}) : super(key: key);

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
    final user = widget.authProvider.user;
    
    // Personal Information Controllers
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: '+1 (555) 123-4567');
    _dobController = TextEditingController(text: 'January 15, 1985');
    _genderController = TextEditingController(text: 'Male');
    _bloodTypeController = TextEditingController(text: 'O+');
    _addressController = TextEditingController(text: '123 Health St, Medical City, MC 12345');
    
    // Medical Information Controllers
    _allergiesController = TextEditingController(text: 'Penicillin, Peanuts');
    _conditionsController = TextEditingController(text: 'Hypertension, Asthma');
    _medicationsController = TextEditingController(text: 'Lisinopril 10mg, Albuterol Inhaler');
    _surgeriesController = TextEditingController(text: 'Appendectomy (2015)');
    _familyHistoryController = TextEditingController(text: 'Heart Disease, Diabetes');
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
      // Here you would typically update the user profile in your backend
      // For now, we'll just show a success message and close the dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Profile - Seva Pulse',
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
                      // Personal Information Section
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
                      
                      // Medical Information Section
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
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF7f8c8d),
                      ),
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
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
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
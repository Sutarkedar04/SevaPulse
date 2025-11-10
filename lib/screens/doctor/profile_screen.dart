import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctorProfile;
  final VoidCallback onLogoutPressed;

  const ProfileScreen({
    Key? key,
    required this.doctorProfile,
    required this.onLogoutPressed,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF3498db).withOpacity(0.1),
                      child: const Icon(Icons.medical_services, size: 40, color: Color(0xFF3498db)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.doctorProfile['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    Text(
                      widget.doctorProfile['specialization'],
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF3498db),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.doctorProfile['hospital'],
                      style: const TextStyle(color: Color(0xFF7f8c8d)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProfileStat('Patients', widget.doctorProfile['patientsCount'].toString()),
                        const SizedBox(width: 20),
                        _buildProfileStat('Rating', '${widget.doctorProfile['rating']} ⭐'),
                        const SizedBox(width: 20),
                        _buildProfileStat('Exp', widget.doctorProfile['experience']),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Professional Details
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Professional Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileDetail('Qualification', widget.doctorProfile['qualification']),
                    _buildProfileDetail('Contact', widget.doctorProfile['contact']),
                    _buildProfileDetail('Email', widget.doctorProfile['email']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // About Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.doctorProfile['bio'],
                      style: const TextStyle(color: Color(0xFF7f8c8d), height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Settings & Logout
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        // Navigate to settings
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Icons.help,
                      title: 'Help & Support',
                      onTap: () {
                        // Navigate to help
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                      onTap: () {
                        // Navigate to privacy policy
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      titleColor: Colors.red,
                      onTap: widget.onLogoutPressed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2c3e50),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF7f8c8d),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF2c3e50),
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

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? const Color(0xFF2c3e50)),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? const Color(0xFF2c3e50),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF7f8c8d)),
      onTap: onTap,
    );
  }
}
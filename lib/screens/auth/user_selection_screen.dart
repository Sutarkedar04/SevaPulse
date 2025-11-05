import 'package:flutter/material.dart';
import 'user_login_screen.dart';
import 'doctor_login_screen.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2c3e50)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Title
              const Text(
                'Continue As',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
              
              const SizedBox(height: 10),
              
              const Text(
                'Select your role to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7f8c8d),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // User Type Selection Cards
              Column(
                children: [
                  // Patient Card
                  _buildUserTypeCard(
                    title: 'Patient',
                    subtitle: 'Book appointments, consult doctors, manage health records',
                    icon: Icons.person,
                    color: const Color(0xFF3498db),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserLoginScreen()),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Doctor Card
                  _buildUserTypeCard(
                    title: 'Doctor',
                    subtitle: 'Manage appointments, consult patients, update availability',
                    icon: Icons.medical_services,
                    color: const Color(0xFF27ae60),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DoctorLoginScreen()),
                      );
                    },
                  ),
                ],
              ),
              
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF7f8c8d),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFbdc3c7), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);
  
  BuildContext? get context => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 20),

            // Hospital Address
            _buildSection(
              'Hospital Address',
              '123 Health Ave,\nMeditown, MD 12345',
              Icons.location_on,
            ),
            const SizedBox(height: 20),

            // Directions
            _buildContactSection(
              'Directions',
              [
                _buildContactItem(
                  'Main Switchboard',
                  '(123) 456-7890',
                  Icons.phone,
                  true,
                ),
                _buildContactItem(
                  'Appointments',
                  '(123) 456-7891',
                  Icons.phone,
                  true,
                ),
                _buildContactItem(
                  'General Inquiries',
                  'contact@stjudeshospital.org',
                  Icons.email,
                  false,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Follow Us
            _buildSection(
              'Follow Us',
              '',
              Icons.share,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSocialIcon(Icons.facebook),
                const SizedBox(width: 16),
                _buildSocialIcon(Icons.link),
                const SizedBox(width: 16),
                _buildSocialIcon(Icons.camera_alt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF3498db)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (content.isNotEmpty)
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF7f8c8d),
              fontSize: 16,
            ),
          ),
      ],
    );
  }

  Widget _buildContactSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2c3e50),
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildContactItem(String title, String contact, IconData icon, bool isPhone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3498db)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                Text(
                  contact,
                  style: const TextStyle(
                    color: Color(0xFF7f8c8d),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (isPhone) {
                ScaffoldMessenger.of(context!).showSnackBar(

                  SnackBar(
                    content: Text('Calling $contact'),
                    backgroundColor: const Color(0xFF27ae60),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context!).showSnackBar(

                  const SnackBar(
                    content: Text('Opening email client'),
                    backgroundColor: Color(0xFF27ae60),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(isPhone ? 'Call' : 'Email'),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF3498db),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
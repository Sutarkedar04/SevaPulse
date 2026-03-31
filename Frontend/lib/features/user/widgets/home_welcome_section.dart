import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';

class HomeWelcomeSection extends StatelessWidget {
  const HomeWelcomeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.name.split(' ')[0] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $userName',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2c3e50),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: AssetImage('assets/images/userfirstimg.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Need to see a doctor?',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF7f8c8d),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Book your next appointment in just a few clicks.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF7f8c8d),
          ),
        ),
      ],
    );
  }
}
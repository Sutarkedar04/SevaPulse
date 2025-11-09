import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Color(0xFF3498db),
            ),
            SizedBox(height: 16),
            Text(
              'Appointments',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your appointments will appear here',
              style: TextStyle(
                color: Color(0xFF7f8c8d),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
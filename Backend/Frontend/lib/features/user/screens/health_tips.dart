import 'package:flutter/material.dart';

class HealthTipsScreen extends StatelessWidget {
  const HealthTipsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tips'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          HealthTipItem(
            title: 'Balanced Diet',
            description: 'Eat plenty of fruits and vegetables daily',
            icon: Icons.restaurant,
            color: Colors.green,
          ),
          HealthTipItem(
            title: 'Regular Exercise',
            description: '30 minutes of physical activity daily',
            icon: Icons.directions_run,
            color: Colors.blue,
          ),
          HealthTipItem(
            title: 'Adequate Sleep',
            description: '7-9 hours of quality sleep every night',
            icon: Icons.nightlight_round,
            color: Colors.purple,
          ),
          HealthTipItem(
            title: 'Stay Hydrated',
            description: 'Drink 8-10 glasses of water daily',
            icon: Icons.water_drop,
            color: Colors.blue,
          ),
          HealthTipItem(
            title: 'Manage Stress',
            description: 'Practice meditation and deep breathing',
            icon: Icons.self_improvement,
            color: Colors.orange,
          ),
          HealthTipItem(
            title: 'Regular Checkups',
            description: 'Annual health screenings are essential',
            icon: Icons.medical_services,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class HealthTipItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const HealthTipItem({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(description),
      ),
    );
  }
}
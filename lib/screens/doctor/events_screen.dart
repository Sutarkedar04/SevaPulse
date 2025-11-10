import 'package:flutter/material.dart';

class EventsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> medicalEvents;
  final VoidCallback onCreateEventPressed;

  const EventsScreen({
    Key? key,
    required this.medicalEvents,
    required this.onCreateEventPressed,
  }) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Medical Events & Camps',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onCreateEventPressed,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27ae60),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Events List
          Expanded(
            child: widget.medicalEvents.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event, size: 64, color: Color(0xFFbdc3c7)),
                        SizedBox(height: 16),
                        Text(
                          'No Events',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your first medical event',
                          style: TextStyle(
                            color: Color(0xFFbdc3c7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.medicalEvents.length,
                    itemBuilder: (context, index) => _buildEventCard(widget.medicalEvents[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event['title'] ?? 'Untitled Event',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498db).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${event['registeredPatients'] ?? 0} Registered',
                    style: const TextStyle(
                      color: Color(0xFF3498db),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF7f8c8d)),
                const SizedBox(width: 8),
                Text('${event['date'] ?? 'No date'} at ${event['time'] ?? 'No time'}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Color(0xFF7f8c8d)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event['location'] ?? 'No location',
                    style: const TextStyle(color: Color(0xFF2c3e50)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${event['registeredPatients'] ?? 0} patients registered',
                  style: const TextStyle(
                    color: Color(0xFF3498db),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Send reminder to patients
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reminders sent to all registered patients'),
                        backgroundColor: Color(0xFF27ae60),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498db),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send Reminder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
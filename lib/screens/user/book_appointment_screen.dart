import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic>? doctor;
  final String? specialty;

  const BookAppointmentScreen({
    Key? key,
    this.doctor,
    this.specialty, required List<Map<String, dynamic>> doctors, required Map<String, dynamic> selectedDoctor,
  }) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
      ),
      body: _selectedDate == null ? _buildDateSelection() : _buildTimeSelection(),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFf8f9fa),
          child: const Row(
            children: [
              Icon(Icons.calendar_today, color: Color(0xFF3498db)),
              SizedBox(width: 8),
              Text(
                'Select Date & Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
        ),

        // Month Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left),
              ),
              const Text(
                'October 2024',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),

        // Calendar Days
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Day headers
              const Row(
                children: [
                  Expanded(child: Text('S', textAlign: TextAlign.center)),
                  Expanded(child: Text('M', textAlign: TextAlign.center)),
                  Expanded(child: Text('T', textAlign: TextAlign.center)),
                  Expanded(child: Text('W', textAlign: TextAlign.center)),
                  Expanded(child: Text('T', textAlign: TextAlign.center)),
                  Expanded(child: Text('F', textAlign: TextAlign.center)),
                  Expanded(child: Text('S', textAlign: TextAlign.center)),
                ],
              ),
              const SizedBox(height: 8),

              // Calendar rows
              _buildCalendarRow(['5', '6', '7', '8', '9', '10', '11']),
              _buildCalendarRow(['12', '13', '14', '15', '16', '17', '18']),
              _buildCalendarRow(['19', '20', '21', '22', '23', '24', '25']),
              _buildCalendarRow(['26', '27', '28', '29', '30', '31', '']),
            ],
          ),
        ),

        const Spacer(),

        // Next Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(2024, 10, 24); // Default to Oct 24
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarRow(List<String> days) {
    return Row(
      children: days.map((day) {
        final isAvailable = day.isNotEmpty && int.parse(day) >= 19 && int.parse(day) <= 31;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.all(2),
            child: TextButton(
              onPressed: isAvailable
                  ? () {
                      setState(() {
                        _selectedDate = DateTime(2024, 10, int.parse(day));
                      });
                    }
                  : null,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(8),
                shape: const CircleBorder(),
                backgroundColor: isAvailable && _selectedDate?.day == int.parse(day)
                    ? const Color(0xFF3498db)
                    : Colors.transparent,
              ),
              child: Text(
                day,
                style: TextStyle(
                  color: isAvailable
                      ? (_selectedDate?.day == int.parse(day) ? Colors.white : const Color(0xFF2c3e50))
                      : const Color(0xFFbdc3c7),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSelection() {
    final availableSlots = [
      '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
      '11:00 AM', '02:00 PM', '02:30 PM', '03:00 PM', '04:30 PM'
    ];

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFf8f9fa),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              const Text(
                'Available Slots for October 24',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
        ),

        // Time Slots
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.0,
            ),
            itemCount: availableSlots.length,
            itemBuilder: (context, index) {
              final slot = availableSlots[index];
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTime = _parseTime(slot);
                  });
                  _showConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498db),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(slot),
              );
            },
          ),
        ),

        // Confirm Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedTime != null ? _showConfirmationDialog : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Confirm Appointment'),
          ),
        ),
      ],
    );
  }

  TimeOfDay _parseTime(String timeString) {
    final format = DateFormat('hh:mm a');
    final date = format.parse(timeString);
    return TimeOfDay.fromDateTime(date);
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.doctor != null) ...[
              Text(
                widget.doctor!['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(widget.specialty ?? ''),
            ],
            const SizedBox(height: 16),
            const Text('Monday, October 28, 2024'),
            Text(_selectedTime?.format(context) ?? '10:30 AM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Change Details'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog();
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Successful!'),
        content: const Text(
          'Your appointment has been successfully scheduled. '
          'We\'ve sent a confirmation to your email.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              // Navigate to appointments screen
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('View My Appointments'),
          ),
        ],
      ),
    );
  }
}
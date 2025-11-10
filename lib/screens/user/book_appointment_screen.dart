import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/appointment_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final String specialty;

  const BookAppointmentScreen({
    Key? key,
    required this.doctor,
    required this.specialty,
  }) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedSlot;
  final AppointmentService _appointmentService = AppointmentService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
      ),
      body: _selectedDate == null ? _buildDateSelection(user) : _buildTimeSelection(user),
    );
  }

  Widget _buildDateSelection(user) {
    return Column(
      children: [
        // Doctor Info Card
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF3498db).withValues(alpha: 0.1),
                  child: const Icon(Icons.medical_services, color: Color(0xFF3498db)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctor['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      Text(
                        widget.specialty,
                        style: const TextStyle(color: Color(0xFF7f8c8d)),
                      ),
                      Text(
                        widget.doctor['hospital'] ?? 'City Hospital',
                        style: const TextStyle(color: Color(0xFF7f8c8d)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

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
            onPressed: _selectedDate != null ? () {
              setState(() {});
            } : null,
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

  Widget _buildTimeSelection(user) {
    final availableSlots = [
      '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
      '11:00 AM', '02:00 PM', '02:30 PM', '03:00 PM', '04:30 PM'
    ];

    return Column(
      children: [
        // Header with back button
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFf8f9fa),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                    _selectedSlot = null;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Text(
                'Available Slots for ${DateFormat('MMMM d').format(_selectedDate!)}',
                style: const TextStyle(
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
              final isSelected = _selectedSlot == slot;
              
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedSlot = slot;
                    _selectedTime = _parseTime(slot);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected 
                      ? const Color(0xFF3498db)
                      : const Color(0xFFecf0f1),
                  foregroundColor: isSelected ? Colors.white : const Color(0xFF2c3e50),
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
            onPressed: _selectedTime != null ? () => _showConfirmationDialog(user) : null,
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

  void _showConfirmationDialog(user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info
            Text(
              widget.doctor['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(widget.specialty),
            const SizedBox(height: 16),
            
            // Appointment Details
            const Text(
              'Appointment Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Date: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)}'),
            Text('Time: $_selectedSlot'),
            const SizedBox(height: 8),
            
            // Patient Info
            const Text(
              'Patient Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Name: ${user?.name ?? "User"}'),
            Text('Email: ${user?.email ?? "N/A"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Change Details'),
          ),
          ElevatedButton(
            onPressed: () {
              _bookAppointment(user);
              Navigator.pop(context);
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  void _bookAppointment(user) {
    // Create appointment object
    final newAppointment = {
      'patientName': user?.name ?? 'User',
      'time': _selectedSlot!,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'type': 'Consultation',
      'status': 'pending',
      'patientId': user?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      'patientEmail': user?.email ?? 'N/A',
      'symptoms': 'General Consultation',
      'priority': 'medium',
      'doctorId': widget.doctor['id'] ?? 'doctor1',
      'doctorName': widget.doctor['name'],
      'specialty': widget.specialty,
    };

    // Add to appointment service
    _appointmentService.addAppointment(newAppointment);

    // Show success dialog
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF27ae60)),
            SizedBox(width: 8),
            Text('Booking Successful!'),
          ],
        ),
        content: const Text(
          'Your appointment has been successfully scheduled. '
          'The doctor will review and confirm your appointment.',
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
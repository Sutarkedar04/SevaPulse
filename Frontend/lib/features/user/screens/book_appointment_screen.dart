import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/appointment_provider.dart';
import '../../../core/constants/api_constants.dart';

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
  DateTime _currentMonth = DateTime.now();
  bool _isBooking = false;

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
      body: _selectedDate == null 
          ? _buildDateSelection(user) 
          : _buildTimeSelection(user),
    );
  }

  Widget _buildDateSelection(user) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF3498db).withOpacity(0.1),
                  child: const Icon(Icons.medical_services, color: Color(0xFF3498db)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctor['name'] ?? 'Doctor Name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.specialty,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.doctor['hospital'] ?? 'City Hospital',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFf8f9fa),
          child: const Row(
            children: [
              Icon(Icons.calendar_today, color: Color(0xFF3498db)),
              SizedBox(width: 8),
              Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left, color: Color(0xFF3498db)),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right, color: Color(0xFF3498db)),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCalendar(),
          ),
        ),

        if (_selectedDate != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFf8f9fa),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF3498db), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ),
              ],
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedDate != null 
                ? () {
                    setState(() {});
                  } 
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 50),
              disabledBackgroundColor: const Color(0xFFbdc3c7),
            ),
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    final previousMonthDays = <String>[];
    if (firstWeekday != 1) {
      final prevMonthLastDay = DateTime(_currentMonth.year, _currentMonth.month, 0).day;
      for (int i = firstWeekday - 1; i > 0; i--) {
        previousMonthDays.add((prevMonthLastDay - i + 1).toString());
      }
    }

    final currentMonthDays = List.generate(daysInMonth, (i) => (i + 1).toString());
    final totalCells = ((previousMonthDays.length + daysInMonth) / 7).ceil() * 7;

    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Text('M', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('T', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('W', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('T', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('F', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('S', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('S', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 8),

        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              String dayText = '';
              bool isCurrentMonth = false;
              bool isAvailable = false;

              if (index < previousMonthDays.length) {
                dayText = previousMonthDays[index];
                isCurrentMonth = false;
              } else if (index < previousMonthDays.length + daysInMonth) {
                final day = int.parse(currentMonthDays[index - previousMonthDays.length]);
                dayText = day.toString();
                isCurrentMonth = true;
                
                final date = DateTime(_currentMonth.year, _currentMonth.month, day);
                final today = DateTime.now();
                final maxDate = DateTime.now().add(const Duration(days: 60));
                // Compare dates in local timezone
                final localToday = DateTime(today.year, today.month, today.day);
                final localDate = DateTime(date.year, date.month, date.day);
                isAvailable = localDate.isAfter(localToday.subtract(const Duration(days: 1))) && 
                             localDate.isBefore(maxDate);
              } else {
                dayText = (index - previousMonthDays.length - daysInMonth + 1).toString();
                isCurrentMonth = false;
              }

              final day = int.tryParse(dayText) ?? 0;
              final isSelected = _selectedDate?.day == day && 
                                 _selectedDate?.month == _currentMonth.month &&
                                 _selectedDate?.year == _currentMonth.year;

              return GestureDetector(
                onTap: isCurrentMonth && isAvailable
                    ? () {
                        setState(() {
                          _selectedDate = DateTime(
                            _currentMonth.year,
                            _currentMonth.month,
                            day,
                          );
                        });
                      }
                    : null,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF3498db)
                        : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      dayText,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isCurrentMonth && isAvailable
                                ? const Color(0xFF2c3e50)
                                : const Color(0xFFbdc3c7)),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      if (_selectedDate != null && 
          (_selectedDate!.month != _currentMonth.month || 
           _selectedDate!.year != _currentMonth.year)) {
        _selectedDate = null;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      if (_selectedDate != null && 
          (_selectedDate!.month != _currentMonth.month || 
           _selectedDate!.year != _currentMonth.year)) {
        _selectedDate = null;
      }
    });
  }

  Widget _buildTimeSelection(user) {
    final availableSlots = [
      '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
      '11:00 AM', '02:00 PM', '02:30 PM', '03:00 PM', '04:30 PM'
    ];

    return Column(
      children: [
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
                icon: const Icon(Icons.arrow_back, color: Color(0xFF3498db)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Available Slots for ${DateFormat('EEEE, MMMM d').format(_selectedDate!)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),

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
                  elevation: isSelected ? 4 : 1,
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedTime != null && !_isBooking 
                ? () => _showConfirmationDialog(user) 
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 50),
              disabledBackgroundColor: const Color(0xFFbdc3c7),
            ),
            child: _isBooking
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Confirm Appointment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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
            Text('Doctor: ${widget.doctor['name']}'),
            Text('Specialty: ${widget.specialty}'),
            Text('Date: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)}'),
            Text('Time: $_selectedSlot'),
            const Divider(),
            Text('Patient: ${user?.name ?? "User"}'),
            Text('Email: ${user?.email ?? "N/A"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _bookAppointment(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27ae60),
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  // Update the _bookAppointment method to check for duplicates:

Future<void> _bookAppointment(user) async {
  // Check for duplicate appointment first
  final isDuplicate = await _checkDuplicateAppointment(
    widget.doctor['id'],
    _selectedDate!,
    _selectedSlot!,
  );
  
  if (isDuplicate) return;

  setState(() {
    _isBooking = true;
  });

  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    
    if (token == null || token.isEmpty) {
      throw Exception('Please login again. Token not found.');
    }

    // Create date at midnight in local timezone
    final selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      0, 0, 0, 0, 0
    );
    
    // Convert to UTC for storage
    final utcDateTime = selectedDateTime.toUtc();

    final appointmentData = {
      'doctorId': widget.doctor['id'],
      'date': utcDateTime.toIso8601String(),
      'time': _selectedSlot!,
      'type': 'consultation',
      'symptoms': 'General Consultation',
    };

    print('Booking appointment with data: $appointmentData');

    final response = await http.post(
      Uri.parse(ApiConstants.appointments),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(appointmentData),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success']) {
        final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
        await appointmentProvider.loadAppointments();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment booked successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        throw Exception(data['message'] ?? 'Failed to book appointment');
      }
    } else {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Failed to book appointment');
    }
  } catch (e) {
    print('Error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isBooking = false;
      });
    }
  }
}
  // Add this method to check for duplicate appointments:

Future<bool> _checkDuplicateAppointment(String doctorId, DateTime date, String time) async {
  Provider.of<AuthProvider>(context, listen: false);
  final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
  
  // Check if user already has an appointment at the same date and time
  final existingAppointment = appointmentProvider.appointments.any((apt) {
    final aptDate = DateTime(apt.date.year, apt.date.month, apt.date.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    return apt.doctorId == doctorId && 
           aptDate.isAtSameMomentAs(selectedDate) && 
           apt.time == time &&
           apt.status != 'cancelled';
  });
  
  if (existingAppointment) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already have an appointment with this doctor at the same date and time!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
    return true; // Duplicate found
  }
  return false; // No duplicate
}
}
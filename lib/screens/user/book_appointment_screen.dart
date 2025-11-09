import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/utils/helpers.dart';

class BookAppointmentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> doctors;
  final Map<String, dynamic>? selectedDoctor;

  const BookAppointmentScreen({
    Key? key,
    required this.doctors,
    this.selectedDoctor,
  }) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  
  Map<String, dynamic>? _selectedDoctor;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDoctor = widget.selectedDoctor;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _bookAppointment() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDoctor == null) {
        Helpers.showSnackBar(context, 'Please select a doctor', isError: true);
        return;
      }
      if (_selectedDate == null) {
        Helpers.showSnackBar(context, 'Please select a date', isError: true);
        return;
      }
      if (_selectedTime == null) {
        Helpers.showSnackBar(context, 'Please select a time', isError: true);
        return;
      }

      // Here you would call the appointment provider to book the appointment
      Helpers.showSnackBar(
        context, 
        'Appointment booked with ${_selectedDoctor!['name']} on ${DateFormat('MMM dd, yyyy').format(_selectedDate!)} at ${_selectedTime!.format(context)}'
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Doctor Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Doctor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedDoctor != null)
                        _buildDoctorCard(_selectedDoctor!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          _showDoctorSelection();
                        },
                        child: const Text('Choose Doctor'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Date Selection
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Preferred Date',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedDate != null 
                      ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                      : ''
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              
              // Time Selection
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Preferred Time',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedTime != null 
                      ? _selectedTime!.format(context)
                      : ''
                ),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),
              
              // Symptoms
              TextFormField(
                controller: _symptomsController,
                decoration: const InputDecoration(
                  labelText: 'Symptoms/Reason for Visit',
                  border: OutlineInputBorder(),
                  hintText: 'Describe your symptoms or reason for appointment...',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe your symptoms';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Book Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27ae60),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF3498db).withValues(alpha: 0.1),
        child: Text(doctor['image']),
      ),
      title: Text(
        doctor['name'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(doctor['specialty']),
      trailing: Text(
        doctor['available'] ? 'Available' : 'Offline',
        style: TextStyle(
          color: doctor['available'] ? const Color(0xFF27ae60) : Colors.grey,
        ),
      ),
    );
  }

  void _showDoctorSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Select a Doctor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.doctors.length,
                itemBuilder: (context, index) {
                  final doctor = widget.doctors[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF3498db).withValues(alpha: 0.1),
                        child: Text(doctor['image']),
                      ),
                      title: Text(doctor['name']),
                      subtitle: Text(doctor['specialty']),
                      trailing: doctor['available'] 
                          ? const Icon(Icons.check_circle, color: Color(0xFF27ae60))
                          : const Icon(Icons.cancel, color: Colors.grey),
                      onTap: doctor['available'] ? () {
                        setState(() {
                          _selectedDoctor = doctor;
                        });
                        Navigator.pop(context);
                      } : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }
}
// lib/features/doctor/screens/events_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../data/providers/auth_provider.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _error;
  String _filterType = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Please login to view events';
          _isLoading = false;
        });
        return;
      }

      print('📡 Fetching health camps from: ${ApiConstants.healthCamps}');

      final response = await http.get(
        Uri.parse(ApiConstants.healthCamps),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null) {
          setState(() {
            _events = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
          print('✅ Loaded ${_events.length} events');
        } else {
          setState(() {
            _error = data['message'] ?? 'No events found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load events';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _createEvent(Map<String, dynamic> newEvent) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Please login to create event');
      }

      print('📝 Creating health camp: $newEvent');

      final response = await http.post(
        Uri.parse(ApiConstants.healthCamps),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(newEvent),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          await _fetchEvents(); // Refresh the list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event created successfully!'),
              backgroundColor: Color(0xFF27ae60),
            ),
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to create event');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to create event');
      }
    } catch (e) {
      print('Error creating event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateEvent(String id, Map<String, dynamic> updatedEvent) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Please login to update event');
      }

      print('📝 Updating health camp: $id');

      final response = await http.put(
        Uri.parse('${ApiConstants.healthCamps}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedEvent),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          await _fetchEvents(); // Refresh the list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event updated successfully!'),
              backgroundColor: Color(0xFF27ae60),
            ),
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to update event');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to update event');
      }
    } catch (e) {
      print('Error updating event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteEvent(String id) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Please login to delete event');
      }

      print('🗑️ Deleting health camp: $id');

      final response = await http.delete(
        Uri.parse('${ApiConstants.healthCamps}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          await _fetchEvents(); // Refresh the list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event deleted successfully'),
              backgroundColor: Color(0xFF27ae60),
            ),
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to delete event');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete event');
      }
    } catch (e) {
      print('Error deleting event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredEvents {
    List<Map<String, dynamic>> filtered = _events.where((event) {
      final matchesSearch = event['title']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      
      if (_filterType == 'upcoming') {
        final eventDate = DateTime.tryParse(event['date'] ?? '');
        final isUpcoming = eventDate != null && 
            eventDate.isAfter(DateTime.now().subtract(const Duration(days: 1)));
        return matchesSearch && isUpcoming;
      } else if (_filterType == 'past') {
        final eventDate = DateTime.tryParse(event['date'] ?? '');
        final isPast = eventDate != null && 
            eventDate.isBefore(DateTime.now());
        return matchesSearch && isPast;
      }
      
      return matchesSearch;
    }).toList();

    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(a['date'] ?? '');
      final dateB = DateTime.tryParse(b['date'] ?? '');
      
      if (dateA == null || dateB == null) return 0;
      return dateA.compareTo(dateB);
    });

    return filtered;
  }

  void _createNewEvent() {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        onSave: (newEvent) async {
          await _createEvent(newEvent);
        },
      ),
    );
  }

  void _editEvent(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        event: event,
        onSave: (updatedEvent) async {
          await _updateEvent(event['_id'], updatedEvent);
        },
      ),
    );
  }

  void _deleteEventConfirm(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(event['_id']);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFe74c3c),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sendReminder(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminders sent to ${event['registeredParticipants']} registered patients'),
        backgroundColor: const Color(0xFF27ae60),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewEvent,
        backgroundColor: const Color(0xFF27ae60),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchEvents,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Medical Events & Camps',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2c3e50),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Search Bar
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search events...',
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF7f8c8d)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFecf0f1),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          
                          // Filter Chips
                          Row(
                            children: [
                              FilterChip(
                                label: const Text('All Events'),
                                selected: _filterType == 'all',
                                onSelected: (selected) {
                                  setState(() {
                                    _filterType = selected ? 'all' : _filterType;
                                  });
                                },
                                selectedColor: const Color(0xFF3498db),
                                checkmarkColor: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Upcoming'),
                                selected: _filterType == 'upcoming',
                                onSelected: (selected) {
                                  setState(() {
                                    _filterType = selected ? 'upcoming' : _filterType;
                                  });
                                },
                                selectedColor: const Color(0xFF27ae60),
                                checkmarkColor: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Past'),
                                selected: _filterType == 'past',
                                onSelected: (selected) {
                                  setState(() {
                                    _filterType = selected ? 'past' : _filterType;
                                  });
                                },
                                selectedColor: const Color(0xFFe67e22),
                                checkmarkColor: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Stats Cards
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFFf8f9fa),
                      child: Row(
                        children: [
                          _buildStatCard('Total Events', _events.length, const Color(0xFF3498db)),
                          const SizedBox(width: 12),
                          _buildStatCard('Upcoming', 
                            _events.where((e) {
                              final date = DateTime.tryParse(e['date'] ?? '');
                              return date != null && date.isAfter(DateTime.now());
                            }).length, 
                            const Color(0xFF27ae60)),
                          const SizedBox(width: 12),
                          _buildStatCard('Total Registrations', 
                            _events.fold<int>(0, (sum, event) => sum + ((event['registeredParticipants'] as int?) ?? 0)),
                            const Color(0xFFe67e22)),
                        ],
                      ),
                    ),

                    // Events List
                    Expanded(
                      child: _filteredEvents.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredEvents.length,
                              itemBuilder: (context, index) => _buildEventCard(_filteredEvents[index]),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final eventDate = DateTime.tryParse(event['date'] ?? '');
    final isPast = eventDate != null && eventDate.isBefore(DateTime.now());
    final isToday = eventDate != null && 
        eventDate.year == DateTime.now().year &&
        eventDate.month == DateTime.now().month &&
        eventDate.day == DateTime.now().day;

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
            // Header with title and status
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
                Row(
                  children: [
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFe74c3c).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'TODAY',
                          style: TextStyle(
                            color: Color(0xFFe74c3c),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (isPast)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7f8c8d).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PAST',
                          style: TextStyle(
                            color: Color(0xFF7f8c8d),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27ae60).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'UPCOMING',
                          style: TextStyle(
                            color: Color(0xFF27ae60),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498db).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${event['registeredParticipants'] ?? 0} Registered',
                        style: const TextStyle(
                          color: Color(0xFF3498db),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Event Details
            _buildEventDetail(Icons.calendar_today, 
                eventDate != null ? DateFormat('EEEE, MMMM d, yyyy').format(eventDate) : 'No date', 
                event['time'] ?? 'No time specified'),
            const SizedBox(height: 8),
            _buildEventDetail(Icons.location_on, event['location'] ?? 'No location'),
            const SizedBox(height: 8),
            if (event['description'] != null && event['description'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventDetail(Icons.description, event['description']),
                  const SizedBox(height: 8),
                ],
              ),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isPast) ...[
                  ElevatedButton(
                    onPressed: () => _sendReminder(event),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498db),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Send Reminder'),
                  ),
                ],
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _editEvent(event),
                      icon: const Icon(Icons.edit, color: Color(0xFF3498db)),
                      tooltip: 'Edit Event',
                    ),
                    IconButton(
                      onPressed: () => _deleteEventConfirm(event),
                      icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                      tooltip: 'Delete Event',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetail(IconData icon, String text, [String? subText]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7f8c8d)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(color: Color(0xFF2c3e50)),
              ),
              if (subText != null)
                Text(
                  subText,
                  style: const TextStyle(
                    color: Color(0xFF7f8c8d),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event,
            size: 80,
            color: const Color(0xFFbdc3c7).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Events Created',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF7f8c8d),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Create your first medical event or health camp to get started.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF95a5a6),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _createNewEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27ae60),
              foregroundColor: Colors.white,
            ),
            child: const Text('Create First Event'),
          ),
        ],
      ),
    );
  }
}

// Event Dialog for Create/Edit
class EventDialog extends StatefulWidget {
  final Map<String, dynamic>? event;
  final Function(Map<String, dynamic>) onSave;

  const EventDialog({
    Key? key,
    this.event,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _servicesController = TextEditingController();
  final _contactController = TextEditingController();
  final _slotsController = TextEditingController();
  final _feeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isFree = true;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!['title'] ?? '';
      _descriptionController.text = widget.event!['description'] ?? '';
      _locationController.text = widget.event!['location'] ?? '';
      _servicesController.text = (widget.event!['services'] as List? ?? []).join(', ');
      _contactController.text = widget.event!['contact'] ?? '';
      _slotsController.text = (widget.event!['availableSlots'] ?? 100).toString();
      _selectedDate = DateTime.tryParse(widget.event!['date'] ?? '');
      _isFree = widget.event!['isFree'] ?? true;
      if (!_isFree && widget.event!['fee'] != null) {
        _feeController.text = widget.event!['fee'].toString();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _servicesController.dispose();
    _contactController.dispose();
    _slotsController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final services = _servicesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      
      final event = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'date': _selectedDate != null ? _selectedDate!.toIso8601String() : DateTime.now().toIso8601String(),
        'time': _selectedTime != null ? _selectedTime!.format(context) : '9:00 AM - 5:00 PM',
        'services': services,
        'contact': _contactController.text,
        'availableSlots': int.parse(_slotsController.text),
        'isFree': _isFree,
        'organization': 'Seva Pulse Hospital',
      };
      
      if (!_isFree && _feeController.text.isNotEmpty) {
        event['fee'] = int.parse(_feeController.text);
      }
      
      widget.onSave(event);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event == null ? 'Create New Event' : 'Edit Event'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Free Diabetes Screening Camp',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  hintText: 'Describe the event purpose and activities...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Hospital Campus, Conference Hall',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Date and Time Selection
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date *',
                        border: const OutlineInputBorder(),
                        hintText: _selectedDate == null 
                            ? 'Select date' 
                            : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                        suffixIcon: IconButton(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today),
                        ),
                      ),
                      validator: (value) {
                        if (_selectedDate == null) {
                          return 'Please select event date';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Time',
                        border: const OutlineInputBorder(),
                        hintText: _selectedTime == null 
                            ? 'Select time' 
                            : _selectedTime!.format(context),
                        suffixIcon: IconButton(
                          onPressed: _selectTime,
                          icon: const Icon(Icons.access_time),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _servicesController,
                decoration: const InputDecoration(
                  labelText: 'Services (comma separated) *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., ECG, BP Check, Blood Test',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter at least one service';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., +91-9876543210',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slotsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Available Slots *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 100',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter available slots';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Is this camp free?'),
                  const SizedBox(width: 16),
                  Switch(
                    value: _isFree,
                    onChanged: (value) {
                      setState(() {
                        _isFree = value;
                      });
                    },
                    activeColor: const Color(0xFF27ae60),
                  ),
                  const SizedBox(width: 8),
                  Text(_isFree ? 'FREE' : 'PAID'),
                ],
              ),
              if (!_isFree) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fee (in ₹) *',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 500',
                  ),
                  validator: (value) {
                    if (!_isFree && (value == null || value.isEmpty)) {
                      return 'Please enter fee amount';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveEvent,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF27ae60),
          ),
          child: Text(widget.event == null ? 'Create Event' : 'Update Event'),
        ),
      ],
    );
  }
}
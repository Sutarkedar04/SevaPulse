import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  late List<Map<String, dynamic>> _events;
  String _filterType = 'all'; // 'all', 'upcoming', 'past'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _events = List.from(widget.medicalEvents);
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

    // Sort by date (upcoming first)
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
        onSave: (newEvent) {
          setState(() {
            _events.add({
              ...newEvent,
              'id': DateTime.now().millisecondsSinceEpoch,
              'registeredPatients': 0,
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event created successfully!'),
              backgroundColor: Color(0xFF27ae60),
            ),
          );
        },
      ),
    );
  }

  void _editEvent(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        event: event,
        onSave: (updatedEvent) {
          setState(() {
            final index = _events.indexWhere((e) => e['id'] == event['id']);
            if (index != -1) {
              _events[index] = {
                ..._events[index],
                ...updatedEvent,
              };
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event updated successfully!'),
              backgroundColor: Color(0xFF27ae60),
            ),
          );
        },
      ),
    );
  }

  void _deleteEvent(Map<String, dynamic> event) {
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
              setState(() {
                _events.removeWhere((e) => e['id'] == event['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event deleted successfully'),
                  backgroundColor: Color(0xFFe74c3c),
                ),
              );
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
        content: Text('Reminders sent to ${event['registeredPatients']} registered patients'),
        backgroundColor: const Color(0xFF27ae60),
      ),
    );
  }

  void _viewRegistrations(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registrations - ${event['title']}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: event['registeredPatients'] ?? 0,
            itemBuilder: (context, index) => ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF3498db).withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: Color(0xFF3498db)),
              ),
              title: Text('Patient ${index + 1}'),
              subtitle: Text('Registered on ${DateFormat('MMM dd, yyyy').format(DateTime.now())}'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
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
                      onPressed: _createNewEvent,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Event'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27ae60),
                        foregroundColor: Colors.white,
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
                  _events.fold<int>(0, (sum, event) => sum + (event['registeredPatients'] ?? 0) as int),
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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
                          color: const Color(0xFFe74c3c).withValues(alpha: 0.1),
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
                          color: const Color(0xFF7f8c8d).withValues(alpha: 0.1),
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
                          color: const Color(0xFF27ae60).withValues(alpha: 0.1),
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
                        color: const Color(0xFF3498db).withValues(alpha: 0.1),
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
                  ElevatedButton(
                    onPressed: () => _viewRegistrations(event),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe67e22),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('View Registrations'),
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
                      onPressed: () => _deleteEvent(event),
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
            color: const Color(0xFFbdc3c7).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No Events Created' : 'No Events Found',
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF7f8c8d),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _searchQuery.isEmpty
                  ? 'Create your first medical event or health camp to get started.'
                  : 'No events found for "$_searchQuery". Try a different search term.',
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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!['title'] ?? '';
      _descriptionController.text = widget.event!['description'] ?? '';
      _locationController.text = widget.event!['location'] ?? '';
      _selectedDate = DateTime.tryParse(widget.event!['date'] ?? '');
      // Parse time if available
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
      final event = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'date': _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '',
        'time': _selectedTime != null ? _selectedTime!.format(context) : '',
      };
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
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Describe the event purpose and activities...',
                ),
                maxLines: 3,
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

// Add DateFormat import at the top

import 'package:flutter/material.dart';

class MyMedicineScreen extends StatefulWidget {
  const MyMedicineScreen({Key? key}) : super(key: key);

  @override
  State<MyMedicineScreen> createState() => _MyMedicineScreenState();
}

class _MyMedicineScreenState extends State<MyMedicineScreen> {
  // Data
  final List<Map<String, dynamic>> _medicines = [];
  final List<String> _scheduleOptions = [
    'Once a day', 
    'Twice a day', 
    'Three times a day', 
    'Four times a day', 
    'Custom'
  ];

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  // State
  List<TimeOfDay> _selectedTimes = [];

  // ==================== STATS & CALCULATIONS ====================
  Map<String, int> get _stats {
    int totalDoses = 0;
    int completedDoses = 0;
    
    for (var medicine in _medicines) {
      totalDoses += (medicine['time'] as List).length;
      completedDoses += (medicine['taken'] as List<bool>).where((taken) => taken).length;
    }
    
    return {
      'total': totalDoses,
      'completed': completedDoses,
      'pending': totalDoses - completedDoses,
    };
  }

  String _calculateRemainingDays(String startDate, String endDate) {
    if (endDate == 'Ongoing' || endDate == 'Not set') return 'Ongoing';
    
    try {
      final end = DateTime.parse(endDate);
      final now = DateTime.now();
      final difference = end.difference(now).inDays;
      
      if (difference < 0) return 'Completed';
      if (difference == 0) return 'Last day';
      return '$difference days left';
    } catch (e) {
      return 'Ongoing';
    }
  }

  // ==================== FORM MANAGEMENT ====================
  void _resetForm() {
    _nameController.clear();
    _dosageController.clear();
    _scheduleController.clear();
    _instructionsController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _selectedTimes.clear();
  }

  String _getStringValue(dynamic value) {
    return value?.toString() ?? '';
  }

  void _updateTimesBasedOnSchedule(String schedule) {
    _selectedTimes.clear();
    switch (schedule) {
      case 'Once a day':
        _selectedTimes.add(const TimeOfDay(hour: 8, minute: 0));
        break;
      case 'Twice a day':
        _selectedTimes.addAll([
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ]);
        break;
      case 'Three times a day':
        _selectedTimes.addAll([
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ]);
        break;
      case 'Four times a day':
        _selectedTimes.addAll([
          const TimeOfDay(hour: 6, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 18, minute: 0),
          const TimeOfDay(hour: 22, minute: 0),
        ]);
        break;
    }
  }

  // ==================== DATE & TIME MANAGEMENT ====================
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _selectTime(BuildContext context, Function setDialogState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setDialogState(() {
        _selectedTimes.add(picked);
        _selectedTimes.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // ==================== MEDICINE CRUD OPERATIONS ====================
  void _addMedicine() {
    _resetForm();
    _showMedicineDialog(isEditing: false);
  }

  void _editMedicine(int index) {
    final medicine = _medicines[index];
    _nameController.text = _getStringValue(medicine['name']);
    _dosageController.text = _getStringValue(medicine['dosage']);
    _scheduleController.text = _getStringValue(medicine['schedule']);
    _instructionsController.text = _getStringValue(medicine['instructions']);
    _startDateController.text = _getStringValue(medicine['startDate']);
    _endDateController.text = _getStringValue(medicine['endDate']);
    
    _selectedTimes = (medicine['time'] as List<String>).map((timeStr) {
      final timeParts = timeStr.split(' ');
      final hourMinute = timeParts[0].split(':');
      final isPM = timeParts[1] == 'PM';
      int hour = int.parse(hourMinute[0]);
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: int.parse(hourMinute[1]));
    }).toList();

    _showMedicineDialog(isEditing: true, index: index);
  }

  void _deleteMedicine(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text('Are you sure you want to delete ${_medicines[index]['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _medicines.removeAt(index));
              Navigator.pop(context);
              _showSnackBar('Medicine deleted successfully', Colors.green);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveMedicine({bool isEditing = false, int? index}) {
    if (_nameController.text.isEmpty || 
        _dosageController.text.isEmpty || 
        _scheduleController.text.isEmpty ||
        _selectedTimes.isEmpty) {
      _showSnackBar('Please fill all required fields', Colors.red);
      return;
    }

    final newMedicine = {
      'id': isEditing ? _medicines[index!]['id'] : DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _nameController.text,
      'dosage': _dosageController.text,
      'schedule': _scheduleController.text,
      'time': _selectedTimes.map(_formatTimeOfDay).toList(),
      'taken': List.filled(_selectedTimes.length, false),
      'startDate': _startDateController.text.isEmpty ? 'Not set' : _startDateController.text,
      'endDate': _endDateController.text.isEmpty ? 'Not set' : _endDateController.text,
      'remaining': _calculateRemainingDays(_startDateController.text, _endDateController.text),
      'instructions': _instructionsController.text.isEmpty ? 'No special instructions' : _instructionsController.text,
    };

    setState(() {
      if (isEditing && index != null) {
        _medicines[index] = newMedicine;
      } else {
        _medicines.add(newMedicine);
      }
    });

    _resetForm();
    _showSnackBar(
      isEditing ? 'Medicine updated successfully' : 'Medicine added successfully', 
      Colors.green
    );
  }

  // ==================== DOSE MANAGEMENT ====================
  void _toggleDose(int medicineIndex, int doseIndex) {
    setState(() {
      _medicines[medicineIndex]['taken'][doseIndex] = 
          !_medicines[medicineIndex]['taken'][doseIndex];
    });
  }

  void _markAllAsTaken(int medicineIndex) {
    setState(() {
      for (int i = 0; i < (_medicines[medicineIndex]['taken'] as List).length; i++) {
        _medicines[medicineIndex]['taken'][i] = true;
      }
    });
  }

  // ==================== DIALOGS & SNACKBARS ====================
  void _showMedicineDialog({bool isEditing = false, int? index}) {
    String? currentScheduleValue = _scheduleController.text.isEmpty ? null : _scheduleController.text;
    if (currentScheduleValue != null && !_scheduleOptions.contains(currentScheduleValue)) {
      currentScheduleValue = null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Medicine' : 'Add New Medicine'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFormField(_nameController, 'Medicine Name'),
                  const SizedBox(height: 16),
                  _buildFormField(_dosageController, 'Dosage (e.g., 500mg, 10ml)'),
                  const SizedBox(height: 16),
                  _buildScheduleDropdown(currentScheduleValue, setDialogState),
                  const SizedBox(height: 16),
                  _buildFormField(_instructionsController, 'Instructions (optional)', maxLines: 2),
                  const SizedBox(height: 16),
                  _buildDateFields(),
                  const SizedBox(height: 16),
                  _buildTimeSection(setDialogState),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _saveMedicine(isEditing: isEditing, index: index);
                  Navigator.pop(context);
                },
                child: Text(isEditing ? 'Update' : 'Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // ==================== UI COMPONENTS ====================
  Widget _buildFormField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildScheduleDropdown(String? value, Function setDialogState) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Schedule',
        border: OutlineInputBorder(),
      ),
      items: _scheduleOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setDialogState(() {
          _scheduleController.text = value!;
          _updateTimesBasedOnSchedule(value);
        });
      },
    );
  }

  Widget _buildDateFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _startDateController,
            decoration: const InputDecoration(
              labelText: 'Start Date',
              border: OutlineInputBorder(),
            ),
            onTap: () => _selectDate(context, _startDateController),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _endDateController,
            decoration: const InputDecoration(
              labelText: 'End Date',
              border: OutlineInputBorder(),
            ),
            onTap: () => _selectDate(context, _endDateController),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection(Function setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dose Times',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF3498db)),
              onPressed: () => _selectTime(context, setDialogState),
            ),
          ],
        ),
        ..._selectedTimes.asMap().entries.map((entry) {
          final idx = entry.key;
          final time = entry.value;
          return ListTile(
            leading: const Icon(Icons.access_time, color: Color(0xFF3498db)),
            title: Text(_formatTimeOfDay(time)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setDialogState(() => _selectedTimes.removeAt(idx)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF3498db), size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2c3e50),
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d)),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine, int medicineIndex) {
    final takenList = medicine['taken'] as List<bool>? ?? [];
    final allTaken = takenList.every((taken) => taken);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMedicineHeader(medicine, medicineIndex),
            const SizedBox(height: 8),
            _buildMedicineStatus(medicine, allTaken),
            const SizedBox(height: 12),
            _buildDoseTimes(medicine, medicineIndex, takenList),
            const SizedBox(height: 8),
            _buildCourseDuration(medicine),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineHeader(Map<String, dynamic> medicine, int medicineIndex) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medicine['name']?.toString() ?? 'Unknown Medicine',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2c3e50)),
              ),
              Text(
                '${medicine['dosage']?.toString() ?? ''} • ${medicine['schedule']?.toString() ?? ''}',
                style: const TextStyle(color: Color(0xFF7f8c8d)),
              ),
            ],
          ),
        ),
        _buildMedicineMenu(medicineIndex),
      ],
    );
  }

  Widget _buildMedicineMenu(int medicineIndex) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Color(0xFF7f8c8d)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit Medicine')),
        const PopupMenuItem(value: 'mark_all', child: Text('Mark All as Taken')),
        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
      ],
      onSelected: (value) => _handleMenuAction(value, medicineIndex),
    );
  }

  void _handleMenuAction(String value, int medicineIndex) {
    switch (value) {
      case 'edit':
        _editMedicine(medicineIndex);
        break;
      case 'mark_all':
        _markAllAsTaken(medicineIndex);
        break;
      case 'delete':
        _deleteMedicine(medicineIndex);
        break;
    }
  }

  Widget _buildMedicineStatus(Map<String, dynamic> medicine, bool allTaken) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: allTaken ? const Color(0xFF27ae60).withValues(alpha: 0.1) : const Color(0xFF3498db).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            medicine['remaining']?.toString() ?? 'Unknown',
            style: TextStyle(
              color: allTaken ? const Color(0xFF27ae60) : const Color(0xFF3498db),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (_hasInstructions(medicine))
          Expanded(
            child: Text(
              medicine['instructions']?.toString() ?? '',
              style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d), fontStyle: FontStyle.italic),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  bool _hasInstructions(Map<String, dynamic> medicine) {
    final instructions = medicine['instructions']?.toString() ?? '';
    return instructions.isNotEmpty && instructions != 'No special instructions';
  }

  Widget _buildDoseTimes(Map<String, dynamic> medicine, int medicineIndex, List<bool> takenList) {
    final timeList = medicine['time'] as List<String>;
    return Column(
      children: List.generate(timeList.length, (doseIndex) {
        final isTaken = doseIndex < takenList.length ? takenList[doseIndex] : false;
        final time = doseIndex < timeList.length ? timeList[doseIndex] : 'Unknown Time';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFf8f9fa),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isTaken ? const Color(0xFF27ae60).withValues(alpha: 0.3) : const Color(0xFFecf0f1)),
          ),
          child: Row(
            children: [
              Checkbox(
                value: isTaken,
                onChanged: (value) => _toggleDose(medicineIndex, doseIndex),
                activeColor: const Color(0xFF27ae60),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isTaken ? const Color(0xFF27ae60) : const Color(0xFF2c3e50),
                        decoration: isTaken ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                    if (doseIndex == 0 && _hasInstructions(medicine))
                      Text(
                        medicine['instructions']?.toString() ?? '',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d)),
                      ),
                  ],
                ),
              ),
              _buildDoseStatus(isTaken),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDoseStatus(bool isTaken) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTaken ? const Color(0xFF27ae60).withValues(alpha: 0.1) : const Color(0xFF3498db).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isTaken ? 'Taken' : 'Pending',
        style: TextStyle(
          color: isTaken ? const Color(0xFF27ae60) : const Color(0xFF3498db),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCourseDuration(Map<String, dynamic> medicine) {
    return Text(
      'Course: ${medicine['startDate']?.toString() ?? 'Not set'} to ${medicine['endDate']?.toString() ?? 'Not set'}',
      style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d)),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication, size: 64, color: Color(0xFFbdc3c7)),
          SizedBox(height: 16),
          Text('No medicines added yet', style: TextStyle(fontSize: 18, color: Color(0xFF7f8c8d))),
          SizedBox(height: 8),
          Text('Tap the + button to add your first medicine', style: TextStyle(color: Color(0xFFbdc3c7))),
        ],
      ),
    );
  }

  Widget _buildChatBot() {
    return Container(
      height: 55,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3498db),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.smart_toy, color: Color(0xFF3498db)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Medicine Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Tap to ask about your medications',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () {
              // Handle chat bot tap
              _showSnackBar('Chat bot feature coming soon!', const Color(0xFF3498db));
            },
          ),
        ],
      ),
    );
  }

  // ==================== MAIN BUILD METHOD ====================
  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF3498db),
            child: const Row(
              children: [
                Icon(Icons.medical_services, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'My Medicine Tracker',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),

          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFf8f9fa),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Doses', stats['total'].toString(), Icons.medication),
                _buildStatItem('Completed', stats['completed'].toString(), Icons.check_circle),
                _buildStatItem('Pending', stats['pending'].toString(), Icons.schedule),
              ],
            ),
          ),

          // Medicine List with Add Button
          Expanded(
            child: Stack(
              children: [
                // Medicine List
                _medicines.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _medicines.length,
                        itemBuilder: (context, index) => _buildMedicineCard(_medicines[index], index),
                      ),

                // Add Medicine Button - Positioned on right side above chat bot
                Positioned(
                  bottom: 40, // Position above the chat bot
                  right: 16,  // Position on the right side
                  child: FloatingActionButton(
                    onPressed: _addMedicine,
                    backgroundColor: const Color(0xFF3498db),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Chat Bot
          _buildChatBot(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _scheduleController.dispose();
    _instructionsController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
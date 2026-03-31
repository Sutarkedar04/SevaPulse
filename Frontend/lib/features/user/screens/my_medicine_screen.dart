import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/medicine_provider.dart';

class MyMedicineScreen extends StatefulWidget {
  const MyMedicineScreen({Key? key}) : super(key: key);

  @override
  State<MyMedicineScreen> createState() => _MyMedicineScreenState();
}

class _MyMedicineScreenState extends State<MyMedicineScreen> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  // State
  List<TimeOfDay> _selectedTimes = [];
  List<String> _scheduleOptions = [
    'Once a day', 
    'Twice a day', 
    'Three times a day', 
    'Four times a day', 
    'Custom'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
      
      if (authProvider.token != null) {
        medicineProvider.setToken(authProvider.token!);
        medicineProvider.loadMedicines();
      }
    });
  }

  // Get stats
  Map<String, int> _getStats(List<Map<String, dynamic>> medicines) {
    int totalDoses = 0;
    int completedDoses = 0;
    
    for (var medicine in medicines) {
      final times = medicine['times'] as List? ?? [];
      final taken = medicine['taken'] as List? ?? [];
      totalDoses += times.length;
      completedDoses += taken.where((t) => t == true).length;
    }
    
    return {
      'total': totalDoses,
      'completed': completedDoses,
      'pending': totalDoses - completedDoses,
    };
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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

  Future<void> _selectDate(TextEditingController controller) async {
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

  void _addMedicine() async {
    _nameController.clear();
    _dosageController.clear();
    _scheduleController.clear();
    _instructionsController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _selectedTimes.clear();
    
    await _showMedicineDialog(isEditing: false);
  }

  Future<void> _editMedicine(Map<String, dynamic> medicine, int index) async {
    _nameController.text = medicine['name'] ?? '';
    _dosageController.text = medicine['dosage'] ?? '';
    _scheduleController.text = medicine['schedule'] ?? '';
    _instructionsController.text = medicine['instructions'] ?? 'No special instructions';
    _startDateController.text = medicine['startDate'] ?? '';
    _endDateController.text = medicine['endDate'] ?? '';
    
    _selectedTimes = (medicine['times'] as List? ?? []).map((timeStr) {
      final timeParts = timeStr.split(' ');
      final hourMinute = timeParts[0].split(':');
      final isPM = timeParts[1] == 'PM';
      int hour = int.parse(hourMinute[0]);
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: int.parse(hourMinute[1]));
    }).toList();

    await _showMedicineDialog(isEditing: true, medicineId: medicine['id'], index: index);
  }

  Future<void> _showMedicineDialog({bool isEditing = false, String? medicineId, int? index}) async {
    String? currentScheduleValue = _scheduleController.text.isEmpty ? null : _scheduleController.text;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Medicine' : 'Add New Medicine'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosage (e.g., 500mg, 10ml)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: currentScheduleValue,
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Instructions (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _startDateController,
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                          ),
                          onTap: () => _selectDate(_startDateController),
                          readOnly: true,
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
                          onTap: () => _selectDate(_endDateController),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
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
                            icon: const Icon(Icons.add_circle, color: Color(0xFF3498db), size: 30),
                            onPressed: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  _selectedTimes.add(picked);
                                  _selectedTimes.sort((a, b) => 
                                    (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_selectedTimes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No times added. Tap + to add dose times.',
                            style: TextStyle(color: Color(0xFF7f8c8d)),
                          ),
                        )
                      else
                        ..._selectedTimes.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final time = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFf8f9fa),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: Color(0xFF3498db)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _formatTimeOfDay(time),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => setDialogState(() => _selectedTimes.removeAt(idx)),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isEmpty) {
                    _showSnackBar('Please enter medicine name', Colors.red);
                    return;
                  }
                  if (_dosageController.text.isEmpty) {
                    _showSnackBar('Please enter dosage', Colors.red);
                    return;
                  }
                  if (_selectedTimes.isEmpty) {
                    _showSnackBar('Please add at least one dose time', Colors.red);
                    return;
                  }
                  
                  Navigator.pop(context);
                  
                  final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
                  final medicineData = {
                    'name': _nameController.text,
                    'dosage': _dosageController.text,
                    'schedule': _scheduleController.text.isNotEmpty ? _scheduleController.text : 'Custom',
                    'times': _selectedTimes.map(_formatTimeOfDay).toList(),
                    'taken': List.filled(_selectedTimes.length, false),
                    'startDate': _startDateController.text.isEmpty ? 'Not set' : _startDateController.text,
                    'endDate': _endDateController.text.isEmpty ? 'Not set' : _endDateController.text,
                    'instructions': _instructionsController.text.isEmpty ? 'No special instructions' : _instructionsController.text,
                    'remaining': _calculateRemainingDays(_startDateController.text, _endDateController.text),
                  };
                  
                  bool success;
                  if (isEditing && medicineId != null) {
                    success = await medicineProvider.updateMedicine(medicineId, medicineData);
                  } else {
                    success = await medicineProvider.addMedicine(medicineData);
                  }
                  
                  if (success && mounted) {
                    _showSnackBar(isEditing ? 'Medicine updated successfully' : 'Medicine added successfully', Colors.green);
                  } else if (mounted) {
                    _showSnackBar(medicineProvider.error ?? 'Failed to save medicine', Colors.red);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27ae60),
                ),
                child: Text(isEditing ? 'Update' : 'Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _calculateRemainingDays(String startDate, String endDate) {
    if (endDate == 'Not set') return 'Ongoing';
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

  void _toggleDose(String id, int doseIndex) async {
    final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
    final success = await medicineProvider.toggleDose(id, doseIndex);
    if (!success && mounted) {
      _showSnackBar(medicineProvider.error ?? 'Failed to update dose', Colors.red);
    }
  }

  void _deleteMedicine(String id) async {
    if (id.isEmpty) {
      _showSnackBar('Cannot delete: Invalid medicine ID', Colors.red);
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: const Text('Are you sure you want to delete this medicine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
              final success = await medicineProvider.deleteMedicine(id);
              
              if (success && mounted) {
                _showSnackBar('Medicine deleted successfully', Colors.green);
              } else if (mounted) {
                _showSnackBar(medicineProvider.error ?? 'Failed to delete medicine', Colors.red);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MedicineProvider>(
        builder: (context, medicineProvider, child) {
          final medicines = medicineProvider.medicines;
          final stats = _getStats(medicines);
          
          return Column(
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

              // Medicine List or Empty State with Centered Button
              Expanded(
                child: medicineProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : medicines.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.medication, size: 80, color: const Color(0xFFbdc3c7)),
                                const SizedBox(height: 20),
                                const Text(
                                  'No medicines added yet',
                                  style: TextStyle(fontSize: 18, color: Color(0xFF7f8c8d)),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Start tracking your medications',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF95a5a6)),
                                ),
                                const SizedBox(height: 30),
                                ElevatedButton.icon(
                                  onPressed: _addMedicine,
                                  icon: const Icon(Icons.add, size: 20),
                                  label: const Text(
                                    'Add Your First Medicine',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3498db),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: medicines.length,
                            itemBuilder: (context, index) {
                              final medicine = medicines[index];
                              return _buildMedicineCard(medicine, index);
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<MedicineProvider>(
        builder: (context, medicineProvider, child) {
          if (medicineProvider.medicines.isNotEmpty) {
            return FloatingActionButton(
              onPressed: _addMedicine,
              backgroundColor: const Color(0xFF3498db),
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF3498db), size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2c3e50)),
        ),
        Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d))),
      ],
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine, int index) {
    final times = List<String>.from(medicine['times'] ?? []);
    final taken = List<bool>.from(medicine['taken'] ?? []);
    final allTaken = taken.isNotEmpty && taken.every((t) => t);
    final medicineId = medicine['id']?.toString() ?? '';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine['name'] ?? 'Unknown Medicine',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2c3e50)),
                      ),
                      Text(
                        '${medicine['dosage'] ?? ''} • ${medicine['schedule'] ?? ''}',
                        style: const TextStyle(color: Color(0xFF7f8c8d)),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF7f8c8d)),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Medicine')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editMedicine(medicine, index);
                    } else if (value == 'delete') {
                      _deleteMedicine(medicineId);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: allTaken ? const Color(0xFF27ae60).withOpacity(0.1) : const Color(0xFF3498db).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    medicine['remaining'] ?? 'Ongoing',
                    style: TextStyle(
                      color: allTaken ? const Color(0xFF27ae60) : const Color(0xFF3498db),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    medicine['instructions'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d), fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...times.asMap().entries.map((entry) {
              final doseIndex = entry.key;
              final time = entry.value;
              final isTaken = doseIndex < taken.length ? taken[doseIndex] : false;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8f9fa),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isTaken ? const Color(0xFF27ae60).withOpacity(0.3) : const Color(0xFFecf0f1)),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isTaken,
                      onChanged: (value) => _toggleDose(medicineId, doseIndex),
                      activeColor: const Color(0xFF27ae60),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isTaken ? const Color(0xFF27ae60) : const Color(0xFF2c3e50),
                          decoration: isTaken ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isTaken ? const Color(0xFF27ae60).withOpacity(0.1) : const Color(0xFF3498db).withOpacity(0.1),
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
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              'Course: ${medicine['startDate'] ?? 'Not set'} to ${medicine['endDate'] ?? 'Not set'}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d)),
            ),
          ],
        ),
      ),
    );
  }
}
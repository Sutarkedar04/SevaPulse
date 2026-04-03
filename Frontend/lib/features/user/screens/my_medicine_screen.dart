import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/medicine_provider.dart';

class MyMedicineScreen extends StatefulWidget {
  const MyMedicineScreen({Key? key}) : super(key: key);

  @override
  State<MyMedicineScreen> createState() => _MyMedicineScreenState();
}

class _MyMedicineScreenState extends State<MyMedicineScreen> with SingleTickerProviderStateMixin {
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

  // Track selected medicine for streak view
  
  // Animation controllers - Initialize properly
  late AnimationController _streakAnimationController;

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers
    _streakAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
      
      if (authProvider.token != null) {
        medicineProvider.setToken(authProvider.token!);
        medicineProvider.loadMedicines();
      }
    });
  }

  @override
  void dispose() {
    _streakAnimationController.dispose();
    super.dispose();
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
      'streak': _calculateStreak(medicines),
    };
  }

  int _calculateStreak(List<Map<String, dynamic>> medicines) {
    // Simplified streak calculation based on today's doses
    int completedToday = 0;
    int totalToday = 0;
    
    for (var medicine in medicines) {
      final times = medicine['times'] as List? ?? [];
      final taken = medicine['taken'] as List? ?? [];
      totalToday += times.length;
      completedToday += taken.where((t) => t == true).length;
    }
    
    // If all doses taken today, streak continues
    if (totalToday > 0 && completedToday == totalToday) {
      return 1; // Return 1 for today's streak
    }
    return 0;
  }

  void _showStreakDetails(Map<String, dynamic> medicine) async {
    setState(() {
    });
    _streakAnimationController.forward();
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Medicine Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        medicine['name'] ?? 'Medicine',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${medicine['dosage']} • ${medicine['schedule']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Streak Counter
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3498db), Color(0xFF2ecc71)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_calculateMedicineStreak(medicine)} Day Streak!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep taking your medicine daily',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Monthly Calendar View
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'March 2026',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      Text(
                        'Streak Tracker',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Calendar Grid
                Expanded(
                  child: _buildMonthlyCalendar(medicine),
                ),
                
                const SizedBox(height: 20),
                
                // Close Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498db),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      _streakAnimationController.reset();
      setState(() {
      });
    });
  }

  int _calculateMedicineStreak(Map<String, dynamic> medicine) {
    final taken = medicine['taken'] as List? ?? [];
    
    if (taken.isEmpty) return 0;
    
    // Count consecutive completed doses
    int streak = 0;
    for (int i = taken.length - 1; i >= 0; i--) {
      if (taken[i] == true) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  Widget _buildMonthlyCalendar(Map<String, dynamic> medicine) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = firstDay.weekday;
    
    // Sample taken dates based on medicine's taken status
    final takenDates = _getTakenDatesForMedicine(medicine);
    
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 35, // 5 rows x 7 days
      itemBuilder: (context, index) {
        final day = index - firstWeekday + 2;
        if (day < 1 || day > daysInMonth) {
          return const SizedBox.shrink();
        }
        
        final date = DateTime(now.year, now.month, day);
        final isTaken = takenDates.contains(date);
        final isToday = date.day == now.day && date.month == now.month;
        
        return Container(
          decoration: BoxDecoration(
            color: isTaken 
                ? const Color(0xFF27ae60).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isToday ? Border.all(color: const Color(0xFF3498db), width: 2) : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isTaken ? FontWeight.bold : FontWeight.normal,
                    color: isTaken ? const Color(0xFF27ae60) : const Color(0xFF2c3e50),
                  ),
                ),
                if (isTaken)
                  const Icon(
                    Icons.check_circle,
                    size: 12,
                    color: Color(0xFF27ae60),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DateTime> _getTakenDatesForMedicine(Map<String, dynamic> medicine) {
    final taken = medicine['taken'] as List? ?? [];
    final now = DateTime.now();
    final dates = <DateTime>[];
    
    // If all doses taken, show today as taken
    if (taken.isNotEmpty && taken.every((t) => t == true)) {
      dates.add(now);
    }
    
    // Add some sample past dates for demonstration
    for (int i = 1; i <= 3; i++) {
      if (taken.isNotEmpty && taken.length >= i) {
        dates.add(now.subtract(Duration(days: i)));
      }
    }
    
    return dates;
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
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
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
              // Header with Add Button on Top
              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3498db), Color(0xFF2980b9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.medical_services, color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'My Medicine',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white, size: 28),
                            onPressed: _addMedicine,
                            tooltip: 'Add Medicine',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Total Doses', stats['total'].toString(), Icons.medication, Colors.white),
                        _buildStatItem('Completed', stats['completed'].toString(), Icons.check_circle, Colors.white),
                        _buildStatItem('Pending', stats['pending'].toString(), Icons.schedule, Colors.white),
                        _buildStatItem('Streak', stats['streak'].toString(), Icons.local_fire_department, Colors.white),
                      ],
                    ),
                  ],
                ),
              ),

              // Medicine List or Empty State
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
                                  'Tap the + button to add your first medicine',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF95a5a6)),
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
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: color.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine, int index) {
    final times = List<String>.from(medicine['times'] ?? []);
    final taken = List<bool>.from(medicine['taken'] ?? []);
    final allTaken = taken.isNotEmpty && taken.every((t) => t);
    final medicineId = medicine['id']?.toString() ?? '';
    final streak = _calculateMedicineStreak(medicine);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showStreakDetails(medicine),
        borderRadius: BorderRadius.circular(12),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        Text(
                          '${medicine['dosage'] ?? ''} • ${medicine['schedule'] ?? ''}',
                          style: const TextStyle(color: Color(0xFF7f8c8d)),
                        ),
                      ],
                    ),
                  ),
                  // Streak Badge
                  if (streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFe67e22).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: Color(0xFFe67e22),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$streak day streak',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFe67e22),
                            ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Course: ${medicine['startDate'] ?? 'Not set'} to ${medicine['endDate'] ?? 'Not set'}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d)),
                  ),
                  TextButton(
                    onPressed: () => _showStreakDetails(medicine),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text(
                      'View Streak →',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3498db),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
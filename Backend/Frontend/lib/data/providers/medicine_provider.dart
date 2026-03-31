// lib/data/providers/medicine_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/services/medicine_service.dart';

class MedicineProvider with ChangeNotifier {
  List<Map<String, dynamic>> _medicines = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final MedicineService _medicineService = MedicineService();

  void setToken(String token) {
    debugPrint('Setting token in MedicineProvider: $token');
    _medicineService.setToken(token);
  }

  // Helper method to map medicine data from backend
  Map<String, dynamic> _mapMedicineData(Map<String, dynamic> medicine) {
    return {
      'id': medicine['_id']?.toString() ?? '',  // Map _id to id
      'name': medicine['name'] ?? '',
      'dosage': medicine['dosage'] ?? '',
      'schedule': medicine['schedule'] ?? '',
      'times': medicine['times'] ?? [],
      'taken': medicine['taken'] ?? [],
      'startDate': medicine['startDate'] ?? 'Not set',
      'endDate': medicine['endDate'] ?? 'Not set',
      'instructions': medicine['instructions'] ?? 'No special instructions',
      'remaining': medicine['remaining'] ?? 'Ongoing',
    };
  }

  Future<void> loadMedicines() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Loading medicines...');
      final rawMedicines = await _medicineService.getMedicines();
      _medicines = rawMedicines.map((m) => _mapMedicineData(m)).toList();
      debugPrint('Medicines loaded: ${_medicines.length}');
      debugPrint('Medicine IDs: ${_medicines.map((m) => m['id']).toList()}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Error loading medicines: $_error');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMedicine(Map<String, dynamic> medicineData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Adding medicine with data: $medicineData');
      final newMedicine = await _medicineService.createMedicine(medicineData);
      _medicines.add(_mapMedicineData(newMedicine));
      debugPrint('Medicine added with ID: ${newMedicine['_id']}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Error adding medicine: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMedicine(String id, Map<String, dynamic> medicineData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedMedicine = await _medicineService.updateMedicine(id, medicineData);
      final index = _medicines.indexWhere((m) => m['id'] == id);
      if (index != -1) {
        _medicines[index] = _mapMedicineData(updatedMedicine);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Error updating medicine: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMedicine(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Deleting medicine with id: $id');
      await _medicineService.deleteMedicine(id);
      _medicines.removeWhere((m) => m['id'] == id);
      debugPrint('Medicine deleted successfully. Remaining: ${_medicines.length}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Error deleting medicine: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleDose(String id, int doseIndex) async {
    try {
      await _medicineService.toggleDose(id, doseIndex);
      final index = _medicines.indexWhere((m) => m['id'] == id);
      if (index != -1) {
        final medicine = _medicines[index];
        final taken = List<bool>.from(medicine['taken'] ?? []);
        if (doseIndex < taken.length) {
          taken[doseIndex] = !taken[doseIndex];
          medicine['taken'] = taken;
          _medicines[index] = medicine;
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Error toggling dose: $_error');
      notifyListeners();
      return false;
    }
  }
}
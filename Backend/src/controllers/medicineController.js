// src/controllers/medicineController.js
const Medicine = require('../models/Medicine');

exports.getMedicines = async (req, res) => {
  try {
    console.log('Fetching medicines for user:', req.user.id);
    const medicines = await Medicine.find({ user: req.user.id });
    console.log('Found medicines:', medicines.length);
    res.status(200).json({ success: true, data: medicines });
  } catch (error) {
    console.error('Error in getMedicines:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.createMedicine = async (req, res) => {
  try {
    console.log('Creating medicine for user:', req.user.id);
    console.log('Medicine data:', req.body);
    
    const medicine = await Medicine.create({
      ...req.body,
      user: req.user.id
    });
    
    console.log('Medicine created with ID:', medicine._id);
    res.status(201).json({ 
      success: true, 
      data: {
        id: medicine._id,
        name: medicine.name,
        dosage: medicine.dosage,
        schedule: medicine.schedule,
        times: medicine.times,
        taken: medicine.taken,
        startDate: medicine.startDate,
        endDate: medicine.endDate,
        instructions: medicine.instructions,
        remaining: medicine.remaining
      }
    });
  } catch (error) {
    console.error('Error in createMedicine:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updateMedicine = async (req, res) => {
  try {
    console.log('Updating medicine ID:', req.params.id);
    const medicine = await Medicine.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    
    if (!medicine) {
      console.log('Medicine not found with ID:', req.params.id);
      return res.status(404).json({ success: false, message: 'Medicine not found' });
    }
    
    res.status(200).json({ success: true, data: medicine });
  } catch (error) {
    console.error('Error in updateMedicine:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.deleteMedicine = async (req, res) => {
  try {
    console.log('Attempting to delete medicine with ID:', req.params.id);
    console.log('User ID:', req.user.id);
    
    const medicine = await Medicine.findById(req.params.id);
    
    if (!medicine) {
      console.log('Medicine not found with ID:', req.params.id);
      return res.status(404).json({ success: false, message: 'Medicine not found' });
    }
    
    // Optional: Check if the medicine belongs to the user
    if (medicine.user.toString() !== req.user.id) {
      console.log('Unauthorized: Medicine does not belong to user');
      return res.status(403).json({ success: false, message: 'Not authorized to delete this medicine' });
    }
    
    await Medicine.findByIdAndDelete(req.params.id);
    console.log('Medicine deleted successfully:', req.params.id);
    
    res.status(200).json({ success: true, message: 'Medicine deleted' });
  } catch (error) {
    console.error('Error in deleteMedicine:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.toggleDose = async (req, res) => {
  try {
    console.log('Toggling dose for medicine ID:', req.params.id);
    console.log('Dose index:', req.params.doseIndex);
    
    const medicine = await Medicine.findById(req.params.id);
    if (!medicine) {
      console.log('Medicine not found with ID:', req.params.id);
      return res.status(404).json({ success: false, message: 'Medicine not found' });
    }
    
    const doseIndex = parseInt(req.params.doseIndex);
    if (doseIndex >= medicine.taken.length) {
      console.log('Invalid dose index:', doseIndex);
      return res.status(400).json({ success: false, message: 'Invalid dose index' });
    }
    
    medicine.taken[doseIndex] = !medicine.taken[doseIndex];
    await medicine.save();
    
    console.log('Dose toggled successfully');
    res.status(200).json({ success: true, data: medicine });
  } catch (error) {
    console.error('Error in toggleDose:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};
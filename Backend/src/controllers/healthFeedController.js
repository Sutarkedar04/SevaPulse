const HealthCamp = require('../models/HealthCamp');

exports.getHealthCamps = async (req, res) => {
  try {
    const camps = await HealthCamp.find().sort({ date: 1 });
    res.status(200).json({ success: true, data: camps });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getHealthCamp = async (req, res) => {
  try {
    const camp = await HealthCamp.findById(req.params.id);
    res.status(200).json({ success: true, data: camp });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.registerForCamp = async (req, res) => {
  try {
    const camp = await HealthCamp.findById(req.params.id);
    if (!camp) {
      return res.status(404).json({ success: false, message: 'Camp not found' });
    }
    
    if (camp.registeredParticipants >= camp.availableSlots) {
      return res.status(400).json({ success: false, message: 'No slots available' });
    }
    
    camp.registeredParticipants += 1;
    await camp.save();
    
    res.status(200).json({ success: true, message: 'Registered successfully', data: camp });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const Doctor = require('../models/Doctor');

router.get('/', protect, async (req, res) => {
  try {
    console.log('👨‍⚕️ Fetching doctors for user:', req.user.id);
    
    const doctors = await Doctor.find()
      .populate('user', 'name email phone profilePicture address');
    
    console.log(`✅ Found ${doctors.length} doctors`);
    
    const formattedDoctors = doctors.map(doctor => ({
      _id: doctor._id,
      user: doctor.user ? {
        name: doctor.user.name,
        email: doctor.user.email,
        phone: doctor.user.phone,
        profilePicture: doctor.user.profilePicture,
        address: doctor.user.address
      } : null,
      specialization: doctor.specialization || 'General',
      experience: doctor.experience || 0,
      consultationFee: doctor.consultationFee || 500,
      department: doctor.department || 'General',
      qualifications: doctor.qualifications || [],
      rating: doctor.rating || 4.5,
      availability: doctor.availability || []
    }));
    
    res.status(200).json({ 
      success: true, 
      count: formattedDoctors.length, 
      data: formattedDoctors 
    });
  } catch (error) {
    console.error('❌ Error in getDoctors:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

router.get('/:id', protect, async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.params.id)
      .populate('user', 'name email phone profilePicture address');
    
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Doctor not found' });
    }
    
    res.status(200).json({ success: true, data: doctor });
  } catch (error) {
    console.error('❌ Error in getDoctor:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
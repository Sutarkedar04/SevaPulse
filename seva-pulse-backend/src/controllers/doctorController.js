const Doctor = require('../models/Doctor');
const User = require('../models/User');

exports.getDoctors = async (req, res) => {
  try {
    console.log('Fetching doctors for user:', req.user.id);
    
    const doctors = await Doctor.find()
      .populate('user', 'name email phone profilePicture address');
    
    console.log('Doctors found:', doctors.length);
    
    // Format the response to match what frontend expects
    const formattedDoctors = doctors.map(doctor => ({
      _id: doctor._id,
      user: doctor.user ? {
        name: doctor.user.name,
        email: doctor.user.email,
        phone: doctor.user.phone,
        profilePicture: doctor.user.profilePicture,
        address: doctor.user.address
      } : null,
      specialization: doctor.specialization,
      experience: doctor.experience,
      consultationFee: doctor.consultationFee,
      department: doctor.department,
      qualifications: doctor.qualifications,
      rating: doctor.rating,
      availability: doctor.availability
    }));
    
    res.status(200).json({ 
      success: true, 
      count: formattedDoctors.length, 
      data: formattedDoctors 
    });
  } catch (error) {
    console.error('Error in getDoctors:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getDoctor = async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.params.id)
      .populate('user', 'name email phone profilePicture address');
    
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Doctor not found' });
    }
    
    const formattedDoctor = {
      _id: doctor._id,
      user: doctor.user ? {
        name: doctor.user.name,
        email: doctor.user.email,
        phone: doctor.user.phone,
        profilePicture: doctor.user.profilePicture,
        address: doctor.user.address
      } : null,
      specialization: doctor.specialization,
      experience: doctor.experience,
      consultationFee: doctor.consultationFee,
      department: doctor.department,
      qualifications: doctor.qualifications,
      rating: doctor.rating,
      availability: doctor.availability
    };
    
    res.status(200).json({ success: true, data: formattedDoctor });
  } catch (error) {
    console.error('Error in getDoctor:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updateDoctor = async (req, res) => {
  try {
    const doctor = await Doctor.findByIdAndUpdate(
      req.params.id, 
      req.body, 
      { new: true, runValidators: true }
    ).populate('user', 'name email phone profilePicture');
    
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Doctor not found' });
    }
    
    res.status(200).json({ success: true, data: doctor });
  } catch (error) {
    console.error('Error in updateDoctor:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};
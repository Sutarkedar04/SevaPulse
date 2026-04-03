const Patient = require('../models/Patient');
const User = require('../models/User');

exports.getPatients = async (req, res, next) => {
  try {
    const patients = await Patient.find().populate('user', 'name email phone profilePicture');
    res.status(200).json({ success: true, count: patients.length, data: patients });
  } catch (error) {
    next(error);
  }
};

exports.getPatient = async (req, res, next) => {
  try {
    const patient = await Patient.findById(req.params.id).populate('user', 'name email phone profilePicture');
    if (!patient) {
      return res.status(404).json({ success: false, message: 'Patient not found' });
    }
    res.status(200).json({ success: true, data: patient });
  } catch (error) {
    next(error);
  }
};

exports.getCurrentPatient = async (req, res, next) => {
  try {
    console.log('Getting current patient for user:', req.user.id);
    
    let patient = await Patient.findOne({ user: req.user.id }).populate('user', 'name email phone profilePicture');
    
    if (!patient) {
      console.log('Creating new patient profile for user:', req.user.id);
      patient = await Patient.create({
        user: req.user.id,
        dateOfBirth: new Date('1990-01-01'),
        gender: 'Not specified'
      });
      
      const user = await User.findById(req.user.id);
      
      return res.status(200).json({ 
        success: true, 
        data: {
          _id: patient._id,
          user: {
            _id: user._id,
            name: user.name,
            email: user.email,
            phone: user.phone,
            profilePicture: user.profilePicture
          },
          dateOfBirth: patient.dateOfBirth,
          gender: patient.gender,
          bloodGroup: patient.bloodGroup,
          address: patient.address,
          allergies: patient.allergies || [],
          medicalHistory: patient.medicalHistory || [],
          currentMedications: patient.currentMedications || []
        }
      });
    }
    
    res.status(200).json({ success: true, data: patient });
  } catch (error) {
    next(error);
  }
};

exports.updatePatient = async (req, res, next) => {
  try {
    console.log('========================================');
    console.log('📝 Updating patient profile');
    console.log('User ID:', req.user.id);
    console.log('Request body:', req.body);
    console.log('========================================');
    
    let patient = await Patient.findOne({ user: req.user.id });
    
    if (!patient) {
      patient = await Patient.create({
        user: req.user.id,
        dateOfBirth: new Date('1990-01-01'),
        gender: 'Not specified'
      });
    }
    
    if (req.body.dateOfBirth && req.body.dateOfBirth != 'Not set') {
      patient.dateOfBirth = new Date(req.body.dateOfBirth);
    }
    if (req.body.gender && req.body.gender != 'Not set') {
      patient.gender = req.body.gender;
    }
    if (req.body.bloodGroup && req.body.bloodGroup != 'Not set') {
      patient.bloodGroup = req.body.bloodGroup;
    }
    if (req.body.address && req.body.address.city && req.body.address.city != 'Not set') {
      patient.address = {
        ...patient.address,
        city: req.body.address.city
      };
    }
    if (req.body.allergies) {
      patient.allergies = req.body.allergies;
    }
    
    await patient.save();
    console.log('✅ Patient updated successfully');
    
    const userUpdate = {};
    if (req.body.name && req.body.name != 'Not set') userUpdate.name = req.body.name;
    if (req.body.email && req.body.email != 'Not set') userUpdate.email = req.body.email;
    if (req.body.phone && req.body.phone != 'Not set') userUpdate.phone = req.body.phone;
    
    if (Object.keys(userUpdate).length > 0) {
      await User.findByIdAndUpdate(req.user.id, userUpdate);
      console.log('✅ User updated successfully');
    }
    
    const updatedPatient = await Patient.findOne({ user: req.user.id }).populate('user', 'name email phone profilePicture');
    
    res.status(200).json({ 
      success: true, 
      data: updatedPatient,
      message: 'Profile updated successfully'
    });
  } catch (error) {
    console.error('❌ Error in updatePatient:', error);
    next(error);
  }
};
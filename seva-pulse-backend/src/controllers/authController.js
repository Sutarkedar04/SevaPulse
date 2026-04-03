// src/controllers/authController.js
const User = require('../models/User');
const Patient = require('../models/Patient');
const Doctor = require('../models/Doctor');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'secretkey123', { expiresIn: '7d' });
};

exports.register = async (req, res, next) => {
  try {
    const { name, email, password, phone, userType, specialization, experience, dateOfBirth, address, gender } = req.body;
    
    console.log('📝 Registration request received:');
    console.log('   Name:', name);
    console.log('   Email:', email);
    console.log('   Phone:', phone);
    console.log('   UserType:', userType);
    
    // Validate required fields
    if (!name || !email || !password || !phone) {
      console.log('❌ Missing required fields');
      return res.status(400).json({ 
        success: false, 
        message: 'Please provide all required fields: name, email, password, phone' 
      });
    }
    
    // Check if user exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      console.log('❌ User already exists:', email);
      return res.status(400).json({ success: false, message: 'User already exists' });
    }
    
    // Hash password manually (as fallback in case model hook fails)
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log('✅ Password hashed successfully');
    
    // Create user
    const user = await User.create({ 
      name, 
      email, 
      password: hashedPassword, 
      phone, 
      role: userType || 'patient',
      isActive: true
    });
    
    console.log('✅ User created successfully with ID:', user._id);
    
    // Create patient profile
    const patientData = {
      user: user._id,
      dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : new Date('1990-01-01'),
      gender: gender || 'Not specified',
      createdAt: new Date()
    };
    
    await Patient.create(patientData);
    console.log('✅ Patient profile created for user:', user._id);
    
    // Generate token
    const token = generateToken(user._id);
    console.log('✅ Token generated');
    
    // Return response
    const responseData = {
      success: true,
      token,
      user: { 
        id: user._id, 
        name: user.name, 
        email: user.email, 
        phone: user.phone,
        userType: user.role,
        createdAt: user.createdAt
      }
    };
    
    console.log('✅ Registration successful for:', email);
    res.status(201).json(responseData);
    
  } catch (error) {
    console.error('❌ Registration error details:');
    console.error('   Error name:', error.name);
    console.error('   Error message:', error.message);
    console.error('   Stack trace:', error.stack);
    
    // Handle specific MongoDB errors
    if (error.code === 11000) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email already registered' 
      });
    }
    
    // Pass error to Express error handler
    next(error);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password, userType } = req.body;
    
    console.log('🔐 Login request:', { email, userType });
    
    if (!email || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Please provide email and password' 
      });
    }
    
    // Find user with password field included
    const user = await User.findOne({ email }).select('+password');
    
    if (!user) {
      console.log('❌ User not found:', email);
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    
    // Compare password
    const isMatch = await bcrypt.compare(password, user.password);
    
    if (!isMatch) {
      console.log('❌ Invalid password for:', email);
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    
    // Check user type
    if (userType && user.role !== userType) {
      console.log('❌ Wrong user type. Expected:', userType, 'Got:', user.role);
      return res.status(401).json({ success: false, message: 'Invalid user type' });
    }
    
    const token = generateToken(user._id);
    
    let profile = null;
    if (user.role === 'patient') {
      profile = await Patient.findOne({ user: user._id });
    } else if (user.role === 'doctor') {
      profile = await Doctor.findOne({ user: user._id });
    }
    
    console.log('✅ Login successful for:', email);
    
    res.status(200).json({
      success: true,
      token,
      user: { 
        id: user._id, 
        name: user.name, 
        email: user.email, 
        phone: user.phone,
        userType: user.role,
        specialization: profile?.specialization || null,
        experience: profile?.experience || null,
        createdAt: user.createdAt
      }
    });
    
  } catch (error) {
    console.error('❌ Login error:', error);
    next(error);
  }
};

exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    let profile = null;
    if (user.role === 'patient') {
      profile = await Patient.findOne({ user: user._id });
    } else if (user.role === 'doctor') {
      profile = await Doctor.findOne({ user: user._id });
    }
    
    res.status(200).json({ 
      success: true, 
      data: { 
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          userType: user.role,
          createdAt: user.createdAt,
          ...(profile ? profile.toObject() : {})
        }
      } 
    });
  } catch (error) {
    console.error('❌ GetMe error:', error);
    next(error);
  }
};

exports.logout = async (req, res, next) => {
  try {
    res.status(200).json({ success: true, message: 'Logged out successfully' });
  } catch (error) {
    console.error('❌ Logout error:', error);
    next(error);
  }
};
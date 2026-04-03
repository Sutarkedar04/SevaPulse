const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Patient = require('../models/Patient');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'secretkey123', { expiresIn: '7d' });
};

// REGISTER
router.post('/register', async (req, res) => {
  try {
    console.log('📝 REGISTER ENDPOINT HIT');
    const { name, email, password, phone, userType, dateOfBirth, gender } = req.body;
    
    console.log('Registration data:', { name, email, phone, userType });
    
    // Validate required fields
    if (!name || !email || !password || !phone) {
      return res.status(400).json({ 
        success: false, 
        message: 'Please provide all required fields: name, email, password, phone' 
      });
    }
    
    // Check if user exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ success: false, message: 'User already exists' });
    }
    
    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Create user
    const user = await User.create({ 
      name, 
      email, 
      password: hashedPassword, 
      phone, 
      role: userType || 'patient',
      isActive: true
    });
    
    console.log('✅ User created:', user._id);
    
    // Create patient profile
    await Patient.create({
      user: user._id,
      dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : new Date('1990-01-01'),
      gender: gender || 'Not specified'
    });
    
    console.log('✅ Patient profile created');
    
    // Generate token
    const token = generateToken(user._id);
    
    // Return response
    return res.status(201).json({
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
    });
    
  } catch (error) {
    console.error('❌ Registration error:', error.message);
    console.error('Stack:', error.stack);
    
    // Handle duplicate key error
    if (error.code === 11000) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email already registered' 
      });
    }
    
    return res.status(500).json({ 
      success: false, 
      message: error.message || 'Registration failed' 
    });
  }
});

// LOGIN
router.post('/login', async (req, res) => {
  try {
    console.log('🔐 LOGIN ENDPOINT HIT');
    const { email, password, userType } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Please provide email and password' 
      });
    }
    
    const user = await User.findOne({ email }).select('+password');
    
    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    
    const isMatch = await bcrypt.compare(password, user.password);
    
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    
    if (userType && user.role !== userType) {
      return res.status(401).json({ success: false, message: 'Invalid user type' });
    }
    
    const token = generateToken(user._id);
    
    return res.status(200).json({
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
    });
    
  } catch (error) {
    console.error('❌ Login error:', error.message);
    return res.status(500).json({ 
      success: false, 
      message: error.message || 'Login failed' 
    });
  }
});

// GET ME
router.get('/me', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ success: false, message: 'Not authorized' });
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secretkey123');
    const user = await User.findById(decoded.id);
    
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    return res.status(200).json({ 
      success: true, 
      data: { 
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          userType: user.role,
          createdAt: user.createdAt
        }
      } 
    });
  } catch (error) {
    console.error('❌ GetMe error:', error.message);
    return res.status(401).json({ success: false, message: 'Invalid token' });
  }
});

// LOGOUT
router.post('/logout', async (req, res) => {
  return res.status(200).json({ success: true, message: 'Logged out successfully' });
});

module.exports = router;
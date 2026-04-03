// src/middleware/auth.js
const jwt = require('jsonwebtoken');
const User = require('../models/User');

exports.protect = async (req, res, next) => {
  console.log('🔒 Auth middleware called for:', req.method, req.url);
  
  let token;
  
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }
  
  if (!token) {
    console.log('❌ No token provided');
    return res.status(401).json({ success: false, message: 'Not authorized, no token' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secretkey123');
    console.log('✅ Token verified for user:', decoded.id);
    
    req.user = await User.findById(decoded.id).select('-password');
    
    if (!req.user) {
      console.log('❌ User not found');
      return res.status(401).json({ success: false, message: 'User not found' });
    }
    
    console.log('✅ User authenticated:', req.user.email);
    next();
  } catch (err) {
    console.error('❌ Auth error:', err.message);
    return res.status(401).json({ success: false, message: 'Not authorized, invalid token' });
  }
};

exports.authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ success: false, message: 'Not authorized for this role' });
    }
    next();
  };
};
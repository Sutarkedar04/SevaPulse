const express = require('express');
const router = express.Router();
const { 
  getPatients, 
  getPatient, 
  getCurrentPatient, 
  updatePatient 
} = require('../controllers/patientController');
const { protect } = require('../middleware/auth');

// IMPORTANT: Do NOT use router.use(protect) - apply to each route individually
// Get current logged-in patient's profile (must be before /:id)
router.get('/me', protect, getCurrentPatient);

// Get all patients
router.get('/', protect, getPatients);

// Get specific patient by ID
router.get('/:id', protect, getPatient);

// Update current patient's profile
router.put('/me', protect, updatePatient);

// Update specific patient by ID
router.put('/:id', protect, updatePatient);

module.exports = router;
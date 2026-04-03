const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const { getPrescriptions, createPrescription, getPrescriptionsByPatient } = require('../controllers/prescriptionController');

router.get('/', protect, getPrescriptions);
router.post('/', protect, createPrescription);
router.get('/patient/:patientId', protect, getPrescriptionsByPatient);

module.exports = router;
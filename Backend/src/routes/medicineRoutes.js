const express = require('express');
const router = express.Router();
const { getMedicines, createMedicine, updateMedicine, deleteMedicine, toggleDose } = require('../controllers/medicineController');
const { protect } = require('../middleware/auth');

router.get('/', protect, getMedicines);
router.post('/', protect, createMedicine);
router.put('/:id', protect, updateMedicine);
router.delete('/:id', protect, deleteMedicine);
router.put('/:id/toggle/:doseIndex', protect, toggleDose);

module.exports = router;
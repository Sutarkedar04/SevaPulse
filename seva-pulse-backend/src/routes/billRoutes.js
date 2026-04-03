const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const { getBills, createBill, payBill } = require('../controllers/billController');

router.get('/', protect, getBills);
router.post('/', protect, createBill);
router.put('/:id/pay', protect, payBill);

module.exports = router;
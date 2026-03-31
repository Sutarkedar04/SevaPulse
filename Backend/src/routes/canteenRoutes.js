const express = require('express');
const router = express.Router();
const { getCanteenMenu } = require('../controllers/canteenController');
const { protect } = require('../middleware/auth');

router.get('/menu', protect, getCanteenMenu);

module.exports = router;
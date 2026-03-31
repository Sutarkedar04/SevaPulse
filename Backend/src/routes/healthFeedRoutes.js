const express = require('express');
const router = express.Router();
const { getHealthCamps, getHealthCamp, registerForCamp } = require('../controllers/healthFeedController');
const { protect } = require('../middleware/auth');

router.get('/', protect, getHealthCamps);
router.get('/:id', protect, getHealthCamp);
router.post('/:id/register', protect, registerForCamp);

module.exports = router;
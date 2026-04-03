const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const HealthCamp = require('../models/HealthCamp');

// Get all health camps
router.get('/', protect, async (req, res) => {
  try {
    console.log('📡 Fetching health camps for user:', req.user.id);
    
    const camps = await HealthCamp.find().sort({ date: 1 });
    
    console.log(`✅ Found ${camps.length} health camps`);
    
    res.status(200).json({ 
      success: true, 
      count: camps.length, 
      data: camps 
    });
  } catch (error) {
    console.error('❌ Error fetching health camps:', error);
    res.status(500).json({ 
      success: false, 
      message: error.message || 'Failed to fetch health camps' 
    });
  }
});

// Get single health camp
router.get('/:id', protect, async (req, res) => {
  try {
    const camp = await HealthCamp.findById(req.params.id);
    
    if (!camp) {
      return res.status(404).json({ success: false, message: 'Health camp not found' });
    }
    
    res.status(200).json({ success: true, data: camp });
  } catch (error) {
    console.error('❌ Error fetching health camp:', error);
    res.status(500).json({ 
      success: false, 
      message: error.message || 'Failed to fetch health camp' 
    });
  }
});

// Create health camp - POST endpoint
router.post('/', protect, async (req, res) => {
  try {
    console.log('📝 Creating health camp for user:', req.user.id);
    console.log('Request body:', req.body);
    
    const campData = {
      title: req.body.title,
      organization: req.body.organization || 'Seva Pulse Hospital',
      date: new Date(req.body.date),
      time: req.body.time,
      location: req.body.location,
      description: req.body.description,
      imageUrl: req.body.imageUrl || '',
      availableSlots: req.body.availableSlots,
      registeredParticipants: 0,
      services: req.body.services || [],
      contact: req.body.contact,
      isFree: req.body.isFree !== undefined ? req.body.isFree : true,
      fee: req.body.isFree ? null : req.body.fee,
      createdAt: new Date()
    };
    
    const camp = await HealthCamp.create(campData);
    
    console.log('✅ Health camp created with ID:', camp._id);
    
    res.status(201).json({ 
      success: true, 
      data: camp,
      message: 'Health camp created successfully'
    });
  } catch (error) {
    console.error('❌ Error creating health camp:', error);
    res.status(500).json({ 
      success: false, 
      message: error.message || 'Failed to create health camp' 
    });
  }
});

// Update health camp
router.put('/:id', protect, async (req, res) => {
  try {
    console.log('📝 Updating health camp:', req.params.id);
    
    const updateData = {
      title: req.body.title,
      organization: req.body.organization,
      date: req.body.date ? new Date(req.body.date) : undefined,
      time: req.body.time,
      location: req.body.location,
      description: req.body.description,
      imageUrl: req.body.imageUrl,
      availableSlots: req.body.availableSlots,
      services: req.body.services,
      contact: req.body.contact,
      isFree: req.body.isFree,
      fee: req.body.isFree ? null : req.body.fee,
      updatedAt: new Date()
    };
    
    // Remove undefined fields
    Object.keys(updateData).forEach(key => 
      updateData[key] === undefined && delete updateData[key]
    );
    
    const camp = await HealthCamp.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );
    
    if (!camp) {
      return res.status(404).json({ success: false, message: 'Health camp not found' });
    }
    
    console.log('✅ Health camp updated successfully');
    
    res.status(200).json({ 
      success: true, 
      data: camp,
      message: 'Health camp updated successfully'
    });
  } catch (error) {
    console.error('❌ Error updating health camp:', error);
    res.status(500).json({ 
      success: false, 
      message: error.message || 'Failed to update health camp' 
    });
  }
});

// Delete health camp
router.delete('/:id', protect, async (req, res) => {
  try {
    console.log('🗑️ Deleting health camp:', req.params.id);
    
    const camp = await HealthCamp.findByIdAndDelete(req.params.id);
    
    if (!camp) {
      return res.status(404).json({ success: false, message: 'Health camp not found' });
    }
    
    console.log('✅ Health camp deleted successfully');
    
    res.status(200).json({ 
      success: true, 
      message: 'Health camp deleted successfully' 
    });
  } catch (error) {
    console.error('❌ Error deleting health camp:', error);
    res.status(500).json({ 
      success: false, 
      message: error.message || 'Failed to delete health camp' 
    });
  }
});

// Register for health camp
router.post('/:id/register', protect, async (req, res) => {
  try {
    console.log('📝 Registering for health camp:', req.params.id);
    console.log('User ID:', req.user.id);
    
    const camp = await HealthCamp.findById(req.params.id);
    
    if (!camp) {
      return res.status(404).json({ success: false, message: 'Camp not found' });
    }
    
    if (camp.registeredParticipants >= camp.availableSlots) {
      return res.status(400).json({ success: false, message: 'No slots available' });
    }
    
    // Check if user already registered (you can implement this with a registrations array)
    // For now, just increment the counter
    
    camp.registeredParticipants += 1;
    await camp.save();
    
    console.log('✅ User registered successfully. Total registered:', camp.registeredParticipants);
    
    res.status(200).json({ 
      success: true, 
      message: 'Registered successfully', 
      data: camp 
    });
  } catch (error) {
    console.error('❌ Error registering for camp:', error);
    res.status(500).json({ 
      success: false, 
      message: error.message || 'Failed to register for camp' 
    });
  }
});

module.exports = router;
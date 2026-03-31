// fix-patients.js
const mongoose = require('mongoose');
const User = require('./src/models/User');
const Patient = require('./src/models/Patient');
require('dotenv').config();

const fixMissingPatients = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/seva-pulse');
    console.log('Connected to MongoDB');
    
    // Find all users with role 'patient'
    const users = await User.find({ role: 'patient' });
    console.log(`Found ${users.length} patients in users collection`);
    
    let created = 0;
    let existing = 0;
    
    for (const user of users) {
      // Check if patient profile exists
      const existingPatient = await Patient.findOne({ user: user._id });
      
      if (!existingPatient) {
        // Create patient profile
        await Patient.create({
          user: user._id,
          dateOfBirth: new Date('1990-01-01'),
          gender: 'Not specified',
          createdAt: new Date()
        });
        console.log(`✅ Created patient profile for user: ${user.name} (${user._id})`);
        created++;
      } else {
        console.log(`✓ Patient profile already exists for user: ${user.name}`);
        existing++;
      }
    }
    
    console.log('\n📊 Summary:');
    console.log(`   - Existing profiles: ${existing}`);
    console.log(`   - Created profiles: ${created}`);
    console.log(`   - Total patients: ${users.length}`);
    
    console.log('\n✨ Fix completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
};

fixMissingPatients();
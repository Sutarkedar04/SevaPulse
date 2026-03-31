const mongoose = require('mongoose');
const CanteenItem = require('./src/models/CanteenItem');
const HealthCamp = require('./src/models/HealthCamp');
require('dotenv').config();

const seedCanteen = async () => {
  const canteenItems = [
    { category: 'Breakfast', name: 'Masala Dosa', price: '₹60', description: 'Crispy rice crepe with potato filling' },
    { category: 'Breakfast', name: 'Idli Sambar', price: '₹40', description: 'Steamed rice cakes with lentil soup' },
    { category: 'Breakfast', name: 'Poha', price: '₹35', description: 'Flattened rice with vegetables' },
    { category: 'Lunch', name: 'Thali Meal', price: '₹120', description: 'Complete meal with 3 vegetables, dal, rice, roti' },
    { category: 'Lunch', name: 'Vegetable Biryani', price: '₹90', description: 'Fragrant rice with mixed vegetables' },
    { category: 'Snacks', name: 'Samosa', price: '₹25', description: 'Crispy pastry with potato filling' },
    { category: 'Snacks', name: 'Vada Pav', price: '₹30', description: 'Mumbai style potato burger' },
    { category: 'Dinner', name: 'Roti Sabzi', price: '₹80', description: 'Indian bread with vegetable curry' }
  ];
  
  await CanteenItem.deleteMany({});
  await CanteenItem.insertMany(canteenItems);
  console.log('Canteen data seeded');
};

const seedHealthCamps = async () => {
  const camps = [
    {
      title: 'Free Heart Checkup Camp',
      organization: 'Seva Pulse Hospital',
      date: new Date('2024-12-20'),
      time: '9:00 AM - 4:00 PM',
      location: 'Main Hospital Campus, Ground Floor',
      description: 'Comprehensive heart health screening including ECG, blood pressure, cholesterol check, and cardiologist consultation.',
      imageUrl: '',
      availableSlots: 150,
      registeredParticipants: 0,
      services: ['ECG', 'BP Check', 'Cholesterol Test', 'Cardiologist Consultation'],
      contact: '+91-9876543210',
      isFree: true
    }
  ];
  
  await HealthCamp.deleteMany({});
  await HealthCamp.insertMany(camps);
  console.log('Health camps seeded');
};

mongoose.connect(process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/seva-pulse')
.then(async () => {
  await seedCanteen();
  await seedHealthCamps();
  console.log('Seeding complete');
  process.exit();
})
.catch(err => console.error(err));
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import routes
const authRoutes = require('./src/routes/authRoutes');
const appointmentRoutes = require('./src/routes/appointmentRoutes');
const doctorRoutes = require('./src/routes/doctorRoutes');
const patientRoutes = require('./src/routes/patientRoutes');
const prescriptionRoutes = require('./src/routes/prescriptionRoutes');
const billRoutes = require('./src/routes/billRoutes');
const medicineRoutes = require('./src/routes/medicineRoutes');
const healthFeedRoutes = require('./src/routes/healthFeedRoutes');
const canteenRoutes = require('./src/routes/canteenRoutes');

const app = express();

// Middleware
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`📨 ${req.method} ${req.url}`);
  next();
});

// Database connection - REMOVED deprecated options
const connectDB = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/seva-pulse';
    console.log(`📡 Connecting to MongoDB at: ${mongoURI}`);
    
    // REMOVED useNewUrlParser and useUnifiedTopology - not needed in Mongoose 9+
    await mongoose.connect(mongoURI);
    
    console.log('✅ MongoDB connected successfully');
    
    // Log all collections to verify
    const collections = await mongoose.connection.db.listCollections().toArray();
    console.log(`📚 Available collections: ${collections.map(c => c.name).join(', ')}`);
    
  } catch (error) {
    console.error('❌ MongoDB connection error:', error.message);
    console.log('⚠️  Make sure MongoDB is running or Atlas connection string is correct:');
    console.log('   - Check your MONGODB_URI in .env file');
    console.log('   - Verify network access in MongoDB Atlas');
    process.exit(1);
  }
};

// Routes with error handling
app.use('/api/auth', authRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/doctors', doctorRoutes);
app.use('/api/patients', patientRoutes);
app.use('/api/prescriptions', prescriptionRoutes);
app.use('/api/bills', billRoutes);
app.use('/api/medicines', medicineRoutes);
app.use('/api/health-feed', healthFeedRoutes);
app.use('/api/canteen', canteenRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    message: 'SevaPulse Backend is running',
    timestamp: new Date().toISOString(),
    mongodb: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected'
  });
});

// 404 handler for undefined routes
app.use((req, res) => {
  res.status(404).json({ 
    success: false, 
    message: `Route ${req.method} ${req.url} not found` 
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('❌ Server error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error'
  });
});

// Start server
const PORT = process.env.PORT || 5000;
const HOST = '0.0.0.0'; // Listen on all network interfaces

connectDB().then(() => {
  app.listen(PORT, HOST, () => {
    console.log(`
    🚀 Server is running!
    📡 Local: http://localhost:${PORT}
    🌐 Network: http://${getLocalIp()}:${PORT}
    📋 API Docs: http://localhost:${PORT}/api/health
    `);
  });
}).catch(err => {
  console.error('Failed to start server:', err);
  process.exit(1);
});

// Helper function to get local IP
function getLocalIp() {
  const { networkInterfaces } = require('os');
  const nets = networkInterfaces();
  
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if (net.family === 'IPv4' && !net.internal) {
        return net.address;
      }
    }
  }
  return 'localhost';
}
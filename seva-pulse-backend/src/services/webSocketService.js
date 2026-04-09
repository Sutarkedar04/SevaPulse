const socketIO = require('socket.io');

class WebSocketService {
  constructor(server) {
    this.io = socketIO(server, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"],
        credentials: true
      }
    });
    
    this.initialize();
  }

  initialize() {
    this.io.on('connection', (socket) => {
      console.log('🔌 New client connected:', socket.id);

      // User joins their room
      socket.on('join', (userId, userType) => {
        socket.join(`${userType}_${userId}`);
        if (userType === 'patient') {
          socket.join('all_patients');
          console.log(`📱 Patient ${userId} joined all_patients room`);
        } else if (userType === 'doctor') {
          socket.join('all_doctors');
          console.log(`👨‍⚕️ Doctor ${userId} joined all_doctors room`);
        }
        console.log(`✅ User ${userId} (${userType}) joined their room`);
      });

      socket.on('disconnect', () => {
        console.log('🔌 Client disconnected:', socket.id);
      });
    });
  }

  getIO() {
    return this.io;
  }
}

module.exports = WebSocketService;
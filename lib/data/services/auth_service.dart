import '../models/user_model.dart';

class AuthService {
  // For now, we'll use mock data. Replace with actual API calls later.
  
  Future<User> login(String email, String password, String userType) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock validation - Replace with real API call
    if (email == 'patient@test.com' && password == 'password') {
      return User(
        id: '1',
        name: 'John Patient',
        email: email,
        phone: '+1234567890',
        userType: 'patient',
        createdAt: DateTime.now(),
      );
    } else if (email == 'doctor@test.com' && password == 'password') {
      return User(
        id: '2',
        name: 'Dr. Sarah Smith',
        email: email,
        phone: '+1234567891',
        userType: 'doctor',
        specialization: 'Cardiologist',
        experience: '10 years',
        createdAt: DateTime.now(),
      );
    } else {
      throw Exception('Invalid email or password');
    }
  }

  Future<User> register(User user, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock registration - Replace with real API call
    if (user.email.isNotEmpty && password.isNotEmpty) {
      return User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: user.name,
        email: user.email,
        phone: user.phone,
        userType: user.userType,
        address: user.address,
        dateOfBirth: user.dateOfBirth,
        specialization: user.specialization,
        experience: user.experience,
        createdAt: DateTime.now(),
      );
    } else {
      throw Exception('Registration failed');
    }
  }

  Future<void> logout() async {
    // Clear any local storage, tokens, etc.
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
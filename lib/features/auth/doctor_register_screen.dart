import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seva_pulse/features/doctor/screens/doctor_home_screen.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';


class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({Key? key}) : super(key: key);

  @override
  State<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _hospitalController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)), // 30 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 25)), // At least 25 years old
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _registerDoctor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Create doctor user object
      final user = User(
        id: '', // Will be set by the server
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        userType: 'doctor',
        profileImage: null,
        createdAt: DateTime.now(),
        specialization: _specializationController.text.trim(),
        experience: _experienceController.text.trim(),
        address: _hospitalController.text.trim(),
        dateOfBirth: _selectedDate,
      );

      // Register doctor using your AuthProvider
      final success = await authProvider.register(user, _passwordController.text);

      if (success && mounted) {
        // Navigate to doctor home screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DoctorHomeScreen()),
          (route) => false,
        );
      } else if (mounted) {
        // Show error from auth provider
        if (authProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error!),
              backgroundColor: const Color(0xFFe74c3c),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: const Color(0xFFe74c3c),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _qualificationController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Registration'),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 20),
              const Text(
                'Join as Doctor',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your doctor account to manage patients and appointments',
                style: TextStyle(
                  color: Color(0xFF7f8c8d),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // Personal Information Section
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF3498db)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3498db)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address *',
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF3498db)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3498db)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF3498db)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3498db)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Date of Birth Field
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of Birth (Optional)',
                  prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF3498db)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3498db)),
                  ),
                  hintText: _selectedDate == null 
                      ? 'Select your date of birth' 
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 30),

              // Professional Information Section
              _buildSectionHeader('Professional Information'),
              const SizedBox(height: 20),

              // Specialization Field
              TextFormField(
                controller: _specializationController,
                decoration: InputDecoration(
                  labelText: 'Specialization *',
                  prefixIcon: const Icon(Icons.medical_services, color: Color(0xFF3498db)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3498db)),
                  ),
                  hintText: 'e.g., Cardiologist, Dermatologist',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your specialization';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Experience Field
              TextFormField(
                controller: _experienceController,
                decoration: InputDecoration(
                  labelText: 'Years of Experience *',
                  prefixIcon: const Icon(Icons.work, color: Color(0xFF3498db)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3498db)),
                  ),
                  hintText: 'e.g., 5 years',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your experience';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Qualification Field
              TextFormField(
                controller: _qualificationController,
                decoration: InputDecoration(
                  labelText: 'Qualifications *',
                  prefixIcon: const Icon(Icons.school, color: Color(0xFF3498db)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3498db)),
                  ),
                  hintText: 'e.g., MBBS, MD, MS',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your qualifications';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Hospital/Clinic Field
              TextFormField(
                controller: _hospitalController,
                decoration: InputDecoration(
                  labelText: 'Hospital/Clinic *',
                  prefixIcon: const Icon(Icons.local_hospital, color: Color(0xFF3498db)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3498db)),
                  ),
                  hintText: 'e.g., City Heart Center',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your hospital/clinic name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Security Section
              _buildSectionHeader('Security'),
              const SizedBox(height: 20),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF3498db)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3498db)),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF7f8c8d),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password *',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF3498db)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3498db)),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF7f8c8d),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerDoctor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27ae60),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Doctor Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Terms and Conditions
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text.rich(
                  TextSpan(
                    text: 'By creating an account, you agree to our ',
                    style: TextStyle(color: Color(0xFF7f8c8d)),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: Color(0xFF3498db),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Color(0xFF3498db),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),

              // Already have account
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Color(0xFF7f8c8d)),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: Color(0xFF3498db),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF3498db).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3498db).withValues(alpha: 0.3)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2c3e50),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers/auth_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../user/screens/user_home_screen.dart';
import 'user_register_screen.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({Key? key}) : super(key: key);

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    // Load saved credentials if remember me was enabled
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email') ?? '';
    final savedPassword = prefs.getString('saved_password') ?? '';
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe && savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword;
      setState(() {
        _rememberMe = true;
      });
    }
    // For now, we'll set some demo values
    _emailController.text = 'patient@test.com';
    _passwordController.text = 'password';
    setState(() {
      _rememberMe = true;
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
        'patient',
      );

      if (success) {
        if (_rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', _emailController.text.trim());
          await prefs.setString('saved_password', _passwordController.text);
          await prefs.setBool('remember_me', true);
        }
        
        // ignore: use_build_context_synchronously
        Helpers.showSnackBar(context, 'Login successful!');
        
        Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const UserHomeScreen()),
          (route) => false,
        );
      } else {
        Helpers.showSnackBar(
          // ignore: use_build_context_synchronously
          context, 
          authProvider.error ?? 'Login failed', 
          isError: true
        );
      }
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserRegisterScreen()),
    );
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password?'),
        content: const Text('Enter your email address to reset your password.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showResetPasswordDialog();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We will send a password reset link to your email.'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email, color: Color(0xFF3498db)),
              validator: Validators.validateEmail,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (Validators.validateEmail(emailController.text) == null) {
                Navigator.pop(context);
                Helpers.showSnackBar(
                  context, 
                  'Password reset link sent to ${emailController.text}'
                );
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2c3e50)),
                  onPressed: () => Navigator.pop(context),
                ),
                
                const SizedBox(height: 20),
                
                // Welcome Section
                _buildWelcomeSection(),
                
                const SizedBox(height: 40),
                
                // Login Form
                _buildLoginForm(),
                
                const SizedBox(height: 30),
                
                // Login Button
                _buildLoginButton(),
                
                const SizedBox(height: 20),
                
                // Additional Options
                _buildAdditionalOptions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App Icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3498db), Color(0xFF2c3e50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.health_and_safety,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        const Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2c3e50),
          ),
        ),
        
        const SizedBox(height: 8),
        
        const Text(
          'Sign in to continue your health journey',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF7f8c8d),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email Field
        CustomTextField(
          controller: _emailController,
          labelText: 'Email Address',
          prefixIcon: const Icon(Icons.email, color: Color(0xFF3498db)),
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
        
        const SizedBox(height: 20),
        
        // Password Field
        CustomTextField(
          controller: _passwordController,
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock, color: Color(0xFF3498db)),
          obscureText: _obscurePassword,
          validator: Validators.validatePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF7f8c8d),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Remember Me & Forgot Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Remember Me
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF3498db),
                ),
                const Text(
                  'Remember me',
                  style: TextStyle(
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            
            // Forgot Password
            TextButton(
              onPressed: _forgotPassword,
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Color(0xFF3498db),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return CustomButton(
          text: 'SIGN IN',
          onPressed: authProvider.isLoading ? () {} : _login,
          isLoading: authProvider.isLoading,
          backgroundColor: const Color(0xFF3498db),
        );
      },
    );
  }

  Widget _buildAdditionalOptions() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.grey[300]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.grey[300]),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Social Login Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              color: const Color(0xFFDB4437),
              onTap: () {
                Helpers.showSnackBar(context, 'Google login coming soon!');
              },
            ),
            
            const SizedBox(width: 16),
            
            _buildSocialButton(
              icon: Icons.facebook,
              color: const Color(0xFF4267B2),
              onTap: () {
                Helpers.showSnackBar(context, 'Facebook login coming soon!');
              },
            ),
          ],
        ),
        
        const SizedBox(height: 30),
        
        // Register Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account?",
              style: TextStyle(
                color: Color(0xFF7f8c8d),
              ),
            ),
            const SizedBox(width: 4),
            TextButton(
              onPressed: _navigateToRegister,
              child: const Text(
                'Sign up',
                style: TextStyle(
                  color: Color(0xFF3498db),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  // Demo Login Buttons for Testing

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
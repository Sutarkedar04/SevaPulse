import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import 'user_selection_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    _animationController.reverse().then((_) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const UserSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(flex: 1),
            
            // Animated Logo/Icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3498db), Color(0xFF2c3e50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3498db).withValues(alpha:0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Main Title with Animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'SEVA PULSE',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2c3e50),
                  letterSpacing: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle with Animation
            SlideTransition(
              position: _slideAnimation,
              child: const Text(
                'IMPROVE YOUR LIFETIME',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3498db),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Description with Animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'Sticking up improves community health care and priorities through collaborative efforts and innovative solutions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7f8c8d),
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            
            const Spacer(flex: 2),
            
            // Feature Highlights
            SlideTransition(
              position: _slideAnimation,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _FeatureItem(
                    icon: Icons.monitor_heart,
                    text: 'Health\nTracking',
                  ),
                  _FeatureItem(
                    icon: Icons.people,
                    text: 'Community\nSupport',
                  ),
                  _FeatureItem(
                    icon: Icons.analytics,
                    text: 'Smart\nAnalytics',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Animated Get Started Button
            ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498db),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF3498db).withValues(alpha:0.4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GET STARTED',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Skip for now option
            TextButton(
              onPressed: _navigateToNext,
              child: const Text(
                'Skip for now',
                style: TextStyle(
                  color: Color(0xFF7f8c8d),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF3498db).withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3498db),
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2c3e50),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
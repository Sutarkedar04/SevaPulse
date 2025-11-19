import 'package:flutter/material.dart';

import 'user_selection_screen.dart';

class SevaPulseSplashScreen extends StatefulWidget {
  const SevaPulseSplashScreen({Key? key}) : super(key: key);

  @override
  State<SevaPulseSplashScreen> createState() => _SevaPulseSplashScreenState();
}

class _SevaPulseSplashScreenState extends State<SevaPulseSplashScreen> 
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  int _currentPage = 0;
  
  final List<Map<String, dynamic>> _splashScreens = [
    {
      'title': 'SEVA PULSE',
      'subtitle': 'Health Access',
      'description': 'Find clinics and hospitals in your city with available transportation options',
      'color': const Color(0xFF3498db),
      'buttonText': 'Next'
    },
    {
      'title': 'SEVA PULSE',
      'subtitle': 'Queue Management',
      'description': 'Skip the waiting line by registering for online queue at clinics and hospitals',
      'color': const Color(0xFF2ecc71),
      'buttonText': 'Next'
    },
    {
      'title': 'SEVA PULSE',
      'subtitle': 'Wellness Guide',
      'description': 'Get health tips and knowledge to stay fit and maintain a healthy lifestyle',
      'color': const Color(0xFFe74c3c),
      'buttonText': 'Get Started'
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _navigateToNext() {
    if (_currentPage < _splashScreens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserSelectionScreen()),
      );
    }
  }

  Widget _buildSplashContent(Map<String, dynamic> screenData) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // K-STAR Logo with animation (replaces the icons)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 250,
                  height: 250,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: screenData['color'].withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: screenData['color'].withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/logo/kstarlogo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // Title with fade animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              screenData['title'],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2c3e50),
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle with slide animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_slideAnimation.value, 0),
                child: Text(
                  screenData['subtitle'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: screenData['color'],
                    letterSpacing: 1.1,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 30),
          
          // Divider with accent color
          Container(
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              color: screenData['color'],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Description with fade animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              screenData['description'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF7f8c8d),
                height: 1.6,
              ),
            ),
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
        child: Column(
          children: [
            // Skip button (only show on first two pages)
            if (_currentPage < _splashScreens.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const UserSelectionScreen()),
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: _splashScreens[_currentPage]['color'],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            
            // PageView for splash screens
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _splashScreens.length,
                itemBuilder: (context, index) {
                  return _buildSplashContent(_splashScreens[index]);
                },
              ),
            ),
            
            // Page indicators
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _splashScreens.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index 
                          ? _splashScreens[index]['color']
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _fadeAnimation.value,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _splashScreens[_currentPage]['color'],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: _splashScreens[_currentPage]['color'].withOpacity(0.3),
                        ),
                        child: Text(
                          _splashScreens[_currentPage]['buttonText'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
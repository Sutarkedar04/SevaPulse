import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import 'prescriptions_screen.dart';
import 'contact_us_screen.dart';
import 'specialties_screen.dart';
import 'profile_screen.dart';
import 'my_medicine_screen.dart';
import 'chatbot_screen.dart';
import 'canteen_menu_screen.dart';
import 'health_feed_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  // Pages for bottom navigation
  final List<Widget> _pages = [
    const HomeContent(),
    const MyMedicineScreen(),
    const PrescriptionsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from Seva Pulse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _openChatbot(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatbotScreen(),
      ),
    );
  }

  void _contactUs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactUsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: AppBar(
        title: const Text(
          'SEVA PULSE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        actions: _currentIndex == 0 ? [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  backgroundColor: Color(0xFF27ae60),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('My Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'contact',
                child: Text('Contact Us'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              } else if (value == 'profile') {
                setState(() {
                  _currentIndex = 3; // Switch to Profile tab
                });
              } else if (value == 'contact') {
                _contactUs(context);
              }
            },
          ),
        ] : null,
      ),
      body: _pages[_currentIndex],
      // Replaced FAB with Chatbot button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openChatbot(context),
        backgroundColor: const Color(0xFF3498db),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildAnimatedBottomNavBar(),
    );
  }

  Widget _buildAnimatedBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF3498db),
          unselectedItemColor: const Color(0xFF7f8c8d),
          backgroundColor: Colors.white,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 0 
                      ? const Color(0xFF3498db).withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home,
                  color: _currentIndex == 0 
                      ? const Color(0xFF3498db)
                      : const Color(0xFF7f8c8d),
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 1 
                      ? const Color(0xFF3498db).withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: _currentIndex == 1 
                      ? const Color(0xFF3498db)
                      : const Color(0xFF7f8c8d),
                ),
              ),
              label: 'My Medicine',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 2 
                      ? const Color(0xFF3498db).withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medication,
                  color: _currentIndex == 2 
                      ? const Color(0xFF3498db)
                      : const Color(0xFF7f8c8d),
                ),
              ),
              label: 'Prescriptions',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 3 
                      ? const Color(0xFF3498db).withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  color: _currentIndex == 3 
                      ? const Color(0xFF3498db)
                      : const Color(0xFF7f8c8d),
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Home Content Widget with Queue Structure Card Stack
class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with SingleTickerProviderStateMixin {
  List<int> cardOrder = [0, 1, 2]; // 0: Front, 1: Middle, 2: Back
  List<Color> cardColors = [
    const Color(0xFF3498db), // Blue for Appointment
    const Color(0xFFe74c3c), // Red for Health Tip
    const Color(0xFF2ecc71), // Green for Health Feed
  ];

  List<Map<String, dynamic>> cardData = [
    {
      'title': 'Book an Appointment',
      'subtitle': 'Schedule with top specialists and get the best medical care. Choose from various specialties and book your visit in just a few taps.',
      'icon': Icons.calendar_today,
      'buttonText': 'Book Now',
      'onPressed': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SpecialtiesScreen(),
          ),
        );
      },
    },
    {
      'title': 'Health Tips',
      'subtitle': 'Daily Health Tips for Better Living\n• Stay hydrated with 8 glasses of water daily\n• Exercise for 30 minutes every day\n• Get 7-8 hours of quality sleep\n• Eat balanced meals with fruits & vegetables',
      'icon': Icons.health_and_safety,
      'buttonText': 'View More Tips',
      'onPressed': (BuildContext context) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('More health tips coming soon!'),
            backgroundColor: Color(0xFF27ae60),
          ),
        );
      },
    },
    {
      'title': 'Health Feed',
      'subtitle': 'Latest health articles and news\n• New Health Camp Announced\n• Government Health Scheme Updates\n• Wellness Program Starting Soon\n• Seasonal Health Advisory',
      'icon': Icons.feed,
      'buttonText': 'Explore Feed',
      'onPressed': (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HealthFeedScreen(),
          ),
        );
      },
    },
  ];

  void changeCardOrder(int cardId, int currentIndex) {
    setState(() {
      // Move the dragged card to the front of the queue
      cardOrder.remove(cardId);
      cardOrder.insert(0, cardId);
    });
  }

  void _openCanteenMenu(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CanteenMenuScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> upcomingVisits = [
      {
        'doctor': 'Dr. Evelyn Reed',
        'specialty': 'Cardiologist',
        'date': 'Tomorrow',
        'time': '10:30 AM',
      },
      {
        'doctor': 'Dr. Alan Grant',
        'specialty': 'Dermatologist',
        'date': '24 Dec 2024',
        'time': '02:00 PM',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(context),
          const SizedBox(height: 20),
          
          // Queue Structure Card Stack
          SizedBox(
            height: 300, // Adjusted height for queue structure
            child: Stack(
              children: [
                for (int i = 0; i < cardOrder.length; i++)
                  QueueCard(
                    color: cardColors[cardOrder[i]],
                    index: i,
                    key: ValueKey(cardOrder[i]),
                    value: cardOrder[i],
                    title: cardData[cardOrder[i]]['title'],
                    subtitle: cardData[cardOrder[i]]['subtitle'],
                    icon: cardData[cardOrder[i]]['icon'],
                    buttonText: cardData[cardOrder[i]]['buttonText'],
                    onPressed: () => cardData[cardOrder[i]]['onPressed'](context),
                    onDragged: () => changeCardOrder(cardOrder[i], i),
                  ),
              ],
            ),
          ),
          
          // Swipe instruction text below cards
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Swipe the card to explore more options',
              style: TextStyle(
                color: Color(0xFF7f8c8d),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Upcoming Visits
          _buildUpcomingVisitsCard(upcomingVisits),
          
          const SizedBox(height: 20),
          
          // Canteen Card
          _buildCanteenCard(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${authProvider.user?.name.split(' ')[0] ?? ''}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2c3e50),
          ),
        ),
        const SizedBox(height: 12),
        // Add your image here
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: AssetImage('assets/images/userfirstimg.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Need to see a doctor?',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF7f8c8d),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Book your next appointment in just a few clicks.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF7f8c8d),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingVisitsCard(List<Map<String, dynamic>> upcomingVisits) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.upcoming, color: Color(0xFF3498db)),
                SizedBox(width: 8),
                Text(
                  'Upcoming Visits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...upcomingVisits.map((visit) => _buildVisitItem(visit)),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitItem(Map<String, dynamic> visit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFecf0f1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3498db),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${visit['doctor']} - ${visit['specialty']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${visit['date']} • ${visit['time']}',
                  style: const TextStyle(
                    color: Color(0xFF7f8c8d),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanteenCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, title, and button in the same row
            Row(
              children: [
                const Icon(Icons.restaurant, color: Color(0xFFe67e22)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Hospital Canteen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _openCanteenMenu(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFe67e22),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'View Menu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withValues(alpha: 0.3),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Fresh & Healthy Food Available',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enjoy delicious and nutritious meals prepared fresh daily. Our canteen offers a variety of healthy options for patients and visitors.',
              style: TextStyle(
                color: Color(0xFF7f8c8d),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.access_time, color: Color(0xFFe67e22), size: 16),
                SizedBox(width: 4),
                Text(
                  'Open: 7:00 AM - 9:00 PM',
                  style: TextStyle(
                    color: Color(0xFF7f8c8d),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Queue Card Widget with Deck Structure
class QueueCard extends StatefulWidget {
  final Color color;
  final int index;
  final int value;
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonText;
  final VoidCallback onPressed;
  final VoidCallback onDragged;

  const QueueCard({
    Key? key,
    required this.color,
    required this.index,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonText,
    required this.onPressed,
    required this.onDragged,
  }) : super(key: key);

  @override
  State<QueueCard> createState() => _QueueCardState();
}

class _QueueCardState extends State<QueueCard> {
  bool _isDragging = false;
  double _dragOffset = 0.0;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = details.delta.dx;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    
    // Very sensitive swipe detection - just 20px threshold
    if (_dragOffset.abs() > 20) {
      widget.onDragged();
    }
    
    _dragOffset = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    // All cards have same size
    const double cardWidth = 320;
    const double cardHeight = 200;
    
    // Queue structure positions (like a deck of cards)
    Map<int, Map<String, double>> queuePositions = {
      0: { // Front card (fully visible)
        'top': 20.0,
        'left': -30,
        'scale': 1.0,
        'elevation': 12.0,
        'opacity': 0.8,
      },
      1: { // Middle card (partially behind)
        'top': 40.0,
        'left': -10,
        'scale': 0.95,
        'elevation': 8.0,
        'opacity': 0.9,
      },
      2: { // Back card (mostly behind)
        'top': 60.0,
        'left': 20,
        'scale': 0.9,
        'elevation': 4.0,
        'opacity': 1,
      },
    };

    final position = queuePositions[widget.index]!;
    final double top = position['top']!;
    final double left = position['left']!;
    final double scale = position['scale']!;
    final double elevation = position['elevation']!;
    final double opacity = position['opacity']!;

    double horizontalOffset = _isDragging ? _dragOffset : 0.0;

    return AnimatedPositioned(
      duration: Duration(milliseconds: _isDragging ? 0 : 300),
      top: top,
      left: ((screenWidth - cardWidth) / 2) + left + horizontalOffset,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        behavior: HitTestBehavior.translucent,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: _isDragging ? 0 : 300),
          opacity: opacity,
          child: AnimatedScale(
            duration: Duration(milliseconds: _isDragging ? 0 : 300),
            scale: scale,
            child: Card(
              elevation: elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color,
                      widget.color.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 28,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.index + 1}/3',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.onPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: widget.color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text(
                                widget.buttonText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (widget.index == 0) // Only show instruction on front card
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.swipe,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Swipe to cycle cards',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
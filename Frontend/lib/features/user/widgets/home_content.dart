// lib/features/user/widgets/home_content.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/appointment_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../shared/widgets/upcoming_visits_card.dart';
import '../../../shared/widgets/canteen_card.dart';
import '../../../shared/widgets/horizontal_card_carousel.dart';
import 'home_welcome_section.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List<Color> cardColors = const [
    Color(0xFF3498db),
    Color(0xFFe74c3c),
    Color(0xFF2ecc71),
  ];

  late List<Map<String, dynamic>> cardData;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCardData();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadAppointments();
    }
  }

  void _initializeCardData() {
    cardData = [
      {
        'title': 'Book an Appointment',
        'subtitle': 'Schedule with top specialists and get the best medical care. Choose from various specialties and book your visit in just a few taps.',
        'icon': Icons.calendar_today,
        'buttonText': 'Book Now',
        'onPressed': (BuildContext context) {
          Navigator.pushNamed(context, '/specialties').then((_) {
            _loadAppointments();
          });
        },
      },
      {
        'title': 'Health Tips',
        'subtitle': 'Daily Health Tips for Better Living\n• Stay hydrated with 8 glasses of water daily\n• Exercise for 30 minutes every day\n• Get 7-8 hours of quality sleep\n• Eat balanced meals with fruits & vegetables',
        'icon': Icons.health_and_safety,
        'buttonText': 'View More Tips',
        'onPressed': (BuildContext context) {
          Navigator.pushNamed(context, '/health-tips');
        },
      },
      {
        'title': 'Health Camps',
        'subtitle': 'Latest health articles and news\n• New Health Camp Announced\n• Government Health Scheme Updates\n• Wellness Program Starting Soon\n• Seasonal Health Advisory',
        'icon': Icons.feed,
        'buttonText': 'Explore Feed',
        'onPressed': (BuildContext context) {
          Navigator.pushNamed(context, '/health-feed');
        },
      },
    ];
  }

  Future<void> _loadAppointments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    print('\n=== LOADING APPOINTMENTS ===');
    print('Token exists: ${authProvider.token != null}');
    print('User ID: ${authProvider.user?.id}');
    print('User Name: ${authProvider.user?.name}');
    
    if (authProvider.token != null && authProvider.token!.isNotEmpty) {
      appointmentProvider.setToken(authProvider.token!);
      await appointmentProvider.loadAppointments();
      
      print('\n=== ALL APPOINTMENTS FROM API ===');
      for (var apt in appointmentProvider.appointments) {
        print('Appointment ID: ${apt.id}');
        print('  - patientId: ${apt.patientId}');
        print('  - doctorName: ${apt.doctorName}');
        print('  - patientName: ${apt.patientName}');
        print('  - date: ${apt.date.toLocal()}');
        print('  - time: ${apt.time}');
        print('  - status: ${apt.status}');
        print('  - Matches user? ${apt.patientId == authProvider.user?.id}');
      }
    } else {
      print('No token available to load appointments');
    }
  }

  void _openCanteenMenu(BuildContext context) {
    Navigator.pushNamed(context, '/canteen-menu');
  }

  void _bookAppointment(BuildContext context) {
    Navigator.pushNamed(context, '/specialties').then((_) {
      _loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return RefreshIndicator(
      onRefresh: () async {
        await _loadAppointments();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeWelcomeSection(),
            const SizedBox(height: 20),
            
            // Horizontal Card Carousel
            HorizontalCardCarousel(
              cardData: cardData,
              cardColors: cardColors,
              autoSlideInterval: const Duration(seconds: 5),
            ),
            
            const SizedBox(height: 20),
            
            // Upcoming Visits Section with Refresh Button
            Consumer<AppointmentProvider>(
              builder: (context, appointmentProvider, child) {
                final authProvider = Provider.of<AuthProvider>(context);
                final userId = authProvider.user?.id ?? '';
                
                print('\n=== BUILDING UPCOMING VISITS ===');
                print('Current User ID: $userId');
                print('Total appointments in provider: ${appointmentProvider.appointments.length}');
                
                if (appointmentProvider.isLoading) {
                  return _buildLoadingCard();
                }
                
                if (appointmentProvider.error != null) {
                  return _buildErrorCard(appointmentProvider.error!);
                }
                
                // Filter by user and exclude cancelled appointments
                final userAppointments = appointmentProvider.appointments
                    .where((a) => a.patientId == userId && a.status.toLowerCase() != 'cancelled')
                    .toList();
                
                print('Appointments after user filter (excluding cancelled): ${userAppointments.length}');
                
                // Get current date in local timezone
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                
                final upcomingAppointments = userAppointments
                    .where((a) {
                      // Convert to local and compare dates
                      final localDate = a.date.toLocal();
                      final appointmentDate = DateTime(
                        localDate.year,
                        localDate.month,
                        localDate.day,
                      );
                      return appointmentDate.isAtSameMomentAs(today) || 
                             appointmentDate.isAfter(today);
                    })
                    .toList()
                  ..sort((a, b) => a.date.compareTo(b.date));
                
                print('Upcoming appointments count: ${upcomingAppointments.length}');
                for (var apt in upcomingAppointments) {
                  print('  ✓ ${apt.doctorName} on ${DateFormat('MMM dd').format(apt.date.toLocal())} at ${apt.time} (${apt.status})');
                }
                
                // Also show past appointments (excluding cancelled)
                final pastAppointments = userAppointments
                    .where((a) {
                      final localDate = a.date.toLocal();
                      final appointmentDate = DateTime(
                        localDate.year,
                        localDate.month,
                        localDate.day,
                      );
                      return appointmentDate.isBefore(today);
                    })
                    .toList()
                  ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and refresh button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.upcoming, color: Color(0xFF3498db)),
                            SizedBox(width: 8),
                            Text(
                              'My Appointments',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2c3e50),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Color(0xFF3498db)),
                          onPressed: () {
                            _loadAppointments();
                          },
                          tooltip: 'Refresh Appointments',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Upcoming Visits Card
                    UpcomingVisitsCard(
                      upcomingAppointments: upcomingAppointments,
                      onBookAppointment: () => _bookAppointment(context),
                    ),
                    
                    // Show past appointments if any
                    if (pastAppointments.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Past Appointments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...pastAppointments.map((appointment) => 
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.history, color: Color(0xFF7f8c8d)),
                            title: Text('Dr. ${appointment.doctorName}'),
                            subtitle: Text('${DateFormat('MMM dd, yyyy').format(appointment.date.toLocal())} at ${appointment.time}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                appointment.status.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF7f8c8d),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Canteen Card
            CanteenCard(
              onViewMenu: () => _openCanteenMenu(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498db)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading appointments...',
                style: TextStyle(
                  color: Color(0xFF7f8c8d),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading appointments',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7f8c8d),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadAppointments(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
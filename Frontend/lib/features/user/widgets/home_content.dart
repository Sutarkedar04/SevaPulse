// lib/features/user/widgets/home_content.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/common/widgets/section_header.dart';
import '../../../presentation/common/widgets/upcoming_visits_card.dart';
import '../../../presentation/common/widgets/canteen_card.dart';
import '../../../presentation/common/widgets/horizontal_card_carousel.dart';
import 'home_welcome_section.dart';
import '../../../data/providers/appointment_provider.dart';
import '../../../data/providers/auth_provider.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with AutomaticKeepAliveClientMixin {
  final List<Color> cardColors = const [
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
    _initializeCardData();
  }

  void _initializeCardData() {
    cardData = [
      {
        'title': 'Book an Appointment',
        'subtitle': 'Schedule with top specialists and get the best medical care.',
        'icon': Icons.calendar_today,
        'buttonText': 'Book Now',
        'onPressed': (BuildContext context) {
          Navigator.pushNamed(context, '/specialties');
        },
      },
      {
        'title': 'Health Tips',
        'subtitle': 'Daily Health Tips for Better Living\n• Stay hydrated\n• Exercise daily\n• Get quality sleep',
        'icon': Icons.health_and_safety,
        'buttonText': 'View Tips',
        'onPressed': (BuildContext context) {
          Navigator.pushNamed(context, '/health-tips');
        },
      },
      {
        'title': 'Health Camps',
        'subtitle': 'Latest health articles and news about upcoming camps',
        'icon': Icons.feed,
        'buttonText': 'Explore',
        'onPressed': (BuildContext context) {
          Navigator.pushNamed(context, '/health-feed');
        },
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return RefreshIndicator(
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
        if (authProvider.token != null) {
          appointmentProvider.setToken(authProvider.token!);
          await appointmentProvider.loadAppointments();
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeWelcomeSection(),
            const SizedBox(height: 20),
            
            HorizontalCardCarousel(
              cardData: cardData,
              cardColors: cardColors,
              autoSlideInterval: const Duration(seconds: 5),
            ),
            
            const SizedBox(height: 20),
            
            Consumer<AppointmentProvider>(
              builder: (context, appointmentProvider, child) {
                final authProvider = Provider.of<AuthProvider>(context);
                final userId = authProvider.user?.id ?? '';
                
                final userAppointments = appointmentProvider.appointments
                    .where((a) => a.patientId == userId && a.status.toLowerCase() != 'cancelled')
                    .toList();
                
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                
                final upcomingAppointments = userAppointments
                    .where((a) {
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
                
                return Column(
                  children: [
                    SectionHeader(
                      title: 'My Appointments',
                      icon: Icons.upcoming,
                      showSeeAll: true,
                      onSeeAll: () {
                        Navigator.pushNamed(context, '/appointments');
                      },
                    ),
                    const SizedBox(height: 16),
                    UpcomingVisitsCard(
                      upcomingAppointments: upcomingAppointments,
                      onBookAppointment: () {
                        Navigator.pushNamed(context, '/specialties');
                      },
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            CanteenCard(
              onViewMenu: () => Navigator.pushNamed(context, '/canteen-menu'),
            ),
          ],
        ),
      ),
    );
  }
}
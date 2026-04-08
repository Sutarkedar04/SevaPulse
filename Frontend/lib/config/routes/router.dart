// lib/config/routes/router.dart
import 'package:go_router/go_router.dart';
import '../../features/auth/SevaPulseSplashScreen.dart';
import '../../features/auth/user_selection_screen.dart';
import '../../features/auth/user_login_screen.dart';
import '../../features/auth/user_register_screen.dart';
import '../../features/auth/doctor_login_screen.dart';
import '../../features/auth/doctor_register_screen.dart';
import '../../features/user/screens/user_home_screen.dart';
import '../../features/user/screens/specialties_screen.dart';
import '../../features/user/screens/doctor_list_screen.dart';
import '../../features/user/screens/book_appointment_screen.dart';
import '../../features/user/screens/appointments_screen.dart';
import '../../features/user/screens/my_medicine_screen.dart';
import '../../features/user/screens/prescriptions_screen.dart';
import '../../features/user/screens/health_feed_screen.dart';
import '../../features/user/screens/health_tips.dart';
import '../../features/user/screens/canteen_menu_screen.dart';
import '../../features/user/screens/chatbot_screen.dart';
import '../../features/user/screens/contact_us_screen.dart';
import '../../features/user/screens/profile_screen.dart';
import '../../features/doctor/screens/doctor_home_screen.dart';
import '../../features/doctor/screens/patients_screen.dart';
import '../../features/doctor/screens/events_screen.dart';
import '../../features/doctor/screens/profile_screen.dart' as doctor_profile;
import 'app_routes.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SevaPulseSplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.userSelection,
          name: 'userSelection',
          builder: (context, state) => const UserSelectionScreen(),
        ),
        
        // Auth Routes
        GoRoute(
          path: AppRoutes.userLogin,
          name: 'userLogin',
          builder: (context, state) => const UserLoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.userRegister,
          name: 'userRegister',
          builder: (context, state) => const UserRegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorLogin,
          name: 'doctorLogin',
          builder: (context, state) => const DoctorLoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorRegister,
          name: 'doctorRegister',
          builder: (context, state) => const DoctorRegisterScreen(),
        ),
        
        // User Routes
        GoRoute(
          path: AppRoutes.userHome,
          name: 'userHome',
          builder: (context, state) => const UserHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.specialties,
          name: 'specialties',
          builder: (context, state) => const SpecialtiesScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorList,
          name: 'doctorList',
          builder: (context, state) {
            final specialty = state.uri.queryParameters['specialty'] ?? '';
            final specialtyId = state.uri.queryParameters['specialtyId'] ?? '';
            final department = state.uri.queryParameters['department'] ?? '';
            return DoctorListScreen(
              specialty: specialty,
              specialtyId: specialtyId,
              department: department,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.bookAppointment,
          name: 'bookAppointment',
          builder: (context, state) {
            final specialty = state.uri.queryParameters['specialty'] ?? '';
            final doctor = {'id': '', 'name': ''};
            return BookAppointmentScreen(
              doctor: doctor,
              specialty: specialty,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.appointments,
          name: 'appointments',
          builder: (context, state) => const AppointmentsScreen(),
        ),
        GoRoute(
          path: AppRoutes.myMedicine,
          name: 'myMedicine',
          builder: (context, state) => const MyMedicineScreen(),
        ),
        GoRoute(
          path: AppRoutes.prescriptions,
          name: 'prescriptions',
          builder: (context, state) => const PrescriptionsScreen(),
        ),
        GoRoute(
          path: AppRoutes.healthFeed,
          name: 'healthFeed',
          builder: (context, state) => const HealthFeedScreen(),
        ),
        GoRoute(
          path: AppRoutes.healthTips,
          name: 'healthTips',
          builder: (context, state) => const HealthTipsScreen(),
        ),
        GoRoute(
          path: AppRoutes.canteenMenu,
          name: 'canteenMenu',
          builder: (context, state) => const CanteenMenuScreen(),
        ),
        GoRoute(
          path: AppRoutes.chatbot,
          name: 'chatbot',
          builder: (context, state) => const ChatbotScreen(),
        ),
        GoRoute(
          path: AppRoutes.contactUs,
          name: 'contactUs',
          builder: (context, state) => const ContactUsScreen(),
        ),
        GoRoute(
          path: AppRoutes.userProfile,
          name: 'userProfile',
          builder: (context, state) => const ProfileScreen(),
        ),
        
        // Doctor Routes
        GoRoute(
          path: AppRoutes.doctorHome,
          name: 'doctorHome',
          builder: (context, state) => const DoctorHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.patients,
          name: 'patients',
          builder: (context, state) => PatientsScreen(  // ✅ Removed 'const'
            patients: const [],
            onPrescriptionPressed: (patient) {},  // ✅ Empty function instead of null
          ),
        ),
        GoRoute(
          path: AppRoutes.events,
          name: 'events',
          builder: (context, state) => const EventsScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorProfile,
          name: 'doctorProfile',
          builder: (context, state) => doctor_profile.ProfileScreen(
            doctorProfile: const {},
            onLogoutPressed: () {},
          ),
        ),
      ],
    );
  }
}
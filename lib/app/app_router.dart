import 'package:flutter_rapid_triage/features/auth/screens/login_screen.dart';
import 'package:flutter_rapid_triage/features/splash/splash_screen.dart';
import 'package:flutter_rapid_triage/features/triage/screens/about/about_screen.dart';
import 'package:flutter_rapid_triage/features/triage/screens/history/sync_history_screen.dart';
import 'package:flutter_rapid_triage/features/triage/screens/home/home_dashboard_screen.dart';
import 'package:flutter_rapid_triage/features/triage/screens/intake/new_triage_intake_screen.dart';
import 'package:flutter_rapid_triage/features/triage/screens/patient/patient_details_screen.dart';
import 'package:flutter_rapid_triage/features/triage/screens/queue/patient_queue_screen.dart';
import 'package:flutter_rapid_triage/features/triage/screens/settings/settings_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: '/intake',
        builder: (context, state) => const NewTriageIntakeScreen(),
        // Added parent route context for proper back navigation
      ),
      GoRoute(
        path: '/queue',
        builder: (context, state) => const PatientQueueScreen(),
      ),
      GoRoute(
        path: '/patient/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PatientDetailsScreen(patientId: id);
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const SyncHistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/triage/presentation/screens/splash/splash_screen.dart';
import '../../features/triage/presentation/screens/login/login_screen.dart';
import '../../features/triage/presentation/screens/home/home_dashboard_screen.dart';
import '../../features/triage/presentation/screens/intake/new_triage_intake_screen.dart';
import '../../features/triage/presentation/screens/queue/patient_queue_screen.dart';
import '../../features/triage/presentation/screens/patient/patient_details_screen.dart';
import '../../features/triage/presentation/screens/history/sync_history_screen.dart';
import '../../features/triage/presentation/screens/settings/settings_screen.dart';
import '../../features/triage/presentation/screens/about/about_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: '/intake',
        builder: (context, state) => const NewTriageIntakeScreen(),
      ),
      GoRoute(
        path: '/queue',
        builder: (context, state) => const PatientQueueScreen(),
      ),
      GoRoute(
        path: '/patient',
        builder: (context, state) => const PatientDetailsScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const SyncHistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}
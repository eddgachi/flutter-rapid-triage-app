import 'package:flutter/material.dart';
import 'package:flutter_rapid_triage/app/app_initializer.dart';
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

  /// Crossfade used between the bottom-nav root screens (and login/splash),
  /// which are siblings swapped via `go()` rather than drilled into — a
  /// directional slide would imply an ordering between tabs that doesn't
  /// exist, so a fade feels right instead.
  static CustomTransitionPage<void> _fadePage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  /// Slide-and-fade used for screens that are drilled into (intake, patient
  /// details) so pushing forward and popping back both read as a single
  /// continuous motion instead of the platform's default abrupt cut/zoom.
  static CustomTransitionPage<void> _slidePage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideIn =
            Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        final slideOut =
            Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.06, 0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeInCubic,
              ),
            );
        return SlideTransition(
          position: slideOut,
          child: SlideTransition(
            position: slideIn,
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = AppInitializer.authRepository.isLoggedIn();
      final location = state.matchedLocation;

      if (location == '/') return null; // splash decides where to go next

      if (!loggedIn && location != '/login') return '/login';
      if (loggedIn && location == '/login') return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _fadePage(state, const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadePage(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            _fadePage(state, const HomeDashboardScreen()),
      ),
      GoRoute(
        path: '/intake',
        pageBuilder: (context, state) =>
            _slidePage(state, const NewTriageIntakeScreen()),
        // Added parent route context for proper back navigation
      ),
      GoRoute(
        path: '/queue',
        pageBuilder: (context, state) =>
            _fadePage(state, const PatientQueueScreen()),
      ),
      GoRoute(
        path: '/patient/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slidePage(state, PatientDetailsScreen(patientId: id));
        },
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) =>
            _fadePage(state, const SyncHistoryScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            _fadePage(state, const SettingsScreen()),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) => _fadePage(state, const AboutScreen()),
      ),
    ],
  );
}

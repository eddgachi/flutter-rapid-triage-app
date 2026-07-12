import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _statuses = [
    'Initializing Systems...',
    'Connecting to Secure Gateway...',
    'Syncing Offline Database...',
    'Validating Field Protocol...',
  ];

  int _currentIndex = 0;
  String _statusText = 'Initializing Systems...';

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  void _startSequence() {
    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_currentIndex < _statuses.length) {
        setState(() {
          _statusText = _statuses[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            context.go('/login');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x0D003D9B), Colors.transparent, Color(0x0D005FAF)],
          ),
        ),
        child: Stack(
          children: [
            // Medical grid background
            Positioned.fill(child: CustomPaint(painter: _MedicalGridPainter())),
            // Large abstract shape
            Positioned(
              top: -MediaQuery.of(context).size.height * 0.1,
              right: -MediaQuery.of(context).size.width * 0.25,
              child: Icon(
                Icons.emergency,
                size: 300,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    _AnimatedLogo(),
                    const SizedBox(height: AppSpacing.lg),
                    // Identity
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 20),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            'RapidTriage',
                            style: AppTypography.textTheme.headlineLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 32,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Mission-Critical Field Triage',
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  letterSpacing: 2,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Status
                    AnimatedOpacity(
                      opacity: _currentIndex > 0 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sync,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            _statusText,
                            style: AppTypography.textTheme.labelMedium
                                ?.copyWith(color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom indicator
            Positioned(
              bottom: 64,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary.withOpacity(0.3),
                      ),
                      backgroundColor: AppColors.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'v4.2.0-secure',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Icon(
                Icons.emergency,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MedicalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 32.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:flutter_rapid_triage/app/app_initializer.dart';
import 'package:flutter_rapid_triage/app/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitializer.initialize();

  runApp(const ProviderScope(child: RapidTriageApp()));
}

class RapidTriageApp extends StatelessWidget {
  const RapidTriageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RapidTriage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_rapid_triage/app/app_initializer.dart';
import 'package:flutter_rapid_triage/app/app_router.dart';
import 'package:flutter_rapid_triage/app/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitializer.initialize();

  runApp(const ProviderScope(child: RapidTriageApp()));
}

class RapidTriageApp extends ConsumerWidget {
  const RapidTriageApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'RapidTriage',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}

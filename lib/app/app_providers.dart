import 'package:flutter_rapid_triage/app/app_initializer.dart';
import 'package:flutter_rapid_triage/core/services/permission_service.dart';
import 'package:flutter_rapid_triage/features/triage/repositories/triage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/api_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/fake_auth_service.dart';
import '../core/services/hive_service.dart';
import '../core/services/location_service.dart';

// Service Providers - using the initialized instances
final hiveServiceProvider = Provider<HiveService>((ref) {
  return AppInitializer.hiveService;
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return AppInitializer.apiService;
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return AppInitializer.connectivityService;
});

final authServiceProvider = Provider<FakeAuthService>((ref) {
  return AppInitializer.authService;
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return AppInitializer.locationService;
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return AppInitializer.permissionService;
});

// Repository Providers
final triageRepositoryProvider = Provider<TriageRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return TriageRepository(hiveService: hiveService);
});

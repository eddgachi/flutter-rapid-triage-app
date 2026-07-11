import 'package:flutter_rapid_triage/core/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/services/api_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/fake_auth_service.dart';
import '../core/services/hive_service.dart';
import '../core/services/location_service.dart';

class AppInitializer {
  static late final HiveService hiveService;
  static late final ApiService apiService;
  static late final ConnectivityService connectivityService;
  static late final FakeAuthService authService;
  static late final LocationService locationService;
  static late final PermissionService permissionService;

  static Future<void> initialize() async {
    hiveService = HiveService();
    apiService = ApiService();
    connectivityService = ConnectivityService();
    authService = FakeAuthService();
    locationService = LocationService();
    permissionService = PermissionService();

    await hiveService.initialize();
    await apiService.initialize();

    // Check permissions (non-blocking)
    await _checkPermissions();
  }

  static Future<void> _checkPermissions() async {
    try {
      // Check location permission
      final locationStatus = await permissionService.getLocationPermission();

      if (locationStatus.isDenied) {
        // Permission denied
        print('Location permission denied');
      } else if (locationStatus.isPermanentlyDenied) {
        // Permission permanently denied - user needs to go to settings
        print('Location permission permanently denied');
      } else if (locationStatus.isGranted) {
        // Permission granted
        print('Location permission granted');

        // Check if location services are enabled
        final isEnabled = await permissionService.isLocationServiceEnabled();
        if (!isEnabled) {
          print('Location services are disabled');
        }
      }
    } catch (e) {
      print('Error checking permissions: $e');
    }
  }
}

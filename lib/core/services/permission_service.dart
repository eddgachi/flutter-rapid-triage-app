// lib/core/services/permission_service.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Check and request location permission
  Future<PermissionStatus> getLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      return await Permission.location.request();
    }
    return status;
  }

  // Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request all necessary permissions
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final permissions = <Permission>[
      Permission.location,
      // Add more permissions as needed:
      // Permission.camera,
      // Permission.storage,
      // Permission.notifications,
    ];

    final results = await permissions.request();
    return results;
  }

  // Get status of all permissions
  Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    final permissions = <Permission>[
      Permission.location,
      // Add more permissions as needed
    ];

    final Map<Permission, PermissionStatus> statusMap = {};
    for (final permission in permissions) {
      statusMap[permission] = await permission.status;
    }
    return statusMap;
  }

  // Show permission rationale dialog
  Future<bool> showPermissionRationale({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Settings'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}

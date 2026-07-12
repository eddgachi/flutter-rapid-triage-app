import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/location_service.dart';
import '../models/location.dart';
import '../models/patient.dart';
import '../models/triage_record.dart';
import '../repositories/triage_repository.dart';
import 'history_controller.dart';
import 'home_controller.dart';
import 'queue_controller.dart';

class IntakeState {
  const IntakeState({
    this.isLoading = false,
    this.success = false,
    this.error,
    this.currentLocation,
    this.isLocationLoading = false,
    this.locationError,
  });

  final bool isLoading;
  final bool success;
  final String? error;
  final TriageLocation? currentLocation;
  final bool isLocationLoading;
  final String? locationError;

  IntakeState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
    TriageLocation? currentLocation,
    bool? isLocationLoading,
    String? locationError,
  }) {
    return IntakeState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error ?? this.error,
      currentLocation: currentLocation ?? this.currentLocation,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      locationError: locationError ?? this.locationError,
    );
  }
}

class IntakeController extends Notifier<IntakeState> {
  /// Fallback location used when the device is offline or GPS is unavailable.
  static const TriageLocation _fallbackLocation = TriageLocation(
    latitude: 0.0,
    longitude: 0.0,
  );

  @override
  IntakeState build() {
    _getCurrentLocation();
    return const IntakeState();
  }

  TriageRepository get _repository => ref.read(triageRepositoryProvider);
  LocationService get _locationService => ref.read(locationServiceProvider);
  ConnectivityService get _connectivityService =>
      ref.read(connectivityServiceProvider);

  /// Attempts to fetch the current GPS location.
  ///
  /// If the device is offline, GPS is disabled, permission is denied,
  /// or the request times out — returns [0.0, 0.0] immediately.
  Future<TriageLocation> _getCurrentLocation() async {
    try {
      state = state.copyWith(isLocationLoading: true, locationError: null);

      // 1. If offline, skip GPS entirely and use fallback
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        state = state.copyWith(
          currentLocation: _fallbackLocation,
          isLocationLoading: false,
          locationError: null,
        );
        return _fallbackLocation;
      }

      // 2. Check if location services are enabled
      final isServiceEnabled = await _locationService
          .isLocationServiceEnabled();
      if (!isServiceEnabled) {
        state = state.copyWith(
          currentLocation: _fallbackLocation,
          isLocationLoading: false,
          locationError: null,
        );
        return _fallbackLocation;
      }

      // 3. Check / request permission
      final hasPermission = await _locationService.requestPermission();
      if (!hasPermission) {
        state = state.copyWith(
          currentLocation: _fallbackLocation,
          isLocationLoading: false,
          locationError: null,
        );
        return _fallbackLocation;
      }

      // 4. Fetch location with a 5-second timeout to avoid hanging
      final position = await _locationService.getCurrentLocation().timeout(
        const Duration(seconds: 5),
      );

      final location = TriageLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      state = state.copyWith(
        currentLocation: location,
        isLocationLoading: false,
      );
      return location;
    } catch (_) {
      // Any failure (timeout, no GPS fix, error) → use fallback silently
      state = state.copyWith(
        currentLocation: _fallbackLocation,
        isLocationLoading: false,
        locationError: null,
      );
      return _fallbackLocation;
    }
  }

  Future<void> submit({
    required String patientName,
    int? age,
    String? gender,
    required String chiefComplaint,
    String? clinicalNotes,
    required int priority,
    required String status,
    String? nfcTag,
  }) async {
    try {
      state = state.copyWith(isLoading: true, success: false, error: null);

      // Gets location immediately — uses fallback (0.0, 0.0) if offline/unavailable
      final location = await _getCurrentLocation();

      final record = TriageRecord(
        patient: Patient(name: patientName, age: age, gender: gender),
        chiefComplaint: chiefComplaint,
        clinicalNotes: clinicalNotes,
        priority: priority,
        status: status.isNotEmpty ? status : 'pending',
        location: location,
        nfcTag: nfcTag,
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      await _repository.save(record);

      state = state.copyWith(isLoading: false, success: true, error: null);

      // Invalidate other providers so they refresh automatically
      ref.invalidate(homeControllerProvider);
      ref.invalidate(queueControllerProvider);
      ref.invalidate(historyControllerProvider);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshLocation() async {
    await _getCurrentLocation();
  }

  void reset() {
    state = const IntakeState();
  }
}

// Provider definition
final intakeControllerProvider =
    NotifierProvider<IntakeController, IntakeState>(IntakeController.new);

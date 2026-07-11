import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/location_service.dart';
import '../models/location.dart';
import '../models/patient.dart';
import '../models/triage_record.dart';
import '../repositories/triage_repository.dart';

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
  @override
  IntakeState build() {
    // Get location when controller initializes
    _getCurrentLocation();
    return const IntakeState();
  }

  TriageRepository get _repository => ref.read(triageRepositoryProvider);
  LocationService get _locationService => ref.read(locationServiceProvider);

  Future<void> _getCurrentLocation() async {
    try {
      state = state.copyWith(isLocationLoading: true, locationError: null);

      // Check location service first
      final isServiceEnabled = await _locationService
          .isLocationServiceEnabled();
      if (!isServiceEnabled) {
        state = state.copyWith(
          isLocationLoading: false,
          locationError: 'Location services are disabled. Please enable GPS.',
        );
        return;
      }

      // Check permission
      final hasPermission = await _locationService.requestPermission();
      if (!hasPermission) {
        state = state.copyWith(
          isLocationLoading: false,
          locationError:
              'Location permission denied. Please enable in settings.',
        );
        return;
      }

      final position = await _locationService.getCurrentLocation();
      final location = TriageLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      state = state.copyWith(
        currentLocation: location,
        isLocationLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLocationLoading: false,
        locationError: 'Failed to get location: $e',
      );
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

      // If we don't have location yet, try to get it
      TriageLocation? location = state.currentLocation;
      if (location == null && state.locationError == null) {
        await _getCurrentLocation();
        location = state.currentLocation;
      }

      // If location is still null but no error, it's still loading
      if (location == null && state.isLocationLoading) {
        // Wait a bit for location to load
        await Future.delayed(const Duration(seconds: 2));
        location = state.currentLocation;
      }

      final record = TriageRecord(
        patient: Patient(name: patientName, age: age, gender: gender),
        chiefComplaint: chiefComplaint,
        clinicalNotes: clinicalNotes,
        priority: priority,
        status: status.isNotEmpty ? status : 'pending',
        location: location, // Will be null if location couldn't be captured
        nfcTag: nfcTag,
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      await _repository.save(record);

      state = state.copyWith(isLoading: false, success: true, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        success: false,
        error: e.toString(),
      );
    }
  }

  // Refresh location
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

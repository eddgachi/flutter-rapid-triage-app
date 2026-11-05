import 'dart:math';

import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/features/triage/models/location.dart';
import 'package:flutter_rapid_triage/features/triage/models/patient.dart';
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';
import 'package:flutter_rapid_triage/features/triage/repositories/triage_repository.dart';

import 'location_service.dart';

/// Populates the local triage box with a handful of realistic-looking
/// records the first time the app runs, so the dashboard/queue/history
/// screens aren't empty on a fresh install. Only ever seeds when the box
/// is empty, so it never touches real data created afterwards.
class DemoDataSeeder {
  DemoDataSeeder({
    required TriageRepository repository,
    required LocationService locationService,
  }) : _repository = repository,
       _locationService = locationService;

  final TriageRepository _repository;
  final LocationService _locationService;

  /// Used when location is unavailable (denied, disabled, emulator with no
  /// fix, offline). Shared with the live incident map so both fall back to
  /// the same default (Nairobi CBD).
  static const _fallbackCenter = TriageLocation(
    latitude: AppConstants.fallbackLatitude,
    longitude: AppConstants.fallbackLongitude,
  );

  Future<void> seedIfEmpty() async {
    if (_repository.totalPatients() > 0) return;

    final center = await _resolveCenter();
    await _repository.saveAll(_buildDemoRecords(center));
  }

  Future<TriageLocation> _resolveCenter() async {
    try {
      final available = await _locationService.isLocationAvailable();
      if (!available) return _fallbackCenter;

      final position = await _locationService.getCurrentPositionWithTimeout(
        timeout: const Duration(seconds: 4),
      );
      return TriageLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return _fallbackCenter;
    }
  }

  List<TriageRecord> _buildDemoRecords(TriageLocation center) {
    final now = DateTime.now();
    final random = Random();

    // Scatters a point within roughly a 2km radius of [center] so seeded
    // patients look like they were triaged in the field nearby, not all
    // stacked on the exact same coordinate.
    TriageLocation nearby() {
      final angle = random.nextDouble() * 2 * pi;
      final radius = random.nextDouble() * 0.018; // ~0-2km in degrees
      return TriageLocation(
        latitude: center.latitude + radius * cos(angle),
        longitude: center.longitude + radius * sin(angle),
      );
    }

    final seeds = <_DemoSeed>[
      _DemoSeed(
        name: 'Marcus Reed',
        age: 54,
        gender: 'Male',
        complaint: 'Chest pain and shortness of breath',
        notes:
            'Diaphoretic, BP 150/95, pain radiating to left arm. O2 administered.',
        priority: 1,
        syncStatus: SyncStatus.synced,
        minutesAgo: 18,
      ),
      _DemoSeed(
        name: 'Aaliyah Chen',
        age: 7,
        gender: 'Female',
        complaint: 'Fall from bicycle, head laceration',
        notes:
            'Alert and oriented. 3cm scalp laceration, no loss of consciousness reported.',
        priority: 2,
        syncStatus: SyncStatus.pending,
        minutesAgo: 42,
      ),
      _DemoSeed(
        name: 'Robert Hale',
        age: 68,
        gender: 'Male',
        complaint: 'Slurred speech, left-sided weakness',
        notes:
            'Onset ~30 min ago. FAST exam positive. Stroke protocol activated.',
        priority: 1,
        syncStatus: SyncStatus.failed,
        minutesAgo: 65,
      ),
      _DemoSeed(
        name: 'Priya Nair',
        age: 29,
        gender: 'Female',
        complaint: 'Twisted ankle, unable to bear weight',
        notes: 'Swelling over lateral malleolus, no obvious deformity.',
        priority: 3,
        syncStatus: SyncStatus.synced,
        minutesAgo: 95,
      ),
      _DemoSeed(
        name: 'Elena Vasquez',
        age: 81,
        gender: 'Female',
        complaint: 'Generalized weakness and dehydration',
        notes:
            'Skin tenting present, confused to time. Family reports poor intake x2 days.',
        priority: 2,
        syncStatus: SyncStatus.pending,
        minutesAgo: 130,
      ),
      _DemoSeed(
        name: 'Tyrell Jackson',
        age: 34,
        gender: 'Male',
        complaint: 'Laceration to forearm, bleeding controlled',
        notes:
            'Direct pressure applied, bleeding controlled. Tetanus status unknown.',
        priority: 4,
        syncStatus: SyncStatus.synced,
        minutesAgo: 200,
      ),
      _DemoSeed(
        name: 'Unknown Male',
        age: null,
        gender: 'Unknown',
        complaint: 'Found unresponsive, downtime unknown',
        notes: 'No pulse on arrival, CPR in progress, AED attached.',
        priority: 1,
        syncStatus: SyncStatus.failed,
        minutesAgo: 240,
      ),
      _DemoSeed(
        name: 'Grace Kim',
        age: 45,
        gender: 'Female',
        complaint: 'Minor burns from kitchen accident',
        notes:
            'Superficial burns to right hand, approx 2% BSA. Cooled and dressed.',
        priority: 5,
        syncStatus: SyncStatus.synced,
        minutesAgo: 320,
      ),
    ];

    return seeds
        .map(
          (s) => TriageRecord(
            patient: Patient(name: s.name, age: s.age, gender: s.gender),
            chiefComplaint: s.complaint,
            clinicalNotes: s.notes,
            priority: s.priority,
            status: 'pending',
            location: nearby(),
            createdAt: now.subtract(Duration(minutes: s.minutesAgo)),
            syncStatus: s.syncStatus,
            syncError: s.syncStatus == SyncStatus.failed
                ? 'Connection error: Unable to reach server'
                : null,
          ),
        )
        .toList();
  }
}

class _DemoSeed {
  const _DemoSeed({
    required this.name,
    required this.age,
    required this.gender,
    required this.complaint,
    required this.notes,
    required this.priority,
    required this.syncStatus,
    required this.minutesAgo,
  });

  final String name;
  final int? age;
  final String gender;
  final String complaint;
  final String notes;
  final int priority;
  final SyncStatus syncStatus;
  final int minutesAgo;
}

import 'package:flutter_rapid_triage/features/triage/controllers/intake_controller.dart';
import 'package:flutter_rapid_triage/features/triage/repositories/triage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/api_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/fake_auth_service.dart';
import '../core/services/hive_service.dart';
import '../core/services/location_service.dart';

final hiveServiceProvider = Provider((ref) => HiveService());

final apiServiceProvider = Provider((ref) => ApiService());

final connectivityServiceProvider = Provider((ref) => ConnectivityService());

final locationServiceProvider = Provider((ref) => LocationService());

final fakeAuthServiceProvider = Provider((ref) => FakeAuthService());

final triageRepositoryProvider = Provider(
  (ref) => TriageRepository(hiveService: ref.read(hiveServiceProvider)),
);

final intakeControllerProvider =
    NotifierProvider<IntakeController, IntakeState>(IntakeController.new);

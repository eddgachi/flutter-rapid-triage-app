import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../models/location.dart';
import '../models/patient.dart';
import '../models/triage_record.dart';
import '../repositories/triage_repository.dart';

class IntakeState {
  const IntakeState({this.isLoading = false, this.success = false, this.error});

  final bool isLoading;
  final bool success;
  final String? error;

  IntakeState copyWith({bool? isLoading, bool? success, String? error}) {
    return IntakeState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error,
    );
  }
}

class IntakeController extends Notifier<IntakeState> {
  @override
  IntakeState build() => const IntakeState();

  /// Repository getter
  TriageRepository get _repository => ref.read(triageRepositoryProvider);

  Future<void> submit({
    required String patientName,
    int? age,
    String? gender,
    required String chiefComplaint,
    String? clinicalNotes,
    required int priority,
    required String status,
    TriageLocation? location,
    String? nfcTag,
  }) async {
    try {
      state = state.copyWith(isLoading: true, success: false, error: null);

      final record = TriageRecord(
        patient: Patient(name: patientName, age: age, gender: gender),
        chiefComplaint: chiefComplaint,
        clinicalNotes: clinicalNotes,
        priority: priority,
        status: status,
        location: location,
        nfcTag: nfcTag,
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      await _repository.save(record);

      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        success: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const IntakeState();
  }
}

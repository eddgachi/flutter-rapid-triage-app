import 'package:flutter_rapid_triage/app/app_providers.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/core/services/connectivity_service.dart';
import 'package:flutter_rapid_triage/features/triage/controllers/sync_controller.dart';
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';
import 'package:flutter_rapid_triage/features/triage/repositories/triage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientState {
  const PatientState({
    this.loading = false,
    this.patient,
    this.error,
    this.isDeleting = false,
  });

  final bool loading;
  final TriageRecord? patient;
  final String? error;
  final bool isDeleting;

  PatientState copyWith({
    bool? loading,
    TriageRecord? patient,
    String? error,
    bool? isDeleting,
  }) {
    return PatientState(
      loading: loading ?? this.loading,
      patient: patient ?? this.patient,
      error: error ?? this.error,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

class PatientController extends Notifier<PatientState> {
  @override
  PatientState build() => const PatientState();

  TriageRepository get _repository => ref.read(triageRepositoryProvider);
  ConnectivityService get _connectivity =>
      ref.read(connectivityServiceProvider);

  // ==================== LOAD PATIENT ====================
  Future<void> load(String id) async {
    try {
      state = state.copyWith(loading: true, error: null);

      final patient = _repository.getById(id);

      if (patient == null) {
        state = state.copyWith(loading: false, error: 'Patient not found');
        return;
      }

      state = state.copyWith(loading: false, patient: patient);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ==================== DELETE PATIENT ====================
  Future<bool> delete() async {
    if (state.patient == null) return false;

    try {
      state = state.copyWith(isDeleting: true, error: null);

      await _repository.delete(state.patient!.id);

      state = state.copyWith(isDeleting: false, patient: null);

      return true;
    } catch (e) {
      state = state.copyWith(isDeleting: false, error: e.toString());
      return false;
    }
  }

  // ==================== SYNC RECORD ====================
  /// Attempts to sync the current record, detecting connectivity and setting
  /// the appropriate syncStatus and syncError.
  Future<bool> syncRecord() async {
    if (state.patient == null) return false;

    try {
      state = state.copyWith(loading: true, error: null);

      final connected = await _connectivity.isConnected();
      if (!connected) {
        final updated = state.patient!.copyWith(
          syncStatus: SyncStatus.failed,
          syncError: 'No internet connection',
        );
        await _repository.update(updated);
        state = state.copyWith(loading: false, patient: updated);
        return false;
      }

      // Set as syncing
      await _repository.updateSyncStatus(state.patient!.id, SyncStatus.syncing);
      final syncing = state.patient!.copyWith(syncStatus: SyncStatus.syncing);
      state = state.copyWith(patient: syncing);

      try {
        // Attempt API call via sync service
        final syncController = ref.read(syncControllerProvider.notifier);
        final result = await syncController.syncRecord(state.patient!.id);

        if (result) {
          final updated = state.patient!.copyWith(
            syncStatus: SyncStatus.synced,
            syncError: null,
          );
          await _repository.update(updated);
          state = state.copyWith(loading: false, patient: updated);
          return true;
        } else {
          final updated = state.patient!.copyWith(
            syncStatus: SyncStatus.failed,
            syncError: 'Failed to sync record',
          );
          await _repository.update(updated);
          state = state.copyWith(loading: false, patient: updated);
          return false;
        }
      } catch (e) {
        final updated = state.patient!.copyWith(
          syncStatus: SyncStatus.failed,
          syncError:
              'Sync error: ${e.toString().length > 80 ? e.toString().substring(0, 80) : e.toString()}',
        );
        await _repository.update(updated);
        state = state.copyWith(loading: false, patient: updated);
        return false;
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  // ==================== MARK AS SYNCED ====================
  Future<bool> markSynced() async {
    if (state.patient == null) return false;

    try {
      state = state.copyWith(loading: true, error: null);

      final updated = state.patient!.copyWith(
        syncStatus: SyncStatus.synced,
        syncError: null,
      );

      await _repository.update(updated);

      state = state.copyWith(loading: false, patient: updated);

      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  // ==================== MARK AS PENDING ====================
  Future<bool> markPending() async {
    if (state.patient == null) return false;

    try {
      state = state.copyWith(loading: true, error: null);

      final updated = state.patient!.copyWith(
        syncStatus: SyncStatus.pending,
        syncError: null,
      );

      await _repository.update(updated);

      state = state.copyWith(loading: false, patient: updated);

      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  // ==================== MARK AS FAILED ====================
  Future<bool> markFailed({String? reason}) async {
    if (state.patient == null) return false;

    try {
      state = state.copyWith(loading: true, error: null);

      final updated = state.patient!.copyWith(
        syncStatus: SyncStatus.failed,
        syncError: reason ?? 'Sync failed',
      );

      await _repository.update(updated);

      state = state.copyWith(loading: false, patient: updated);

      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  // ==================== UPDATE PATIENT ====================
  Future<bool> update(TriageRecord updatedRecord) async {
    try {
      state = state.copyWith(loading: true, error: null);

      await _repository.update(updatedRecord);

      state = state.copyWith(loading: false, patient: updatedRecord);

      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  // ==================== REFRESH ====================
  Future<void> refresh() async {
    if (state.patient != null) {
      await load(state.patient!.id);
    }
  }

  // ==================== CLEAR ====================
  void clear() {
    state = const PatientState();
  }

  // ==================== GET PATIENT SUMMARY ====================
  Map<String, dynamic> getPatientSummary() {
    if (state.patient == null) return {};

    final patient = state.patient!;
    return {
      'id': patient.id,
      'name': patient.patient.name,
      'age': patient.patient.age,
      'gender': patient.patient.gender,
      'priority': patient.priority,
      'priorityLabel': _getPriorityLabel(patient.priority),
      'status': patient.status,
      'syncStatus': patient.syncStatus.name,
      'syncError': patient.syncError,
      'chiefComplaint': patient.chiefComplaint,
      'clinicalNotes': patient.clinicalNotes,
      'createdAt': patient.createdAt,
    };
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Critical (P1)';
      case 2:
        return 'Urgent (P2)';
      case 3:
        return 'Delayed (P3)';
      case 4:
        return 'Expectant (P4)';
      case 5:
        return 'Minor (P5)';
      default:
        return 'Unknown';
    }
  }
}

// Provider definition
final patientControllerProvider =
    NotifierProvider<PatientController, PatientState>(PatientController.new);

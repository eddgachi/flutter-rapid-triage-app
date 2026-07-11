import 'package:flutter_rapid_triage/app/app_providers.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
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

  // ==================== MARK AS SYNCED ====================
  Future<bool> markSynced() async {
    if (state.patient == null) return false;

    try {
      state = state.copyWith(loading: true, error: null);

      final updated = state.patient!.copyWith(syncStatus: SyncStatus.synced);

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

      final updated = state.patient!.copyWith(syncStatus: SyncStatus.pending);

      await _repository.update(updated);

      state = state.copyWith(loading: false, patient: updated);

      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  // ==================== MARK AS FAILED ====================
  Future<bool> markFailed() async {
    if (state.patient == null) return false;

    try {
      state = state.copyWith(loading: true, error: null);

      final updated = state.patient!.copyWith(syncStatus: SyncStatus.failed);

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

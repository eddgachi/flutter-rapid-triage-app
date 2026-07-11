import 'package:flutter_rapid_triage/app/app_providers.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';
import 'package:flutter_rapid_triage/features/triage/repositories/triage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QueueState {
  const QueueState({
    this.loading = false,
    this.search = '',
    this.priority,
    this.statusFilter,
    this.records = const [],
    this.error,
  });

  final bool loading;
  final String search;
  final int? priority;
  final String? statusFilter;
  final List<TriageRecord> records;
  final String? error;

  QueueState copyWith({
    bool? loading,
    String? search,
    int? priority,
    String? statusFilter,
    List<TriageRecord>? records,
    String? error,
  }) {
    return QueueState(
      loading: loading ?? this.loading,
      search: search ?? this.search,
      priority: priority ?? this.priority,
      statusFilter: statusFilter ?? this.statusFilter,
      records: records ?? this.records,
      error: error ?? this.error,
    );
  }
}

class QueueController extends Notifier<QueueState> {
  @override
  QueueState build() {
    // Load records on initialization
    load();
    return const QueueState();
  }

  TriageRepository get _repository => ref.read(triageRepositoryProvider);

  // ==================== LOAD ALL ====================
  Future<void> load() async {
    try {
      state = state.copyWith(loading: true, error: null);

      final records = _repository.getAll();

      state = state.copyWith(loading: false, records: records);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ==================== SEARCH ====================
  void search(String query) {
    try {
      state = state.copyWith(search: query, loading: true);

      final results = _repository.search(query);

      state = state.copyWith(loading: false, records: results);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ==================== FILTER BY PRIORITY ====================
  void filterPriority(int? priority) {
    try {
      state = state.copyWith(priority: priority, loading: true);

      List<TriageRecord> records;

      if (priority == null) {
        // If no priority filter, show all records
        records = _repository.getAll();
      } else {
        // Use the repository's getByPriority method
        records = _repository.getByPriority(priority);
      }

      state = state.copyWith(loading: false, records: records);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ==================== FILTER BY SYNC STATUS ====================
  void filterBySyncStatus(String? status) {
    try {
      state = state.copyWith(statusFilter: status, loading: true);

      List<TriageRecord> records;

      if (status == null) {
        records = _repository.getAll();
      } else {
        // Map string status to SyncStatus enum
        final syncStatus = SyncStatus.values.firstWhere(
          (e) => e.name == status,
          orElse: () => SyncStatus.pending,
        );
        records = _repository.getBySyncStatus(syncStatus);
      }

      state = state.copyWith(loading: false, records: records);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ==================== GET PENDING RECORDS ====================
  void loadPending() {
    try {
      state = state.copyWith(loading: true, error: null);

      final records = _repository.getPending();

      state = state.copyWith(
        loading: false,
        records: records,
        search: '',
        priority: null,
        statusFilter: 'pending',
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ==================== GET SYNCED RECORDS ====================
  void loadSynced() {
    try {
      state = state.copyWith(loading: true, error: null);

      final records = _repository.getSynced();

      state = state.copyWith(
        loading: false,
        records: records,
        search: '',
        priority: null,
        statusFilter: 'synced',
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ==================== GET CRITICAL RECORDS ====================
  void loadCritical() {
    try {
      state = state.copyWith(loading: true, error: null);

      final records = _repository.getCritical();

      state = state.copyWith(
        loading: false,
        records: records,
        search: '',
        priority: 1,
        statusFilter: null,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ==================== GET TODAY'S RECORDS ====================
  void loadToday() {
    try {
      state = state.copyWith(loading: true, error: null);

      final records = _repository.getToday();

      state = state.copyWith(
        loading: false,
        records: records,
        search: '',
        priority: null,
        statusFilter: null,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ==================== REFRESH ====================
  Future<void> refresh() async {
    await load();
  }

  // ==================== CLEAR FILTERS ====================
  void clearFilters() {
    state = state.copyWith(search: '', priority: null, statusFilter: null);
    load();
  }

  // ==================== GET LATEST RECORDS ====================
  void loadLatest(int count) {
    try {
      state = state.copyWith(loading: true, error: null);

      final records = _repository.getLatest(count);

      state = state.copyWith(loading: false, records: records);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ==================== COUNT METHODS ====================
  int totalCount() {
    return _repository.totalPatients();
  }

  int pendingCount() {
    return _repository.pendingCount();
  }

  int syncedCount() {
    return _repository.syncedCount();
  }

  int criticalCount() {
    return _repository.criticalCount();
  }

  // ==================== GET COUNT INFORMATION ====================
  Map<String, int> getCounts() {
    return {
      'total': _repository.totalPatients(),
      'pending': _repository.pendingCount(),
      'synced': _repository.syncedCount(),
      'critical': _repository.criticalCount(),
    };
  }
}

// Provider definition
final queueControllerProvider = NotifierProvider<QueueController, QueueState>(
  QueueController.new,
);

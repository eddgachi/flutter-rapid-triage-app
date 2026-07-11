import 'package:flutter_rapid_triage/app/app_providers.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';
import 'package:flutter_rapid_triage/features/triage/repositories/triage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryState {
  const HistoryState({
    this.loading = false,
    this.records = const [],
    this.filteredRecords = const [],
    this.filterType = HistoryFilterType.all,
    this.searchQuery = '',
    this.error,
  });

  final bool loading;
  final List<TriageRecord> records;
  final List<TriageRecord> filteredRecords;
  final HistoryFilterType filterType;
  final String searchQuery;
  final String? error;

  HistoryState copyWith({
    bool? loading,
    List<TriageRecord>? records,
    List<TriageRecord>? filteredRecords,
    HistoryFilterType? filterType,
    String? searchQuery,
    String? error,
  }) {
    return HistoryState(
      loading: loading ?? this.loading,
      records: records ?? this.records,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      filterType: filterType ?? this.filterType,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
    );
  }
}

enum HistoryFilterType {
  all,
  today,
  thisWeek,
  thisMonth,
  pending,
  synced,
  failed,
  critical,
}

class HistoryController extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    load();
    return const HistoryState();
  }

  TriageRepository get _repository => ref.read(triageRepositoryProvider);

  // ==================== LOAD ALL HISTORY ====================
  Future<void> load() async {
    try {
      state = state.copyWith(loading: true, error: null);

      final records = _repository.getAll();

      state = state.copyWith(loading: false, records: records);

      _applyFilters();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ==================== SEARCH ====================
  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  // ==================== FILTER BY TYPE ====================
  void filterByType(HistoryFilterType type) {
    state = state.copyWith(filterType: type);
    _applyFilters();
  }

  // ==================== APPLY FILTERS ====================
  void _applyFilters() {
    final records = state.records;
    final query = state.searchQuery.toLowerCase().trim();
    final filterType = state.filterType;

    List<TriageRecord> filtered = records;

    // Apply search
    if (query.isNotEmpty) {
      filtered = filtered.where((record) {
        return record.patient.name.toLowerCase().contains(query) ||
            record.chiefComplaint.toLowerCase().contains(query) ||
            (record.clinicalNotes?.toLowerCase().contains(query) ?? false) ||
            record.id.toLowerCase().contains(query);
      }).toList();
    }

    // Apply filter type
    switch (filterType) {
      case HistoryFilterType.all:
        break;
      case HistoryFilterType.today:
        filtered = _filterToday(filtered);
        break;
      case HistoryFilterType.thisWeek:
        filtered = _filterThisWeek(filtered);
        break;
      case HistoryFilterType.thisMonth:
        filtered = _filterThisMonth(filtered);
        break;
      case HistoryFilterType.pending:
        filtered = filtered
            .where((r) => r.syncStatus == SyncStatus.pending)
            .toList();
        break;
      case HistoryFilterType.synced:
        filtered = filtered
            .where((r) => r.syncStatus == SyncStatus.synced)
            .toList();
        break;
      case HistoryFilterType.failed:
        filtered = filtered
            .where((r) => r.syncStatus == SyncStatus.failed)
            .toList();
        break;
      case HistoryFilterType.critical:
        filtered = filtered.where((r) => r.priority == 1).toList();
        break;
    }

    state = state.copyWith(filteredRecords: filtered);
  }

  List<TriageRecord> _filterToday(List<TriageRecord> records) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return records.where((r) {
      return r.createdAt.isAfter(startOfDay) && r.createdAt.isBefore(endOfDay);
    }).toList();
  }

  List<TriageRecord> _filterThisWeek(List<TriageRecord> records) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    return records.where((r) => r.createdAt.isAfter(startOfDay)).toList();
  }

  List<TriageRecord> _filterThisMonth(List<TriageRecord> records) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return records.where((r) => r.createdAt.isAfter(startOfMonth)).toList();
  }

  // ==================== REFRESH ====================
  Future<void> refresh() async {
    await load();
  }

  // ==================== CLEAR SEARCH ====================
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
    _applyFilters();
  }

  // ==================== GET STATISTICS ====================
  Map<String, dynamic> getStatistics() {
    final total = state.records.length;
    final pending = state.records
        .where((r) => r.syncStatus == SyncStatus.pending)
        .length;
    final synced = state.records
        .where((r) => r.syncStatus == SyncStatus.synced)
        .length;
    final failed = state.records
        .where((r) => r.syncStatus == SyncStatus.failed)
        .length;
    final critical = state.records.where((r) => r.priority == 1).length;

    return {
      'total': total,
      'pending': pending,
      'synced': synced,
      'failed': failed,
      'critical': critical,
    };
  }
}

// Provider definition
final historyControllerProvider =
    NotifierProvider<HistoryController, HistoryState>(HistoryController.new);

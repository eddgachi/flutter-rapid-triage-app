import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/core/services/hive_service.dart';
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';

class TriageRepository {
  TriageRepository({required HiveService hiveService}) : _hive = hiveService;

  final HiveService _hive;

  // ==================== GET ALL ====================
  List<TriageRecord> getAll() {
    final box = _hive.getBox(AppConstants.triageBox);

    return box.values
        .map((e) => TriageRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ==================== GET PENDING ====================
  List<TriageRecord> getPending() {
    final all = getAll();
    return all
        .where((record) => record.syncStatus == SyncStatus.pending)
        .toList();
  }

  // ==================== GET SYNCED ====================
  List<TriageRecord> getSynced() {
    final all = getAll();
    return all
        .where((record) => record.syncStatus == SyncStatus.synced)
        .toList();
  }

  // ==================== GET CRITICAL (P1) ====================
  List<TriageRecord> getCritical() {
    final all = getAll();
    return all.where((record) => record.priority == 1).toList();
  }

  // ==================== GET TODAY'S RECORDS ====================
  List<TriageRecord> getToday() {
    final all = getAll();
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return all.where((record) {
      return record.createdAt.isAfter(startOfDay) &&
          record.createdAt.isBefore(endOfDay);
    }).toList();
  }

  // ==================== SEARCH ====================
  List<TriageRecord> search(String query) {
    if (query.isEmpty) return getAll();

    final all = getAll();
    final lowerQuery = query.toLowerCase().trim();

    return all.where((record) {
      // Search by patient name
      if (record.patient.name.toLowerCase().contains(lowerQuery)) return true;

      // Search by chief complaint
      if (record.chiefComplaint.toLowerCase().contains(lowerQuery)) return true;

      // Search by clinical notes
      if (record.clinicalNotes != null &&
          record.clinicalNotes!.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search by NFC tag
      if (record.nfcTag != null &&
          record.nfcTag!.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search by ID (partial match)
      if (record.id.toLowerCase().contains(lowerQuery)) return true;

      return false;
    }).toList();
  }

  // ==================== GET BY ID ====================
  TriageRecord? getById(String id) {
    final box = _hive.getBox(AppConstants.triageBox);
    final json = box.get(id);

    if (json == null) return null;

    return TriageRecord.fromJson(Map<String, dynamic>.from(json));
  }

  // ==================== SAVE ====================
  Future<void> save(TriageRecord record) async {
    final box = _hive.getBox(AppConstants.triageBox);
    await box.put(record.id, record.toJson());
  }

  // ==================== UPDATE ====================
  Future<void> update(TriageRecord record) async {
    final box = _hive.getBox(AppConstants.triageBox);
    await box.put(record.id, record.toJson());
  }

  // ==================== DELETE ====================
  Future<void> delete(String id) async {
    final box = _hive.getBox(AppConstants.triageBox);
    await box.delete(id);
  }

  // ==================== COUNT METHODS ====================

  // ==================== TOTAL PATIENTS ====================
  int totalPatients() {
    final box = _hive.getBox(AppConstants.triageBox);
    return box.length;
  }

  // ==================== PENDING COUNT ====================
  int pendingCount() {
    final all = getAll();
    return all
        .where((record) => record.syncStatus == SyncStatus.pending)
        .length;
  }

  // ==================== SYNCED COUNT ====================
  int syncedCount() {
    final all = getAll();
    return all.where((record) => record.syncStatus == SyncStatus.synced).length;
  }

  // ==================== CRITICAL COUNT ====================
  int criticalCount() {
    final all = getAll();
    return all.where((record) => record.priority == 1).length;
  }

  // ==================== ADDITIONAL HELPER METHODS ====================

  // Get records by priority
  List<TriageRecord> getByPriority(int priority) {
    final all = getAll();
    return all.where((record) => record.priority == priority).toList();
  }

  // Get records by status (pending, in-transit, etc.)
  List<TriageRecord> getByStatus(String status) {
    final all = getAll();
    return all.where((record) => record.status == status).toList();
  }

  // Get records by date range
  List<TriageRecord> getByDateRange(DateTime start, DateTime end) {
    final all = getAll();
    return all.where((record) {
      return record.createdAt.isAfter(start) && record.createdAt.isBefore(end);
    }).toList();
  }

  // Get records with notes
  List<TriageRecord> getWithNotes() {
    final all = getAll();
    return all.where((record) => record.clinicalNotes != null).toList();
  }

  // Count records by priority
  Map<int, int> countByPriority() {
    final all = getAll();
    final Map<int, int> counts = {};

    for (final record in all) {
      counts[record.priority] = (counts[record.priority] ?? 0) + 1;
    }

    return counts;
  }

  // Count records by sync status
  Map<SyncStatus, int> countBySyncStatus() {
    final all = getAll();
    final Map<SyncStatus, int> counts = {};

    for (final record in all) {
      counts[record.syncStatus] = (counts[record.syncStatus] ?? 0) + 1;
    }

    return counts;
  }

  // Delete all records
  Future<void> deleteAll() async {
    final box = _hive.getBox(AppConstants.triageBox);
    await box.clear();
  }

  // Batch save multiple records
  Future<void> saveAll(List<TriageRecord> records) async {
    final box = _hive.getBox(AppConstants.triageBox);

    final Map<String, dynamic> batch = {};
    for (final record in records) {
      batch[record.id] = record.toJson();
    }

    await box.putAll(batch);
  }

  // Update sync status for a record
  Future<void> updateSyncStatus(String id, SyncStatus newStatus) async {
    final record = getById(id);
    if (record != null) {
      final updated = record.copyWith(syncStatus: newStatus);
      await update(updated);
    }
  }

  // Update sync status with error reason
  Future<void> updateSyncStatusWithError(
    String id,
    SyncStatus newStatus,
    String? error,
  ) async {
    final record = getById(id);
    if (record != null) {
      final updated = record.copyWith(syncStatus: newStatus, syncError: error);
      await update(updated);
    }
  }

  // Get records with sync status
  List<TriageRecord> getBySyncStatus(SyncStatus status) {
    final all = getAll();
    return all.where((record) => record.syncStatus == status).toList();
  }

  // Get records that failed sync
  List<TriageRecord> getFailedSync() {
    final all = getAll();
    return all
        .where((record) => record.syncStatus == SyncStatus.failed)
        .toList();
  }

  // Get latest N records
  List<TriageRecord> getLatest(int count) {
    final all = getAll();
    final limit = count > all.length ? all.length : count;
    return all.sublist(0, limit);
  }
}

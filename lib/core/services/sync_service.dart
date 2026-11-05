import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/features/triage/repositories/triage_repository.dart';

import 'api_service.dart';
import 'connectivity_service.dart';

class SyncService {
  final TriageRepository _repository;
  final ApiService _apiService;
  final ConnectivityService _connectivityService;
  final bool Function() _isAutoSyncEnabled;
  final bool Function() _isWifiOnly;
  StreamSubscription? _connectivitySubscription;
  Timer? _syncTimer;

  SyncService({
    required TriageRepository repository,
    required ApiService apiService,
    required ConnectivityService connectivityService,
    bool Function() isAutoSyncEnabled = _alwaysTrue,
    bool Function() isWifiOnly = _alwaysFalse,
  }) : _repository = repository,
       _apiService = apiService,
       _connectivityService = connectivityService,
       _isAutoSyncEnabled = isAutoSyncEnabled,
       _isWifiOnly = isWifiOnly;

  static bool _alwaysTrue() => true;
  static bool _alwaysFalse() => false;

  // Whether an automatic (non-user-initiated) sync is currently allowed,
  // respecting the "Background Auto-sync" and "Sync over WiFi only" settings.
  Future<bool> _canAutoSync() async {
    if (!_isAutoSyncEnabled()) return false;
    if (_isWifiOnly()) return _connectivityService.isOnWifi();
    return _connectivityService.isConnected();
  }

  // Start listening to connectivity changes
  void startListening() {
    _connectivitySubscription = _connectivityService.changes.listen((
      results,
    ) async {
      final isConnected = !results.contains(ConnectivityResult.none);
      if (isConnected && await _canAutoSync()) {
        _performSync();
      }
    });

    // Sync every 5 minutes if connected
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (await _canAutoSync()) {
        _performSync();
      }
    });

    // Initial sync check
    _canAutoSync().then((canSync) {
      if (canSync) {
        _performSync();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }

  Future<SyncResult> _performSync() async {
    try {
      final pendingRecords = _repository.getPending();
      // Also retry failed records
      final failedRecords = _repository.getFailedSync();
      final allRecords = [...pendingRecords, ...failedRecords];

      // Deduplicate by ID
      final seen = <String>{};
      final recordsToSync = <dynamic>[];
      for (final r in allRecords) {
        if (seen.add(r.id)) {
          recordsToSync.add(r);
        }
      }

      if (recordsToSync.isEmpty) {
        return SyncResult(success: true, synced: 0, failed: 0);
      }

      int synced = 0;
      int failed = 0;
      String? lastError;

      for (final record in recordsToSync) {
        try {
          await _repository.updateSyncStatus(record.id, SyncStatus.syncing);

          // Send to API
          await _apiService.submitRecord(record.toJson());

          // Mark as synced, clear any error
          await _repository.updateSyncStatusWithError(
            record.id,
            SyncStatus.synced,
            null,
          );
          synced++;
        } catch (e) {
          final errorMsg = _extractErrorReason(e);
          lastError = errorMsg;
          await _repository.updateSyncStatusWithError(
            record.id,
            SyncStatus.failed,
            errorMsg,
          );
          failed++;
        }
      }

      return SyncResult(
        success: failed == 0,
        synced: synced,
        failed: failed,
        error: lastError,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        synced: 0,
        failed: 0,
        error: e.toString(),
      );
    }
  }

  // ApiService throws plain Exceptions with an already human-readable
  // message (there's no real HTTP client under it to produce status codes
  // or socket errors), so this just strips Dart's "Exception: " prefix.
  String _extractErrorReason(Object error) {
    final msg = error.toString();
    const prefix = 'Exception: ';
    if (msg.startsWith(prefix)) {
      return msg.substring(prefix.length);
    }
    if (msg.length > 80) {
      return msg.substring(0, 80);
    }
    return msg;
  }

  Future<SyncResult> syncNow() async {
    final connected = await _connectivityService.isConnected();
    if (!connected) {
      return SyncResult(
        success: false,
        synced: 0,
        failed: 0,
        error: 'No internet connection',
      );
    }
    return _performSync();
  }

  Future<bool> syncRecord(String id) async {
    final connected = await _connectivityService.isConnected();
    if (!connected) {
      await _repository.updateSyncStatusWithError(
        id,
        SyncStatus.failed,
        'No internet connection',
      );
      return false;
    }

    try {
      final record = _repository.getById(id);
      if (record == null) return false;

      await _repository.updateSyncStatusWithError(id, SyncStatus.syncing, null);

      await _apiService.updateRecord(id, record.toJson());

      await _repository.updateSyncStatusWithError(id, SyncStatus.synced, null);
      return true;
    } catch (e) {
      final errorMsg = _extractErrorReason(e);
      await _repository.updateSyncStatusWithError(
        id,
        SyncStatus.failed,
        errorMsg,
      );
      return false;
    }
  }

  SyncStatus getSyncStatus(String id) {
    final record = _repository.getById(id);
    return record?.syncStatus ?? SyncStatus.pending;
  }
}

class SyncResult {
  final bool success;
  final int synced;
  final int failed;
  final String? error;

  SyncResult({
    required this.success,
    required this.synced,
    required this.failed,
    this.error,
  });
}

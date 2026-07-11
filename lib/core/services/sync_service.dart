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
  StreamSubscription? _connectivitySubscription;
  Timer? _syncTimer;

  SyncService({
    required TriageRepository repository,
    required ApiService apiService,
    required ConnectivityService connectivityService,
  }) : _repository = repository,
       _apiService = apiService,
       _connectivityService = connectivityService;

  // Start listening to connectivity changes
  void startListening() {
    _connectivitySubscription = _connectivityService.changes.listen((results) {
      final isConnected = !results.contains(ConnectivityResult.none);
      if (isConnected) {
        _performSync();
      }
    });

    // Sync every 5 minutes if connected
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _connectivityService.isConnected().then((connected) {
        if (connected) {
          _performSync();
        }
      });
    });

    // Initial sync check
    _connectivityService.isConnected().then((connected) {
      if (connected) {
        _performSync();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }

  // Perform full sync
  Future<SyncResult> _performSync() async {
    try {
      final pendingRecords = _repository.getPending();
      if (pendingRecords.isEmpty) {
        return SyncResult(success: true, synced: 0, failed: 0);
      }

      int synced = 0;
      int failed = 0;

      for (final record in pendingRecords) {
        try {
          // Update status to syncing
          await _repository.updateSyncStatus(record.id, SyncStatus.syncing);

          // Send to API
          await _apiService.client.post(
            '/triage/records',
            data: record.toJson(),
          );

          // Mark as synced
          await _repository.updateSyncStatus(record.id, SyncStatus.synced);
          synced++;
        } catch (e) {
          // Mark as failed
          await _repository.updateSyncStatus(record.id, SyncStatus.failed);
          failed++;
        }
      }

      return SyncResult(success: failed == 0, synced: synced, failed: failed);
    } catch (e) {
      return SyncResult(
        success: false,
        synced: 0,
        failed: 0,
        error: e.toString(),
      );
    }
  }

  // Manual sync trigger
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

  // Sync a single record
  Future<bool> syncRecord(String id) async {
    final connected = await _connectivityService.isConnected();
    if (!connected) return false;

    try {
      final record = _repository.getById(id);
      if (record == null) return false;

      await _repository.updateSyncStatus(id, SyncStatus.syncing);

      await _apiService.client.put(
        '/triage/records/$id',
        data: record.toJson(),
      );

      await _repository.updateSyncStatus(id, SyncStatus.synced);
      return true;
    } catch (e) {
      await _repository.updateSyncStatus(id, SyncStatus.failed);
      return false;
    }
  }

  // Get sync status
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

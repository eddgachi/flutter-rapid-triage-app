import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_rapid_triage/app/app_providers.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/core/services/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.lastSyncTime,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.error,
    this.isConnected = true,
  });

  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int syncedCount;
  final int failedCount;
  final String? error;
  final bool isConnected;

  SyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncTime,
    int? syncedCount,
    int? failedCount,
    String? error,
    bool? isConnected,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      syncedCount: syncedCount ?? this.syncedCount,
      failedCount: failedCount ?? this.failedCount,
      error: error ?? this.error,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class SyncController extends Notifier<SyncState> {
  SyncService? _syncService;

  @override
  SyncState build() {
    _initialize();
    return const SyncState();
  }

  void _initialize() {
    final repository = ref.read(triageRepositoryProvider);
    final apiService = ref.read(apiServiceProvider);
    final connectivityService = ref.read(connectivityServiceProvider);

    _syncService = SyncService(
      repository: repository,
      apiService: apiService,
      connectivityService: connectivityService,
    );

    _syncService!.startListening();

    // Listen to connectivity changes
    connectivityService.isConnected().then((connected) {
      state = state.copyWith(isConnected: connected);
    });

    connectivityService.changes.listen((results) {
      final connected = !results.contains(ConnectivityResult.none);
      state = state.copyWith(isConnected: connected);
    });
  }

  void dispose() {
    _syncService?.dispose();
  }

  // Manual sync
  Future<void> syncNow() async {
    if (state.isSyncing) return;

    state = state.copyWith(isSyncing: true, error: null);

    final result = await _syncService?.syncNow();

    state = state.copyWith(
      isSyncing: false,
      lastSyncTime: DateTime.now(),
      syncedCount: result?.synced ?? 0,
      failedCount: result?.failed ?? 0,
      error: result?.error,
    );
  }

  // Sync a single record
  Future<bool> syncRecord(String id) async {
    final result = await _syncService?.syncRecord(id) ?? false;
    if (result) {
      state = state.copyWith(
        lastSyncTime: DateTime.now(),
        syncedCount: state.syncedCount + 1,
      );
    } else {
      state = state.copyWith(
        lastSyncTime: DateTime.now(),
        failedCount: state.failedCount + 1,
      );
    }
    return result;
  }

  // Clear sync errors
  void clearErrors() {
    state = state.copyWith(error: null);
  }

  // Get sync status for a record
  SyncStatus getSyncStatus(String id) {
    return _syncService?.getSyncStatus(id) ?? SyncStatus.pending;
  }

  // Check if connected
  bool get isConnected => state.isConnected;
}

final syncControllerProvider = NotifierProvider<SyncController, SyncState>(
  SyncController.new,
);

import 'package:flutter_rapid_triage/app/app_providers.dart';
import 'package:flutter_rapid_triage/features/triage/models/triage_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  const HomeState({
    this.loading = false,
    this.totalPatients = 0,
    this.pendingPatients = 0,
    this.syncedPatients = 0,
    this.failedPatients = 0,
    this.criticalPatients = 0,
    this.recentPatients = const [],
  });

  final bool loading;
  final int totalPatients;
  final int pendingPatients;
  final int syncedPatients;
  final int failedPatients;
  final int criticalPatients;
  final List<TriageRecord> recentPatients;

  HomeState copyWith({
    bool? loading,
    int? totalPatients,
    int? pendingPatients,
    int? syncedPatients,
    int? failedPatients,
    int? criticalPatients,
    List<TriageRecord>? recentPatients,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      totalPatients: totalPatients ?? this.totalPatients,
      pendingPatients: pendingPatients ?? this.pendingPatients,
      syncedPatients: syncedPatients ?? this.syncedPatients,
      failedPatients: failedPatients ?? this.failedPatients,
      criticalPatients: criticalPatients ?? this.criticalPatients,
      recentPatients: recentPatients ?? this.recentPatients,
    );
  }
}

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    load();
    return const HomeState();
  }

  void load() {
    final repo = ref.read(triageRepositoryProvider);

    final patients = repo.getAll();

    state = HomeState(
      totalPatients: repo.totalPatients(),
      pendingPatients: repo.pendingCount(),
      syncedPatients: repo.syncedCount(),
      failedPatients: repo.getFailedSync().length,
      criticalPatients: repo.criticalCount(),
      recentPatients: patients.take(5).toList(),
    );
  }

  Future<void> refresh() async => load();
}

// Provider definition
final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

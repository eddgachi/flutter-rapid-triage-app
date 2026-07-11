class AppConstants {
  AppConstants._();

  static const String appName = 'RapidTriage';
  static const String appVersion = '4.2.0-secure';
  static const String appBuild = '8829';

  static const authBox = 'auth';
  static const settingsBox = 'settings';
  static const triageBox = 'triage_records';
}

class TriageLevel {
  TriageLevel._();

  static const String p1 = 'P1';
  static const String p2 = 'P2';
  static const String p3 = 'P3';
  static const String p4 = 'P4';
  static const String p5 = 'P5';
}

enum PatientStatus { pending, inTransit }

enum SyncStatus {
  pending, // Waiting to be synced
  synced, // Successfully synced
  failed, // Failed to sync
  syncing, // Currently syncing
}

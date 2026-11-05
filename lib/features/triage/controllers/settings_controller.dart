import 'package:flutter_rapid_triage/app/app_providers.dart';
import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Persists device/sync toggles in the Hive settings box so the UI reflects
/// what was actually chosen instead of resetting to hardcoded defaults.
class SettingsState {
  const SettingsState({
    this.gpsTrackingEnabled = true,
    this.nfcScanningEnabled = true,
    this.backgroundAutoSyncEnabled = true,
    this.syncOverWifiOnly = false,
  });

  final bool gpsTrackingEnabled;
  final bool nfcScanningEnabled;
  final bool backgroundAutoSyncEnabled;
  final bool syncOverWifiOnly;

  SettingsState copyWith({
    bool? gpsTrackingEnabled,
    bool? nfcScanningEnabled,
    bool? backgroundAutoSyncEnabled,
    bool? syncOverWifiOnly,
  }) {
    return SettingsState(
      gpsTrackingEnabled: gpsTrackingEnabled ?? this.gpsTrackingEnabled,
      nfcScanningEnabled: nfcScanningEnabled ?? this.nfcScanningEnabled,
      backgroundAutoSyncEnabled:
          backgroundAutoSyncEnabled ?? this.backgroundAutoSyncEnabled,
      syncOverWifiOnly: syncOverWifiOnly ?? this.syncOverWifiOnly,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  static const _gpsKey = 'gpsTrackingEnabled';
  static const _nfcKey = 'nfcScanningEnabled';
  static const _autoSyncKey = 'backgroundAutoSyncEnabled';
  static const _wifiOnlyKey = 'syncOverWifiOnly';

  Box get _box =>
      ref.read(hiveServiceProvider).getBox(AppConstants.settingsBox);

  @override
  SettingsState build() {
    return SettingsState(
      gpsTrackingEnabled: _box.get(_gpsKey, defaultValue: true) as bool,
      nfcScanningEnabled: _box.get(_nfcKey, defaultValue: true) as bool,
      backgroundAutoSyncEnabled:
          _box.get(_autoSyncKey, defaultValue: true) as bool,
      syncOverWifiOnly: _box.get(_wifiOnlyKey, defaultValue: false) as bool,
    );
  }

  void setGpsTracking(bool value) {
    state = state.copyWith(gpsTrackingEnabled: value);
    _box.put(_gpsKey, value);
  }

  void setNfcScanning(bool value) {
    state = state.copyWith(nfcScanningEnabled: value);
    _box.put(_nfcKey, value);
  }

  void setBackgroundAutoSync(bool value) {
    state = state.copyWith(backgroundAutoSyncEnabled: value);
    _box.put(_autoSyncKey, value);
  }

  void setSyncOverWifiOnly(bool value) {
    state = state.copyWith(syncOverWifiOnly: value);
    _box.put(_wifiOnlyKey, value);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

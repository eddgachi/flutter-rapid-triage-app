import 'dart:async';
import 'dart:math';

/// Stands in for a real triage-records API, the same way FakeAuthService
/// stands in for a real auth backend — there's no live server behind this
/// app yet. Simulates network latency and an occasional failure so the
/// sync flow (pending -> syncing -> synced/failed, with a working Retry)
/// has something realistic to do without depending on one.
class ApiService {
  final Random _random = Random();

  Future<void> initialize() async {}

  Future<void> submitRecord(Map<String, dynamic> data) => _simulateRequest();

  Future<void> updateRecord(String id, Map<String, dynamic> data) =>
      _simulateRequest();

  Future<void> _simulateRequest() async {
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(600)));

    if (_random.nextDouble() < _simulatedFailureRate) {
      final message =
          _simulatedFailureMessages[_random.nextInt(
            _simulatedFailureMessages.length,
          )];
      throw Exception(message);
    }
  }

  static const _simulatedFailureRate = 0.12;

  static const _simulatedFailureMessages = [
    'Connection error: Unable to reach server',
    'Request timed out',
    'Server error: Service unavailable',
  ];
}

import '../core/services/api_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/fake_auth_service.dart';
import '../core/services/hive_service.dart';

class AppInitializer {
  static Future<void> initialize() async {
    final hive = HiveService();
    final api = ApiService();
    final connectivity = ConnectivityService();
    final auth = FakeAuthService();

    await hive.initialize();
    await api.initialize();

    // Placeholder for future initialization
    connectivity.isConnected();
    auth.currentUser;
  }
}

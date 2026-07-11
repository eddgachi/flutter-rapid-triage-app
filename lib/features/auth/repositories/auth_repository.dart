import 'package:flutter_rapid_triage/core/constants/app_constants.dart';
import 'package:flutter_rapid_triage/core/services/fake_auth_service.dart';
import 'package:flutter_rapid_triage/core/services/hive_service.dart';
import 'package:flutter_rapid_triage/features/auth/models/user.dart';

class AuthRepository {
  AuthRepository({
    required HiveService hiveService,
    required FakeAuthService authService,
  }) : _hive = hiveService,
       _auth = authService;

  final HiveService _hive;
  final FakeAuthService _auth;

  static const _userKey = 'current_user';

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final user = await _auth.login(username: username, password: password);

    final box = _hive.getBox(AppConstants.authBox);

    await box.put(_userKey, user.toJson());

    return user;
  }

  Future<void> logout() async {
    final box = _hive.getBox(AppConstants.authBox);

    await box.delete(_userKey);

    await _auth.logout();
  }

  User? currentUser() {
    final box = _hive.getBox(AppConstants.authBox);

    final json = box.get(_userKey);

    if (json == null) {
      return null;
    }

    return User.fromJson(Map<String, dynamic>.from(json));
  }

  bool isLoggedIn() {
    return currentUser() != null;
  }
}

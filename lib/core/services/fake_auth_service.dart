import '../../features/auth/models/user.dart';

class FakeAuthService {
  User? _currentUser;

  Future<User> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: username,
    );

    return _currentUser!;
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  User? get currentUser => _currentUser;
}

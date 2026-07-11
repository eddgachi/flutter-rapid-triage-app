import '../../features/auth/models/user.dart';

class FakeAuthService {
  User? _currentUser;

  Future<User?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User(id: '1', name: username);

    return _currentUser;
  }

  User? get currentUser => _currentUser;

  Future<void> logout() async {
    _currentUser = null;
  }
}

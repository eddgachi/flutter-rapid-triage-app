import 'package:flutter_rapid_triage/app/app_providers.dart';
import 'package:flutter_rapid_triage/core/utils/sentinel.dart';
import 'package:flutter_rapid_triage/features/auth/models/user.dart';
import 'package:flutter_rapid_triage/features/auth/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  const AuthState({this.isLoading = false, this.user, this.error});

  final bool isLoading;
  final User? user;
  final String? error;

  AuthState copyWith({
    bool? isLoading,
    Object? user = unset,
    Object? error = unset,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user == unset ? this.user : user as User?,
      error: error == unset ? this.error : error as String?,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState(user: _repository.currentUser());
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    if (username.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Enter your clinical ID and password',
      );
      return false;
    }

    try {
      final user = await _repository.login(
        username: username.trim(),
        password: password,
      );
      state = state.copyWith(isLoading: false, user: user, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  bool get isLoggedIn => state.user != null;
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

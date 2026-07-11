import 'package:flutter_rapid_triage/features/auth/models/user.dart';

class AuthState {
  const AuthState({this.isLoading = false, this.user, this.error});

  final bool isLoading;
  final User? user;
  final String? error;

  AuthState copyWith({bool? isLoading, User? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

// lib/features/auth/providers/auth_state.dart
import 'package:atomicoat_17th_version/features/auth/data/models/user_model.dart';

class AuthState {
  final bool isLoading;
  final UserModel? currentUser;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.currentUser,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? currentUser,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      error: error ?? this.error,
    );
  }
}
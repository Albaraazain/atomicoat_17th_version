// lib/features/auth/providers/auth_provider.dart
import 'package:atomicoat_17th_version/features/auth/data/models/user_model.dart';
import 'package:atomicoat_17th_version/features/auth/data/repositories/auth_repository.dart';
import 'package:atomicoat_17th_version/features/auth/providers/auth_state.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  AuthState _state = AuthState();

  AuthProvider(this._authRepository) {
    _initializeAuth();
  }

  AuthState get state => _state;
  UserModel? get currentUser => _state.currentUser;
  bool get isAdmin => currentUser?.role == UserRole.admin || currentUser?.role == UserRole.superAdmin;
  bool get isSuperAdmin => currentUser?.role == UserRole.superAdmin;
  bool get isAuthenticated => currentUser != null;

  void _updateState({
    bool? isLoading,
    UserModel? currentUser,
    String? error,
  }) {
    _state = _state.copyWith(
      isLoading: isLoading,
      currentUser: currentUser,
      error: error,
    );
    notifyListeners();
  }

  Future<void> _initializeAuth() async {
    _authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        // Fetch full user data from Firestore
        final userData = await _authRepository.getUserData(user.uid);
        _updateState(currentUser: userData);
      } else {
        _updateState(currentUser: null);
      }
    });
  }

  Future<void> register(String email, String password, String name, String machineSerial) async {
    try {
      _updateState(isLoading: true, error: null);
      await _authRepository.registerUser(email, password, name, machineSerial);
      _updateState(isLoading: false);
    } catch (e) {
      _updateState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _updateState(isLoading: true, error: null);
      await _authRepository.signIn(email, password);
      _updateState(isLoading: false);
    } catch (e) {
      _updateState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _updateState(isLoading: true, error: null);
      await _authRepository.signOut();
      _updateState(isLoading: false, currentUser: null);
    } catch (e) {
      _updateState(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

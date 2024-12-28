// lib/features/auth/providers/auth_provider.dart
import 'package:atomicoat_17th_version/core/utils/logger.dart';
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
    AppLogger.debug('Initializing auth state changes listener');
    _authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          AppLogger.debug('Auth state changed: User logged in with uid: ${user.uid}');
          final userData = await _authRepository.getUserData(user.uid);
          _updateState(currentUser: userData);
          AppLogger.info('User data updated in state: ${userData?.toJson()}');
        } catch (e, stackTrace) {
          AppLogger.error('Error fetching user data', e, stackTrace);
          _updateState(currentUser: null, error: 'Failed to fetch user data');
        }
      } else {
        AppLogger.debug('Auth state changed: User logged out');
        _updateState(currentUser: null);
      }
    });
  }

  Future<void> register(String email, String password, String name, String machineSerial) async {
    try {
      AppLogger.info('Starting registration process for email: $email');
      _updateState(isLoading: true, error: null);
      final user = await _authRepository.registerUser(email, password, name, machineSerial);
      _updateState(isLoading: false, currentUser: user);
      AppLogger.info('Registration successful for user: ${user.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Registration failed', e, stackTrace);
      _updateState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      AppLogger.info('Starting sign in process for email: $email');
      _updateState(isLoading: true, error: null);
      final user = await _authRepository.signIn(email, password);
      _updateState(isLoading: false, currentUser: user);
      AppLogger.info('Sign in successful for user: ${user?.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Sign in failed', e, stackTrace);
      _updateState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      AppLogger.info('Starting sign out process');
      _updateState(isLoading: true, error: null);
      await _authRepository.signOut();
      _updateState(isLoading: false, currentUser: null);
      AppLogger.info('Sign out successful');
    } catch (e, stackTrace) {
      AppLogger.error('Sign out failed', e, stackTrace);
      _updateState(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

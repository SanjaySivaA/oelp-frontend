import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';
import '../services/api_service.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? error;

  AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.token,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier(this._apiService) : super(AuthState()) {
    // Note: checkInitialAuth is likely called from your app's entry point (e.g., main.dart)
  }

  Future<void> checkInitialAuth() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        final user = await _apiService.getMe(token);
        state = state.copyWith(status: AuthStatus.authenticated, user: user, token: token);
      } catch (e) {
        await logout();
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, error: null);
      final tokenData = await _apiService.loginUser(email: email, password: password);
      final user = await _apiService.getMe(tokenData.accessToken);

      await _storage.write(key: 'auth_token', value: tokenData.accessToken);
      state = state.copyWith(status: AuthStatus.authenticated, user: user, token: tokenData.accessToken);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, error: null);
      final response = await _apiService.registerUser(name: name, email: email, password: password);
      await _storage.write(key: 'auth_token', value: response.token.accessToken);
      state = state.copyWith(status: AuthStatus.authenticated, user: response.userInfo, token: response.token.accessToken);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null, token: null, error: null);
  }
}

// MODIFIED: Renamed to authNotifierProvider. This is for triggering actions (login, logout, etc.).
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

// NEW: This provider gives simple, read-only access to the AuthState object.
// Other providers will use this to get the current token or user data.
final authProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';

const _storage = FlutterSecureStorage();
const _userKey = 'gamblock_user';

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? role;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.displayName,
    this.role,
    this.isLoading = true,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? displayName,
    String? role,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isKepala => role == 'partner' || role == 'platform_admin';
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final token = await _storage.read(key: 'access_token');
    final userJson = await _storage.read(key: _userKey);
    if (token != null && userJson != null) {
      final user = jsonDecode(userJson) as Map<String, dynamic>;
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        userId: user['id'] as String?,
        email: user['email'] as String?,
        displayName: user['display_name'] as String?,
        role: user['role'] as String?,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await ApiClient.dio.post('/v1/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data['data'];
      if (data != null) {
        await ApiClient.saveTokens(
          data['access_token'] as String,
          data['refresh_token'] as String,
        );
        final user = data['user'] as Map<String, dynamic>;
        await _storage.write(key: _userKey, value: jsonEncode(user));
        state = state.copyWith(
          isAuthenticated: true,
          userId: user['id'] as String?,
          email: user['email'] as String?,
          displayName: user['display_name'] as String?,
          role: user['role'] as String?,
        );
        return user;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<Map<String, dynamic>?> register(String email, String password, String name) async {
    try {
      final response = await ApiClient.dio.post('/v1/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });
      final data = response.data['data'];
      if (data != null) {
        await ApiClient.saveTokens(
          data['access_token'] as String,
          data['refresh_token'] as String,
        );
        final user = data['user'] as Map<String, dynamic>;
        await _storage.write(key: _userKey, value: jsonEncode(user));
        state = state.copyWith(
          isAuthenticated: true,
          userId: user['id'] as String?,
          email: user['email'] as String?,
          displayName: user['display_name'] as String?,
          role: user['role'] as String?,
        );
        return user;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<void> logout() async {
    await ApiClient.clearTokens();
    await _storage.delete(key: _userKey);
    state = const AuthState(isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

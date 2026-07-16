import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../device/device_registry.dart';
import '../network/api_client.dart';
import '../network/api_response.dart';
import '../platform/platform_bridge.dart';

const _storage = FlutterSecureStorage();
const _userKey = 'gamblock_user';

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.displayName,
    this.role,
    this.deviceId,
    this.isLoading = true,
  });

  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? role;
  final String? deviceId;
  final bool isLoading;

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? displayName,
    String? role,
    String? deviceId,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      deviceId: deviceId ?? this.deviceId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    ApiClient.onSessionExpired = _expireLocalSession;
    _init();
  }

  Future<void> _init() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final userJson = await _storage.read(key: _userKey);
      if (token == null || userJson == null) {
        state = const AuthState(isLoading: false);
        return;
      }
      final decoded = jsonDecode(userJson);
      if (decoded is! Map) {
        throw const FormatException('Stored user is not an object');
      }
      final user = Map<String, dynamic>.from(decoded);
      final userId = user['id']?.toString();
      if (userId == null || userId.isEmpty) {
        throw const FormatException('Stored user has no id');
      }
      final deviceId = await DeviceRegistry.deviceIdFor(userId);
      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        userId: userId,
        email: user['email']?.toString(),
        displayName: user['display_name']?.toString(),
        role: user['role']?.toString(),
        deviceId: deviceId,
      );
      if (deviceId != null) {
        try {
          await DeviceRegistry.heartbeat(userId);
        } catch (_) {
          // An offline backend must not invalidate a locally restored session.
        }
      }
    } catch (_) {
      await _clearLocalSession();
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await ApiClient.dio.post(
      '/v1/auth/login',
      data: {'email': email, 'password': password},
    );
    return _completeSession(ApiResponse.map(response));
  }

  Future<Map<String, dynamic>?> register(
    String email,
    String password,
    String name,
  ) async {
    final response = await ApiClient.dio.post(
      '/v1/auth/register',
      data: {'email': email, 'password': password, 'name': name},
    );
    return _completeSession(ApiResponse.map(response));
  }

  Future<Map<String, dynamic>?> _completeSession(
    Map<String, dynamic>? data,
  ) async {
    if (data == null) return null;
    final accessToken = data['access_token']?.toString();
    final refreshToken = data['refresh_token']?.toString();
    final rawUser = data['user'];
    if (accessToken == null ||
        refreshToken == null ||
        rawUser is! Map<String, dynamic>) {
      throw const FormatException('Authentication response is incomplete');
    }
    await ApiClient.saveTokens(accessToken, refreshToken);
    final user = Map<String, dynamic>.from(rawUser);
    await _storage.write(key: _userKey, value: jsonEncode(user));
    final userId = user['id']?.toString() ?? '';
    String? deviceId;
    try {
      final device = await DeviceRegistry.register(
        userId: userId,
        displayName: user['display_name']?.toString() ?? '',
      );
      deviceId = device.id;
    } catch (_) {
      deviceId = await DeviceRegistry.deviceIdFor(userId);
      if (deviceId != null) {
        await PlatformBridge.setDeviceId(deviceId);
      }
    }
    state = AuthState(
      isAuthenticated: true,
      isLoading: false,
      userId: userId,
      email: user['email']?.toString(),
      displayName: user['display_name']?.toString(),
      role: user['role']?.toString(),
      deviceId: deviceId,
    );
    return user;
  }

  Future<void> updateDisplayName(String displayName) async {
    final response = await ApiClient.dio.patch(
      '/v1/me',
      data: {'display_name': displayName.trim()},
    );
    final user = ApiResponse.map(response);
    if (user == null) throw StateError('Profile response is empty');
    await _storage.write(key: _userKey, value: jsonEncode(user));
    state = state.copyWith(displayName: user['display_name']?.toString());
  }

  Future<void> ensureDeviceRegistered() async {
    final userId = state.userId;
    if (!state.isAuthenticated || userId == null) return;
    final device = await DeviceRegistry.register(
      userId: userId,
      displayName: state.displayName ?? '',
    );
    state = state.copyWith(deviceId: device.id);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiClient.dio.patch(
      '/v1/me/password',
      data: {'current_password': currentPassword, 'new_password': newPassword},
    );
    await _clearLocalSession();
  }

  Future<void> logout() async {
    final refreshToken = await ApiClient.getRefreshToken();
    if (refreshToken != null) {
      try {
        await ApiClient.dio.post(
          '/v1/auth/logout',
          data: {'refresh_token': refreshToken},
        );
      } catch (_) {
        // Local logout remains available when the backend is offline.
      }
    }
    await _clearLocalSession();
  }

  Future<void> _expireLocalSession() => _clearLocalSession();

  Future<void> _clearLocalSession() async {
    await ApiClient.clearTokens();
    await _storage.delete(key: _userKey);
    state = const AuthState(isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

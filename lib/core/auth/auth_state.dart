import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../device/device_registry.dart';
import '../network/api_client.dart';
import '../network/api_response.dart';
import '../platform/platform_bridge.dart';
import '../../features/auth/data/google_auth_service.dart';

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
    this.phone,
    this.phoneVerified = false,
    this.passwordEnabled = false,
    this.googleLinked = false,
  });

  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? role;
  final String? deviceId;
  final bool isLoading;
  final String? phone;
  final bool phoneVerified;
  final bool passwordEnabled;
  final bool googleLinked;

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? displayName,
    String? role,
    String? deviceId,
    bool? isLoading,
    String? phone,
    bool? phoneVerified,
    bool? passwordEnabled,
    bool? googleLinked,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      deviceId: deviceId ?? this.deviceId,
      isLoading: isLoading ?? this.isLoading,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      passwordEnabled: passwordEnabled ?? this.passwordEnabled,
      googleLinked: googleLinked ?? this.googleLinked,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._googleAuth) : super(const AuthState()) {
    ApiClient.onSessionExpired = _expireLocalSession;
    _init();
  }

  final GoogleAuthService _googleAuth;

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
      if (user['role']?.toString() != 'user') {
        throw const FormatException('Stored user is not a student account');
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
        phone: user['phone_e164']?.toString(),
        phoneVerified: user['phone_verified_at'] != null,
        passwordEnabled: user['_password_enabled'] == true,
        googleLinked: user['_google_linked'] == true,
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
    final data = ApiResponse.map(response);
    if (data?['password_change_required'] == true) return data;
    return _completeSession(data);
  }

  Future<Map<String, dynamic>?> completeInitialPasswordChange(
    String token,
    String newPassword,
  ) async {
    final response = await ApiClient.dio.post(
      '/v1/auth/first-login/password',
      data: {'token': token, 'new_password': newPassword},
    );
    return _completeSession(ApiResponse.map(response));
  }

  Future<Map<String, dynamic>?> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    final response = await ApiClient.dio.post(
      '/v1/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        'role': 'user',
      },
    );
    return _completeSession(ApiResponse.map(response));
  }

  Future<Map<String, dynamic>?> loginWithGoogle() async {
    final google = await _googleAuth.authenticate();
    final response = await ApiClient.dio.post(
      '/v1/auth/google',
      data: {'id_token': google.idToken, 'nonce': google.nonce, 'role': 'user'},
    );
    return _completeSession(ApiResponse.map(response));
  }

  Future<void> requestPasswordReset(String email) async {
    await ApiClient.dio.post(
      '/v1/auth/password-reset/request',
      data: {'email': email.trim()},
    );
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await ApiClient.dio.post(
      '/v1/auth/password-reset/confirm',
      data: {
        'email': email.trim(),
        'code': code.trim(),
        'new_password': newPassword,
      },
    );
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
    final user = Map<String, dynamic>.from(rawUser);
    if (user['role']?.toString() != 'user') {
      await ApiClient.clearTokens();
      throw StateError('Aplikasi ini hanya tersedia untuk akun mahasiswa');
    }
    user['_password_enabled'] = data['password_enabled'] == true;
    user['_google_linked'] = data['google_linked'] == true;
    await ApiClient.saveTokens(accessToken, refreshToken);
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
      phone: user['phone_e164']?.toString(),
      phoneVerified: user['phone_verified_at'] != null,
      passwordEnabled: user['_password_enabled'] == true,
      googleLinked: user['_google_linked'] == true,
    );
    return user;
  }

  Future<void> refreshProfile() async {
    final response = await ApiClient.dio.get('/v1/me');
    final user = ApiResponse.map(response);
    if (user == null) return;
    if (user['role']?.toString() != 'user') {
      await logout();
      throw StateError('Aplikasi ini hanya tersedia untuk akun mahasiswa');
    }
    user['_password_enabled'] = user['password_enabled'] == true;
    user['_google_linked'] = user['google_linked'] == true;
    await _storage.write(key: _userKey, value: jsonEncode(user));
    state = state.copyWith(
      email: user['email']?.toString(),
      displayName: user['display_name']?.toString(),
      phone: user['phone_e164']?.toString(),
      phoneVerified: user['phone_verified_at'] != null,
      passwordEnabled: user['_password_enabled'] == true,
      googleLinked: user['_google_linked'] == true,
    );
  }

  Future<String?> startPhoneVerification([String? phone]) async {
    final response = await ApiClient.dio.post(
      '/v1/auth/phone-verification/start',
      data: phone == null || phone.trim().isEmpty ? {} : {'phone': phone.trim()},
    );
    final data = ApiResponse.map(response);
    return data?['preview_code']?.toString();
  }

  Future<void> confirmPhoneVerification(String code) async {
    await ApiClient.dio.post(
      '/v1/auth/phone-verification/confirm',
      data: {'code': code.trim()},
    );
    await refreshProfile();
  }

  Future<void> linkGoogle(String currentPassword) async {
    final google = await _googleAuth.authenticate();
    await ApiClient.dio.post(
      '/v1/me/google/link',
      data: {
        'current_password': currentPassword,
        'id_token': google.idToken,
        'nonce': google.nonce,
      },
    );
    state = state.copyWith(googleLinked: true);
  }

  Future<void> updateDisplayName(String displayName) async {
    final response = await ApiClient.dio.patch(
      '/v1/me',
      data: {'display_name': displayName.trim()},
    );
    final user = ApiResponse.map(response);
    if (user == null) throw StateError('Profile response is empty');
    user['_password_enabled'] = state.passwordEnabled;
    user['_google_linked'] = state.googleLinked;
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
  return AuthNotifier(GoogleAuthService());
});

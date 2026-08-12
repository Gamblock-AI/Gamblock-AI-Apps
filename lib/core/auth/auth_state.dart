import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../device/device_registry.dart';
import '../network/api_client.dart';
import '../network/api_response.dart';
import '../platform/platform_bridge.dart';
import '../settings/app_settings.dart';
import '../notifications/reminder_preference_api.dart';

const _storage = FlutterSecureStorage();
const _userKey = 'gamblock_user';

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.avatarVersion = 0,
    this.role,
    this.deviceId,
    this.isLoading = true,
    this.phone,
    this.phoneVerified = false,
    this.passwordEnabled = false,
  });

  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? avatarUrl;

  /// Incremented whenever the avatar is uploaded or deleted so widgets can add
  /// a cache-busting query parameter (the backend returns a stable route).
  final int avatarVersion;
  final String? role;
  final String? deviceId;
  final bool isLoading;
  final String? phone;
  final bool phoneVerified;
  final bool passwordEnabled;

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? displayName,
    String? avatarUrl,
    int? avatarVersion,
    String? role,
    String? deviceId,
    bool? isLoading,
    String? phone,
    bool? phoneVerified,
    bool? passwordEnabled,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarVersion: avatarVersion ?? this.avatarVersion,
      role: role ?? this.role,
      deviceId: deviceId ?? this.deviceId,
      isLoading: isLoading ?? this.isLoading,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      passwordEnabled: passwordEnabled ?? this.passwordEnabled,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState()) {
    ApiClient.onSessionExpired = _expireLocalSession;
    _init();
  }

  final Ref _ref;

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
        avatarUrl: user['avatar_url']?.toString(),
        role: user['role']?.toString(),
        deviceId: deviceId,
        phone: user['phone_e164']?.toString(),
        phoneVerified: user['phone_verified_at'] != null,
        passwordEnabled: user['_password_enabled'] == true,
      );
      if (deviceId != null) {
        try {
          await DeviceRegistry.heartbeat(userId);
        } catch (_) {
          // An offline backend must not invalidate a locally restored session.
        }
      }
      await _syncReminderFromBackend();
    } catch (_) {
      await _clearLocalSession();
    }
  }

  /// Applies the backend reminder preference after a session is established so
  /// a change made on the web or another device is reflected here.
  Future<void> _syncReminderFromBackend() async {
    try {
      final preference = await ReminderPreferenceApi.fetch();
      if (preference == null) return;
      await _ref
          .read(appSettingsProvider.notifier)
          .applyBackendPreference(preference);
    } catch (_) {
      // Syncing is best-effort; the locally stored reminder stays in effect.
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await ApiClient.dio.post(
      '/v1/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = ApiResponse.map(response);
    if (data == null) return null;
    if (data['password_change_required'] == true) return data;
    if (data['verification_required'] == true) return data;
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
    final data = ApiResponse.map(response);
    if (data == null) return null;
    if (data['verification_required'] == true) return data;
    return _completeSession(data);
  }

  /// Registers an account. The backend issues no session: it returns the
  /// verification response so the caller can route to the WhatsApp OTP screen.
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
    return ApiResponse.map(response);
  }

  /// Finalizes a session from a legacy/fallback response that still carries
  /// access tokens (for example the login path for an already-verified phone).
  Future<Map<String, dynamic>?> completeSession(
    Map<String, dynamic>? data,
  ) {
    return _completeSession(data);
  }

  /// Completes the public WhatsApp OTP flow using the short-lived verification
  /// token issued at registration or sign-in.
  Future<bool> verifyPhone(String verificationToken, String code) async {
    final response = await ApiClient.dio.post(
      '/v1/auth/phone-verification/verify',
      data: {'verification_token': verificationToken, 'code': code},
    );
    return ApiResponse.map(response)?['verified'] == true;
  }

  /// Requests a fresh WhatsApp code for the verification token's account.
  /// Returns the demo-mode preview code when the backend delivers one, or null
  /// when no preview is available (mirrors [startPhoneVerification]).
  Future<String?> resendPhone(String verificationToken) async {
    final response = await ApiClient.dio.post(
      '/v1/auth/phone-verification/verify/resend',
      data: {'verification_token': verificationToken},
    );
    return ApiResponse.map(response)?['preview_code']?.toString();
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
      avatarUrl: user['avatar_url']?.toString(),
      role: user['role']?.toString(),
      deviceId: deviceId,
      phone: user['phone_e164']?.toString(),
      phoneVerified: user['phone_verified_at'] != null,
      passwordEnabled: user['_password_enabled'] == true,
    );
    await _syncReminderFromBackend();
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
    await _storage.write(key: _userKey, value: jsonEncode(user));
    state = state.copyWith(
      email: user['email']?.toString(),
      displayName: user['display_name']?.toString(),
      avatarUrl: user['avatar_url']?.toString(),
      phone: user['phone_e164']?.toString(),
      phoneVerified: user['phone_verified_at'] != null,
      passwordEnabled: user['_password_enabled'] == true,
    );
  }

  /// Applies an avatar change returned by the backend (upload or delete).
  /// Persists the full updated user so a later session restore shows the new
  /// avatar, and updates state even when [avatarUrl] is null (avatar deleted).
  Future<void> applyAvatar(String? avatarUrl) async {
    final user = await _readStoredUser();
    if (user != null) {
      user['avatar_url'] = avatarUrl == null || avatarUrl.isEmpty
          ? null
          : avatarUrl;
      await _storage.write(key: _userKey, value: jsonEncode(user));
    }
    final normalized = avatarUrl == null || avatarUrl.isEmpty ? null : avatarUrl;
    state = AuthState(
      isAuthenticated: state.isAuthenticated,
      isLoading: state.isLoading,
      userId: state.userId,
      email: state.email,
      displayName: state.displayName,
      avatarUrl: normalized,
      avatarVersion: state.avatarVersion + 1,
      role: state.role,
      deviceId: state.deviceId,
      phone: state.phone,
      phoneVerified: state.phoneVerified,
      passwordEnabled: state.passwordEnabled,
    );
  }

  Future<Map<String, dynamic>?> _readStoredUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson == null) return null;
      final decoded = jsonDecode(userJson);
      return decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : null;
    } catch (_) {
      return null;
    }
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

  Future<void> updateDisplayName(String displayName) async {
    final response = await ApiClient.dio.patch(
      '/v1/me',
      data: {'display_name': displayName.trim()},
    );
    final user = ApiResponse.map(response);
    if (user == null) throw StateError('Profile response is empty');
    user['_password_enabled'] = state.passwordEnabled;
    await _storage.write(key: _userKey, value: jsonEncode(user));
    state = state.copyWith(
      displayName: user['display_name']?.toString(),
      avatarUrl: user['avatar_url']?.toString(),
    );
  }

  /// Uploads a square WebP avatar (≤2 MiB) as multipart field `avatar`.
  /// The backend returns the updated user, whose `avatar_url` is applied.
  Future<void> uploadAvatar(Uint8List webpBytes) async {
    final formData = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(
        webpBytes,
        filename: 'avatar.webp',
        contentType: DioMediaType('image', 'webp'),
      ),
    });
    final response = await ApiClient.dio.post(
      '/v1/me/avatar',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final user = ApiResponse.map(response);
    if (user == null) throw StateError('Avatar response is empty');
    await applyAvatar(user['avatar_url']?.toString());
    await refreshProfile();
  }

  /// Deletes the current avatar. The backend returns the updated user.
  Future<void> deleteAvatar() async {
    final response = await ApiClient.dio.delete('/v1/me/avatar');
    final user = ApiResponse.map(response);
    if (user == null) throw StateError('Avatar response is empty');
    await applyAvatar(user['avatar_url']?.toString());
    await refreshProfile();
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
  return AuthNotifier(ref);
});

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

/// Centralized HTTP client for the Gamblock-AI backend.
///
/// The base URL is read from [AppConfig] (`.env` → `API_BASE_URL`) so it is never
/// hardcoded here. Tokens are persisted in flutter_secure_storage (platform
/// keychain/keystore). A 401 triggers a single refresh attempt with retry.
class ApiClient {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  static late final Dio _dio;
  static bool _initialized = false;
  static Future<bool>? _refreshInFlight;
  static Future<void> Function()? onSessionExpired;

  /// In-memory access-token cache so the Dio interceptor does not hit the
  /// platform Keystore on every request. Written on save/refresh, cleared on
  /// clearTokens; falls back to secure storage on process start.
  static String? _cachedAccessToken;

  /// Initialize the Dio instance with interceptors. Must be called once after
  /// `AppConfig` is available (i.e. after `dotenv.load()` in main).
  static Future<void> init() async {
    if (_initialized) return;
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          // Marks this client as the shipped Android/Windows app so the backend
          // restricts session issuance to student (`user`) accounts.
          'X-Client-Type': 'native',
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _cachedAccessToken ??
              await _storage.read(key: _accessTokenKey);
          if (token != null) {
            _cachedAccessToken = token;
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final alreadyRetried =
              error.requestOptions.extra['auth_retried'] == true;
          final isRefreshRequest =
              error.requestOptions.path == '/v1/auth/refresh';
          if (error.response?.statusCode == 401 &&
              !alreadyRetried &&
              !isRefreshRequest) {
            final refreshed = await _refreshOnce();
            if (refreshed) {
              final retryResponse = await _retryWithNewToken(
                error.requestOptions,
              );
              handler.resolve(retryResponse);
              return;
            }
            await clearTokens();
            await onSessionExpired?.call();
          }
          handler.next(error);
        },
      ),
    );
    _initialized = true;
  }

  static Dio get dio {
    if (!_initialized) {
      throw StateError('ApiClient.init() must be called before use');
    }
    return _dio;
  }

  static String get baseUrl => AppConfig.apiBaseUrl;

  static Future<bool> _refreshOnce() {
    final existing = _refreshInFlight;
    if (existing != null) return existing;
    final future = _tryRefresh();
    _refreshInFlight = future;
    future.whenComplete(() => _refreshInFlight = null);
    return future;
  }

  static Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;
      final response = await Dio(
        BaseOptions(baseUrl: AppConfig.apiBaseUrl),
      ).post('/v1/auth/refresh', data: {'refresh_token': refreshToken});
      final data = response.data['data'];
      if (data != null) {
        final accessToken = data['access_token']?.toString();
        if (accessToken != null) {
          _cachedAccessToken = accessToken;
          await _storage.write(key: _accessTokenKey, value: accessToken);
        }
        await _storage.write(
          key: _refreshTokenKey,
          value: data['refresh_token'],
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<Response> _retryWithNewToken(
    RequestOptions requestOptions,
  ) async {
    final token = await _storage.read(key: _accessTokenKey);
    final opts = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $token'},
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
      extra: {...requestOptions.extra, 'auth_retried': true},
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: opts,
    );
  }

  static Future<void> saveTokens(String access, String refresh) async {
    _cachedAccessToken = access;
    await _storage.write(key: _accessTokenKey, value: access);
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }

  static Future<void> clearTokens() async {
    _cachedAccessToken = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  static Future<String?> getAccessToken() async {
    return _cachedAccessToken ?? _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }
}

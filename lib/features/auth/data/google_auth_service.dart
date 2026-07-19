import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../domain/google_auth_result.dart';

class GoogleAuthService {
  Future<GoogleAuthResult> authenticate() async {
    if (Platform.isAndroid) return _authenticateAndroid();
    if (Platform.isWindows) return _authenticateWindows();
    throw UnsupportedError('Google sign-in is not available on this platform');
  }

  Future<GoogleAuthResult> _authenticateAndroid() async {
    final clientId = AppConfig.googleWebClientId;
    if (clientId.isEmpty) {
      throw StateError('Google sign-in is not configured');
    }
    final signIn = GoogleSignIn.instance;
    await signIn.initialize(serverClientId: clientId);
    final account = await signIn.authenticate(scopeHint: const ['email']);
    final authentication = account.authentication;
    final idToken = authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google did not return an ID token');
    }
    return GoogleAuthResult(idToken: idToken);
  }

  Future<GoogleAuthResult> _authenticateWindows() async {
    final clientId = AppConfig.googleWindowsClientId;
    if (clientId.isEmpty) {
      throw StateError('Google sign-in is not configured');
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final redirectUri = 'http://127.0.0.1:${server.port}/oauth/callback';
    final state = _randomUrlSafe(32);
    final nonce = _randomUrlSafe(32);
    final verifier = _randomUrlSafe(64);
    final challenge = base64Url
        .encode(sha256.convert(utf8.encode(verifier)).bytes)
        .replaceAll('=', '');
    final authorization =
        Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
          'client_id': clientId,
          'redirect_uri': redirectUri,
          'response_type': 'code',
          'scope': 'openid email profile',
          'state': state,
          'nonce': nonce,
          'code_challenge': challenge,
          'code_challenge_method': 'S256',
        });
    if (!await launchUrl(authorization, mode: LaunchMode.externalApplication)) {
      await server.close(force: true);
      throw StateError('Unable to open the Google sign-in page');
    }
    try {
      final request = await server.first.timeout(const Duration(minutes: 3));
      final returnedState = request.uri.queryParameters['state'];
      final code = request.uri.queryParameters['code'];
      final error = request.uri.queryParameters['error'];
      request.response.headers.contentType = ContentType.html;
      request.response.write(
        '<!doctype html><meta charset="utf-8"><title>Gamblock-AI</title>'
        '<body style="font-family:sans-serif;padding:40px">'
        '${error == null ? 'Login selesai. Anda dapat kembali ke Gamblock-AI.' : 'Login dibatalkan. Anda dapat menutup jendela ini.'}'
        '</body>',
      );
      await request.response.close();
      if (error != null || code == null || returnedState != state) {
        throw StateError(
          'Google sign-in was cancelled or could not be verified',
        );
      }
      final response = await Dio().post<Map<String, dynamic>>(
        'https://oauth2.googleapis.com/token',
        data: {
          'client_id': clientId,
          'code': code,
          'code_verifier': verifier,
          'grant_type': 'authorization_code',
          'redirect_uri': redirectUri,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final idToken = response.data?['id_token']?.toString();
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google did not return an ID token');
      }
      return GoogleAuthResult(idToken: idToken, nonce: nonce);
    } finally {
      await server.close(force: true);
    }
  }

  String _randomUrlSafe(int length) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}

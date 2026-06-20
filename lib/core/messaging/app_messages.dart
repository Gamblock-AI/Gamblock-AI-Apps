import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// End-user-facing message catalog (mirrors backend internal/i18n/messages.go
/// and Next.js lib/messages.ts).
///
/// Maps the stable backend error `code` (from the API envelope
/// `{ data, error: { code, message }, request_id }`) to friendly Indonesian
/// text. Use [friendlyMessage] to resolve any thrown error into a
/// production-safe string; in development the technical detail is surfaced.
///
/// Keep codes in sync across the three catalogs.
class AppMessages {
  AppMessages._();

  /// Generic fallback when a code has no specific friendly message.
  static const generic = 'Terjadi kendala, silakan coba beberapa saat lagi.';

  static const Map<String, String> _messages = {
    // auth
    'email_required': 'Email wajib diisi.',
    'validation_failed': 'Email dan nama wajib diisi.',
    'invalid_credentials': 'Email atau kata sandi salah. Silakan periksa kembali.',
    'registration_failed': 'Pendaftaran gagal. Email mungkin sudah terdaftar.',
    'google_verification_failed': 'Verifikasi Google gagal. Silakan coba lagi.',
    'invalid_refresh_token': 'Sesi tidak valid. Silakan masuk kembali.',
    'refresh_token_required': 'Sesi telah berakhir. Silakan masuk kembali.',
    'logout_failed': 'Gagal keluar. Silakan coba lagi.',

    // partners / accountability
    'partner_email_required': 'Email pendamping wajib diisi.',
    'fetch_partners_failed': 'Gagal memuat data pendamping.',
    'partner_invite_failed': 'Gagal mengirim undangan pendamping.',
    'partner_accept_failed': 'Gagal menerima undangan pendamping.',
    'partner_revoke_failed': 'Gagal memutuskan hubungan pendamping.',
    'fetch_approval_requests_failed': 'Gagal memuat daftar permohonan.',
    'approval_request_failed': 'Gagal mengajukan permohonan.',
    'approval_cancel_failed': 'Gagal membatalkan permohonan.',
    'approval_approve_failed': 'Gagal menyetujui permohonan.',
    'approval_deny_failed': 'Gagal menolak permohonan.',

    // organizations
    'name_required': 'Nama grup wajib diisi.',
    'create_org_failed': 'Gagal membuat grup.',
    'org_not_found': 'Grup tidak ditemukan.',
    'group_code_required': 'Kode grup wajib diisi.',
    'join_failed': 'Kode grup tidak valid. Coba lagi.',
    'no_org': 'Anda belum bergabung dengan grup mana pun.',
    'list_members_failed': 'Gagal memuat daftar anggota.',
    'analytics_failed': 'Gagal memuat analitik grup.',
    'remove_member_failed': 'Gagal mengeluarkan anggota.',

    // missions
    'mission_fetch_failed': 'Gagal memuat misi harian.',
    'mission_update_failed': 'Gagal memperbarui misi harian.',

    // reflections / psychoeducation
    'fetch_reflections_failed': 'Gagal memuat jurnal refleksi.',
    'reflection_create_failed': 'Gagal menyimpan jurnal refleksi.',
    'fetch_modules_failed': 'Gagal memuat modul psikoedukasi.',
    'module_not_found': 'Modul tidak ditemukan.',

    // quick approval
    'invalid_token': 'Token tidak valid atau sudah kadaluarsa.',
    'resolve_failed': 'Gagal memproses permohonan.',

    // support / data requests
    'fetch_support_cases_failed': 'Gagal memuat tiket bantuan.',
    'support_case_failed': 'Gagal mengirim tiket bantuan.',
    'fetch_data_requests_failed': 'Gagal memuat permintaan data.',
    'data_request_failed': 'Gagal mengajukan permintaan data.',

    // releases / emergency
    'release_not_found': 'Rilis tidak ditemukan.',
    'generate_key_failed': 'Gagal membuat kunci darurat.',
    'invalid_key': 'Kunci darurat tidak valid.',
  };

  /// Friendly message for a backend error [code], or [generic] if unknown.
  static String forCode(String? code) {
    if (code == null) return generic;
    return _messages[code] ?? generic;
  }

  /// Resolve any thrown error into a production-safe friendly message.
  ///
  /// Reads the Dio response envelope `error.code`/`error.message` when present.
  /// Production: friendly catalog/backend message (never leaks). Development:
  /// technical detail (code + message/status) for debugging.
  static String friendlyMessage(Object error) {
    final code = _extractCode(error);
    final backendMessage = _extractMessage(error);
    final status = _extractStatus(error);

    if (!AppConfig.isProduction) {
      // Development: surface technical detail.
      if (code != null) return '[$code] ${backendMessage ?? forCode(code)}';
      if (status != null) return 'API error: $status';
      return error.toString();
    }

    // Production: friendly only.
    if (backendMessage != null && backendMessage.trim().isNotEmpty) {
      return backendMessage;
    }
    if (code != null) return forCode(code);
    if (status != null) return _statusMessage(status);
    return generic;
  }

  static String? _extractCode(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final err = data['error'];
        if (err is Map<String, dynamic>) {
          final code = err['code'];
          if (code is String) return code;
        }
      }
    }
    return null;
  }

  static String? _extractMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final err = data['error'];
        if (err is Map<String, dynamic>) {
          final msg = err['message'];
          if (msg is String) return msg;
        }
      }
    }
    return null;
  }

  static int? _extractStatus(Object error) {
    if (error is DioException) return error.response?.statusCode;
    return null;
  }

  static String _statusMessage(int status) {
    switch (status) {
      case 400:
        return 'Permintaan tidak valid. Periksa kembali isian Anda.';
      case 401:
        return 'Sesi telah berakhir. Silakan masuk kembali.';
      case 403:
        return 'Anda tidak memiliki izin untuk aksi ini.';
      case 404:
        return 'Data yang diminta tidak ditemukan.';
      case 409:
        return 'Konflik data. Silakan muat ulang dan coba lagi.';
      case 429:
        return 'Terlalu banyak permintaan. Coba lagi sebentar lagi.';
      case 500:
      case 502:
      case 503:
        return 'Server sedang sibuk. Silakan coba beberapa saat lagi.';
      default:
        return generic;
    }
  }
}

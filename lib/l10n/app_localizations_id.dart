// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Gamblock AI';

  @override
  String get protectionActive => 'Proteksi Aktif';

  @override
  String get protectionDesc =>
      'Perangkat ini sedang diawasi oleh AI lokal Gamblock.';

  @override
  String get cancel => 'Batal';

  @override
  String get submit => 'Kirim';

  @override
  String get protectionActiveTitle => 'Perlindungan perangkat aktif';

  @override
  String get protectionSensorsTitle => 'Perangkat & Sensor';

  @override
  String get protectionRequestSent =>
      'Permohonan dikirim. Menunggu persetujuan.';

  @override
  String get save => 'Simpan';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get verifyCode => 'Verifikasi kode';

  @override
  String get msgErrDataConflict =>
      'Konflik data. Silakan muat ulang dan coba lagi.';

  @override
  String get msgErrLoadTicket => 'Gagal memuat tiket bantuan.';

  @override
  String get msgErrServerBusy =>
      'Server sedang sibuk. Silakan coba beberapa saat lagi.';

  @override
  String get msgErrDataNotFound => 'Data yang diminta tidak ditemukan.';

  @override
  String get msgErrConnection =>
      'Tidak dapat terhubung ke server. Periksa koneksi Anda dan coba lagi.';

  @override
  String get msgErrGeneric =>
      'Terjadi kendala, silakan coba beberapa saat lagi.';

  @override
  String get msgErrModuleNotFound => 'Modul tidak ditemukan.';

  @override
  String get msgErrSendTicket => 'Gagal mengirim tiket bantuan.';

  @override
  String get msgErrActionRequired => 'Jenis tindakan wajib dipilih.';

  @override
  String get msgErrLoadAdminModules => 'Gagal memuat modul admin.';

  @override
  String get msgErrLoadAdminSupportCases => 'Gagal memuat tiket admin.';

  @override
  String get msgErrInternal =>
      'Terjadi kendala pada layanan. Silakan coba beberapa saat lagi.';

  @override
  String get msgErrCreateAdminModule => 'Modul admin belum dapat dibuat.';

  @override
  String get protectionTitle => 'Proteksi';

  @override
  String get retry => 'Coba lagi';

  @override
  String get refresh => 'Muat ulang';

  @override
  String get copy => 'Salin';

  @override
  String get copied => 'Tersalin';

  @override
  String get close => 'Tutup';

  @override
  String get protectionSetupAction => 'Setup platform';

  @override
  String get protectionSyncError => 'Status akun belum dapat disinkronkan';

  @override
  String get protectionAccountabilityTitle => 'Persetujuan perubahan proteksi';

  @override
  String dashboardHello(String name) {
    return 'Halo, $name';
  }

  @override
  String get dashboardHelloGuest => 'Halo';

  @override
  String get protectionInactiveTitle => 'Selesaikan perlindungan perangkat';

  @override
  String get protectionOnDevicePrivacyDesc =>
      'Analisis tetap di perangkat. Server hanya menerima hitungan agregat perlindungan.';

  @override
  String get protectionSignInTitle => 'Proteksi lokal tetap berjalan';

  @override
  String get protectionSignInBody =>
      'Masuk untuk mendaftarkan perangkat, menyinkronkan agregat, dan meminta persetujuan pendamping.';

  @override
  String get protectionStatusActive => 'Proteksi aktif';

  @override
  String get protectionStatusPaused => 'Proteksi dijeda oleh grant';

  @override
  String get protectionStatusDegraded => 'Proteksi terdegradasi';

  @override
  String get protectionStatusInactive => 'Proteksi tidak aktif';

  @override
  String get protectionStatusLocal =>
      'Keputusan dan intervensi berjalan lokal pada perangkat.';

  @override
  String get protectionServiceLabel => 'Service';

  @override
  String get protectionSensorLabel => 'Sensor';

  @override
  String get protectionPermissionLabel => 'Izin';

  @override
  String get protectionArtifactLabel => 'Model dan ruleset';

  @override
  String get protectionPartnerRequired =>
      'Hubungkan pendamping sebelum meminta perubahan proteksi.';

  @override
  String get protectionRequestPending => 'Menunggu persetujuan';

  @override
  String get protectionRequestApproved =>
      'Permintaan telah disetujui dan siap diterapkan.';

  @override
  String get protectionActionLabel => 'Perubahan yang diminta';

  @override
  String get protectionPartnerReady =>
      'Pendamping aktif. Perubahan proteksi dapat diminta dari perangkat ini.';

  @override
  String get protectionApplyApproval => 'Terapkan izin';

  @override
  String get protectionRequestAction => 'Ajukan perubahan';

  @override
  String get protectionApprovalApplied =>
      'Persetujuan diterapkan pada perangkat.';

  @override
  String get protectionApprovalDialogTitle => 'Minta perubahan proteksi';

  @override
  String get protectionApprovalDialogBody =>
      'Permintaan terikat pada perangkat dan harus disetujui pendamping aktif. Proteksi tetap berjalan sampai grant diterapkan.';

  @override
  String get protectionPauseAction => 'Jeda';

  @override
  String get protectionDisableAction => 'Nonaktifkan';

  @override
  String get protectionUninstallAction => 'Copot';

  @override
  String get protectionDurationLabel => 'Durasi jeda';

  @override
  String minutesCount(int minutes) {
    return '$minutes menit';
  }

  @override
  String get protectionReasonLabel => 'Alasan perubahan';

  @override
  String get protectionReasonHelp =>
      'Alasan ini dibagikan kepada pendamping, tanpa data penjelajahan.';

  @override
  String get languageId => 'Bahasa Indonesia';

  @override
  String get languageEn => 'English';

  @override
  String get verifyEmailTitle => 'Verifikasi WhatsApp Anda';

  @override
  String get verifyEmailSent => 'Kode verifikasi WhatsApp telah dikirim.';

  @override
  String get continueAction => 'Lanjutkan';

  @override
  String get verifyEmailBody =>
      'Diperlukan untuk fitur pendamping dan pemulihan akun. Masukkan kode yang dikirim ke WhatsApp.';

  @override
  String get protectionArtifactUnavailable => 'tidak tersedia';

  @override
  String get dashboardAppreciationTitle => 'Perlindunganmu menemanimu';

  @override
  String dashboardAppreciationBody(int count) {
    return 'Perlindungan menemanimu $count kali dalam 7 hari terakhir. Setiap jeda adalah ruang untuk memilih ulang.';
  }

  @override
  String get dashboardGamiFirstOpen =>
      'Selamat datang kembali. Mulai pelan-pelan saja.';

  @override
  String get protectionSensorSubLocalService => 'Layanan proteksi lokal';

  @override
  String get protectionSensorSubDomRelay => 'Relay browser';

  @override
  String get protectionSensorSubAccessibility => 'Izin aksesibilitas';

  @override
  String get protectionSensorFooterLoopback => 'Relai pasif di perangkat';

  @override
  String get protectionSensorFooterPrivacy => 'Privasi di perangkat';

  @override
  String get protectionPlatformLocal => 'Perangkat lokal';

  @override
  String get protectionPlatformAndroid => 'Perangkat Android';

  @override
  String get protectionPlatformWindows => 'Perangkat Windows';

  @override
  String get protectionPlatformLinux => 'Perangkat Linux';

  @override
  String get protectionPlatformMacos => 'Perangkat macOS';

  @override
  String get protectionStatusLocalActive =>
      'AI lokal siap melindungi perangkat ini';

  @override
  String get protectionStatusLocalInactive =>
      'Analisis tetap di perangkat dan privat';

  @override
  String get protectionStatusPrivateChip => 'PRIVAT';

  @override
  String get protectionDataStaysOnDevice =>
      'Data penjelajahan tetap di perangkat';

  @override
  String get viewAll => 'Lihat semua';

  @override
  String get authWelcomeBack => 'Selamat datang kembali.';

  @override
  String get authRegister => 'Daftar';

  @override
  String get authNoAccount => 'Belum punya akun?';

  @override
  String get authLoginAgain => 'masuk kembali';

  @override
  String get authLoginBtn => 'Masuk';

  @override
  String get authForgotPassword => 'Lupa kata sandi?';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Konfirmasi kata sandi';

  @override
  String get authConfirmPasswordMismatch => 'Kata sandi tidak cocok.';

  @override
  String get authEmailInvalid => 'Masukkan alamat email yang valid.';

  @override
  String get authPasswordRequired => 'Kata sandi wajib diisi.';

  @override
  String get authPasswordMinimum => 'Kata sandi minimal 8 karakter.';

  @override
  String get authNameMinimum => 'Nama minimal 3 karakter.';

  @override
  String get authEmail => 'Email';

  @override
  String get authWhatsapp => 'Nomor WhatsApp';

  @override
  String get authWhatsappInvalid => 'Masukkan nomor WhatsApp yang valid.';

  @override
  String get codeVerificationLabel => 'Kode verifikasi WhatsApp';

  @override
  String get authLoginDesc => 'Masuk untuk melanjutkan perlindungan Anda.';

  @override
  String get authCreateAccountTitle => 'Buat akun baru.';

  @override
  String get authRegisterAs => 'Saya mendaftar sebagai';

  @override
  String get authFullName => 'Nama Lengkap';

  @override
  String get authRegisterAndContinue => 'Buat Akun & Lanjutkan';

  @override
  String get authRegisterDesc =>
      'Prototipe berprinsip privasi yang dirancang untuk mahasiswa Indonesia.';

  @override
  String get authHasAccount => 'Sudah punya akun?';

  @override
  String get authStartFree => 'mulai gratis';

  @override
  String get msgErrPasswordResetInvalid =>
      'Kode pemulihan tidak valid, sudah digunakan, atau telah kedaluwarsa.';

  @override
  String get msgErrPasswordResetFailed =>
      'Pemulihan kata sandi belum dapat diproses. Silakan coba lagi.';

  @override
  String get msgErrInvalidSession => 'Sesi tidak valid. Silakan masuk kembali.';

  @override
  String get msgErrInvalidToken => 'Token tidak valid atau sudah kadaluarsa.';

  @override
  String get msgErrEmailRequired => 'Email wajib diisi.';

  @override
  String get msgErrTranslationInvalidInput => 'Input translasi tidak valid.';

  @override
  String get msgErrRegisterFailed =>
      'Pendaftaran gagal. Email mungkin sudah terdaftar.';

  @override
  String get msgErrSessionExpired =>
      'Sesi telah berakhir. Silakan masuk kembali.';

  @override
  String get msgErrInvalidCredentials =>
      'Email atau kata sandi salah. Silakan periksa kembali.';

  @override
  String get msgErrLogout => 'Gagal keluar. Silakan coba lagi.';

  @override
  String get msgErrEmailNameRequired => 'Email dan nama wajib diisi.';

  @override
  String get msgErrUnauthorized => 'Anda tidak memiliki izin untuk aksi ini.';

  @override
  String get msgErrDevLogin => 'Gagal masuk sebagai pengguna demo.';

  @override
  String get msgErrTokenRequired => 'Token validasi wajib diisi.';

  @override
  String get msgErrInvalidInput =>
      'Token dan status (approved/denied) wajib diisi.';

  @override
  String get msgErrPasswordValidation =>
      'Kata sandi saat ini dan kata sandi baru minimal 8 karakter wajib diisi.';

  @override
  String get msgErrCurrentPasswordInvalid => 'Kata sandi saat ini tidak benar.';

  @override
  String get msgErrPasswordReuse =>
      'Kata sandi baru harus berbeda dari kata sandi saat ini.';

  @override
  String get msgErrAuthRequired =>
      'Sesi diperlukan. Silakan masuk terlebih dahulu.';

  @override
  String get msgErrForbidden => 'Anda tidak memiliki izin untuk tindakan ini.';

  @override
  String get msgErrInvalidBody =>
      'Data yang dikirim tidak dapat dibaca. Periksa isian lalu coba lagi.';

  @override
  String get msgErrValidation => 'Periksa kembali isian yang belum sesuai.';

  @override
  String get resendEmail => 'Kirim ulang';

  @override
  String get authResetTitle => 'Lupa kata sandi?';

  @override
  String get authResetTitleCode => 'Masukkan kode pemulihan';

  @override
  String get authResetDesc =>
      'Masukkan email akun. Kami akan mengirim kode tanpa membagikan status pendaftaran email.';

  @override
  String get authResetDescCode =>
      'Kode 12 karakter telah dikirim bila email terdaftar. Kode berlaku 30 menit.';

  @override
  String get authResetSuccess =>
      'Kata sandi berhasil diperbarui. Silakan masuk.';

  @override
  String get authResetNewCodeRequested => 'Kode pemulihan baru telah diminta.';

  @override
  String get authChangeEmail => 'Ganti email';

  @override
  String get authResendCode => 'Kirim ulang kode';

  @override
  String get authRecoveryCodeLabel => 'Kode pemulihan';

  @override
  String get authRecoveryCodeInvalid => 'Kode harus berisi 12 karakter.';

  @override
  String get authNewPasswordLabel => 'Kata sandi baru';

  @override
  String get authPasswordMinChars => 'Gunakan minimal 8 karakter.';

  @override
  String get authPasswordMinShort => 'Minimal 8 karakter';

  @override
  String get authCreateNewPassword => 'Buat kata sandi baru';

  @override
  String get authSendCode => 'Kirim kode';

  @override
  String get authBackToLogin => 'Kembali ke login';

  @override
  String get authTempPasswordDesc =>
      'Kata sandi sementara hanya berlaku untuk langkah ini.';

  @override
  String get authPasswordChangeMin => 'Kata sandi baru minimal 8 karakter.';

  @override
  String get authVerifyPhoneTitle => 'Verifikasi Nomor WhatsApp';

  @override
  String authVerifyPhoneDesc(String phone) {
    return 'Kode 6 digit telah dikirim ke WhatsApp $phone. Masukkan kode untuk menyelesaikan verifikasi.';
  }

  @override
  String get authVerifyCodeLabel => 'Kode Verifikasi';

  @override
  String get authVerifyCodeHint => '6 digit';

  @override
  String get authVerifyCodeInvalid => 'Masukkan kode 6 digit.';

  @override
  String get authVerifyButton => 'Verifikasi';

  @override
  String get authVerifyResend => 'Kirim ulang kode';

  @override
  String get authVerifyResending => 'Mengirim ulang...';

  @override
  String get authVerifySent => 'Kode baru telah dikirim.';

  @override
  String authVerifyPreviewCodeHint(String code) {
    return 'Kode demo: $code';
  }

  @override
  String get authVerifyError =>
      'Verifikasi belum berhasil. Periksa kode atau minta kode baru.';

  @override
  String get authVerifyMissingTitle => 'Verifikasi tidak ditemukan';

  @override
  String get authVerifyMissingBody =>
      'Sesi verifikasi sudah berakhir. Silakan masuk kembali untuk meminta kode baru.';

  @override
  String get authSaveAndLogin => 'Simpan dan masuk';

  @override
  String get authShowPassword => 'Tampilkan kata sandi';

  @override
  String get authHidePassword => 'Sembunyikan kata sandi';

  @override
  String get settingsLogout => 'Keluar';

  @override
  String get settingsAppVersion => 'Gamblock AI v1.0.0';

  @override
  String get settingsLogoutConfirm => 'Apakah Anda yakin ingin keluar?';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsAboutApp => 'Tentang Aplikasi';

  @override
  String get settingsAccountabilityPartner => 'Pendamping Akuntabilitas';

  @override
  String get settingsEmailVerified => 'Email terverifikasi';

  @override
  String get settingsEmailUnverified => 'Email belum terverifikasi';

  @override
  String get settingsWhatsappVerified => 'WhatsApp terverifikasi';

  @override
  String get settingsWhatsappUnverified => 'WhatsApp belum terverifikasi';

  @override
  String get settingsAvatarUpload => 'Unggah foto profil';

  @override
  String get settingsAvatarChange => 'Ganti foto profil';

  @override
  String get settingsAvatarRemove => 'Hapus foto';

  @override
  String get settingsAvatarUpdated => 'Foto profil berhasil diperbarui.';

  @override
  String get settingsAvatarRemoved => 'Foto profil berhasil dihapus.';

  @override
  String get settingsAvatarInvalid =>
      'Gambar tidak dapat dibaca. Pilih foto lain.';

  @override
  String get settingsAccountSection => 'Akun';

  @override
  String get settingsPreferencesSection => 'Preferensi';

  @override
  String get settingsWindowsSection => 'Windows dan ekstensi';

  @override
  String get settingsAboutSection => 'Tentang dan bantuan';

  @override
  String get settingsUserFallback => 'Pengguna';

  @override
  String get settingsEditProfile => 'Ubah nama profil';

  @override
  String get settingsProfileUpdated => 'Profil berhasil diperbarui.';

  @override
  String get settingsChangePassword => 'Ubah kata sandi';

  @override
  String get settingsCurrentPassword => 'Kata sandi saat ini';

  @override
  String get settingsNewPassword => 'Kata sandi baru';

  @override
  String get settingsConfirmPassword => 'Ulangi kata sandi baru';

  @override
  String get settingsShowPassword => 'Tampilkan kata sandi';

  @override
  String get settingsHidePassword => 'Sembunyikan kata sandi';

  @override
  String get settingsPasswordMismatch =>
      'Kata sandi baru minimal 8 karakter dan harus sama.';

  @override
  String get settingsPasswordUpdated =>
      'Kata sandi diperbarui. Silakan masuk kembali.';

  @override
  String get settingsLanguage => 'Bahasa aplikasi';

  @override
  String get settingsHaptics => 'Umpan balik getar';

  @override
  String get settingsHealthNotifications => 'Notifikasi kesehatan proteksi';

  @override
  String get settingsHealthNotificationsBody =>
      'Notifikasi hanya memuat status service atau izin, tanpa data situs.';

  @override
  String get settingsPairingToken => 'Token pairing ekstensi';

  @override
  String get settingsPairingUnavailable => 'Service Windows belum terhubung.';

  @override
  String get settingsRotatePairing => 'Rotasi token pairing';

  @override
  String get settingsArtifacts => 'Artefak proteksi lokal';

  @override
  String get settingsPrivacy => 'Kebijakan privasi';

  @override
  String get settingsHelp => 'Pusat bantuan';

  @override
  String get settingsRotateConfirmTitle => 'Putar token penyambungan?';

  @override
  String get settingsRotateConfirmBody =>
      'Penyambungan ekstensi browser yang ada akan langsung tidak berlaku dan perlu disambungkan ulang.';

  @override
  String get settingsRotateConfirmAction => 'Putar token';

  @override
  String get settingsRotateSuccess => 'Token penyambungan diperbarui.';

  @override
  String get settingsPasswordChangedTitle => 'Kata sandi diperbarui';

  @override
  String get settingsPasswordChangedBody =>
      'Silakan masuk kembali dengan kata sandi baru.';

  @override
  String get settingsReminderTitle => 'Pengingat check-in harian';

  @override
  String get settingsReminderDesc =>
      'Sekali sehari, di waktu pilihanmu. Tanpa isi sensitif di layar kunci.';

  @override
  String get settingsReminderTime => 'Waktu pengingat';

  @override
  String get settingsReminderPermissionDenied =>
      'Izin notifikasi belum diberikan. Kamu bisa mengaktifkannya lewat pengaturan sistem.';

  @override
  String get legalPrivacyTitle => 'Kebijakan Privasi';

  @override
  String get legalPrivacyUpdated => 'Terakhir diperbarui: Agustus 2026';

  @override
  String get legalPrivacyIntro =>
      'Privasi adalah prinsip inti Gamblock-AI. Kebijakan ini menjelaskan data apa yang kami proses dan bagaimana kami melindunginya, selaras dengan prinsip minimalisasi data UU PDP.';

  @override
  String get legalPrivacyS1Title => 'Prinsip Privasi On-Device';

  @override
  String get legalPrivacyS1Body =>
      'Dengan persetujuan terpisah, Accessibility Service Android membaca teks yang terlihat pada Chrome dan Edge yang didukung, termasuk bilah URL, judul, heading, dan teks tautan. Data tersebut diproses sementara untuk inferensi AI di perangkat, lalu aplikasi dapat menjalankan aksi Kembali dan menampilkan Pattern Interrupt.\nURL, domain, teks halaman, screenshot, dan riwayat penelusuran tidak pernah dikirim ke server atau layanan AI eksternal.';

  @override
  String get legalPrivacyS2Title => 'Data yang Kami Proses';

  @override
  String get legalPrivacyS2Body =>
      'Untuk akun dan pendampingan, kami memproses data seperti nama tampilan, email, relasi grup, pilihan persetujuan, agregat jumlah perlindungan, dan timestamp sistem saat pemblokiran bila kategori tersebut diaktifkan. Public key perangkat dan thumbprint pseudonim dipakai hanya untuk mengikat grant persetujuan ke perangkat.\nPayload ini tidak memuat URL, domain, DOM, judul, screenshot, skor halaman, atau riwayat penelusuran.';

  @override
  String get legalPrivacyS3Title => 'Enkripsi dan Keamanan';

  @override
  String get legalPrivacyS3Body =>
      'Jurnal refleksi dan catatan sensitif dienkripsi menggunakan AES-256-GCM sebelum disimpan. Grant penghentian perlindungan ditandatangani backend, berumur pendek, dan terikat ke public key native perangkat.\nKeystore Android dan Windows CNG/DPAPI melindungi material serta state lokal yang relevan.';

  @override
  String get legalPrivacyS4Title => 'Dasbor Pengawasan Bersifat Agregat';

  @override
  String get legalPrivacyS4Body =>
      'Pendamping hanya melihat skor dan statistik agregat, bukan URL atau riwayat penelusuran mentah milik Member.\nIni menjaga keseimbangan antara akuntabilitas dan privasi pengguna.';

  @override
  String get legalPrivacyS5Title => 'Hak Pengguna';

  @override
  String get legalPrivacyS5Body =>
      'Anda dapat menolak persetujuan Accessibility dan tetap menggunakan fitur yang tidak memerlukannya. Anda juga berhak mengakses, memperbaiki, dan meminta penghapusan data pribadi sesuai ketentuan yang berlaku.\nEdisi Play dapat dicopot melalui mekanisme Android biasa; edisi pilot memiliki jalur administrator darurat yang terdokumentasi. Permintaan data diajukan melalui pusat bantuan.';

  @override
  String get legalPrivacyS6Title => 'Kontak';

  @override
  String get legalPrivacyS6Body =>
      'Untuk pertanyaan terkait privasi, silakan hubungi tim pengembang melalui kanal dukungan yang tersedia di aplikasi.\nKebijakan ini dapat diperbarui dan perubahan material akan diinformasikan.';

  @override
  String get legalHelpTitle => 'Pusat Bantuan';

  @override
  String get legalHelpUpdated => 'Pusat bantuan Gamblock-AI';

  @override
  String get legalHelpIntro =>
      'Temukan jawaban cepat seputar pemasangan, akun, privasi, dan fitur pendampingan Gamblock-AI.';

  @override
  String get legalHelpS1Title => 'Memulai';

  @override
  String get legalHelpS1Body =>
      'Edisi Android publik dipasang melalui Google Play. Edisi Research Android dan Pilot Windows hanya dipasang oleh tim pada perangkat uji yang disetujui.\nSetelah membuat akun, ikuti disclosure Accessibility sebelum memilih apakah akan mengaktifkan proteksi browser, lalu tautkan Accountability Partner bila diperlukan.';

  @override
  String get legalHelpS2Title => 'Akun & Masuk';

  @override
  String get legalHelpS2Body =>
      'Gunakan email terdaftar untuk masuk. Lupa kata sandi? Gunakan tautan \"Lupa kata sandi\" di halaman masuk untuk mengatur ulang.\nSatu akun Member terhubung ke satu grup pendamping pada satu waktu.';

  @override
  String get legalHelpS3Title => 'Privasi & Keamanan';

  @override
  String get legalHelpS3Body =>
      'Seluruh deteksi berjalan lokal di perangkat. Riwayat penelusuran Anda tidak pernah dikirim ke server.\nJurnal refleksi dienkripsi dengan standar AES-256-GCM.';

  @override
  String get legalHelpS4Title => 'Pendamping (Accountability Partner)';

  @override
  String get legalHelpS4Body =>
      'Pada edisi Research/Pilot, persetujuan pendamping adalah jalur normal untuk menghentikan proteksi; administrator tetap memiliki break-glass yang bersih. Edisi Play tidak mencegah pencopotan dari pengaturan Android.\nPendamping hanya melihat statistik agregat yang diizinkan, bukan riwayat penelusuran mentah.';

  @override
  String get legalHelpS5Title => 'Masih butuh bantuan?';

  @override
  String get legalHelpS5Body =>
      'Jika masalah belum teratasi, hubungi tim kami melalui halaman Hubungi Kami.\nKami berupaya merespons pertanyaan sesegera mungkin selama periode program.';

  @override
  String get msgErrCreateDevice => 'Gagal mendaftarkan perangkat.';

  @override
  String get msgErrUpdateDevice => 'Gagal memperbarui perangkat.';

  @override
  String get msgErrHeartbeat => 'Gagal mengirim sinyal aktif perangkat.';

  @override
  String get selfTestAction => 'Jalankan pemeriksaan';

  @override
  String get selfTestPassed => 'Pemeriksaan lokal berhasil';

  @override
  String get selfTestFailed => 'Pemeriksaan lokal gagal';

  @override
  String get selfTestFixtureBody =>
      'Semua yang dibutuhkan untuk melindungi Anda lolos pemeriksaan.';

  @override
  String get selfTestNativeUnavailable =>
      'Perlindungan belum tersedia di perangkat ini.';

  @override
  String get selfTestIntegrityFailed =>
      'Sebagian berkas proteksi tidak dapat diverifikasi.';

  @override
  String get selfTestFixtureMismatch =>
      'Hasil pemeriksaan proteksi tidak sesuai yang diharapkan.';

  @override
  String get selfTestArtifactInvalid => 'Sebagian berkas proteksi tidak valid.';

  @override
  String get selfTestSensorDisconnected => 'Sensor browser tidak terhubung.';

  @override
  String get selfTestAccessibilityMissing =>
      'Izin akses Android belum diberikan.';

  @override
  String get deviceRegistrationMissing => 'Perangkat belum terdaftar';

  @override
  String get deviceRegistrationMissingBody =>
      'Fitur ini memerlukan perangkat terdaftar. Daftarkan perangkat lewat aplikasi Android/Windows, atau selesaikan pengaturan di sini.';

  @override
  String get statusConnected => 'Terhubung';

  @override
  String get statusDisconnected => 'Terputus';

  @override
  String get emergencyTitle => 'Pemulihan darurat';

  @override
  String get emergencyBody =>
      'Gunakan hanya saat pendamping tidak tersedia atau perangkat terkunci dalam kondisi yang aman untuk dipulihkan.';

  @override
  String emergencyStatus(String status) {
    return 'Status permintaan darurat: $status';
  }

  @override
  String get emergencyRequestAction => 'Minta pemulihan';

  @override
  String get emergencyEnterKeyAction => 'Masukkan kunci';

  @override
  String get emergencyRequestCreated =>
      'Permintaan pemulihan darurat berhasil dibuat.';

  @override
  String get emergencyKeyTitle => 'Masukkan kunci darurat';

  @override
  String get emergencyKeyLabel => 'Kunci satu-kali-pakai';

  @override
  String get emergencyKeyHelp =>
      'Kunci diterbitkan setelah ditinjau dua admin platform berbeda, terikat pada perangkat ini, dan berlaku 24 jam.';

  @override
  String get emergencyKeyApplied => 'Grant darurat diterapkan selama 10 menit.';

  @override
  String get checkSetupAction => 'Periksa setup';

  @override
  String get helpPageOpenError =>
      'Halaman bantuan belum dapat dibuka. Coba lagi.';

  @override
  String get statusChipOk => 'OK';

  @override
  String get statusChipWarn => 'WASPADA';

  @override
  String get statusChipOff => 'MATI';

  @override
  String get statusGranted => 'Diberikan';

  @override
  String get statusRevoked => 'Dicabut';

  @override
  String get statusDisabled => 'Nonaktif';

  @override
  String get statusUnknown => 'Tidak diketahui';

  @override
  String get degradedAccessibilityDisabled => 'Aksesibilitas dinonaktifkan';

  @override
  String get degradedAccessibilityNotGranted =>
      'Izin aksesibilitas belum diberikan';

  @override
  String get degradedServiceStopped => 'Layanan proteksi terhenti';

  @override
  String get degradedPermissionRevoked => 'Izin sistem dicabut';

  @override
  String get degradedSensorDisconnected => 'Sensor terputus';

  @override
  String get statusPending => 'menunggu';

  @override
  String get statusReviewed => 'dalam tinjauan';

  @override
  String get statusApproved => 'disetujui';

  @override
  String get statusRejected => 'ditolak';

  @override
  String get statusExpired => 'kedaluwarsa';

  @override
  String get analyticsTitle => 'Analitik';

  @override
  String get analyticsSignInTitle => 'Masuk untuk melihat analitik';

  @override
  String get analyticsSignInBody =>
      'Analitik hanya berisi hitungan agregat perangkat dan tidak memuat URL atau riwayat penjelajahan.';

  @override
  String get analyticsSevenDays => '7 hari';

  @override
  String get analyticsThirtyDays => '30 hari';

  @override
  String get analyticsErrorTitle => 'Analitik belum dapat dimuat';

  @override
  String get analyticsPrivacyNote =>
      'Hanya hitungan harian yang ditampilkan. URL, domain, judul halaman, dan teks DOM tidak disimpan atau dikirim.';

  @override
  String get analyticsDataSynced =>
      'Hitungan hari yang selesai sudah disinkronkan ke akun Anda.';

  @override
  String get analyticsDataLocalOnly =>
      'Backend tidak tersedia atau data belum cukup; tampilan ini memakai hitungan lokal yang tersedia.';

  @override
  String get analyticsBlocked => 'Konten diblokir';

  @override
  String get analyticsInterventions => 'Intervensi';

  @override
  String get analyticsTamper => 'Upaya perubahan';

  @override
  String get analyticsPermission => 'Izin dicabut';

  @override
  String get analyticsSummaryTitle => 'Ringkasan Perlindungan';

  @override
  String get analyticsSummaryDesc =>
      'Pantau tren pemblokiran otomatis, intervensi perilaku, dan statistik proteksi lokal.';

  @override
  String get analyticsChartTitle => 'Tren Aktivitas Proteksi';

  @override
  String get analytics7Days => '7 Hari Terakhir';

  @override
  String get analytics30Days => '30 Hari Terakhir';

  @override
  String get analyticsLegendBlocked => 'Blokir';

  @override
  String get analyticsLegendInterventions => 'Intervensi';

  @override
  String get analyticsNoActivityTitle => 'Belum Ada Aktivitas Terdeteksi';

  @override
  String get analyticsNoActivityDesc =>
      'Grafik akan terisi otomatis saat terjadi pemblokiran atau intervensi.';

  @override
  String get analyticsPrivacySectionTitle => 'Jaminan Privasi & Keamanan Data';

  @override
  String get analyticsOnDeviceTitle => 'Privasi terjaga';

  @override
  String get analyticsOnDeviceDesc =>
      'Semua dianalisis di perangkat Anda, tidak pernah di cloud.';

  @override
  String get analyticsNoBrowsingHistoryTitle => 'Tanpa Riwayat Penelusuran';

  @override
  String get analyticsNoBrowsingHistoryDesc =>
      'Riwayat penelusuran Anda tidak pernah meninggalkan perangkat ini.';

  @override
  String analyticsChartSummary(int blocked, int interventions) {
    return '$blocked diblokir, $interventions intervensi';
  }

  @override
  String analyticsDayTooltip(int blocked, int interventions) {
    return '$blocked diblokir · $interventions intervensi';
  }

  @override
  String get analyticsMilestoneTitle => 'Perlindunganmu bekerja';

  @override
  String analyticsMilestoneBody(int count, int days) {
    return 'Perlindungan membantumu $count kali dalam $days hari terakhir. Setiap jeda adalah ruang untuk memilih ulang.';
  }

  @override
  String get msgErrLoadPartner => 'Gagal memuat data pendamping.';

  @override
  String get msgErrRejectRequest => 'Gagal menolak permohonan.';

  @override
  String get msgErrInvalidRequest =>
      'Permintaan tidak valid. Periksa kembali isian Anda.';

  @override
  String get msgErrGroupCodeRequired => 'Kode grup wajib diisi.';

  @override
  String get msgErrProcessRequest => 'Gagal memproses permohonan.';

  @override
  String get msgErrApproveRequest => 'Gagal menyetujui permohonan.';

  @override
  String get msgErrGroupNotFound => 'Grup tidak ditemukan.';

  @override
  String get msgErrSubmitRequest => 'Gagal mengajukan permohonan.';

  @override
  String get msgErrInvalidEmergencyKey => 'Kunci darurat tidak valid.';

  @override
  String get msgErrBlockedEventsRejected =>
      'Data waktu blokir perangkat tidak dapat diterima.';

  @override
  String get msgErrCreateGroup => 'Gagal membuat grup.';

  @override
  String get msgErrCreateEmergencyKey => 'Gagal membuat kunci darurat.';

  @override
  String get msgErrRemoveMember => 'Gagal mengeluarkan anggota.';

  @override
  String get msgErrLoadDataRequest => 'Gagal memuat permintaan data.';

  @override
  String get msgErrLoadGroupAnalytics => 'Gagal memuat analitik grup.';

  @override
  String get msgErrSubmitDataRequest => 'Gagal mengajukan permintaan data.';

  @override
  String get msgErrNotInGroup => 'Anda belum bergabung dengan grup mana pun.';

  @override
  String get msgErrTooManyRequests =>
      'Terlalu banyak permintaan. Coba lagi sebentar lagi.';

  @override
  String get msgErrDisconnectPartner => 'Gagal memutuskan hubungan pendamping.';

  @override
  String get msgErrLoadRequests => 'Gagal memuat daftar permohonan.';

  @override
  String get msgErrCancelRequest => 'Gagal membatalkan permohonan.';

  @override
  String get msgErrPartnerEmailRequired => 'Email pendamping wajib diisi.';

  @override
  String get msgErrGroupNameRequired => 'Nama grup wajib diisi.';

  @override
  String get msgErrLoadMembers => 'Gagal memuat daftar anggota.';

  @override
  String get msgErrInvalidGroupCodeSpecific =>
      'Kode grup tidak valid. Coba lagi.';

  @override
  String get msgErrAcceptInvite => 'Gagal menerima undangan pendamping.';

  @override
  String get msgErrSendInvite => 'Gagal mengirim undangan pendamping.';

  @override
  String get msgErrEmergencyKeyRequired => 'Kunci darurat wajib diisi.';

  @override
  String get msgErrPrivacyPayloadRejected =>
      'Permintaan ditolak karena memuat data yang tidak boleh dikirim.';

  @override
  String get partnerTitle => 'Pendamping';

  @override
  String get partnerSignInTitle => 'Masuk untuk mengelola pendamping';

  @override
  String get partnerSignInBody =>
      'Hubungan pendamping dan permintaan persetujuan disimpan pada akun Anda.';

  @override
  String get partnerErrorTitle => 'Data pendamping belum dapat dimuat';

  @override
  String get partnerInviteCreated => 'Undangan pendamping berhasil dibuat.';

  @override
  String get partnerNone => 'Belum ada pendamping aktif';

  @override
  String get partnerNoneBody =>
      'Masukkan kode dari pendamping tepercaya. Pendamping tidak dapat melihat URL, riwayat penjelajahan, atau catatan pemulihan pribadi.';

  @override
  String get partnerActiveBody =>
      'Pendamping aktif dapat menyetujui perubahan proteksi untuk perangkat yang terdaftar.';

  @override
  String get partnerEmailLabel => 'Email pendamping';

  @override
  String get partnerEmailHelp =>
      'Gunakan email orang tepercaya yang memahami dan menyetujui peran ini.';

  @override
  String get partnerInviteAction => 'Buat undangan';

  @override
  String get partnerInviteLink => 'Tautan undangan';

  @override
  String get partnerInviteCopied => 'Tautan undangan tersalin.';

  @override
  String get partnerRequestHistory => 'Riwayat permintaan';

  @override
  String get partnerNoRequests => 'Belum ada permintaan';

  @override
  String get partnerNoRequestsBody =>
      'Permintaan perubahan proteksi dari perangkat akan muncul di sini.';

  @override
  String get partnerManageAction => 'Kelola pendamping';

  @override
  String get accountabilityJoinTitle => 'Hubungkan pendamping dengan kode grup';

  @override
  String get accountabilityJoinBody =>
      'Tinjau nama grup dan pendamping sebelum bergabung. Satu akun hanya dapat memiliki satu grup aktif.';

  @override
  String get accountabilityPreviewAction => 'Tinjau grup';

  @override
  String accountabilityManagedBy(String name) {
    return 'Dikelola oleh $name';
  }

  @override
  String get accountabilityJoinConfirmTitle => 'Bergabung ke grup ini?';

  @override
  String accountabilityJoinConfirmBody(String name) {
    return '$name akan menjadi pendamping Anda. Ringkasan agregat awal dapat Anda matikan dari portal web kapan saja.';
  }

  @override
  String get accountabilityJoinAction => 'Konfirmasi dan bergabung';

  @override
  String get accountabilityJoinSuccess =>
      'Grup akuntabilitas berhasil dihubungkan.';

  @override
  String accountabilityActiveGroup(String name) {
    return 'Terhubung melalui grup $name. Pendamping hanya menerima agregat yang Anda izinkan.';
  }

  @override
  String get partnerSharingPrivacy => 'Privasi Berbagi';

  @override
  String get partnerSharingDesc =>
      'Atur jenis ringkasan agregat yang dapat dilihat pendamping.';

  @override
  String get partnerLeaveSection => 'Keluar dari Pendampingan';

  @override
  String get partnerLeaveNormal => 'Ajukan keluar normal';

  @override
  String get partnerLeaveUnsafe => 'Situasi tidak aman';

  @override
  String get partnerPrivacyBadge => 'Privasi Terlindungi · Hanya Agregat';

  @override
  String get accSharingTitle => 'Data Agregat Dibagikan';

  @override
  String get accSharingSubtitle =>
      'Atur preferensi data agregat anonim untuk pendamping.';

  @override
  String get accShareHealthTitle => 'Kesehatan Perlindungan';

  @override
  String get accShareHealthSubtitle =>
      'Status aktif, degradasi, & izin (tanpa URL).';

  @override
  String get accShareActivityTitle => 'Aktivitas Perlindungan';

  @override
  String get accShareActivitySubtitle =>
      'Hitungan pemblokiran & intervensi agregat.';

  @override
  String get accShareEngagementTitle => 'Keterlibatan Pemulihan';

  @override
  String get accShareEngagementSubtitle =>
      'Ringkasan partisipasi (bukan isi jurnal).';

  @override
  String get accShareEducationTitle => 'Progres Edukasi';

  @override
  String get accShareEducationSubtitle =>
      'Penyelesaian modul psikoedukasi harian.';

  @override
  String get accSharingUpdated => 'Preferensi berbagi diperbarui.';

  @override
  String get accUnsafeExitTitle => 'Keluar Situasi Tidak Aman';

  @override
  String get accNormalExitTitle => 'Ajukan Keluar Pendampingan';

  @override
  String get accUnsafeExitDesc =>
      'Berbagi data segera dihentikan dan permintaan normal dibatalkan.';

  @override
  String get accNormalExitDesc =>
      'Pendamping memiliki waktu 72 jam untuk meninjau permintaan.';

  @override
  String get accReasonLabel => 'Alasan (opsional)';

  @override
  String get accReasonHint => 'Berikan penjelasan singkat...';

  @override
  String get accSendRequest => 'Kirim Permintaan';

  @override
  String get accExitRequestSent => 'Permintaan keluar dikirim.';

  @override
  String get accExitRequestCancelled => 'Permintaan keluar dibatalkan.';

  @override
  String get accApprovalCancelled => 'Permintaan persetujuan dibatalkan.';

  @override
  String get accExitPendingTitle => 'Permintaan keluar sedang ditinjau';

  @override
  String get accExitPendingBody =>
      'Anda dapat membatalkan permintaan normal selama masih tertunda.';

  @override
  String get accExitChoose =>
      'Pilih alur normal atau hentikan berbagi segera bila situasi tidak aman.';

  @override
  String get accCodeRequired => 'Masukkan kode grup terlebih dahulu.';

  @override
  String get accountabilityGroupCodeHint => 'Contoh: ABCD234567';

  @override
  String get roleMember => 'Member';

  @override
  String get onboardingGroupCode => 'Kode Grup';

  @override
  String get introSkip => 'Lewati';

  @override
  String get introNext => 'Lanjut';

  @override
  String get introStartBtn => 'Mulai Sekarang';

  @override
  String introStepOf(int n, int total) {
    return 'LANGKAH $n DARI $total';
  }

  @override
  String get introSlide1Lead => 'JANGAN LUPA';

  @override
  String get introSlide1Highlight => 'LINDUNGI';

  @override
  String get introSlide1Tail => 'DIRIMU';

  @override
  String get introSlide1Subtitle =>
      'Perlindungan AI di perangkatmu menjaga setiap langkah — tanpa mengintip datamu.';

  @override
  String get introSlide2Lead => 'TIDAK APA-APA';

  @override
  String get introSlide2Highlight => 'BERHENTI SEJENAK';

  @override
  String get introSlide2Tail => '';

  @override
  String get introSlide2Subtitle =>
      'Pattern Interrupt memberi ruang bernapas saat dorongan itu datang.';

  @override
  String get introSlide3Lead => 'BERJEDA SEJENAK.';

  @override
  String get introSlide3Highlight => 'AMBIL KENDALI';

  @override
  String get introSlide3Tail => '';

  @override
  String get introSlide3Subtitle =>
      'Deteksi lokal, dukungan pemulihan, dan partner akuntabilitas dalam satu aplikasi.';

  @override
  String get setupTitle => 'Setup perangkat';

  @override
  String get setupIntro =>
      'Selesaikan checklist ini agar status proteksi ditampilkan secara jujur dan setiap izin diberikan dengan persetujuan Anda.';

  @override
  String get setupPrivacyTitle => 'Pahami batas privasi';

  @override
  String get setupPrivacyBody =>
      'URL dan teks halaman hanya diproses lokal. Backend menerima hitungan agregat saja.';

  @override
  String get setupAccountTitle => 'Hubungkan akun';

  @override
  String get setupAccountBody =>
      'Akun diperlukan untuk registrasi perangkat, pendamping, dan sinkronisasi agregat.';

  @override
  String get setupAccountReady => 'Akun telah terhubung.';

  @override
  String get setupDeviceTitle => 'Daftarkan perangkat';

  @override
  String get setupDeviceBody =>
      'Perangkat harus memiliki ID akun yang stabil sebelum membuat permintaan persetujuan.';

  @override
  String setupDeviceReady(String deviceId) {
    return 'Perangkat terdaftar sebagai $deviceId.';
  }

  @override
  String get setupDeviceAction => 'Daftarkan perangkat';

  @override
  String get setupDeviceRegistered => 'Perangkat berhasil didaftarkan.';

  @override
  String get setupPlatformTitle => 'Aktifkan proteksi platform';

  @override
  String get setupPlatformBody =>
      'Android memerlukan Accessibility Service. Windows memerlukan service, user-session agent, serta ekstensi Chrome/Edge yang dipasangkan dengan token lokal.';

  @override
  String get setupPlatformReady => 'Runtime proteksi platform aktif.';

  @override
  String get setupPlatformAction => 'Buka pengaturan platform';

  @override
  String get setupSelfTestTitle => 'Verifikasi model lokal';

  @override
  String get setupSelfTestBody =>
      'Self-test menggunakan fixture lokal dan tidak mengirim konten halaman.';

  @override
  String get setupFinishAction => 'Buka status proteksi';

  @override
  String get setupLimitations =>
      'Sideload normal memberikan friksi, bukan perlindungan uninstall absolut. Administrator perangkat tetap memiliki kendali OS.';

  @override
  String get patternBreatheDesc =>
      'Tarik napas dalam-dalam.\nDorongan ini akan lewat.';

  @override
  String get patternContinuePsychoeducation => 'Lanjut ke Psikoedukasi';

  @override
  String get patternInterruptTitle => 'Ambil jeda sebelum melanjutkan';

  @override
  String get patternBreatheLabel => 'Animasi napas perlahan';

  @override
  String patternSecondsRemaining(int seconds) {
    return '$seconds detik tersisa';
  }

  @override
  String get patternReady => 'Jeda selesai. Pilih langkah berikutnya.';

  @override
  String get patternGroundingAction => 'Latihan grounding offline';

  @override
  String get patternHelpAction => 'Butuh bantuan';

  @override
  String get patternLaterAction => 'Kembali ke proteksi';

  @override
  String get patternGroundingTitle => 'Perhatikan lima hal di sekitar Anda';

  @override
  String get patternReturnProtection => 'Selesai dan kembali';

  @override
  String get patternWaitHint => 'Sebentar lagi — tarik napas dulu.';

  @override
  String get patternPhaseInhale => 'Tarik napas…';

  @override
  String get patternPhaseExhale => 'Hembuskan perlahan…';

  @override
  String get patternPhaseStatic => 'Tarik napas perlahan, lalu hembuskan.';

  @override
  String get msgErrUpdateMission => 'Gagal memperbarui misi harian.';

  @override
  String get msgErrLoadPsychoeducation => 'Gagal memuat modul psikoedukasi.';

  @override
  String get msgErrSaveJournal => 'Gagal menyimpan jurnal refleksi.';

  @override
  String get msgErrLoadMissions => 'Gagal memuat misi harian.';

  @override
  String get msgErrLoadJournal => 'Gagal memuat jurnal refleksi.';

  @override
  String get msgErrTranslationFailed =>
      'Gagal menerjemahkan konten. Silakan coba lagi.';

  @override
  String get msgErrTranslationUnavailable =>
      'Layanan AI penerjemahan sedang tidak tersedia.';

  @override
  String get msgErrTranslationRateLimited =>
      'Penerjemahan AI sedang sibuk, coba lagi dalam beberapa saat.';

  @override
  String get msgErrSpkRecommendationFailed =>
      'Rekomendasi harian belum dapat dimuat.';

  @override
  String get msgErrSpkInterventionNotFound =>
      'Rekomendasi tidak ditemukan atau bukan milik Anda.';

  @override
  String get msgErrSpkInterventionCompleteFailed =>
      'Rekomendasi belum dapat ditandai selesai.';

  @override
  String get msgErrSpkPreferenceInvalid => 'Preferensi belum valid.';

  @override
  String get msgErrInvalidMission => 'Nomor misi harus 1-5.';

  @override
  String get msgErrTextRequired => 'Teks refleksi wajib diisi.';

  @override
  String get msgErrSummaryRequired => 'Ringkasan tiket wajib diisi.';

  @override
  String get msgErrTypeRequired => 'Jenis permintaan wajib dipilih.';

  @override
  String get recoveryWebTitle => 'Pemulihan tersedia di website';

  @override
  String get recoveryWebBody =>
      'Jurnal, check-in, misi, dan psikoedukasi tetap berada di website agar aplikasi ini fokus pada proteksi perangkat.';

  @override
  String get recoveryWebAction => 'Buka pemulihan web';

  @override
  String get backToProtection => 'Kembali ke proteksi';

  @override
  String get webPageOpenError => 'Halaman belum dapat dibuka. Coba lagi.';

  @override
  String get recoveryPageOpenError =>
      'Halaman pemulihan belum dapat dibuka. Coba lagi.';

  @override
  String get groundingStep1Title => 'Lihat';

  @override
  String get groundingStep1Body =>
      'Sebutkan lima hal yang bisa Anda lihat di sekitar Anda.';

  @override
  String get groundingStep2Title => 'Rasakan';

  @override
  String get groundingStep2Body =>
      'Sebutkan empat hal yang bisa Anda sentuh atau rasakan.';

  @override
  String get groundingStep3Title => 'Dengar';

  @override
  String get groundingStep3Body =>
      'Sebutkan tiga suara yang bisa Anda dengar saat ini.';

  @override
  String get groundingStep4Title => 'Cium';

  @override
  String get groundingStep4Body => 'Sebutkan dua aroma yang bisa Anda cium.';

  @override
  String get groundingStep5Title => 'Lindungi';

  @override
  String get groundingStep5Body =>
      'Sebutkan satu hal yang ingin Anda lindungi hari ini.';

  @override
  String groundingStepProgress(int current, int total) {
    return 'Langkah $current dari $total';
  }

  @override
  String get groundingNext => 'Lanjut';

  @override
  String get groundingDone => 'Selesai';

  @override
  String get groundingCompleteTitle => 'Latihan selesai';

  @override
  String get groundingCompleteBody =>
      'Anda sudah hadir sepenuhnya di momen ini. Pilih langkah berikutnya dengan tenang.';

  @override
  String get recoveryWebEyebrow => 'lanjutkan di web';

  @override
  String get quickActionsTitle => 'Tindakan Cepat';

  @override
  String get quickActionBreathe => 'Jeda & Tarik Napas';

  @override
  String get quickActionBreatheSubtitle =>
      'Latihan napas singkat sebelum melanjutkan';

  @override
  String get quickActionRecovery => 'Pemulihan & Dukungan';

  @override
  String get quickActionRecoverySubtitle =>
      'Buka panduan dan dukungan pemulihan';

  @override
  String get reminderChannelName => 'Pengingat harian';

  @override
  String get reminderChannelDesc => 'Pengingat check-in sekali sehari';

  @override
  String get reminderNotificationTitle => 'Waktu untuk dirimu';

  @override
  String get reminderNotificationBody =>
      'Luangkan satu menit untuk check-in hari ini. Kapan pun kamu siap.';

  @override
  String get reminderBodyStreak =>
      'Jangan putus ritme-mu — isi check-in harianmu.';

  @override
  String get reminderBodyStep =>
      'Satu langkah kecil tetap kemajuan. Check-in sebentar saja.';

  @override
  String get reminderBodyConsistent =>
      'Tetap tenang, tetap konsisten. Check-in harian menunggumu.';
}

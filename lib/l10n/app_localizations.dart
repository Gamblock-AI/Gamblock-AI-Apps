import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Gamblock AI'**
  String get appName;

  /// No description provided for @protectionActive.
  ///
  /// In id, this message translates to:
  /// **'Proteksi Aktif'**
  String get protectionActive;

  /// No description provided for @protectionDesc.
  ///
  /// In id, this message translates to:
  /// **'Perangkat ini sedang diawasi oleh AI lokal Gamblock.'**
  String get protectionDesc;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get submit;

  /// No description provided for @protectionActiveTitle.
  ///
  /// In id, this message translates to:
  /// **'Perlindungan perangkat aktif'**
  String get protectionActiveTitle;

  /// No description provided for @protectionSensorsTitle.
  ///
  /// In id, this message translates to:
  /// **'Perangkat & Sensor'**
  String get protectionSensorsTitle;

  /// No description provided for @protectionRequestSent.
  ///
  /// In id, this message translates to:
  /// **'Permohonan dikirim. Menunggu persetujuan.'**
  String get protectionRequestSent;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @dashboardTitle.
  ///
  /// In id, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @verifyCode.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi kode'**
  String get verifyCode;

  /// No description provided for @msgErrDataConflict.
  ///
  /// In id, this message translates to:
  /// **'Konflik data. Silakan muat ulang dan coba lagi.'**
  String get msgErrDataConflict;

  /// No description provided for @msgErrLoadTicket.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat tiket bantuan.'**
  String get msgErrLoadTicket;

  /// No description provided for @msgErrServerBusy.
  ///
  /// In id, this message translates to:
  /// **'Server sedang sibuk. Silakan coba beberapa saat lagi.'**
  String get msgErrServerBusy;

  /// No description provided for @msgErrDataNotFound.
  ///
  /// In id, this message translates to:
  /// **'Data yang diminta tidak ditemukan.'**
  String get msgErrDataNotFound;

  /// No description provided for @msgErrConnection.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat terhubung ke server. Periksa koneksi Anda dan coba lagi.'**
  String get msgErrConnection;

  /// No description provided for @msgErrGeneric.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kendala, silakan coba beberapa saat lagi.'**
  String get msgErrGeneric;

  /// No description provided for @msgErrModuleNotFound.
  ///
  /// In id, this message translates to:
  /// **'Modul tidak ditemukan.'**
  String get msgErrModuleNotFound;

  /// No description provided for @msgErrSendTicket.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengirim tiket bantuan.'**
  String get msgErrSendTicket;

  /// No description provided for @msgErrActionRequired.
  ///
  /// In id, this message translates to:
  /// **'Jenis tindakan wajib dipilih.'**
  String get msgErrActionRequired;

  /// No description provided for @msgErrLoadAdminModules.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat modul admin.'**
  String get msgErrLoadAdminModules;

  /// No description provided for @msgErrLoadAdminSupportCases.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat tiket admin.'**
  String get msgErrLoadAdminSupportCases;

  /// No description provided for @msgErrInternal.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kendala pada layanan. Silakan coba beberapa saat lagi.'**
  String get msgErrInternal;

  /// No description provided for @msgErrCreateAdminModule.
  ///
  /// In id, this message translates to:
  /// **'Modul admin belum dapat dibuat.'**
  String get msgErrCreateAdminModule;

  /// No description provided for @protectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Proteksi'**
  String get protectionTitle;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In id, this message translates to:
  /// **'Muat ulang'**
  String get refresh;

  /// No description provided for @copy.
  ///
  /// In id, this message translates to:
  /// **'Salin'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In id, this message translates to:
  /// **'Tersalin'**
  String get copied;

  /// No description provided for @close.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// No description provided for @protectionSetupAction.
  ///
  /// In id, this message translates to:
  /// **'Setup platform'**
  String get protectionSetupAction;

  /// No description provided for @protectionSyncError.
  ///
  /// In id, this message translates to:
  /// **'Status akun belum dapat disinkronkan'**
  String get protectionSyncError;

  /// No description provided for @protectionAccountabilityTitle.
  ///
  /// In id, this message translates to:
  /// **'Persetujuan perubahan proteksi'**
  String get protectionAccountabilityTitle;

  /// No description provided for @dashboardHello.
  ///
  /// In id, this message translates to:
  /// **'Halo, {name}'**
  String dashboardHello(String name);

  /// No description provided for @dashboardHelloGuest.
  ///
  /// In id, this message translates to:
  /// **'Halo'**
  String get dashboardHelloGuest;

  /// No description provided for @protectionInactiveTitle.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan perlindungan perangkat'**
  String get protectionInactiveTitle;

  /// No description provided for @protectionOnDevicePrivacyDesc.
  ///
  /// In id, this message translates to:
  /// **'Analisis tetap di perangkat. Server hanya menerima hitungan agregat perlindungan.'**
  String get protectionOnDevicePrivacyDesc;

  /// No description provided for @protectionSignInTitle.
  ///
  /// In id, this message translates to:
  /// **'Proteksi lokal tetap berjalan'**
  String get protectionSignInTitle;

  /// No description provided for @protectionSignInBody.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk mendaftarkan perangkat, menyinkronkan agregat, dan meminta persetujuan pendamping.'**
  String get protectionSignInBody;

  /// No description provided for @protectionStatusActive.
  ///
  /// In id, this message translates to:
  /// **'Proteksi aktif'**
  String get protectionStatusActive;

  /// No description provided for @protectionStatusPaused.
  ///
  /// In id, this message translates to:
  /// **'Proteksi dijeda oleh grant'**
  String get protectionStatusPaused;

  /// No description provided for @protectionStatusDegraded.
  ///
  /// In id, this message translates to:
  /// **'Proteksi terdegradasi'**
  String get protectionStatusDegraded;

  /// No description provided for @protectionStatusInactive.
  ///
  /// In id, this message translates to:
  /// **'Proteksi tidak aktif'**
  String get protectionStatusInactive;

  /// No description provided for @protectionStatusLocal.
  ///
  /// In id, this message translates to:
  /// **'Keputusan dan intervensi berjalan lokal pada perangkat.'**
  String get protectionStatusLocal;

  /// No description provided for @protectionServiceLabel.
  ///
  /// In id, this message translates to:
  /// **'Service'**
  String get protectionServiceLabel;

  /// No description provided for @protectionSensorLabel.
  ///
  /// In id, this message translates to:
  /// **'Sensor'**
  String get protectionSensorLabel;

  /// No description provided for @protectionPermissionLabel.
  ///
  /// In id, this message translates to:
  /// **'Izin'**
  String get protectionPermissionLabel;

  /// No description provided for @protectionArtifactLabel.
  ///
  /// In id, this message translates to:
  /// **'Sistem Proteksi AI'**
  String get protectionArtifactLabel;

  /// No description provided for @protectionModelReady.
  ///
  /// In id, this message translates to:
  /// **'Aktif & siap'**
  String get protectionModelReady;

  /// No description provided for @sensorServiceActive.
  ///
  /// In id, this message translates to:
  /// **'Layanan aktif berjalan'**
  String get sensorServiceActive;

  /// No description provided for @sensorServiceAction.
  ///
  /// In id, this message translates to:
  /// **'Perlu diaktifkan via setup'**
  String get sensorServiceAction;

  /// No description provided for @sensorBrowserActive.
  ///
  /// In id, this message translates to:
  /// **'Ekstensi browser terhubung'**
  String get sensorBrowserActive;

  /// No description provided for @sensorBrowserDegraded.
  ///
  /// In id, this message translates to:
  /// **'Koneksi sensor terdegradasi'**
  String get sensorBrowserDegraded;

  /// No description provided for @sensorBrowserAction.
  ///
  /// In id, this message translates to:
  /// **'Pasang ekstensi browser'**
  String get sensorBrowserAction;

  /// No description provided for @sensorPermissionActive.
  ///
  /// In id, this message translates to:
  /// **'Izin sistem diberikan'**
  String get sensorPermissionActive;

  /// No description provided for @sensorPermissionAction.
  ///
  /// In id, this message translates to:
  /// **'Berikan izin aksesibilitas'**
  String get sensorPermissionAction;

  /// No description provided for @sensorModelActive.
  ///
  /// In id, this message translates to:
  /// **'Model AI lokal siap bekerja'**
  String get sensorModelActive;

  /// No description provided for @protectionPartnerRequired.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan pendamping sebelum meminta perubahan proteksi.'**
  String get protectionPartnerRequired;

  /// No description provided for @protectionRequestPending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu persetujuan'**
  String get protectionRequestPending;

  /// No description provided for @protectionRequestApproved.
  ///
  /// In id, this message translates to:
  /// **'Permintaan telah disetujui dan siap diterapkan.'**
  String get protectionRequestApproved;

  /// No description provided for @protectionActionLabel.
  ///
  /// In id, this message translates to:
  /// **'Perubahan yang diminta'**
  String get protectionActionLabel;

  /// No description provided for @protectionPartnerReady.
  ///
  /// In id, this message translates to:
  /// **'Pendamping aktif. Perubahan proteksi dapat diminta dari perangkat ini.'**
  String get protectionPartnerReady;

  /// No description provided for @protectionApplyApproval.
  ///
  /// In id, this message translates to:
  /// **'Terapkan izin'**
  String get protectionApplyApproval;

  /// No description provided for @protectionRequestAction.
  ///
  /// In id, this message translates to:
  /// **'Ajukan perubahan'**
  String get protectionRequestAction;

  /// No description provided for @protectionApprovalApplied.
  ///
  /// In id, this message translates to:
  /// **'Persetujuan diterapkan pada perangkat.'**
  String get protectionApprovalApplied;

  /// No description provided for @protectionApprovalDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Minta perubahan proteksi'**
  String get protectionApprovalDialogTitle;

  /// No description provided for @protectionApprovalDialogBody.
  ///
  /// In id, this message translates to:
  /// **'Permintaan terikat pada perangkat dan harus disetujui pendamping aktif. Proteksi tetap berjalan sampai grant diterapkan.'**
  String get protectionApprovalDialogBody;

  /// No description provided for @protectionPauseAction.
  ///
  /// In id, this message translates to:
  /// **'Jeda'**
  String get protectionPauseAction;

  /// No description provided for @protectionDisableAction.
  ///
  /// In id, this message translates to:
  /// **'Nonaktifkan'**
  String get protectionDisableAction;

  /// No description provided for @protectionUninstallAction.
  ///
  /// In id, this message translates to:
  /// **'Copot'**
  String get protectionUninstallAction;

  /// No description provided for @protectionDurationLabel.
  ///
  /// In id, this message translates to:
  /// **'Durasi jeda'**
  String get protectionDurationLabel;

  /// No description provided for @minutesCount.
  ///
  /// In id, this message translates to:
  /// **'{minutes} menit'**
  String minutesCount(int minutes);

  /// No description provided for @protectionReasonLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan perubahan'**
  String get protectionReasonLabel;

  /// No description provided for @protectionReasonHelp.
  ///
  /// In id, this message translates to:
  /// **'Alasan ini dibagikan kepada pendamping, tanpa data penjelajahan.'**
  String get protectionReasonHelp;

  /// No description provided for @languageId.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageId;

  /// No description provided for @languageEn.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi WhatsApp Anda'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSent.
  ///
  /// In id, this message translates to:
  /// **'Kode verifikasi WhatsApp telah dikirim.'**
  String get verifyEmailSent;

  /// No description provided for @continueAction.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get continueAction;

  /// No description provided for @verifyEmailBody.
  ///
  /// In id, this message translates to:
  /// **'Diperlukan untuk fitur pendamping dan pemulihan akun. Masukkan kode yang dikirim ke WhatsApp.'**
  String get verifyEmailBody;

  /// No description provided for @protectionArtifactUnavailable.
  ///
  /// In id, this message translates to:
  /// **'tidak tersedia'**
  String get protectionArtifactUnavailable;

  /// No description provided for @dashboardAppreciationTitle.
  ///
  /// In id, this message translates to:
  /// **'Perlindunganmu menemanimu'**
  String get dashboardAppreciationTitle;

  /// No description provided for @dashboardAppreciationBody.
  ///
  /// In id, this message translates to:
  /// **'Perlindungan menemanimu {count} kali dalam 7 hari terakhir. Setiap jeda adalah ruang untuk memilih ulang.'**
  String dashboardAppreciationBody(int count);

  /// No description provided for @dashboardGamiFirstOpen.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang kembali. Mulai pelan-pelan saja.'**
  String get dashboardGamiFirstOpen;

  /// No description provided for @protectionSensorSubLocalService.
  ///
  /// In id, this message translates to:
  /// **'Layanan proteksi lokal'**
  String get protectionSensorSubLocalService;

  /// No description provided for @protectionSensorSubDomRelay.
  ///
  /// In id, this message translates to:
  /// **'Relay browser'**
  String get protectionSensorSubDomRelay;

  /// No description provided for @protectionSensorSubAccessibility.
  ///
  /// In id, this message translates to:
  /// **'Izin aksesibilitas'**
  String get protectionSensorSubAccessibility;

  /// No description provided for @protectionSensorFooterLoopback.
  ///
  /// In id, this message translates to:
  /// **'Relai pasif di perangkat'**
  String get protectionSensorFooterLoopback;

  /// No description provided for @protectionSensorFooterPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Privasi di perangkat'**
  String get protectionSensorFooterPrivacy;

  /// No description provided for @protectionPlatformLocal.
  ///
  /// In id, this message translates to:
  /// **'Perangkat lokal'**
  String get protectionPlatformLocal;

  /// No description provided for @protectionPlatformAndroid.
  ///
  /// In id, this message translates to:
  /// **'Perangkat Android'**
  String get protectionPlatformAndroid;

  /// No description provided for @protectionPlatformWindows.
  ///
  /// In id, this message translates to:
  /// **'Perangkat Windows'**
  String get protectionPlatformWindows;

  /// No description provided for @protectionPlatformLinux.
  ///
  /// In id, this message translates to:
  /// **'Perangkat Linux'**
  String get protectionPlatformLinux;

  /// No description provided for @protectionPlatformMacos.
  ///
  /// In id, this message translates to:
  /// **'Perangkat macOS'**
  String get protectionPlatformMacos;

  /// No description provided for @protectionStatusLocalActive.
  ///
  /// In id, this message translates to:
  /// **'AI lokal siap melindungi perangkat ini'**
  String get protectionStatusLocalActive;

  /// No description provided for @protectionStatusLocalInactive.
  ///
  /// In id, this message translates to:
  /// **'Analisis tetap di perangkat dan privat'**
  String get protectionStatusLocalInactive;

  /// No description provided for @protectionStatusPrivateChip.
  ///
  /// In id, this message translates to:
  /// **'PRIVAT'**
  String get protectionStatusPrivateChip;

  /// No description provided for @protectionDataStaysOnDevice.
  ///
  /// In id, this message translates to:
  /// **'Data penjelajahan tetap di perangkat'**
  String get protectionDataStaysOnDevice;

  /// No description provided for @viewAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get viewAll;

  /// No description provided for @authWelcomeBack.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang kembali.'**
  String get authWelcomeBack;

  /// No description provided for @authRegister.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get authRegister;

  /// No description provided for @authNoAccount.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun?'**
  String get authNoAccount;

  /// No description provided for @authLoginAgain.
  ///
  /// In id, this message translates to:
  /// **'masuk kembali'**
  String get authLoginAgain;

  /// No description provided for @authLoginBtn.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get authLoginBtn;

  /// No description provided for @authForgotPassword.
  ///
  /// In id, this message translates to:
  /// **'Lupa kata sandi?'**
  String get authForgotPassword;

  /// No description provided for @authPassword.
  ///
  /// In id, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi kata sandi'**
  String get authConfirmPassword;

  /// No description provided for @authConfirmPasswordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi tidak cocok.'**
  String get authConfirmPasswordMismatch;

  /// No description provided for @authEmailInvalid.
  ///
  /// In id, this message translates to:
  /// **'Masukkan alamat email yang valid.'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi wajib diisi.'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordMinimum.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi minimal 8 karakter.'**
  String get authPasswordMinimum;

  /// No description provided for @authNameMinimum.
  ///
  /// In id, this message translates to:
  /// **'Nama minimal 3 karakter.'**
  String get authNameMinimum;

  /// No description provided for @authEmail.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authWhatsapp.
  ///
  /// In id, this message translates to:
  /// **'Nomor WhatsApp'**
  String get authWhatsapp;

  /// No description provided for @authWhatsappInvalid.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nomor WhatsApp yang valid.'**
  String get authWhatsappInvalid;

  /// No description provided for @codeVerificationLabel.
  ///
  /// In id, this message translates to:
  /// **'Kode verifikasi WhatsApp'**
  String get codeVerificationLabel;

  /// No description provided for @authLoginDesc.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melanjutkan perlindungan Anda.'**
  String get authLoginDesc;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat akun baru.'**
  String get authCreateAccountTitle;

  /// No description provided for @authRegisterAs.
  ///
  /// In id, this message translates to:
  /// **'Saya mendaftar sebagai'**
  String get authRegisterAs;

  /// No description provided for @authFullName.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get authFullName;

  /// No description provided for @authRegisterAndContinue.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun & Lanjutkan'**
  String get authRegisterAndContinue;

  /// No description provided for @authRegisterDesc.
  ///
  /// In id, this message translates to:
  /// **'Prototipe berprinsip privasi yang dirancang untuk mahasiswa Indonesia.'**
  String get authRegisterDesc;

  /// No description provided for @authHasAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun?'**
  String get authHasAccount;

  /// No description provided for @authStartFree.
  ///
  /// In id, this message translates to:
  /// **'mulai gratis'**
  String get authStartFree;

  /// No description provided for @msgErrPasswordResetInvalid.
  ///
  /// In id, this message translates to:
  /// **'Kode pemulihan tidak valid, sudah digunakan, atau telah kedaluwarsa.'**
  String get msgErrPasswordResetInvalid;

  /// No description provided for @msgErrPasswordResetFailed.
  ///
  /// In id, this message translates to:
  /// **'Pemulihan kata sandi belum dapat diproses. Silakan coba lagi.'**
  String get msgErrPasswordResetFailed;

  /// No description provided for @msgErrInvalidSession.
  ///
  /// In id, this message translates to:
  /// **'Sesi tidak valid. Silakan masuk kembali.'**
  String get msgErrInvalidSession;

  /// No description provided for @msgErrInvalidToken.
  ///
  /// In id, this message translates to:
  /// **'Token tidak valid atau sudah kadaluarsa.'**
  String get msgErrInvalidToken;

  /// No description provided for @msgErrEmailRequired.
  ///
  /// In id, this message translates to:
  /// **'Email wajib diisi.'**
  String get msgErrEmailRequired;

  /// No description provided for @msgErrTranslationInvalidInput.
  ///
  /// In id, this message translates to:
  /// **'Input translasi tidak valid.'**
  String get msgErrTranslationInvalidInput;

  /// No description provided for @msgErrRegisterFailed.
  ///
  /// In id, this message translates to:
  /// **'Pendaftaran gagal. Email mungkin sudah terdaftar.'**
  String get msgErrRegisterFailed;

  /// No description provided for @msgErrSessionExpired.
  ///
  /// In id, this message translates to:
  /// **'Sesi telah berakhir. Silakan masuk kembali.'**
  String get msgErrSessionExpired;

  /// No description provided for @msgErrInvalidCredentials.
  ///
  /// In id, this message translates to:
  /// **'Email atau kata sandi salah. Silakan periksa kembali.'**
  String get msgErrInvalidCredentials;

  /// No description provided for @msgErrLogout.
  ///
  /// In id, this message translates to:
  /// **'Gagal keluar. Silakan coba lagi.'**
  String get msgErrLogout;

  /// No description provided for @msgErrEmailNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Email dan nama wajib diisi.'**
  String get msgErrEmailNameRequired;

  /// No description provided for @msgErrUnauthorized.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak memiliki izin untuk aksi ini.'**
  String get msgErrUnauthorized;

  /// No description provided for @msgErrStudentOnly.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi ini hanya untuk akun mahasiswa.'**
  String get msgErrStudentOnly;

  /// No description provided for @msgErrDevLogin.
  ///
  /// In id, this message translates to:
  /// **'Gagal masuk sebagai pengguna demo.'**
  String get msgErrDevLogin;

  /// No description provided for @msgErrTokenRequired.
  ///
  /// In id, this message translates to:
  /// **'Token validasi wajib diisi.'**
  String get msgErrTokenRequired;

  /// No description provided for @msgErrInvalidInput.
  ///
  /// In id, this message translates to:
  /// **'Token dan status (approved/denied) wajib diisi.'**
  String get msgErrInvalidInput;

  /// No description provided for @msgErrPasswordValidation.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi saat ini dan kata sandi baru minimal 8 karakter wajib diisi.'**
  String get msgErrPasswordValidation;

  /// No description provided for @msgErrCurrentPasswordInvalid.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi saat ini tidak benar.'**
  String get msgErrCurrentPasswordInvalid;

  /// No description provided for @msgErrPasswordReuse.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi baru harus berbeda dari kata sandi saat ini.'**
  String get msgErrPasswordReuse;

  /// No description provided for @msgErrAuthRequired.
  ///
  /// In id, this message translates to:
  /// **'Sesi diperlukan. Silakan masuk terlebih dahulu.'**
  String get msgErrAuthRequired;

  /// No description provided for @msgErrForbidden.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak memiliki izin untuk tindakan ini.'**
  String get msgErrForbidden;

  /// No description provided for @msgErrInvalidBody.
  ///
  /// In id, this message translates to:
  /// **'Data yang dikirim tidak dapat dibaca. Periksa isian lalu coba lagi.'**
  String get msgErrInvalidBody;

  /// No description provided for @msgErrValidation.
  ///
  /// In id, this message translates to:
  /// **'Periksa kembali isian yang belum sesuai.'**
  String get msgErrValidation;

  /// No description provided for @resendEmail.
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang'**
  String get resendEmail;

  /// No description provided for @authResetTitle.
  ///
  /// In id, this message translates to:
  /// **'Lupa kata sandi?'**
  String get authResetTitle;

  /// No description provided for @authResetTitleCode.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode pemulihan'**
  String get authResetTitleCode;

  /// No description provided for @authResetDesc.
  ///
  /// In id, this message translates to:
  /// **'Masukkan email akun. Kami akan mengirim kode tanpa membagikan status pendaftaran email.'**
  String get authResetDesc;

  /// No description provided for @authResetDescCode.
  ///
  /// In id, this message translates to:
  /// **'Kode 12 karakter telah dikirim bila email terdaftar. Kode berlaku 30 menit.'**
  String get authResetDescCode;

  /// No description provided for @authResetSuccess.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi berhasil diperbarui. Silakan masuk.'**
  String get authResetSuccess;

  /// No description provided for @authResetNewCodeRequested.
  ///
  /// In id, this message translates to:
  /// **'Kode pemulihan baru telah diminta.'**
  String get authResetNewCodeRequested;

  /// No description provided for @authChangeEmail.
  ///
  /// In id, this message translates to:
  /// **'Ganti email'**
  String get authChangeEmail;

  /// No description provided for @authResendCode.
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang kode'**
  String get authResendCode;

  /// No description provided for @authRecoveryCodeLabel.
  ///
  /// In id, this message translates to:
  /// **'Kode pemulihan'**
  String get authRecoveryCodeLabel;

  /// No description provided for @authRecoveryCodeInvalid.
  ///
  /// In id, this message translates to:
  /// **'Kode harus berisi 12 karakter.'**
  String get authRecoveryCodeInvalid;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi baru'**
  String get authNewPasswordLabel;

  /// No description provided for @authPasswordMinChars.
  ///
  /// In id, this message translates to:
  /// **'Gunakan minimal 8 karakter.'**
  String get authPasswordMinChars;

  /// No description provided for @authPasswordMinShort.
  ///
  /// In id, this message translates to:
  /// **'Minimal 8 karakter'**
  String get authPasswordMinShort;

  /// No description provided for @authCreateNewPassword.
  ///
  /// In id, this message translates to:
  /// **'Buat kata sandi baru'**
  String get authCreateNewPassword;

  /// No description provided for @authSendCode.
  ///
  /// In id, this message translates to:
  /// **'Kirim kode'**
  String get authSendCode;

  /// No description provided for @authBackToLogin.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke login'**
  String get authBackToLogin;

  /// No description provided for @authTempPasswordDesc.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi sementara hanya berlaku untuk langkah ini.'**
  String get authTempPasswordDesc;

  /// No description provided for @authPasswordChangeMin.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi baru minimal 8 karakter.'**
  String get authPasswordChangeMin;

  /// No description provided for @authVerifyPhoneTitle.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi Nomor WhatsApp'**
  String get authVerifyPhoneTitle;

  /// No description provided for @authVerifyPhoneDesc.
  ///
  /// In id, this message translates to:
  /// **'Kode 6 digit telah dikirim ke WhatsApp {phone}. Masukkan kode untuk menyelesaikan verifikasi.'**
  String authVerifyPhoneDesc(String phone);

  /// No description provided for @authVerifyCodeLabel.
  ///
  /// In id, this message translates to:
  /// **'Kode Verifikasi'**
  String get authVerifyCodeLabel;

  /// No description provided for @authVerifyCodeHint.
  ///
  /// In id, this message translates to:
  /// **'6 digit'**
  String get authVerifyCodeHint;

  /// No description provided for @authVerifyCodeInvalid.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode 6 digit.'**
  String get authVerifyCodeInvalid;

  /// No description provided for @authVerifyButton.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi'**
  String get authVerifyButton;

  /// No description provided for @authVerifyResend.
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang kode'**
  String get authVerifyResend;

  /// No description provided for @authVerifyResending.
  ///
  /// In id, this message translates to:
  /// **'Mengirim ulang...'**
  String get authVerifyResending;

  /// No description provided for @authVerifySent.
  ///
  /// In id, this message translates to:
  /// **'Kode baru telah dikirim.'**
  String get authVerifySent;

  /// No description provided for @authVerifyPreviewCodeHint.
  ///
  /// In id, this message translates to:
  /// **'Kode demo: {code}'**
  String authVerifyPreviewCodeHint(String code);

  /// No description provided for @authVerifyError.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi belum berhasil. Periksa kode atau minta kode baru.'**
  String get authVerifyError;

  /// No description provided for @authVerifyMissingTitle.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi tidak ditemukan'**
  String get authVerifyMissingTitle;

  /// No description provided for @authVerifyMissingBody.
  ///
  /// In id, this message translates to:
  /// **'Sesi verifikasi sudah berakhir. Silakan masuk kembali untuk meminta kode baru.'**
  String get authVerifyMissingBody;

  /// No description provided for @authSaveAndLogin.
  ///
  /// In id, this message translates to:
  /// **'Simpan dan masuk'**
  String get authSaveAndLogin;

  /// No description provided for @authShowPassword.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan kata sandi'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan kata sandi'**
  String get authHidePassword;

  /// No description provided for @settingsLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get settingsLogout;

  /// No description provided for @settingsAppVersion.
  ///
  /// In id, this message translates to:
  /// **'Gamblock AI v1.0.0'**
  String get settingsAppVersion;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin keluar?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsAboutApp.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get settingsAboutApp;

  /// No description provided for @settingsAccountabilityPartner.
  ///
  /// In id, this message translates to:
  /// **'Pendamping Akuntabilitas'**
  String get settingsAccountabilityPartner;

  /// No description provided for @settingsEmailVerified.
  ///
  /// In id, this message translates to:
  /// **'Email terverifikasi'**
  String get settingsEmailVerified;

  /// No description provided for @settingsEmailUnverified.
  ///
  /// In id, this message translates to:
  /// **'Email belum terverifikasi'**
  String get settingsEmailUnverified;

  /// No description provided for @settingsWhatsappVerified.
  ///
  /// In id, this message translates to:
  /// **'WhatsApp terverifikasi'**
  String get settingsWhatsappVerified;

  /// No description provided for @settingsWhatsappUnverified.
  ///
  /// In id, this message translates to:
  /// **'WhatsApp belum terverifikasi'**
  String get settingsWhatsappUnverified;

  /// No description provided for @settingsAvatarUpload.
  ///
  /// In id, this message translates to:
  /// **'Unggah foto profil'**
  String get settingsAvatarUpload;

  /// No description provided for @settingsAvatarChange.
  ///
  /// In id, this message translates to:
  /// **'Ganti foto profil'**
  String get settingsAvatarChange;

  /// No description provided for @settingsAvatarRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto'**
  String get settingsAvatarRemove;

  /// No description provided for @settingsAvatarDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto profil'**
  String get settingsAvatarDialogTitle;

  /// No description provided for @settingsAvatarDialogBody.
  ///
  /// In id, this message translates to:
  /// **'Pilih cara untuk memperbarui foto profil Anda.'**
  String get settingsAvatarDialogBody;

  /// No description provided for @settingsAvatarChooseGallery.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari galeri'**
  String get settingsAvatarChooseGallery;

  /// No description provided for @settingsAvatarUseCamera.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto'**
  String get settingsAvatarUseCamera;

  /// No description provided for @settingsAvatarDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto profil?'**
  String get settingsAvatarDeleteTitle;

  /// No description provided for @settingsAvatarDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Foto profil Anda akan dihapus dan diganti dengan inisial nama.'**
  String get settingsAvatarDeleteBody;

  /// No description provided for @settingsAvatarEditorTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur foto profil'**
  String get settingsAvatarEditorTitle;

  /// No description provided for @settingsAvatarEditorBody.
  ///
  /// In id, this message translates to:
  /// **'Geser atau perbesar foto, lalu putar bila diperlukan.'**
  String get settingsAvatarEditorBody;

  /// No description provided for @settingsAvatarRotateLeft.
  ///
  /// In id, this message translates to:
  /// **'Putar ke kiri'**
  String get settingsAvatarRotateLeft;

  /// No description provided for @settingsAvatarRotateRight.
  ///
  /// In id, this message translates to:
  /// **'Putar ke kanan'**
  String get settingsAvatarRotateRight;

  /// No description provided for @settingsAvatarZoom.
  ///
  /// In id, this message translates to:
  /// **'Perbesar'**
  String get settingsAvatarZoom;

  /// No description provided for @settingsAvatarReset.
  ///
  /// In id, this message translates to:
  /// **'Atur ulang'**
  String get settingsAvatarReset;

  /// No description provided for @settingsAvatarUsePhoto.
  ///
  /// In id, this message translates to:
  /// **'Gunakan foto'**
  String get settingsAvatarUsePhoto;

  /// No description provided for @settingsAvatarSaving.
  ///
  /// In id, this message translates to:
  /// **'Menyiapkan...'**
  String get settingsAvatarSaving;

  /// No description provided for @settingsAvatarEditorFailed.
  ///
  /// In id, this message translates to:
  /// **'Foto belum dapat dipotong. Coba foto lain.'**
  String get settingsAvatarEditorFailed;

  /// No description provided for @settingsAvatarSourceTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Pilih gambar dengan ukuran maksimal 8 MB.'**
  String get settingsAvatarSourceTooLarge;

  /// No description provided for @settingsAvatarUpdated.
  ///
  /// In id, this message translates to:
  /// **'Foto profil berhasil diperbarui.'**
  String get settingsAvatarUpdated;

  /// No description provided for @settingsAvatarRemoved.
  ///
  /// In id, this message translates to:
  /// **'Foto profil berhasil dihapus.'**
  String get settingsAvatarRemoved;

  /// No description provided for @settingsAvatarInvalid.
  ///
  /// In id, this message translates to:
  /// **'Gambar tidak dapat dibaca. Pilih foto lain.'**
  String get settingsAvatarInvalid;

  /// No description provided for @settingsAccountSection.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get settingsAccountSection;

  /// No description provided for @settingsPreferencesSection.
  ///
  /// In id, this message translates to:
  /// **'Preferensi'**
  String get settingsPreferencesSection;

  /// No description provided for @settingsWindowsSection.
  ///
  /// In id, this message translates to:
  /// **'Windows dan ekstensi'**
  String get settingsWindowsSection;

  /// No description provided for @settingsAboutSection.
  ///
  /// In id, this message translates to:
  /// **'Tentang dan bantuan'**
  String get settingsAboutSection;

  /// No description provided for @settingsUserFallback.
  ///
  /// In id, this message translates to:
  /// **'Pengguna'**
  String get settingsUserFallback;

  /// No description provided for @settingsEditProfile.
  ///
  /// In id, this message translates to:
  /// **'Ubah nama profil'**
  String get settingsEditProfile;

  /// No description provided for @settingsProfileUpdated.
  ///
  /// In id, this message translates to:
  /// **'Profil berhasil diperbarui.'**
  String get settingsProfileUpdated;

  /// No description provided for @settingsChangePassword.
  ///
  /// In id, this message translates to:
  /// **'Ubah kata sandi'**
  String get settingsChangePassword;

  /// No description provided for @settingsCurrentPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi saat ini'**
  String get settingsCurrentPassword;

  /// No description provided for @settingsNewPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi baru'**
  String get settingsNewPassword;

  /// No description provided for @settingsConfirmPassword.
  ///
  /// In id, this message translates to:
  /// **'Ulangi kata sandi baru'**
  String get settingsConfirmPassword;

  /// No description provided for @settingsShowPassword.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan kata sandi'**
  String get settingsShowPassword;

  /// No description provided for @settingsHidePassword.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan kata sandi'**
  String get settingsHidePassword;

  /// No description provided for @settingsPasswordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi baru minimal 8 karakter dan harus sama.'**
  String get settingsPasswordMismatch;

  /// No description provided for @settingsPasswordUpdated.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi diperbarui. Silakan masuk kembali.'**
  String get settingsPasswordUpdated;

  /// No description provided for @settingsLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa aplikasi'**
  String get settingsLanguage;

  /// No description provided for @settingsHaptics.
  ///
  /// In id, this message translates to:
  /// **'Umpan balik getar'**
  String get settingsHaptics;

  /// No description provided for @settingsHealthNotifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi kesehatan proteksi'**
  String get settingsHealthNotifications;

  /// No description provided for @settingsHealthNotificationsBody.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi hanya memuat status service atau izin, tanpa data situs.'**
  String get settingsHealthNotificationsBody;

  /// No description provided for @settingsPairingToken.
  ///
  /// In id, this message translates to:
  /// **'Token pairing ekstensi'**
  String get settingsPairingToken;

  /// No description provided for @settingsPairingUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Service Windows belum terhubung.'**
  String get settingsPairingUnavailable;

  /// No description provided for @settingsRotatePairing.
  ///
  /// In id, this message translates to:
  /// **'Rotasi token pairing'**
  String get settingsRotatePairing;

  /// No description provided for @settingsArtifacts.
  ///
  /// In id, this message translates to:
  /// **'Artefak proteksi lokal'**
  String get settingsArtifacts;

  /// No description provided for @settingsPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Kebijakan privasi'**
  String get settingsPrivacy;

  /// No description provided for @settingsHelp.
  ///
  /// In id, this message translates to:
  /// **'Pusat bantuan'**
  String get settingsHelp;

  /// No description provided for @settingsRotateConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Putar token penyambungan?'**
  String get settingsRotateConfirmTitle;

  /// No description provided for @settingsRotateConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Penyambungan ekstensi browser yang ada akan langsung tidak berlaku dan perlu disambungkan ulang.'**
  String get settingsRotateConfirmBody;

  /// No description provided for @settingsRotateConfirmAction.
  ///
  /// In id, this message translates to:
  /// **'Putar token'**
  String get settingsRotateConfirmAction;

  /// No description provided for @settingsRotateSuccess.
  ///
  /// In id, this message translates to:
  /// **'Token penyambungan diperbarui.'**
  String get settingsRotateSuccess;

  /// No description provided for @settingsPasswordChangedTitle.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi diperbarui'**
  String get settingsPasswordChangedTitle;

  /// No description provided for @settingsPasswordChangedBody.
  ///
  /// In id, this message translates to:
  /// **'Silakan masuk kembali dengan kata sandi baru.'**
  String get settingsPasswordChangedBody;

  /// No description provided for @settingsReminderTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengingat check-in harian'**
  String get settingsReminderTitle;

  /// No description provided for @settingsReminderDesc.
  ///
  /// In id, this message translates to:
  /// **'Sekali sehari, di waktu pilihanmu. Tanpa isi sensitif di layar kunci.'**
  String get settingsReminderDesc;

  /// No description provided for @settingsReminderTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu pengingat'**
  String get settingsReminderTime;

  /// No description provided for @settingsReminderPermissionDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin notifikasi belum diberikan. Kamu bisa mengaktifkannya lewat pengaturan sistem.'**
  String get settingsReminderPermissionDenied;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In id, this message translates to:
  /// **'Kebijakan Privasi'**
  String get legalPrivacyTitle;

  /// No description provided for @legalPrivacyUpdated.
  ///
  /// In id, this message translates to:
  /// **'Terakhir diperbarui: Agustus 2026'**
  String get legalPrivacyUpdated;

  /// No description provided for @legalPrivacyIntro.
  ///
  /// In id, this message translates to:
  /// **'Privasi adalah prinsip inti Gamblock-AI. Kebijakan ini menjelaskan data apa yang kami proses dan bagaimana kami melindunginya, selaras dengan prinsip minimalisasi data UU PDP.'**
  String get legalPrivacyIntro;

  /// No description provided for @legalPrivacyS1Title.
  ///
  /// In id, this message translates to:
  /// **'Prinsip Privasi On-Device'**
  String get legalPrivacyS1Title;

  /// No description provided for @legalPrivacyS1Body.
  ///
  /// In id, this message translates to:
  /// **'Dengan persetujuan terpisah, Accessibility Service Android membaca teks yang terlihat pada Chrome dan Edge yang didukung, termasuk bilah URL, judul, heading, dan teks tautan. Data tersebut diproses sementara untuk inferensi AI di perangkat, lalu aplikasi dapat menjalankan aksi Kembali dan menampilkan Pattern Interrupt.\nURL, domain, teks halaman, screenshot, dan riwayat penelusuran tidak pernah dikirim ke server atau layanan AI eksternal.'**
  String get legalPrivacyS1Body;

  /// No description provided for @legalPrivacyS2Title.
  ///
  /// In id, this message translates to:
  /// **'Data yang Kami Proses'**
  String get legalPrivacyS2Title;

  /// No description provided for @legalPrivacyS2Body.
  ///
  /// In id, this message translates to:
  /// **'Untuk akun dan pendampingan, kami memproses data seperti nama tampilan, email, relasi grup, pilihan persetujuan, agregat jumlah perlindungan, dan timestamp sistem saat pemblokiran bila kategori tersebut diaktifkan. Public key perangkat dan thumbprint pseudonim dipakai hanya untuk mengikat grant persetujuan ke perangkat.\nPayload ini tidak memuat URL, domain, DOM, judul, screenshot, skor halaman, atau riwayat penelusuran.'**
  String get legalPrivacyS2Body;

  /// No description provided for @legalPrivacyS3Title.
  ///
  /// In id, this message translates to:
  /// **'Enkripsi dan Keamanan'**
  String get legalPrivacyS3Title;

  /// No description provided for @legalPrivacyS3Body.
  ///
  /// In id, this message translates to:
  /// **'Jurnal refleksi dan catatan sensitif dienkripsi menggunakan AES-256-GCM sebelum disimpan. Grant penghentian perlindungan ditandatangani backend, berumur pendek, dan terikat ke public key native perangkat.\nKeystore Android dan Windows CNG/DPAPI melindungi material serta state lokal yang relevan.'**
  String get legalPrivacyS3Body;

  /// No description provided for @legalPrivacyS4Title.
  ///
  /// In id, this message translates to:
  /// **'Dasbor Pengawasan Bersifat Agregat'**
  String get legalPrivacyS4Title;

  /// No description provided for @legalPrivacyS4Body.
  ///
  /// In id, this message translates to:
  /// **'Pendamping hanya melihat skor dan statistik agregat, bukan URL atau riwayat penelusuran mentah milik Member.\nIni menjaga keseimbangan antara akuntabilitas dan privasi pengguna.'**
  String get legalPrivacyS4Body;

  /// No description provided for @legalPrivacyS5Title.
  ///
  /// In id, this message translates to:
  /// **'Hak Pengguna'**
  String get legalPrivacyS5Title;

  /// No description provided for @legalPrivacyS5Body.
  ///
  /// In id, this message translates to:
  /// **'Anda dapat menolak persetujuan Accessibility dan tetap menggunakan fitur yang tidak memerlukannya. Anda juga berhak mengakses, memperbaiki, dan meminta penghapusan data pribadi sesuai ketentuan yang berlaku.\nEdisi Play dapat dicopot melalui mekanisme Android biasa; edisi pilot memiliki jalur administrator darurat yang terdokumentasi. Permintaan data diajukan melalui pusat bantuan.'**
  String get legalPrivacyS5Body;

  /// No description provided for @legalPrivacyS6Title.
  ///
  /// In id, this message translates to:
  /// **'Kontak'**
  String get legalPrivacyS6Title;

  /// No description provided for @legalPrivacyS6Body.
  ///
  /// In id, this message translates to:
  /// **'Untuk pertanyaan terkait privasi, silakan hubungi tim pengembang melalui kanal dukungan yang tersedia di aplikasi.\nKebijakan ini dapat diperbarui dan perubahan material akan diinformasikan.'**
  String get legalPrivacyS6Body;

  /// No description provided for @legalHelpTitle.
  ///
  /// In id, this message translates to:
  /// **'Pusat Bantuan'**
  String get legalHelpTitle;

  /// No description provided for @legalHelpUpdated.
  ///
  /// In id, this message translates to:
  /// **'Pusat bantuan Gamblock-AI'**
  String get legalHelpUpdated;

  /// No description provided for @legalHelpIntro.
  ///
  /// In id, this message translates to:
  /// **'Temukan jawaban cepat seputar pemasangan, akun, privasi, dan fitur pendampingan Gamblock-AI.'**
  String get legalHelpIntro;

  /// No description provided for @legalHelpS1Title.
  ///
  /// In id, this message translates to:
  /// **'Memulai'**
  String get legalHelpS1Title;

  /// No description provided for @legalHelpS1Body.
  ///
  /// In id, this message translates to:
  /// **'Edisi Android publik dipasang melalui Google Play. Edisi Research Android dan Pilot Windows hanya dipasang oleh tim pada perangkat uji yang disetujui.\nSetelah membuat akun, ikuti disclosure Accessibility sebelum memilih apakah akan mengaktifkan proteksi browser, lalu tautkan Accountability Partner bila diperlukan.'**
  String get legalHelpS1Body;

  /// No description provided for @legalHelpS2Title.
  ///
  /// In id, this message translates to:
  /// **'Akun & Masuk'**
  String get legalHelpS2Title;

  /// No description provided for @legalHelpS2Body.
  ///
  /// In id, this message translates to:
  /// **'Gunakan email terdaftar untuk masuk. Lupa kata sandi? Gunakan tautan \"Lupa kata sandi\" di halaman masuk untuk mengatur ulang.\nSatu akun Member terhubung ke satu grup pendamping pada satu waktu.'**
  String get legalHelpS2Body;

  /// No description provided for @legalHelpS3Title.
  ///
  /// In id, this message translates to:
  /// **'Privasi & Keamanan'**
  String get legalHelpS3Title;

  /// No description provided for @legalHelpS3Body.
  ///
  /// In id, this message translates to:
  /// **'Seluruh deteksi berjalan lokal di perangkat. Riwayat penelusuran Anda tidak pernah dikirim ke server.\nJurnal refleksi dienkripsi dengan standar AES-256-GCM.'**
  String get legalHelpS3Body;

  /// No description provided for @legalHelpS4Title.
  ///
  /// In id, this message translates to:
  /// **'Pendamping (Accountability Partner)'**
  String get legalHelpS4Title;

  /// No description provided for @legalHelpS4Body.
  ///
  /// In id, this message translates to:
  /// **'Pada edisi Research/Pilot, persetujuan pendamping adalah jalur normal untuk menghentikan proteksi; administrator tetap memiliki break-glass yang bersih. Edisi Play tidak mencegah pencopotan dari pengaturan Android.\nPendamping hanya melihat statistik agregat yang diizinkan, bukan riwayat penelusuran mentah.'**
  String get legalHelpS4Body;

  /// No description provided for @legalHelpS5Title.
  ///
  /// In id, this message translates to:
  /// **'Masih butuh bantuan?'**
  String get legalHelpS5Title;

  /// No description provided for @legalHelpS5Body.
  ///
  /// In id, this message translates to:
  /// **'Jika masalah belum teratasi, hubungi tim kami melalui halaman Hubungi Kami.\nKami berupaya merespons pertanyaan sesegera mungkin selama periode program.'**
  String get legalHelpS5Body;

  /// No description provided for @msgErrCreateDevice.
  ///
  /// In id, this message translates to:
  /// **'Gagal mendaftarkan perangkat.'**
  String get msgErrCreateDevice;

  /// No description provided for @msgErrUpdateDevice.
  ///
  /// In id, this message translates to:
  /// **'Gagal memperbarui perangkat.'**
  String get msgErrUpdateDevice;

  /// No description provided for @msgErrHeartbeat.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengirim sinyal aktif perangkat.'**
  String get msgErrHeartbeat;

  /// No description provided for @selfTestAction.
  ///
  /// In id, this message translates to:
  /// **'Jalankan pemeriksaan'**
  String get selfTestAction;

  /// No description provided for @selfTestPassed.
  ///
  /// In id, this message translates to:
  /// **'Pemeriksaan lokal berhasil'**
  String get selfTestPassed;

  /// No description provided for @selfTestFailed.
  ///
  /// In id, this message translates to:
  /// **'Pemeriksaan lokal gagal'**
  String get selfTestFailed;

  /// No description provided for @selfTestFixtureBody.
  ///
  /// In id, this message translates to:
  /// **'Semua yang dibutuhkan untuk melindungi Anda lolos pemeriksaan.'**
  String get selfTestFixtureBody;

  /// No description provided for @selfTestNativeUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Perlindungan belum tersedia di perangkat ini.'**
  String get selfTestNativeUnavailable;

  /// No description provided for @selfTestIntegrityFailed.
  ///
  /// In id, this message translates to:
  /// **'Sebagian berkas proteksi tidak dapat diverifikasi.'**
  String get selfTestIntegrityFailed;

  /// No description provided for @selfTestFixtureMismatch.
  ///
  /// In id, this message translates to:
  /// **'Hasil pemeriksaan proteksi tidak sesuai yang diharapkan.'**
  String get selfTestFixtureMismatch;

  /// No description provided for @selfTestArtifactInvalid.
  ///
  /// In id, this message translates to:
  /// **'Sebagian berkas proteksi tidak valid.'**
  String get selfTestArtifactInvalid;

  /// No description provided for @selfTestSensorDisconnected.
  ///
  /// In id, this message translates to:
  /// **'Sensor browser tidak terhubung.'**
  String get selfTestSensorDisconnected;

  /// No description provided for @selfTestAccessibilityMissing.
  ///
  /// In id, this message translates to:
  /// **'Izin akses Android belum diberikan.'**
  String get selfTestAccessibilityMissing;

  /// No description provided for @deviceRegistrationMissing.
  ///
  /// In id, this message translates to:
  /// **'Perangkat belum terdaftar'**
  String get deviceRegistrationMissing;

  /// No description provided for @deviceRegistrationMissingBody.
  ///
  /// In id, this message translates to:
  /// **'Fitur ini memerlukan perangkat terdaftar. Daftarkan perangkat lewat aplikasi Android/Windows, atau selesaikan pengaturan di sini.'**
  String get deviceRegistrationMissingBody;

  /// No description provided for @statusConnected.
  ///
  /// In id, this message translates to:
  /// **'Terhubung'**
  String get statusConnected;

  /// No description provided for @statusDisconnected.
  ///
  /// In id, this message translates to:
  /// **'Terputus'**
  String get statusDisconnected;

  /// No description provided for @emergencyTitle.
  ///
  /// In id, this message translates to:
  /// **'Pemulihan darurat'**
  String get emergencyTitle;

  /// No description provided for @emergencyBody.
  ///
  /// In id, this message translates to:
  /// **'Gunakan hanya saat pendamping tidak tersedia atau perangkat terkunci dalam kondisi yang aman untuk dipulihkan.'**
  String get emergencyBody;

  /// No description provided for @emergencyStatus.
  ///
  /// In id, this message translates to:
  /// **'Status permintaan darurat: {status}'**
  String emergencyStatus(String status);

  /// No description provided for @emergencyRequestAction.
  ///
  /// In id, this message translates to:
  /// **'Minta pemulihan'**
  String get emergencyRequestAction;

  /// No description provided for @emergencyEnterKeyAction.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kunci'**
  String get emergencyEnterKeyAction;

  /// No description provided for @emergencyRequestCreated.
  ///
  /// In id, this message translates to:
  /// **'Permintaan pemulihan darurat berhasil dibuat.'**
  String get emergencyRequestCreated;

  /// No description provided for @emergencyKeyTitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kunci darurat'**
  String get emergencyKeyTitle;

  /// No description provided for @emergencyKeyLabel.
  ///
  /// In id, this message translates to:
  /// **'Kunci satu-kali-pakai'**
  String get emergencyKeyLabel;

  /// No description provided for @emergencyKeyHelp.
  ///
  /// In id, this message translates to:
  /// **'Kunci diterbitkan setelah ditinjau dua admin platform berbeda, terikat pada perangkat ini, dan berlaku 24 jam.'**
  String get emergencyKeyHelp;

  /// No description provided for @emergencyKeyApplied.
  ///
  /// In id, this message translates to:
  /// **'Grant darurat diterapkan selama 10 menit.'**
  String get emergencyKeyApplied;

  /// No description provided for @checkSetupAction.
  ///
  /// In id, this message translates to:
  /// **'Periksa setup'**
  String get checkSetupAction;

  /// No description provided for @helpPageOpenError.
  ///
  /// In id, this message translates to:
  /// **'Halaman bantuan belum dapat dibuka. Coba lagi.'**
  String get helpPageOpenError;

  /// No description provided for @statusChipOk.
  ///
  /// In id, this message translates to:
  /// **'OK'**
  String get statusChipOk;

  /// No description provided for @statusChipWarn.
  ///
  /// In id, this message translates to:
  /// **'WASPADA'**
  String get statusChipWarn;

  /// No description provided for @statusChipOff.
  ///
  /// In id, this message translates to:
  /// **'MATI'**
  String get statusChipOff;

  /// No description provided for @statusGranted.
  ///
  /// In id, this message translates to:
  /// **'Diberikan'**
  String get statusGranted;

  /// No description provided for @statusRevoked.
  ///
  /// In id, this message translates to:
  /// **'Dicabut'**
  String get statusRevoked;

  /// No description provided for @statusDisabled.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get statusDisabled;

  /// No description provided for @statusUnknown.
  ///
  /// In id, this message translates to:
  /// **'Tidak diketahui'**
  String get statusUnknown;

  /// No description provided for @degradedAccessibilityDisabled.
  ///
  /// In id, this message translates to:
  /// **'Aksesibilitas dinonaktifkan'**
  String get degradedAccessibilityDisabled;

  /// No description provided for @degradedAccessibilityNotGranted.
  ///
  /// In id, this message translates to:
  /// **'Izin aksesibilitas belum diberikan'**
  String get degradedAccessibilityNotGranted;

  /// No description provided for @degradedServiceStopped.
  ///
  /// In id, this message translates to:
  /// **'Layanan proteksi terhenti'**
  String get degradedServiceStopped;

  /// No description provided for @degradedPermissionRevoked.
  ///
  /// In id, this message translates to:
  /// **'Izin sistem dicabut'**
  String get degradedPermissionRevoked;

  /// No description provided for @degradedSensorDisconnected.
  ///
  /// In id, this message translates to:
  /// **'Sensor terputus'**
  String get degradedSensorDisconnected;

  /// No description provided for @statusPending.
  ///
  /// In id, this message translates to:
  /// **'menunggu'**
  String get statusPending;

  /// No description provided for @statusReviewed.
  ///
  /// In id, this message translates to:
  /// **'dalam tinjauan'**
  String get statusReviewed;

  /// No description provided for @statusApproved.
  ///
  /// In id, this message translates to:
  /// **'disetujui'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In id, this message translates to:
  /// **'ditolak'**
  String get statusRejected;

  /// No description provided for @statusExpired.
  ///
  /// In id, this message translates to:
  /// **'kedaluwarsa'**
  String get statusExpired;

  /// No description provided for @analyticsTitle.
  ///
  /// In id, this message translates to:
  /// **'Analitik'**
  String get analyticsTitle;

  /// No description provided for @analyticsSignInTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melihat analitik'**
  String get analyticsSignInTitle;

  /// No description provided for @analyticsSignInBody.
  ///
  /// In id, this message translates to:
  /// **'Analitik hanya berisi hitungan agregat perangkat dan tidak memuat URL atau riwayat penjelajahan.'**
  String get analyticsSignInBody;

  /// No description provided for @analyticsSevenDays.
  ///
  /// In id, this message translates to:
  /// **'7 hari'**
  String get analyticsSevenDays;

  /// No description provided for @analyticsThirtyDays.
  ///
  /// In id, this message translates to:
  /// **'30 hari'**
  String get analyticsThirtyDays;

  /// No description provided for @analyticsErrorTitle.
  ///
  /// In id, this message translates to:
  /// **'Analitik belum dapat dimuat'**
  String get analyticsErrorTitle;

  /// No description provided for @analyticsPrivacyNote.
  ///
  /// In id, this message translates to:
  /// **'Hanya hitungan harian yang ditampilkan. URL, domain, judul halaman, dan teks DOM tidak disimpan atau dikirim.'**
  String get analyticsPrivacyNote;

  /// No description provided for @analyticsDataSynced.
  ///
  /// In id, this message translates to:
  /// **'Hitungan hari yang selesai sudah disinkronkan ke akun Anda.'**
  String get analyticsDataSynced;

  /// No description provided for @analyticsDataLocalOnly.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan proteksi dihitung dan tersimpan aman di perangkat Anda.'**
  String get analyticsDataLocalOnly;

  /// No description provided for @analyticsBlocked.
  ///
  /// In id, this message translates to:
  /// **'Konten diblokir'**
  String get analyticsBlocked;

  /// No description provided for @analyticsInterventions.
  ///
  /// In id, this message translates to:
  /// **'Intervensi'**
  String get analyticsInterventions;

  /// No description provided for @analyticsTamper.
  ///
  /// In id, this message translates to:
  /// **'Upaya perubahan'**
  String get analyticsTamper;

  /// No description provided for @analyticsPermission.
  ///
  /// In id, this message translates to:
  /// **'Izin dicabut'**
  String get analyticsPermission;

  /// No description provided for @analyticsSummaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Perlindungan'**
  String get analyticsSummaryTitle;

  /// No description provided for @analyticsSummaryDesc.
  ///
  /// In id, this message translates to:
  /// **'Pantau tren pemblokiran otomatis, intervensi perilaku, dan statistik proteksi lokal.'**
  String get analyticsSummaryDesc;

  /// No description provided for @analyticsChartTitle.
  ///
  /// In id, this message translates to:
  /// **'Tren Aktivitas Proteksi'**
  String get analyticsChartTitle;

  /// No description provided for @analytics7Days.
  ///
  /// In id, this message translates to:
  /// **'7 Hari Terakhir'**
  String get analytics7Days;

  /// No description provided for @analytics30Days.
  ///
  /// In id, this message translates to:
  /// **'30 Hari Terakhir'**
  String get analytics30Days;

  /// No description provided for @analyticsLegendBlocked.
  ///
  /// In id, this message translates to:
  /// **'Blokir'**
  String get analyticsLegendBlocked;

  /// No description provided for @analyticsLegendInterventions.
  ///
  /// In id, this message translates to:
  /// **'Intervensi'**
  String get analyticsLegendInterventions;

  /// No description provided for @analyticsNoActivityTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Aktivitas Terdeteksi'**
  String get analyticsNoActivityTitle;

  /// No description provided for @analyticsNoActivityDesc.
  ///
  /// In id, this message translates to:
  /// **'Grafik akan terisi otomatis saat terjadi pemblokiran atau intervensi.'**
  String get analyticsNoActivityDesc;

  /// No description provided for @analyticsPrivacySectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Jaminan Privasi & Keamanan Data'**
  String get analyticsPrivacySectionTitle;

  /// No description provided for @analyticsOnDeviceTitle.
  ///
  /// In id, this message translates to:
  /// **'Privasi terjaga'**
  String get analyticsOnDeviceTitle;

  /// No description provided for @analyticsOnDeviceDesc.
  ///
  /// In id, this message translates to:
  /// **'Semua dianalisis di perangkat Anda, tidak pernah di cloud.'**
  String get analyticsOnDeviceDesc;

  /// No description provided for @analyticsNoBrowsingHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Tanpa Riwayat Penelusuran'**
  String get analyticsNoBrowsingHistoryTitle;

  /// No description provided for @analyticsNoBrowsingHistoryDesc.
  ///
  /// In id, this message translates to:
  /// **'Riwayat penelusuran Anda tidak pernah meninggalkan perangkat ini.'**
  String get analyticsNoBrowsingHistoryDesc;

  /// No description provided for @analyticsChartSummary.
  ///
  /// In id, this message translates to:
  /// **'{blocked} diblokir, {interventions} intervensi'**
  String analyticsChartSummary(int blocked, int interventions);

  /// No description provided for @analyticsDayTooltip.
  ///
  /// In id, this message translates to:
  /// **'{blocked} diblokir · {interventions} intervensi'**
  String analyticsDayTooltip(int blocked, int interventions);

  /// No description provided for @analyticsMilestoneTitle.
  ///
  /// In id, this message translates to:
  /// **'Perlindunganmu bekerja'**
  String get analyticsMilestoneTitle;

  /// No description provided for @analyticsMilestoneBody.
  ///
  /// In id, this message translates to:
  /// **'Perlindungan membantumu {count} kali dalam {days} hari terakhir. Setiap jeda adalah ruang untuk memilih ulang.'**
  String analyticsMilestoneBody(int count, int days);

  /// No description provided for @msgErrLoadPartner.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data pendamping.'**
  String get msgErrLoadPartner;

  /// No description provided for @msgErrRejectRequest.
  ///
  /// In id, this message translates to:
  /// **'Gagal menolak permohonan.'**
  String get msgErrRejectRequest;

  /// No description provided for @msgErrInvalidRequest.
  ///
  /// In id, this message translates to:
  /// **'Permintaan tidak valid. Periksa kembali isian Anda.'**
  String get msgErrInvalidRequest;

  /// No description provided for @msgErrGroupCodeRequired.
  ///
  /// In id, this message translates to:
  /// **'Kode grup wajib diisi.'**
  String get msgErrGroupCodeRequired;

  /// No description provided for @msgErrProcessRequest.
  ///
  /// In id, this message translates to:
  /// **'Gagal memproses permohonan.'**
  String get msgErrProcessRequest;

  /// No description provided for @msgErrApproveRequest.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyetujui permohonan.'**
  String get msgErrApproveRequest;

  /// No description provided for @msgErrGroupNotFound.
  ///
  /// In id, this message translates to:
  /// **'Grup tidak ditemukan.'**
  String get msgErrGroupNotFound;

  /// No description provided for @msgErrSubmitRequest.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengajukan permohonan.'**
  String get msgErrSubmitRequest;

  /// No description provided for @msgErrInvalidEmergencyKey.
  ///
  /// In id, this message translates to:
  /// **'Kunci darurat tidak valid.'**
  String get msgErrInvalidEmergencyKey;

  /// No description provided for @msgErrBlockedEventsRejected.
  ///
  /// In id, this message translates to:
  /// **'Data waktu blokir perangkat tidak dapat diterima.'**
  String get msgErrBlockedEventsRejected;

  /// No description provided for @msgErrCreateGroup.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat grup.'**
  String get msgErrCreateGroup;

  /// No description provided for @msgErrCreateEmergencyKey.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat kunci darurat.'**
  String get msgErrCreateEmergencyKey;

  /// No description provided for @msgErrRemoveMember.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengeluarkan anggota.'**
  String get msgErrRemoveMember;

  /// No description provided for @msgErrLoadDataRequest.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat permintaan data.'**
  String get msgErrLoadDataRequest;

  /// No description provided for @msgErrLoadGroupAnalytics.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat analitik grup.'**
  String get msgErrLoadGroupAnalytics;

  /// No description provided for @msgErrSubmitDataRequest.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengajukan permintaan data.'**
  String get msgErrSubmitDataRequest;

  /// No description provided for @msgErrNotInGroup.
  ///
  /// In id, this message translates to:
  /// **'Anda belum bergabung dengan grup mana pun.'**
  String get msgErrNotInGroup;

  /// No description provided for @msgErrTooManyRequests.
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak permintaan. Coba lagi sebentar lagi.'**
  String get msgErrTooManyRequests;

  /// No description provided for @msgErrDisconnectPartner.
  ///
  /// In id, this message translates to:
  /// **'Gagal memutuskan hubungan pendamping.'**
  String get msgErrDisconnectPartner;

  /// No description provided for @msgErrLoadRequests.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat daftar permohonan.'**
  String get msgErrLoadRequests;

  /// No description provided for @msgErrCancelRequest.
  ///
  /// In id, this message translates to:
  /// **'Gagal membatalkan permohonan.'**
  String get msgErrCancelRequest;

  /// No description provided for @msgErrPartnerEmailRequired.
  ///
  /// In id, this message translates to:
  /// **'Email pendamping wajib diisi.'**
  String get msgErrPartnerEmailRequired;

  /// No description provided for @msgErrGroupNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama grup wajib diisi.'**
  String get msgErrGroupNameRequired;

  /// No description provided for @msgErrLoadMembers.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat daftar anggota.'**
  String get msgErrLoadMembers;

  /// No description provided for @msgErrInvalidGroupCodeSpecific.
  ///
  /// In id, this message translates to:
  /// **'Kode grup tidak valid. Coba lagi.'**
  String get msgErrInvalidGroupCodeSpecific;

  /// No description provided for @msgErrAcceptInvite.
  ///
  /// In id, this message translates to:
  /// **'Gagal menerima undangan pendamping.'**
  String get msgErrAcceptInvite;

  /// No description provided for @msgErrSendInvite.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengirim undangan pendamping.'**
  String get msgErrSendInvite;

  /// No description provided for @msgErrEmergencyKeyRequired.
  ///
  /// In id, this message translates to:
  /// **'Kunci darurat wajib diisi.'**
  String get msgErrEmergencyKeyRequired;

  /// No description provided for @msgErrPrivacyPayloadRejected.
  ///
  /// In id, this message translates to:
  /// **'Permintaan ditolak karena memuat data yang tidak boleh dikirim.'**
  String get msgErrPrivacyPayloadRejected;

  /// No description provided for @partnerTitle.
  ///
  /// In id, this message translates to:
  /// **'Pendamping'**
  String get partnerTitle;

  /// No description provided for @partnerSignInTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk mengelola pendamping'**
  String get partnerSignInTitle;

  /// No description provided for @partnerSignInBody.
  ///
  /// In id, this message translates to:
  /// **'Hubungan pendamping dan permintaan persetujuan disimpan pada akun Anda.'**
  String get partnerSignInBody;

  /// No description provided for @partnerErrorTitle.
  ///
  /// In id, this message translates to:
  /// **'Data pendamping belum dapat dimuat'**
  String get partnerErrorTitle;

  /// No description provided for @partnerInviteCreated.
  ///
  /// In id, this message translates to:
  /// **'Undangan pendamping berhasil dibuat.'**
  String get partnerInviteCreated;

  /// No description provided for @partnerNone.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pendamping aktif'**
  String get partnerNone;

  /// No description provided for @partnerNoneBody.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode dari pendamping tepercaya. Pendamping tidak dapat melihat URL, riwayat penjelajahan, atau catatan pemulihan pribadi.'**
  String get partnerNoneBody;

  /// No description provided for @partnerActiveBody.
  ///
  /// In id, this message translates to:
  /// **'Pendamping aktif dapat menyetujui perubahan proteksi untuk perangkat yang terdaftar.'**
  String get partnerActiveBody;

  /// No description provided for @partnerEmailLabel.
  ///
  /// In id, this message translates to:
  /// **'Email pendamping'**
  String get partnerEmailLabel;

  /// No description provided for @partnerEmailHelp.
  ///
  /// In id, this message translates to:
  /// **'Gunakan email orang tepercaya yang memahami dan menyetujui peran ini.'**
  String get partnerEmailHelp;

  /// No description provided for @partnerInviteAction.
  ///
  /// In id, this message translates to:
  /// **'Buat undangan'**
  String get partnerInviteAction;

  /// No description provided for @partnerInviteLink.
  ///
  /// In id, this message translates to:
  /// **'Tautan undangan'**
  String get partnerInviteLink;

  /// No description provided for @partnerInviteCopied.
  ///
  /// In id, this message translates to:
  /// **'Tautan undangan tersalin.'**
  String get partnerInviteCopied;

  /// No description provided for @partnerRequestHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat permintaan'**
  String get partnerRequestHistory;

  /// No description provided for @partnerNoRequests.
  ///
  /// In id, this message translates to:
  /// **'Belum ada permintaan'**
  String get partnerNoRequests;

  /// No description provided for @partnerNoRequestsBody.
  ///
  /// In id, this message translates to:
  /// **'Permintaan perubahan proteksi dari perangkat akan muncul di sini.'**
  String get partnerNoRequestsBody;

  /// No description provided for @partnerManageAction.
  ///
  /// In id, this message translates to:
  /// **'Kelola pendamping'**
  String get partnerManageAction;

  /// No description provided for @accountabilityJoinTitle.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan pendamping dengan kode grup'**
  String get accountabilityJoinTitle;

  /// No description provided for @accountabilityJoinBody.
  ///
  /// In id, this message translates to:
  /// **'Tinjau nama grup dan pendamping sebelum bergabung. Satu akun hanya dapat memiliki satu grup aktif.'**
  String get accountabilityJoinBody;

  /// No description provided for @accountabilityPreviewAction.
  ///
  /// In id, this message translates to:
  /// **'Tinjau grup'**
  String get accountabilityPreviewAction;

  /// No description provided for @accountabilityManagedBy.
  ///
  /// In id, this message translates to:
  /// **'Dikelola oleh {name}'**
  String accountabilityManagedBy(String name);

  /// No description provided for @accountabilityJoinConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Bergabung ke grup ini?'**
  String get accountabilityJoinConfirmTitle;

  /// No description provided for @accountabilityJoinConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'{name} akan menjadi pendamping Anda. Ringkasan agregat awal dapat Anda matikan dari portal web kapan saja.'**
  String accountabilityJoinConfirmBody(String name);

  /// No description provided for @accountabilityJoinAction.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi dan bergabung'**
  String get accountabilityJoinAction;

  /// No description provided for @accountabilityJoinSuccess.
  ///
  /// In id, this message translates to:
  /// **'Grup akuntabilitas berhasil dihubungkan.'**
  String get accountabilityJoinSuccess;

  /// No description provided for @accountabilityActiveGroup.
  ///
  /// In id, this message translates to:
  /// **'Terhubung melalui grup {name}. Pendamping hanya menerima agregat yang Anda izinkan.'**
  String accountabilityActiveGroup(String name);

  /// No description provided for @partnerSharingPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Privasi Berbagi'**
  String get partnerSharingPrivacy;

  /// No description provided for @partnerSharingDesc.
  ///
  /// In id, this message translates to:
  /// **'Atur jenis ringkasan agregat yang dapat dilihat pendamping.'**
  String get partnerSharingDesc;

  /// No description provided for @partnerLeaveSection.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari Pendampingan'**
  String get partnerLeaveSection;

  /// No description provided for @partnerLeaveNormal.
  ///
  /// In id, this message translates to:
  /// **'Ajukan keluar normal'**
  String get partnerLeaveNormal;

  /// No description provided for @partnerLeaveUnsafe.
  ///
  /// In id, this message translates to:
  /// **'Situasi tidak aman'**
  String get partnerLeaveUnsafe;

  /// No description provided for @partnerPrivacyBadge.
  ///
  /// In id, this message translates to:
  /// **'Privasi Terlindungi · Hanya Agregat'**
  String get partnerPrivacyBadge;

  /// No description provided for @accSharingTitle.
  ///
  /// In id, this message translates to:
  /// **'Data Agregat Dibagikan'**
  String get accSharingTitle;

  /// No description provided for @accSharingSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Atur preferensi data agregat anonim untuk pendamping.'**
  String get accSharingSubtitle;

  /// No description provided for @accShareHealthTitle.
  ///
  /// In id, this message translates to:
  /// **'Kesehatan Perlindungan'**
  String get accShareHealthTitle;

  /// No description provided for @accShareHealthSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Status aktif, degradasi, & izin (tanpa URL).'**
  String get accShareHealthSubtitle;

  /// No description provided for @accShareActivityTitle.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas Perlindungan'**
  String get accShareActivityTitle;

  /// No description provided for @accShareActivitySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Hitungan pemblokiran & intervensi agregat.'**
  String get accShareActivitySubtitle;

  /// No description provided for @accShareEngagementTitle.
  ///
  /// In id, this message translates to:
  /// **'Keterlibatan Pemulihan'**
  String get accShareEngagementTitle;

  /// No description provided for @accShareEngagementSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan partisipasi (bukan isi jurnal).'**
  String get accShareEngagementSubtitle;

  /// No description provided for @accShareEducationTitle.
  ///
  /// In id, this message translates to:
  /// **'Progres Edukasi'**
  String get accShareEducationTitle;

  /// No description provided for @accShareEducationSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Penyelesaian modul psikoedukasi harian.'**
  String get accShareEducationSubtitle;

  /// No description provided for @accSharingUpdated.
  ///
  /// In id, this message translates to:
  /// **'Preferensi berbagi diperbarui.'**
  String get accSharingUpdated;

  /// No description provided for @accUnsafeExitTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluar Situasi Tidak Aman'**
  String get accUnsafeExitTitle;

  /// No description provided for @accNormalExitTitle.
  ///
  /// In id, this message translates to:
  /// **'Ajukan Keluar Pendampingan'**
  String get accNormalExitTitle;

  /// No description provided for @accUnsafeExitDesc.
  ///
  /// In id, this message translates to:
  /// **'Berbagi data segera dihentikan dan permintaan normal dibatalkan.'**
  String get accUnsafeExitDesc;

  /// No description provided for @accNormalExitDesc.
  ///
  /// In id, this message translates to:
  /// **'Pendamping memiliki waktu 72 jam untuk meninjau permintaan.'**
  String get accNormalExitDesc;

  /// No description provided for @accReasonLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan (opsional)'**
  String get accReasonLabel;

  /// No description provided for @accReasonHint.
  ///
  /// In id, this message translates to:
  /// **'Berikan penjelasan singkat...'**
  String get accReasonHint;

  /// No description provided for @accSendRequest.
  ///
  /// In id, this message translates to:
  /// **'Kirim Permintaan'**
  String get accSendRequest;

  /// No description provided for @accExitRequestSent.
  ///
  /// In id, this message translates to:
  /// **'Permintaan keluar dikirim.'**
  String get accExitRequestSent;

  /// No description provided for @accExitRequestCancelled.
  ///
  /// In id, this message translates to:
  /// **'Permintaan keluar dibatalkan.'**
  String get accExitRequestCancelled;

  /// No description provided for @accApprovalCancelled.
  ///
  /// In id, this message translates to:
  /// **'Permintaan persetujuan dibatalkan.'**
  String get accApprovalCancelled;

  /// No description provided for @accExitPendingTitle.
  ///
  /// In id, this message translates to:
  /// **'Permintaan keluar sedang ditinjau'**
  String get accExitPendingTitle;

  /// No description provided for @accExitPendingBody.
  ///
  /// In id, this message translates to:
  /// **'Anda dapat membatalkan permintaan normal selama masih tertunda.'**
  String get accExitPendingBody;

  /// No description provided for @accExitChoose.
  ///
  /// In id, this message translates to:
  /// **'Pilih alur normal atau hentikan berbagi segera bila situasi tidak aman.'**
  String get accExitChoose;

  /// No description provided for @accCodeRequired.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode grup terlebih dahulu.'**
  String get accCodeRequired;

  /// No description provided for @accountabilityGroupCodeHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: ABCD234567'**
  String get accountabilityGroupCodeHint;

  /// No description provided for @accActionUninstall.
  ///
  /// In id, this message translates to:
  /// **'Izinkan penghapusan aplikasi'**
  String get accActionUninstall;

  /// No description provided for @accActionPause.
  ///
  /// In id, this message translates to:
  /// **'Jeda perlindungan'**
  String get accActionPause;

  /// No description provided for @accActionPauseDuration.
  ///
  /// In id, this message translates to:
  /// **'Jeda perlindungan {minutes} menit'**
  String accActionPauseDuration(int minutes);

  /// No description provided for @accActionDisable.
  ///
  /// In id, this message translates to:
  /// **'Nonaktifkan perlindungan'**
  String get accActionDisable;

  /// No description provided for @accActionEmergency.
  ///
  /// In id, this message translates to:
  /// **'Akses darurat'**
  String get accActionEmergency;

  /// No description provided for @accStatusApproved.
  ///
  /// In id, this message translates to:
  /// **'Disetujui'**
  String get accStatusApproved;

  /// No description provided for @accStatusPending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get accStatusPending;

  /// No description provided for @accStatusDenied.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get accStatusDenied;

  /// No description provided for @accStatusExpired.
  ///
  /// In id, this message translates to:
  /// **'Kedaluwarsa'**
  String get accStatusExpired;

  /// No description provided for @accStatusCancelled.
  ///
  /// In id, this message translates to:
  /// **'Dibatalkan'**
  String get accStatusCancelled;

  /// No description provided for @accReasonAccessibilityDisabled.
  ///
  /// In id, this message translates to:
  /// **'Layanan aksesibilitas dinonaktifkan'**
  String get accReasonAccessibilityDisabled;

  /// No description provided for @accReasonTroubleshooting.
  ///
  /// In id, this message translates to:
  /// **'Perbaikan pengaturan aplikasi'**
  String get accReasonTroubleshooting;

  /// No description provided for @accReasonDeviceAdminDisabled.
  ///
  /// In id, this message translates to:
  /// **'Administrator perangkat dinonaktifkan'**
  String get accReasonDeviceAdminDisabled;

  /// No description provided for @accReasonAppUpdate.
  ///
  /// In id, this message translates to:
  /// **'Pembaruan aplikasi diperlukan'**
  String get accReasonAppUpdate;

  /// No description provided for @accReasonTesting.
  ///
  /// In id, this message translates to:
  /// **'Pengujian perlindungan'**
  String get accReasonTesting;

  /// No description provided for @roleMember.
  ///
  /// In id, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// No description provided for @onboardingGroupCode.
  ///
  /// In id, this message translates to:
  /// **'Kode Grup'**
  String get onboardingGroupCode;

  /// No description provided for @introSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get introSkip;

  /// No description provided for @introNext.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get introNext;

  /// No description provided for @introStartBtn.
  ///
  /// In id, this message translates to:
  /// **'Mulai Sekarang'**
  String get introStartBtn;

  /// No description provided for @introStepOf.
  ///
  /// In id, this message translates to:
  /// **'LANGKAH {n} DARI {total}'**
  String introStepOf(int n, int total);

  /// No description provided for @introSlide1Lead.
  ///
  /// In id, this message translates to:
  /// **'JANGAN LUPA'**
  String get introSlide1Lead;

  /// No description provided for @introSlide1Highlight.
  ///
  /// In id, this message translates to:
  /// **'LINDUNGI DIRIMU'**
  String get introSlide1Highlight;

  /// No description provided for @introSlide1Tail.
  ///
  /// In id, this message translates to:
  /// **''**
  String get introSlide1Tail;

  /// No description provided for @introSlide1Subtitle.
  ///
  /// In id, this message translates to:
  /// **'Perlindungan AI di perangkatmu menjaga setiap langkah — tanpa mengintip datamu.'**
  String get introSlide1Subtitle;

  /// No description provided for @introSlide2Lead.
  ///
  /// In id, this message translates to:
  /// **'TIDAK APA-APA'**
  String get introSlide2Lead;

  /// No description provided for @introSlide2Highlight.
  ///
  /// In id, this message translates to:
  /// **'BERHENTI SEJENAK'**
  String get introSlide2Highlight;

  /// No description provided for @introSlide2Tail.
  ///
  /// In id, this message translates to:
  /// **''**
  String get introSlide2Tail;

  /// No description provided for @introSlide2Subtitle.
  ///
  /// In id, this message translates to:
  /// **'Pattern Interrupt memberi ruang bernapas saat dorongan itu datang.'**
  String get introSlide2Subtitle;

  /// No description provided for @introSlide3Lead.
  ///
  /// In id, this message translates to:
  /// **'BERJEDA SEJENAK.'**
  String get introSlide3Lead;

  /// No description provided for @introSlide3Highlight.
  ///
  /// In id, this message translates to:
  /// **'AMBIL KENDALI'**
  String get introSlide3Highlight;

  /// No description provided for @introSlide3Tail.
  ///
  /// In id, this message translates to:
  /// **''**
  String get introSlide3Tail;

  /// No description provided for @introSlide3Subtitle.
  ///
  /// In id, this message translates to:
  /// **'Deteksi lokal, dukungan pemulihan, dan partner akuntabilitas dalam satu aplikasi.'**
  String get introSlide3Subtitle;

  /// No description provided for @setupTitle.
  ///
  /// In id, this message translates to:
  /// **'Setup perangkat'**
  String get setupTitle;

  /// No description provided for @setupIntro.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan checklist ini agar status proteksi ditampilkan secara jujur dan setiap izin diberikan dengan persetujuan Anda.'**
  String get setupIntro;

  /// No description provided for @setupPrivacyTitle.
  ///
  /// In id, this message translates to:
  /// **'Pahami batas privasi'**
  String get setupPrivacyTitle;

  /// No description provided for @setupPrivacyBody.
  ///
  /// In id, this message translates to:
  /// **'URL dan teks halaman hanya diproses lokal. Backend menerima hitungan agregat saja.'**
  String get setupPrivacyBody;

  /// No description provided for @setupAccountTitle.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan akun'**
  String get setupAccountTitle;

  /// No description provided for @setupAccountBody.
  ///
  /// In id, this message translates to:
  /// **'Akun diperlukan untuk registrasi perangkat, pendamping, dan sinkronisasi agregat.'**
  String get setupAccountBody;

  /// No description provided for @setupAccountReady.
  ///
  /// In id, this message translates to:
  /// **'Akun telah terhubung.'**
  String get setupAccountReady;

  /// No description provided for @setupDeviceTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftarkan perangkat'**
  String get setupDeviceTitle;

  /// No description provided for @setupDeviceBody.
  ///
  /// In id, this message translates to:
  /// **'Perangkat harus memiliki ID akun yang stabil sebelum membuat permintaan persetujuan.'**
  String get setupDeviceBody;

  /// No description provided for @setupDeviceReady.
  ///
  /// In id, this message translates to:
  /// **'Perangkat terdaftar sebagai {deviceId}.'**
  String setupDeviceReady(String deviceId);

  /// No description provided for @setupDeviceAction.
  ///
  /// In id, this message translates to:
  /// **'Daftarkan perangkat'**
  String get setupDeviceAction;

  /// No description provided for @setupDeviceRegistered.
  ///
  /// In id, this message translates to:
  /// **'Perangkat berhasil didaftarkan.'**
  String get setupDeviceRegistered;

  /// No description provided for @setupPlatformTitle.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan proteksi platform'**
  String get setupPlatformTitle;

  /// No description provided for @setupPlatformBody.
  ///
  /// In id, this message translates to:
  /// **'Android memerlukan Accessibility Service. Windows memerlukan service, user-session agent, serta ekstensi Chrome/Edge yang dipasangkan dengan token lokal.'**
  String get setupPlatformBody;

  /// No description provided for @setupPlatformReady.
  ///
  /// In id, this message translates to:
  /// **'Runtime proteksi platform aktif.'**
  String get setupPlatformReady;

  /// No description provided for @setupPlatformAction.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan platform'**
  String get setupPlatformAction;

  /// No description provided for @setupSelfTestTitle.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi model lokal'**
  String get setupSelfTestTitle;

  /// No description provided for @setupSelfTestBody.
  ///
  /// In id, this message translates to:
  /// **'Self-test menggunakan fixture lokal dan tidak mengirim konten halaman.'**
  String get setupSelfTestBody;

  /// No description provided for @setupFinishAction.
  ///
  /// In id, this message translates to:
  /// **'Buka status proteksi'**
  String get setupFinishAction;

  /// No description provided for @setupLimitations.
  ///
  /// In id, this message translates to:
  /// **'Sideload normal memberikan friksi, bukan perlindungan uninstall absolut. Administrator perangkat tetap memiliki kendali OS.'**
  String get setupLimitations;

  /// No description provided for @patternBreatheDesc.
  ///
  /// In id, this message translates to:
  /// **'Tarik napas dalam-dalam.\nDorongan ini akan lewat.'**
  String get patternBreatheDesc;

  /// No description provided for @patternContinuePsychoeducation.
  ///
  /// In id, this message translates to:
  /// **'Lanjut ke Psikoedukasi'**
  String get patternContinuePsychoeducation;

  /// No description provided for @patternInterruptTitle.
  ///
  /// In id, this message translates to:
  /// **'Ambil jeda sebelum melanjutkan'**
  String get patternInterruptTitle;

  /// No description provided for @patternBreatheLabel.
  ///
  /// In id, this message translates to:
  /// **'Animasi napas perlahan'**
  String get patternBreatheLabel;

  /// No description provided for @patternSecondsRemaining.
  ///
  /// In id, this message translates to:
  /// **'{seconds} detik tersisa'**
  String patternSecondsRemaining(int seconds);

  /// No description provided for @patternReady.
  ///
  /// In id, this message translates to:
  /// **'Jeda selesai. Pilih langkah berikutnya.'**
  String get patternReady;

  /// No description provided for @patternGroundingAction.
  ///
  /// In id, this message translates to:
  /// **'Latihan grounding offline'**
  String get patternGroundingAction;

  /// No description provided for @patternHelpAction.
  ///
  /// In id, this message translates to:
  /// **'Butuh bantuan'**
  String get patternHelpAction;

  /// No description provided for @patternLaterAction.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke proteksi'**
  String get patternLaterAction;

  /// No description provided for @patternGroundingTitle.
  ///
  /// In id, this message translates to:
  /// **'Perhatikan lima hal di sekitar Anda'**
  String get patternGroundingTitle;

  /// No description provided for @patternReturnProtection.
  ///
  /// In id, this message translates to:
  /// **'Selesai dan kembali'**
  String get patternReturnProtection;

  /// No description provided for @patternWaitHint.
  ///
  /// In id, this message translates to:
  /// **'Sebentar lagi — tarik napas dulu.'**
  String get patternWaitHint;

  /// No description provided for @patternPhaseInhale.
  ///
  /// In id, this message translates to:
  /// **'Tarik napas…'**
  String get patternPhaseInhale;

  /// No description provided for @patternPhaseExhale.
  ///
  /// In id, this message translates to:
  /// **'Hembuskan perlahan…'**
  String get patternPhaseExhale;

  /// No description provided for @patternPhaseStatic.
  ///
  /// In id, this message translates to:
  /// **'Tarik napas perlahan, lalu hembuskan.'**
  String get patternPhaseStatic;

  /// No description provided for @msgErrUpdateMission.
  ///
  /// In id, this message translates to:
  /// **'Gagal memperbarui misi harian.'**
  String get msgErrUpdateMission;

  /// No description provided for @msgErrLoadPsychoeducation.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat modul psikoedukasi.'**
  String get msgErrLoadPsychoeducation;

  /// No description provided for @msgErrSaveJournal.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan jurnal refleksi.'**
  String get msgErrSaveJournal;

  /// No description provided for @msgErrLoadMissions.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat misi harian.'**
  String get msgErrLoadMissions;

  /// No description provided for @msgErrLoadJournal.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat jurnal refleksi.'**
  String get msgErrLoadJournal;

  /// No description provided for @msgErrTranslationFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menerjemahkan konten. Silakan coba lagi.'**
  String get msgErrTranslationFailed;

  /// No description provided for @msgErrTranslationUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Layanan AI penerjemahan sedang tidak tersedia.'**
  String get msgErrTranslationUnavailable;

  /// No description provided for @msgErrTranslationRateLimited.
  ///
  /// In id, this message translates to:
  /// **'Penerjemahan AI sedang sibuk, coba lagi dalam beberapa saat.'**
  String get msgErrTranslationRateLimited;

  /// No description provided for @msgErrSpkRecommendationFailed.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi harian belum dapat dimuat.'**
  String get msgErrSpkRecommendationFailed;

  /// No description provided for @msgErrSpkInterventionNotFound.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi tidak ditemukan atau bukan milik Anda.'**
  String get msgErrSpkInterventionNotFound;

  /// No description provided for @msgErrSpkInterventionCompleteFailed.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi belum dapat ditandai selesai.'**
  String get msgErrSpkInterventionCompleteFailed;

  /// No description provided for @msgErrSpkPreferenceInvalid.
  ///
  /// In id, this message translates to:
  /// **'Preferensi belum valid.'**
  String get msgErrSpkPreferenceInvalid;

  /// No description provided for @msgErrInvalidMission.
  ///
  /// In id, this message translates to:
  /// **'Nomor misi harus 1-5.'**
  String get msgErrInvalidMission;

  /// No description provided for @msgErrTextRequired.
  ///
  /// In id, this message translates to:
  /// **'Teks refleksi wajib diisi.'**
  String get msgErrTextRequired;

  /// No description provided for @msgErrSummaryRequired.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan tiket wajib diisi.'**
  String get msgErrSummaryRequired;

  /// No description provided for @msgErrTypeRequired.
  ///
  /// In id, this message translates to:
  /// **'Jenis permintaan wajib dipilih.'**
  String get msgErrTypeRequired;

  /// No description provided for @webPageOpenError.
  ///
  /// In id, this message translates to:
  /// **'Halaman belum dapat dibuka. Coba lagi.'**
  String get webPageOpenError;

  /// No description provided for @groundingStep1Title.
  ///
  /// In id, this message translates to:
  /// **'Lihat'**
  String get groundingStep1Title;

  /// No description provided for @groundingStep1Body.
  ///
  /// In id, this message translates to:
  /// **'Sebutkan lima hal yang bisa Anda lihat di sekitar Anda.'**
  String get groundingStep1Body;

  /// No description provided for @groundingStep2Title.
  ///
  /// In id, this message translates to:
  /// **'Rasakan'**
  String get groundingStep2Title;

  /// No description provided for @groundingStep2Body.
  ///
  /// In id, this message translates to:
  /// **'Sebutkan empat hal yang bisa Anda sentuh atau rasakan.'**
  String get groundingStep2Body;

  /// No description provided for @groundingStep3Title.
  ///
  /// In id, this message translates to:
  /// **'Dengar'**
  String get groundingStep3Title;

  /// No description provided for @groundingStep3Body.
  ///
  /// In id, this message translates to:
  /// **'Sebutkan tiga suara yang bisa Anda dengar saat ini.'**
  String get groundingStep3Body;

  /// No description provided for @groundingStep4Title.
  ///
  /// In id, this message translates to:
  /// **'Cium'**
  String get groundingStep4Title;

  /// No description provided for @groundingStep4Body.
  ///
  /// In id, this message translates to:
  /// **'Sebutkan dua aroma yang bisa Anda cium.'**
  String get groundingStep4Body;

  /// No description provided for @groundingStep5Title.
  ///
  /// In id, this message translates to:
  /// **'Lindungi'**
  String get groundingStep5Title;

  /// No description provided for @groundingStep5Body.
  ///
  /// In id, this message translates to:
  /// **'Sebutkan satu hal yang ingin Anda lindungi hari ini.'**
  String get groundingStep5Body;

  /// No description provided for @groundingStepProgress.
  ///
  /// In id, this message translates to:
  /// **'Langkah {current} dari {total}'**
  String groundingStepProgress(int current, int total);

  /// No description provided for @groundingNext.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get groundingNext;

  /// No description provided for @groundingDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get groundingDone;

  /// No description provided for @groundingCompleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Latihan selesai'**
  String get groundingCompleteTitle;

  /// No description provided for @groundingCompleteBody.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah hadir sepenuhnya di momen ini. Pilih langkah berikutnya dengan tenang.'**
  String get groundingCompleteBody;

  /// No description provided for @reminderChannelName.
  ///
  /// In id, this message translates to:
  /// **'Pengingat harian'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDesc.
  ///
  /// In id, this message translates to:
  /// **'Pengingat check-in sekali sehari'**
  String get reminderChannelDesc;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In id, this message translates to:
  /// **'Waktu untuk dirimu'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderNotificationBody.
  ///
  /// In id, this message translates to:
  /// **'Luangkan satu menit untuk check-in hari ini. Kapan pun kamu siap.'**
  String get reminderNotificationBody;

  /// No description provided for @reminderBodyStreak.
  ///
  /// In id, this message translates to:
  /// **'Jangan putus ritme-mu — isi check-in harianmu.'**
  String get reminderBodyStreak;

  /// No description provided for @reminderBodyStep.
  ///
  /// In id, this message translates to:
  /// **'Satu langkah kecil tetap kemajuan. Check-in sebentar saja.'**
  String get reminderBodyStep;

  /// No description provided for @reminderBodyConsistent.
  ///
  /// In id, this message translates to:
  /// **'Tetap tenang, tetap konsisten. Check-in harian menunggumu.'**
  String get reminderBodyConsistent;

  /// No description provided for @miniGamesEyebrow.
  ///
  /// In id, this message translates to:
  /// **'MINI GAME'**
  String get miniGamesEyebrow;

  /// No description provided for @miniGamesTitle.
  ///
  /// In id, this message translates to:
  /// **'Mini game'**
  String get miniGamesTitle;

  /// No description provided for @miniGamesDescription.
  ///
  /// In id, this message translates to:
  /// **'Ambil jeda ringan dan fokus dengan empat aktivitas singkat.'**
  String get miniGamesDescription;

  /// No description provided for @miniGamesSessionOnly.
  ///
  /// In id, this message translates to:
  /// **'Permainan hanya berlangsung di perangkat ini selama sesi berjalan. Skor dan pilihan tidak disimpan atau dibagikan.'**
  String get miniGamesSessionOnly;

  /// No description provided for @miniGamesSpectrumTitle.
  ///
  /// In id, this message translates to:
  /// **'Sprint Spektrum'**
  String get miniGamesSpectrumTitle;

  /// No description provided for @miniGamesSpectrumDescription.
  ///
  /// In id, this message translates to:
  /// **'Sebutkan warna tinta, bukan kata yang tertulis.'**
  String get miniGamesSpectrumDescription;

  /// No description provided for @miniGamesSpectrumInstruction.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan 12 ronde singkat. Pilih warna tinta setiap kata sebelum waktu habis.'**
  String get miniGamesSpectrumInstruction;

  /// No description provided for @miniGamesPictureTitle.
  ///
  /// In id, this message translates to:
  /// **'Tempa Gambar'**
  String get miniGamesPictureTitle;

  /// No description provided for @miniGamesPictureDescription.
  ///
  /// In id, this message translates to:
  /// **'Susun kembali gambar buah dengan menukar potongan.'**
  String get miniGamesPictureDescription;

  /// No description provided for @miniGamesPictureInstruction.
  ///
  /// In id, this message translates to:
  /// **'Pilih dua potongan untuk ditukar. Kembalikan setiap bagian ke posisi semula.'**
  String get miniGamesPictureInstruction;

  /// No description provided for @miniGamesTwinTitle.
  ///
  /// In id, this message translates to:
  /// **'Jejak Kembar'**
  String get miniGamesTwinTitle;

  /// No description provided for @miniGamesTwinDescription.
  ///
  /// In id, this message translates to:
  /// **'Ingat letak setiap pasangan buah yang sama.'**
  String get miniGamesTwinDescription;

  /// No description provided for @miniGamesTwinInstruction.
  ///
  /// In id, this message translates to:
  /// **'Buka dua kartu setiap giliran dan temukan semua pasangan yang sama.'**
  String get miniGamesTwinInstruction;

  /// No description provided for @miniGamesTwinPreview.
  ///
  /// In id, this message translates to:
  /// **'Ingat posisi kartunya. Papan akan tertutup sebentar lagi.'**
  String get miniGamesTwinPreview;

  /// No description provided for @miniGamesBrainTitle.
  ///
  /// In id, this message translates to:
  /// **'Puncak Otak'**
  String get miniGamesBrainTitle;

  /// No description provided for @miniGamesBrainDescription.
  ///
  /// In id, this message translates to:
  /// **'Coba delapan pertanyaan singkat dari kuis yang diacak.'**
  String get miniGamesBrainDescription;

  /// No description provided for @miniGamesBrainInstruction.
  ///
  /// In id, this message translates to:
  /// **'Pilih jawaban yang menurutmu benar. Pertanyaan berikutnya muncul setelah pilihanmu.'**
  String get miniGamesBrainInstruction;

  /// No description provided for @miniGamesRound.
  ///
  /// In id, this message translates to:
  /// **'Ronde {current} dari {total}'**
  String miniGamesRound(int current, int total);

  /// No description provided for @miniGamesSeconds.
  ///
  /// In id, this message translates to:
  /// **'Sisa {seconds} dtk'**
  String miniGamesSeconds(int seconds);

  /// No description provided for @miniGamesReadWord.
  ///
  /// In id, this message translates to:
  /// **'Baca kata, lalu sebutkan warna tintanya.'**
  String get miniGamesReadWord;

  /// No description provided for @miniGamesChooseInk.
  ///
  /// In id, this message translates to:
  /// **'Apa warna tintanya?'**
  String get miniGamesChooseInk;

  /// No description provided for @miniGamesColorBlue.
  ///
  /// In id, this message translates to:
  /// **'Biru'**
  String get miniGamesColorBlue;

  /// No description provided for @miniGamesColorYellow.
  ///
  /// In id, this message translates to:
  /// **'Kuning'**
  String get miniGamesColorYellow;

  /// No description provided for @miniGamesColorRed.
  ///
  /// In id, this message translates to:
  /// **'Merah'**
  String get miniGamesColorRed;

  /// No description provided for @miniGamesColorGreen.
  ///
  /// In id, this message translates to:
  /// **'Hijau'**
  String get miniGamesColorGreen;

  /// No description provided for @miniGamesPause.
  ///
  /// In id, this message translates to:
  /// **'Jeda'**
  String get miniGamesPause;

  /// No description provided for @miniGamesResume.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get miniGamesResume;

  /// No description provided for @miniGamesEasy.
  ///
  /// In id, this message translates to:
  /// **'Mudah'**
  String get miniGamesEasy;

  /// No description provided for @miniGamesMedium.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get miniGamesMedium;

  /// No description provided for @miniGamesHard.
  ///
  /// In id, this message translates to:
  /// **'Sulit'**
  String get miniGamesHard;

  /// No description provided for @miniGamesPictureSelect.
  ///
  /// In id, this message translates to:
  /// **'Pilih dua potongan untuk ditukar.'**
  String get miniGamesPictureSelect;

  /// No description provided for @miniGamesCompleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Bagus sekali'**
  String get miniGamesCompleteTitle;

  /// No description provided for @miniGamesPlayAgain.
  ///
  /// In id, this message translates to:
  /// **'Main lagi'**
  String get miniGamesPlayAgain;

  /// No description provided for @miniGamesBackToHub.
  ///
  /// In id, this message translates to:
  /// **'Menu mini game'**
  String get miniGamesBackToHub;

  /// No description provided for @miniGamesExitTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari permainan?'**
  String get miniGamesExitTitle;

  /// No description provided for @miniGamesExitBody.
  ///
  /// In id, this message translates to:
  /// **'Progres permainan saat ini akan diulang saat kamu keluar.'**
  String get miniGamesExitBody;

  /// No description provided for @miniGamesExitStay.
  ///
  /// In id, this message translates to:
  /// **'Tetap bermain'**
  String get miniGamesExitStay;

  /// No description provided for @miniGamesExitConfirm.
  ///
  /// In id, this message translates to:
  /// **'Keluar & ulangi'**
  String get miniGamesExitConfirm;

  /// No description provided for @miniGamesStart.
  ///
  /// In id, this message translates to:
  /// **'Mulai permainan'**
  String get miniGamesStart;

  /// No description provided for @miniGamesDifficultyLabel.
  ///
  /// In id, this message translates to:
  /// **'Pilih tingkat kesulitan'**
  String get miniGamesDifficultyLabel;

  /// No description provided for @miniGamesPieceCount.
  ///
  /// In id, this message translates to:
  /// **'{count} keping'**
  String miniGamesPieceCount(int count);

  /// No description provided for @miniGamesPairCount.
  ///
  /// In id, this message translates to:
  /// **'{pairs} pasang · {cards} kartu'**
  String miniGamesPairCount(int pairs, int cards);

  /// No description provided for @miniGamesMoves.
  ///
  /// In id, this message translates to:
  /// **'Langkah'**
  String get miniGamesMoves;

  /// No description provided for @miniGamesPieces.
  ///
  /// In id, this message translates to:
  /// **'Keping'**
  String get miniGamesPieces;

  /// No description provided for @miniGamesTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get miniGamesTime;

  /// No description provided for @miniGamesPairs.
  ///
  /// In id, this message translates to:
  /// **'Pasangan'**
  String get miniGamesPairs;

  /// No description provided for @miniGamesReset.
  ///
  /// In id, this message translates to:
  /// **'Atur ulang'**
  String get miniGamesReset;

  /// No description provided for @miniGamesShuffle.
  ///
  /// In id, this message translates to:
  /// **'Acak'**
  String get miniGamesShuffle;

  /// No description provided for @miniGamesChangeChallenge.
  ///
  /// In id, this message translates to:
  /// **'Ubah tantangan'**
  String get miniGamesChangeChallenge;

  /// No description provided for @miniGamesChangeDifficulty.
  ///
  /// In id, this message translates to:
  /// **'Ubah kesulitan'**
  String get miniGamesChangeDifficulty;

  /// No description provided for @miniGamesPictureReadyTitle.
  ///
  /// In id, this message translates to:
  /// **'Siapkan puzzlemu'**
  String get miniGamesPictureReadyTitle;

  /// No description provided for @miniGamesPictureReadyDescription.
  ///
  /// In id, this message translates to:
  /// **'Pilih gambar dan ukuran papan sebelum mulai bermain.'**
  String get miniGamesPictureReadyDescription;

  /// No description provided for @miniGamesPictureImageChoiceLabel.
  ///
  /// In id, this message translates to:
  /// **'Pilih gambar'**
  String get miniGamesPictureImageChoiceLabel;

  /// No description provided for @miniGamesPictureReferenceLabel.
  ///
  /// In id, this message translates to:
  /// **'Gambar referensi'**
  String get miniGamesPictureReferenceLabel;

  /// No description provided for @miniGamesPictureCompleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Puzzle selesai'**
  String get miniGamesPictureCompleteTitle;

  /// No description provided for @miniGamesPictureCompleteDescription.
  ///
  /// In id, this message translates to:
  /// **'Kamu menyusun gambar dalam {moves} langkah dan {time}.'**
  String miniGamesPictureCompleteDescription(int moves, String time);

  /// No description provided for @miniGamesPictureStudyCorner.
  ///
  /// In id, this message translates to:
  /// **'Sudut belajar'**
  String get miniGamesPictureStudyCorner;

  /// No description provided for @miniGamesPictureFruitMarket.
  ///
  /// In id, this message translates to:
  /// **'Pasar buah'**
  String get miniGamesPictureFruitMarket;

  /// No description provided for @miniGamesPictureBerryGarden.
  ///
  /// In id, this message translates to:
  /// **'Kebun beri'**
  String get miniGamesPictureBerryGarden;

  /// No description provided for @miniGamesPictureTropicalPlatter.
  ///
  /// In id, this message translates to:
  /// **'Hidangan tropis'**
  String get miniGamesPictureTropicalPlatter;

  /// No description provided for @miniGamesPictureOrchardBasket.
  ///
  /// In id, this message translates to:
  /// **'Keranjang kebun'**
  String get miniGamesPictureOrchardBasket;

  /// No description provided for @miniGamesPictureCitrusTable.
  ///
  /// In id, this message translates to:
  /// **'Meja sitrus'**
  String get miniGamesPictureCitrusTable;

  /// No description provided for @miniGamesTwinReadyTitle.
  ///
  /// In id, this message translates to:
  /// **'Siap melacak pasangan?'**
  String get miniGamesTwinReadyTitle;

  /// No description provided for @miniGamesTwinReadyDescription.
  ///
  /// In id, this message translates to:
  /// **'Pilih ukuran papan, ingat kartunya, lalu temukan semua pasangan.'**
  String get miniGamesTwinReadyDescription;

  /// No description provided for @miniGamesTwinCompleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Semua pasangan ditemukan'**
  String get miniGamesTwinCompleteTitle;

  /// No description provided for @miniGamesTwinCompleteDescription.
  ///
  /// In id, this message translates to:
  /// **'Kamu menemukan semua pasangan dalam {moves} langkah dan {time}.'**
  String miniGamesTwinCompleteDescription(int moves, String time);

  /// No description provided for @miniGamesTwinHiddenCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu tersembunyi {position}'**
  String miniGamesTwinHiddenCard(int position);

  /// No description provided for @miniGamesTwinRevealedCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu {position}, {fruit}'**
  String miniGamesTwinRevealedCard(int position, String fruit);

  /// No description provided for @miniGamesTwinMatchedCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu cocok {position}, {fruit}'**
  String miniGamesTwinMatchedCard(int position, String fruit);

  /// No description provided for @miniGamesTwinApple.
  ///
  /// In id, this message translates to:
  /// **'Apel'**
  String get miniGamesTwinApple;

  /// No description provided for @miniGamesTwinBanana.
  ///
  /// In id, this message translates to:
  /// **'Pisang'**
  String get miniGamesTwinBanana;

  /// No description provided for @miniGamesTwinOrange.
  ///
  /// In id, this message translates to:
  /// **'Jeruk'**
  String get miniGamesTwinOrange;

  /// No description provided for @miniGamesTwinKiwi.
  ///
  /// In id, this message translates to:
  /// **'Kiwi'**
  String get miniGamesTwinKiwi;

  /// No description provided for @miniGamesTwinBlueberry.
  ///
  /// In id, this message translates to:
  /// **'Blueberi'**
  String get miniGamesTwinBlueberry;

  /// No description provided for @miniGamesTwinGrapes.
  ///
  /// In id, this message translates to:
  /// **'Anggur'**
  String get miniGamesTwinGrapes;

  /// No description provided for @miniGamesTwinDragonfruit.
  ///
  /// In id, this message translates to:
  /// **'Buah naga'**
  String get miniGamesTwinDragonfruit;

  /// No description provided for @miniGamesTwinPineapple.
  ///
  /// In id, this message translates to:
  /// **'Nanas'**
  String get miniGamesTwinPineapple;

  /// No description provided for @miniGamesTwinCoconut.
  ///
  /// In id, this message translates to:
  /// **'Kelapa'**
  String get miniGamesTwinCoconut;

  /// No description provided for @miniGamesTwinPeach.
  ///
  /// In id, this message translates to:
  /// **'Persik'**
  String get miniGamesTwinPeach;

  /// No description provided for @miniGamesTwinPear.
  ///
  /// In id, this message translates to:
  /// **'Pir'**
  String get miniGamesTwinPear;

  /// No description provided for @miniGamesTwinWatermelon.
  ///
  /// In id, this message translates to:
  /// **'Semangka'**
  String get miniGamesTwinWatermelon;

  /// No description provided for @miniGamesSpectrumResult.
  ///
  /// In id, this message translates to:
  /// **'Kamu mengenali {correct} dari {total} warna tinta.'**
  String miniGamesSpectrumResult(int correct, int total);

  /// No description provided for @miniGamesPictureResult.
  ///
  /// In id, this message translates to:
  /// **'Gambar sudah tersusun kembali.'**
  String get miniGamesPictureResult;

  /// No description provided for @miniGamesTwinResult.
  ///
  /// In id, this message translates to:
  /// **'Kamu menemukan semua pasangan yang sama.'**
  String get miniGamesTwinResult;

  /// No description provided for @miniGamesBrainResult.
  ///
  /// In id, this message translates to:
  /// **'Kamu menjawab benar {correct} dari {total} pertanyaan.'**
  String miniGamesBrainResult(int correct, int total);

  /// No description provided for @miniGamesBrainEverestQ.
  ///
  /// In id, this message translates to:
  /// **'Gunung tertinggi di atas permukaan laut adalah?'**
  String get miniGamesBrainEverestQ;

  /// No description provided for @miniGamesBrainEverestA.
  ///
  /// In id, this message translates to:
  /// **'Gunung Everest'**
  String get miniGamesBrainEverestA;

  /// No description provided for @miniGamesBrainEverestB.
  ///
  /// In id, this message translates to:
  /// **'K2'**
  String get miniGamesBrainEverestB;

  /// No description provided for @miniGamesBrainEverestC.
  ///
  /// In id, this message translates to:
  /// **'Kilimanjaro'**
  String get miniGamesBrainEverestC;

  /// No description provided for @miniGamesBrainEverestD.
  ///
  /// In id, this message translates to:
  /// **'Denali'**
  String get miniGamesBrainEverestD;

  /// No description provided for @miniGamesBrainPacificQ.
  ///
  /// In id, this message translates to:
  /// **'Samudra terbesar di Bumi adalah?'**
  String get miniGamesBrainPacificQ;

  /// No description provided for @miniGamesBrainPacificA.
  ///
  /// In id, this message translates to:
  /// **'Samudra Pasifik'**
  String get miniGamesBrainPacificA;

  /// No description provided for @miniGamesBrainPacificB.
  ///
  /// In id, this message translates to:
  /// **'Samudra Atlantik'**
  String get miniGamesBrainPacificB;

  /// No description provided for @miniGamesBrainPacificC.
  ///
  /// In id, this message translates to:
  /// **'Samudra Hindia'**
  String get miniGamesBrainPacificC;

  /// No description provided for @miniGamesBrainPacificD.
  ///
  /// In id, this message translates to:
  /// **'Samudra Arktik'**
  String get miniGamesBrainPacificD;

  /// No description provided for @miniGamesBrainTokyoQ.
  ///
  /// In id, this message translates to:
  /// **'Ibu kota Jepang adalah?'**
  String get miniGamesBrainTokyoQ;

  /// No description provided for @miniGamesBrainTokyoA.
  ///
  /// In id, this message translates to:
  /// **'Tokyo'**
  String get miniGamesBrainTokyoA;

  /// No description provided for @miniGamesBrainTokyoB.
  ///
  /// In id, this message translates to:
  /// **'Kyoto'**
  String get miniGamesBrainTokyoB;

  /// No description provided for @miniGamesBrainTokyoC.
  ///
  /// In id, this message translates to:
  /// **'Osaka'**
  String get miniGamesBrainTokyoC;

  /// No description provided for @miniGamesBrainTokyoD.
  ///
  /// In id, this message translates to:
  /// **'Sapporo'**
  String get miniGamesBrainTokyoD;

  /// No description provided for @miniGamesBrainGizaQ.
  ///
  /// In id, this message translates to:
  /// **'Piramida Agung Giza berada di negara?'**
  String get miniGamesBrainGizaQ;

  /// No description provided for @miniGamesBrainGizaA.
  ///
  /// In id, this message translates to:
  /// **'Mesir'**
  String get miniGamesBrainGizaA;

  /// No description provided for @miniGamesBrainGizaB.
  ///
  /// In id, this message translates to:
  /// **'Yordania'**
  String get miniGamesBrainGizaB;

  /// No description provided for @miniGamesBrainGizaC.
  ///
  /// In id, this message translates to:
  /// **'Maroko'**
  String get miniGamesBrainGizaC;

  /// No description provided for @miniGamesBrainGizaD.
  ///
  /// In id, this message translates to:
  /// **'Turki'**
  String get miniGamesBrainGizaD;

  /// No description provided for @miniGamesBrainJupiterQ.
  ///
  /// In id, this message translates to:
  /// **'Planet terbesar dalam tata surya adalah?'**
  String get miniGamesBrainJupiterQ;

  /// No description provided for @miniGamesBrainJupiterA.
  ///
  /// In id, this message translates to:
  /// **'Jupiter'**
  String get miniGamesBrainJupiterA;

  /// No description provided for @miniGamesBrainJupiterB.
  ///
  /// In id, this message translates to:
  /// **'Saturnus'**
  String get miniGamesBrainJupiterB;

  /// No description provided for @miniGamesBrainJupiterC.
  ///
  /// In id, this message translates to:
  /// **'Bumi'**
  String get miniGamesBrainJupiterC;

  /// No description provided for @miniGamesBrainJupiterD.
  ///
  /// In id, this message translates to:
  /// **'Neptunus'**
  String get miniGamesBrainJupiterD;

  /// No description provided for @miniGamesBrainMarsQ.
  ///
  /// In id, this message translates to:
  /// **'Planet yang dikenal sebagai Planet Merah adalah?'**
  String get miniGamesBrainMarsQ;

  /// No description provided for @miniGamesBrainMarsA.
  ///
  /// In id, this message translates to:
  /// **'Mars'**
  String get miniGamesBrainMarsA;

  /// No description provided for @miniGamesBrainMarsB.
  ///
  /// In id, this message translates to:
  /// **'Venus'**
  String get miniGamesBrainMarsB;

  /// No description provided for @miniGamesBrainMarsC.
  ///
  /// In id, this message translates to:
  /// **'Merkurius'**
  String get miniGamesBrainMarsC;

  /// No description provided for @miniGamesBrainMarsD.
  ///
  /// In id, this message translates to:
  /// **'Uranus'**
  String get miniGamesBrainMarsD;

  /// No description provided for @miniGamesBrainCarbonQ.
  ///
  /// In id, this message translates to:
  /// **'Gas dengan rumus CO₂ adalah?'**
  String get miniGamesBrainCarbonQ;

  /// No description provided for @miniGamesBrainCarbonA.
  ///
  /// In id, this message translates to:
  /// **'Karbon dioksida'**
  String get miniGamesBrainCarbonA;

  /// No description provided for @miniGamesBrainCarbonB.
  ///
  /// In id, this message translates to:
  /// **'Oksigen'**
  String get miniGamesBrainCarbonB;

  /// No description provided for @miniGamesBrainCarbonC.
  ///
  /// In id, this message translates to:
  /// **'Nitrogen'**
  String get miniGamesBrainCarbonC;

  /// No description provided for @miniGamesBrainCarbonD.
  ///
  /// In id, this message translates to:
  /// **'Hidrogen'**
  String get miniGamesBrainCarbonD;

  /// No description provided for @miniGamesBrainHeartQ.
  ///
  /// In id, this message translates to:
  /// **'Organ yang memompa darah ke seluruh tubuh adalah?'**
  String get miniGamesBrainHeartQ;

  /// No description provided for @miniGamesBrainHeartA.
  ///
  /// In id, this message translates to:
  /// **'Jantung'**
  String get miniGamesBrainHeartA;

  /// No description provided for @miniGamesBrainHeartB.
  ///
  /// In id, this message translates to:
  /// **'Paru-paru'**
  String get miniGamesBrainHeartB;

  /// No description provided for @miniGamesBrainHeartC.
  ///
  /// In id, this message translates to:
  /// **'Hati'**
  String get miniGamesBrainHeartC;

  /// No description provided for @miniGamesBrainHeartD.
  ///
  /// In id, this message translates to:
  /// **'Ginjal'**
  String get miniGamesBrainHeartD;

  /// No description provided for @miniGamesBrainIndependenceQ.
  ///
  /// In id, this message translates to:
  /// **'Pada tahun berapa Indonesia memproklamasikan kemerdekaan?'**
  String get miniGamesBrainIndependenceQ;

  /// No description provided for @miniGamesBrainIndependenceA.
  ///
  /// In id, this message translates to:
  /// **'1945'**
  String get miniGamesBrainIndependenceA;

  /// No description provided for @miniGamesBrainIndependenceB.
  ///
  /// In id, this message translates to:
  /// **'1942'**
  String get miniGamesBrainIndependenceB;

  /// No description provided for @miniGamesBrainIndependenceC.
  ///
  /// In id, this message translates to:
  /// **'1949'**
  String get miniGamesBrainIndependenceC;

  /// No description provided for @miniGamesBrainIndependenceD.
  ///
  /// In id, this message translates to:
  /// **'1950'**
  String get miniGamesBrainIndependenceD;

  /// No description provided for @miniGamesBrainBorobudurQ.
  ///
  /// In id, this message translates to:
  /// **'Candi Borobudur berada di provinsi?'**
  String get miniGamesBrainBorobudurQ;

  /// No description provided for @miniGamesBrainBorobudurA.
  ///
  /// In id, this message translates to:
  /// **'Jawa Tengah'**
  String get miniGamesBrainBorobudurA;

  /// No description provided for @miniGamesBrainBorobudurB.
  ///
  /// In id, this message translates to:
  /// **'Jawa Timur'**
  String get miniGamesBrainBorobudurB;

  /// No description provided for @miniGamesBrainBorobudurC.
  ///
  /// In id, this message translates to:
  /// **'Jawa Barat'**
  String get miniGamesBrainBorobudurC;

  /// No description provided for @miniGamesBrainBorobudurD.
  ///
  /// In id, this message translates to:
  /// **'Bali'**
  String get miniGamesBrainBorobudurD;

  /// No description provided for @miniGamesBrainLaskarQ.
  ///
  /// In id, this message translates to:
  /// **'Siapa penulis novel Laskar Pelangi?'**
  String get miniGamesBrainLaskarQ;

  /// No description provided for @miniGamesBrainLaskarA.
  ///
  /// In id, this message translates to:
  /// **'Andrea Hirata'**
  String get miniGamesBrainLaskarA;

  /// No description provided for @miniGamesBrainLaskarB.
  ///
  /// In id, this message translates to:
  /// **'Pramoedya Ananta Toer'**
  String get miniGamesBrainLaskarB;

  /// No description provided for @miniGamesBrainLaskarC.
  ///
  /// In id, this message translates to:
  /// **'Dee Lestari'**
  String get miniGamesBrainLaskarC;

  /// No description provided for @miniGamesBrainLaskarD.
  ///
  /// In id, this message translates to:
  /// **'Tere Liye'**
  String get miniGamesBrainLaskarD;

  /// No description provided for @miniGamesBrainPancasilaQ.
  ///
  /// In id, this message translates to:
  /// **'Pancasila memiliki berapa sila?'**
  String get miniGamesBrainPancasilaQ;

  /// No description provided for @miniGamesBrainPancasilaA.
  ///
  /// In id, this message translates to:
  /// **'Lima'**
  String get miniGamesBrainPancasilaA;

  /// No description provided for @miniGamesBrainPancasilaB.
  ///
  /// In id, this message translates to:
  /// **'Tiga'**
  String get miniGamesBrainPancasilaB;

  /// No description provided for @miniGamesBrainPancasilaC.
  ///
  /// In id, this message translates to:
  /// **'Empat'**
  String get miniGamesBrainPancasilaC;

  /// No description provided for @miniGamesBrainPancasilaD.
  ///
  /// In id, this message translates to:
  /// **'Enam'**
  String get miniGamesBrainPancasilaD;

  /// No description provided for @miniGamesBrainCpuQ.
  ///
  /// In id, this message translates to:
  /// **'Komponen utama untuk memproses data pada komputer disebut?'**
  String get miniGamesBrainCpuQ;

  /// No description provided for @miniGamesBrainCpuA.
  ///
  /// In id, this message translates to:
  /// **'Prosesor'**
  String get miniGamesBrainCpuA;

  /// No description provided for @miniGamesBrainCpuB.
  ///
  /// In id, this message translates to:
  /// **'Penyimpanan'**
  String get miniGamesBrainCpuB;

  /// No description provided for @miniGamesBrainCpuC.
  ///
  /// In id, this message translates to:
  /// **'Monitor'**
  String get miniGamesBrainCpuC;

  /// No description provided for @miniGamesBrainCpuD.
  ///
  /// In id, this message translates to:
  /// **'Papan ketik'**
  String get miniGamesBrainCpuD;

  /// No description provided for @miniGamesBrainHttpsQ.
  ///
  /// In id, this message translates to:
  /// **'Apa yang dibantu oleh HTTPS pada sebuah situs?'**
  String get miniGamesBrainHttpsQ;

  /// No description provided for @miniGamesBrainHttpsA.
  ///
  /// In id, this message translates to:
  /// **'Koneksi terenkripsi'**
  String get miniGamesBrainHttpsA;

  /// No description provided for @miniGamesBrainHttpsB.
  ///
  /// In id, this message translates to:
  /// **'Gambar lebih besar'**
  String get miniGamesBrainHttpsB;

  /// No description provided for @miniGamesBrainHttpsC.
  ///
  /// In id, this message translates to:
  /// **'Akses luring'**
  String get miniGamesBrainHttpsC;

  /// No description provided for @miniGamesBrainHttpsD.
  ///
  /// In id, this message translates to:
  /// **'Prosesor lebih cepat'**
  String get miniGamesBrainHttpsD;

  /// No description provided for @miniGamesBrainBinaryQ.
  ///
  /// In id, this message translates to:
  /// **'Angka apa yang digunakan dalam sistem biner?'**
  String get miniGamesBrainBinaryQ;

  /// No description provided for @miniGamesBrainBinaryA.
  ///
  /// In id, this message translates to:
  /// **'0 dan 1'**
  String get miniGamesBrainBinaryA;

  /// No description provided for @miniGamesBrainBinaryB.
  ///
  /// In id, this message translates to:
  /// **'1 dan 2'**
  String get miniGamesBrainBinaryB;

  /// No description provided for @miniGamesBrainBinaryC.
  ///
  /// In id, this message translates to:
  /// **'A dan Z'**
  String get miniGamesBrainBinaryC;

  /// No description provided for @miniGamesBrainBinaryD.
  ///
  /// In id, this message translates to:
  /// **'0 sampai 9'**
  String get miniGamesBrainBinaryD;

  /// No description provided for @miniGamesBrainRouterQ.
  ///
  /// In id, this message translates to:
  /// **'Router utamanya digunakan untuk?'**
  String get miniGamesBrainRouterQ;

  /// No description provided for @miniGamesBrainRouterA.
  ///
  /// In id, this message translates to:
  /// **'Menghubungkan jaringan'**
  String get miniGamesBrainRouterA;

  /// No description provided for @miniGamesBrainRouterB.
  ///
  /// In id, this message translates to:
  /// **'Mencetak dokumen'**
  String get miniGamesBrainRouterB;

  /// No description provided for @miniGamesBrainRouterC.
  ///
  /// In id, this message translates to:
  /// **'Mengedit foto'**
  String get miniGamesBrainRouterC;

  /// No description provided for @miniGamesBrainRouterD.
  ///
  /// In id, this message translates to:
  /// **'Menyimpan kata sandi'**
  String get miniGamesBrainRouterD;

  /// No description provided for @tourLabel.
  ///
  /// In id, this message translates to:
  /// **'Panduan dashboard'**
  String get tourLabel;

  /// No description provided for @tourWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Dashboard kamu'**
  String get tourWelcomeTitle;

  /// No description provided for @tourWelcomeBody.
  ///
  /// In id, this message translates to:
  /// **'Ini dashboard pribadimu. Pantau status perlindungan, ritme pemulihan, dan progres hari ini dalam satu layar.'**
  String get tourWelcomeBody;

  /// No description provided for @tourHeroTitle.
  ///
  /// In id, this message translates to:
  /// **'Kesehatan proteksi'**
  String get tourHeroTitle;

  /// No description provided for @tourHeroBody.
  ///
  /// In id, this message translates to:
  /// **'Pantau apakah sistem proteksi di perangkatmu aktif dan sehat.'**
  String get tourHeroBody;

  /// No description provided for @tourProtectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Status sensor'**
  String get tourProtectionTitle;

  /// No description provided for @tourProtectionBody.
  ///
  /// In id, this message translates to:
  /// **'Cek status layanan, browser, izin aksesibilitas, dan model AI di perangkatmu.'**
  String get tourProtectionBody;

  /// No description provided for @tourFabTitle.
  ///
  /// In id, this message translates to:
  /// **'Mini games'**
  String get tourFabTitle;

  /// No description provided for @tourFabBody.
  ///
  /// In id, this message translates to:
  /// **'Tombol tengah membuka mini games penyemangat saat kamu butuh jeda.'**
  String get tourFabBody;

  /// No description provided for @tourNavTitle.
  ///
  /// In id, this message translates to:
  /// **'Navigasi cepat'**
  String get tourNavTitle;

  /// No description provided for @tourNavBody.
  ///
  /// In id, this message translates to:
  /// **'Bar bawah menempatkan menu yang paling sering dipakai dalam jangkauan ibu jari.'**
  String get tourNavBody;

  /// No description provided for @tourProfileTitle.
  ///
  /// In id, this message translates to:
  /// **'Menu profil'**
  String get tourProfileTitle;

  /// No description provided for @tourProfileBody.
  ///
  /// In id, this message translates to:
  /// **'Foto profil mengarah ke pengaturan akun dan data pribadimu.'**
  String get tourProfileBody;

  /// No description provided for @tourSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get tourSkip;

  /// No description provided for @tourBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get tourBack;

  /// No description provided for @tourNext.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get tourNext;

  /// No description provided for @tourDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get tourDone;

  /// No description provided for @tourStepOf.
  ///
  /// In id, this message translates to:
  /// **'{current} dari {total}'**
  String tourStepOf(int current, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

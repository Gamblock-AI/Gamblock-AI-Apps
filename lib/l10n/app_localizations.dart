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

  /// No description provided for @settingsAccountPreferences.
  ///
  /// In id, this message translates to:
  /// **'akun & preferensi'**
  String get settingsAccountPreferences;

  /// No description provided for @settingsOpenPsychoeducation.
  ///
  /// In id, this message translates to:
  /// **'Buka Web Psikoedukasi'**
  String get settingsOpenPsychoeducation;

  /// No description provided for @settingsLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get settingsLogout;

  /// No description provided for @roleKepala.
  ///
  /// In id, this message translates to:
  /// **'Kepala'**
  String get roleKepala;

  /// No description provided for @settingsAppVersion.
  ///
  /// In id, this message translates to:
  /// **'Gamblock AI v1.0.0'**
  String get settingsAppVersion;

  /// No description provided for @roleMember.
  ///
  /// In id, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// No description provided for @settingsManagePartner.
  ///
  /// In id, this message translates to:
  /// **'Kelola pendamping'**
  String get settingsManagePartner;

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
  /// **'Accountability Partner'**
  String get settingsAccountabilityPartner;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @protectionApprovalDesc.
  ///
  /// In id, this message translates to:
  /// **'Permohonan ini akan dikirim ke Accountability Partner Anda untuk disetujui. '**
  String get protectionApprovalDesc;

  /// No description provided for @protectionRequestUninstall.
  ///
  /// In id, this message translates to:
  /// **'Ajukan Izin Pencopotan'**
  String get protectionRequestUninstall;

  /// No description provided for @submit.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get submit;

  /// No description provided for @protectionAppLockedDesc.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi tetap terkunci sampai ada persetujuan.'**
  String get protectionAppLockedDesc;

  /// No description provided for @protectionSiteBlocked.
  ///
  /// In id, this message translates to:
  /// **'Situs judi diblokir'**
  String get protectionSiteBlocked;

  /// No description provided for @protectionRecentBlocks.
  ///
  /// In id, this message translates to:
  /// **'Blokir Terbaru'**
  String get protectionRecentBlocks;

  /// No description provided for @protectionInactive.
  ///
  /// In id, this message translates to:
  /// **'Perlindungan Nonaktif'**
  String get protectionInactive;

  /// No description provided for @protectionActiveTitle.
  ///
  /// In id, this message translates to:
  /// **'Perlindungan Aktif'**
  String get protectionActiveTitle;

  /// No description provided for @protectionActiveDays.
  ///
  /// In id, this message translates to:
  /// **'Hari Aktif'**
  String get protectionActiveDays;

  /// No description provided for @protectionMobileRequest.
  ///
  /// In id, this message translates to:
  /// **'Pengajuan dari aplikasi mobile'**
  String get protectionMobileRequest;

  /// No description provided for @protectionTotalBlocks.
  ///
  /// In id, this message translates to:
  /// **'Total Blokir'**
  String get protectionTotalBlocks;

  /// No description provided for @protectionRequestSent.
  ///
  /// In id, this message translates to:
  /// **'Permohonan dikirim. Menunggu persetujuan.'**
  String get protectionRequestSent;

  /// No description provided for @protectionDeviceProtected.
  ///
  /// In id, this message translates to:
  /// **'Perangkat ini dilindungi.'**
  String get protectionDeviceProtected;

  /// No description provided for @recoveryMoodQuestion.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana kondisi emosi Anda hari ini?'**
  String get recoveryMoodQuestion;

  /// No description provided for @recoveryLogMood.
  ///
  /// In id, this message translates to:
  /// **'Catat Mood'**
  String get recoveryLogMood;

  /// No description provided for @recoveryMoodLogged.
  ///
  /// In id, this message translates to:
  /// **'Mood tercatat'**
  String get recoveryMoodLogged;

  /// No description provided for @recoveryDailyMissions.
  ///
  /// In id, this message translates to:
  /// **'Misi Harian'**
  String get recoveryDailyMissions;

  /// No description provided for @recoveryEmptyJournalDesc.
  ///
  /// In id, this message translates to:
  /// **'Tulis refleksi pertama Anda di atas untuk memulai.'**
  String get recoveryEmptyJournalDesc;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @recoveryWriteJournal.
  ///
  /// In id, this message translates to:
  /// **'Tulis Jurnal Refleksi'**
  String get recoveryWriteJournal;

  /// No description provided for @recoveryJournalHint.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan bagaimana perasaan Anda hari ini...'**
  String get recoveryJournalHint;

  /// No description provided for @recoveryNoJournal.
  ///
  /// In id, this message translates to:
  /// **'Belum ada jurnal'**
  String get recoveryNoJournal;

  /// No description provided for @recoveryJournalHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Refleksi'**
  String get recoveryJournalHistory;

  /// No description provided for @recoveryMissionPsychoeducation.
  ///
  /// In id, this message translates to:
  /// **'Menyelesaikan 1 modul psikoedukasi'**
  String get recoveryMissionPsychoeducation;

  /// No description provided for @recoveryJournalSaved.
  ///
  /// In id, this message translates to:
  /// **'Jurnal disimpan'**
  String get recoveryJournalSaved;

  /// No description provided for @recoveryMissionNoGambling.
  ///
  /// In id, this message translates to:
  /// **'Tidak mengakses situs judi hari ini'**
  String get recoveryMissionNoGambling;

  /// No description provided for @recoveryMissionDiscussion.
  ///
  /// In id, this message translates to:
  /// **'Berdiskusi dengan pendamping'**
  String get recoveryMissionDiscussion;

  /// No description provided for @recoveryMissionMeditation.
  ///
  /// In id, this message translates to:
  /// **'Melakukan meditasi pernapasan'**
  String get recoveryMissionMeditation;

  /// No description provided for @recoveryMissionJournal.
  ///
  /// In id, this message translates to:
  /// **'Menulis 1 entri jurnal refleksi'**
  String get recoveryMissionJournal;

  /// No description provided for @recoveryTitle.
  ///
  /// In id, this message translates to:
  /// **'Pemulihan'**
  String get recoveryTitle;

  /// No description provided for @errorCreateGroup.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat grup'**
  String get errorCreateGroup;

  /// No description provided for @errorInvalidGroupCode.
  ///
  /// In id, this message translates to:
  /// **'Group code tidak valid'**
  String get errorInvalidGroupCode;

  /// No description provided for @onboardingGroupCode.
  ///
  /// In id, this message translates to:
  /// **'Kode Grup'**
  String get onboardingGroupCode;

  /// No description provided for @onboardingGroupCreated.
  ///
  /// In id, this message translates to:
  /// **'Grup Berhasil Dibuat!'**
  String get onboardingGroupCreated;

  /// No description provided for @backToLogin.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Login'**
  String get backToLogin;

  /// No description provided for @onboardingEnterGroupCode.
  ///
  /// In id, this message translates to:
  /// **'Masukkan Kode Grup'**
  String get onboardingEnterGroupCode;

  /// No description provided for @onboardingInvalidGroupCode.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode grup yang valid'**
  String get onboardingInvalidGroupCode;

  /// No description provided for @onboardingGetCodeDesc.
  ///
  /// In id, this message translates to:
  /// **'Dapatkan kode dari Dosen atau Pendamping Anda'**
  String get onboardingGetCodeDesc;

  /// No description provided for @onboardingCodeHint.
  ///
  /// In id, this message translates to:
  /// **'Kode 6 karakter'**
  String get onboardingCodeHint;

  /// No description provided for @onboardingCreateGroupTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat Grup Monitoring'**
  String get onboardingCreateGroupTitle;

  /// No description provided for @onboardingGroupName.
  ///
  /// In id, this message translates to:
  /// **'Nama Grup'**
  String get onboardingGroupName;

  /// No description provided for @onboardingCreateGroupDesc.
  ///
  /// In id, this message translates to:
  /// **'Sebagai Dosen/Pendamping, buat grup untuk mengawasi mahasiswa Anda'**
  String get onboardingCreateGroupDesc;

  /// No description provided for @errorGroupNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama grup diperlukan'**
  String get errorGroupNameRequired;

  /// No description provided for @onboardingCreateGroupBtn.
  ///
  /// In id, this message translates to:
  /// **'Buat Grup'**
  String get onboardingCreateGroupBtn;

  /// No description provided for @dashboardTitle.
  ///
  /// In id, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @onboardingGroupNameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Kelas TI-2024A'**
  String get onboardingGroupNameHint;

  /// No description provided for @patternBreatheDesc.
  ///
  /// In id, this message translates to:
  /// **'Tarik napas dalam-dalam.\\nDorongan ini akan lewat.'**
  String get patternBreatheDesc;

  /// No description provided for @patternContinuePsychoeducation.
  ///
  /// In id, this message translates to:
  /// **'Lanjut ke Psikoedukasi'**
  String get patternContinuePsychoeducation;

  /// No description provided for @patternTakeControlDesc.
  ///
  /// In id, this message translates to:
  /// **'Ambil kendali. Lanjutkan ke modul pemulihan diri.'**
  String get patternTakeControlDesc;

  /// No description provided for @patternInterruptSuccess.
  ///
  /// In id, this message translates to:
  /// **'Dorongan berhasil\\ndiputus.'**
  String get patternInterruptSuccess;

  /// No description provided for @patternInterruptActive.
  ///
  /// In id, this message translates to:
  /// **'PATTERN INTERRUPT AKTIF'**
  String get patternInterruptActive;

  /// No description provided for @dashboardWeeklyTrend.
  ///
  /// In id, this message translates to:
  /// **'Tren Mingguan'**
  String get dashboardWeeklyTrend;

  /// No description provided for @dashboardAnalytics.
  ///
  /// In id, this message translates to:
  /// **'analitik perlindungan'**
  String get dashboardAnalytics;

  /// No description provided for @dashboardViewProtectionStatus.
  ///
  /// In id, this message translates to:
  /// **'Lihat Status Proteksi'**
  String get dashboardViewProtectionStatus;

  /// No description provided for @dashboardYourProgress.
  ///
  /// In id, this message translates to:
  /// **'Perkembangan Anda.'**
  String get dashboardYourProgress;

  /// No description provided for @introHeroTitle.
  ///
  /// In id, this message translates to:
  /// **'putuskan siklus\\njudi online.'**
  String get introHeroTitle;

  /// No description provided for @introHeroDesc.
  ///
  /// In id, this message translates to:
  /// **'deteksi cerdas berbasis on-device ai, intervensi psikologis otomatis, dan rehabilitasi mandiri — untuk mahasiswa indonesia.'**
  String get introHeroDesc;

  /// No description provided for @introAiShield.
  ///
  /// In id, this message translates to:
  /// **'on-device ai shield'**
  String get introAiShield;

  /// No description provided for @introHowItWorksStep1.
  ///
  /// In id, this message translates to:
  /// **'unduh & pasang'**
  String get introHowItWorksStep1;

  /// No description provided for @introHowItWorksStep1Desc.
  ///
  /// In id, this message translates to:
  /// **'instal di android atau windows. gratis, tanpa kartu kredit.'**
  String get introHowItWorksStep1Desc;

  /// No description provided for @introHowItWorksStep3.
  ///
  /// In id, this message translates to:
  /// **'pulihkan & bangkit'**
  String get introHowItWorksStep3;

  /// No description provided for @introHowItWorksStep2.
  ///
  /// In id, this message translates to:
  /// **'deteksi otomatis'**
  String get introHowItWorksStep2;

  /// No description provided for @introHowItWorksStep3Desc.
  ///
  /// In id, this message translates to:
  /// **'pattern interrupt memutus dorongan, lalu psikoedukasi memandu pemulihan.'**
  String get introHowItWorksStep3Desc;

  /// No description provided for @introHowItWorksStep2Desc.
  ///
  /// In id, this message translates to:
  /// **'hybrid ai menganalisis dom, bow, dan pola url di latar belakang.'**
  String get introHowItWorksStep2Desc;

  /// No description provided for @introHowItWorksTitle.
  ///
  /// In id, this message translates to:
  /// **'tiga langkah\\nmenuju kendali diri.'**
  String get introHowItWorksTitle;

  /// No description provided for @introHowItWorksSubtitle.
  ///
  /// In id, this message translates to:
  /// **'cara kerja'**
  String get introHowItWorksSubtitle;

  /// No description provided for @introFeature1.
  ///
  /// In id, this message translates to:
  /// **'on-device ai & privasi'**
  String get introFeature1;

  /// No description provided for @introFeaturesTitle.
  ///
  /// In id, this message translates to:
  /// **'ekosistem yang\\nmendukung kepulihan.'**
  String get introFeaturesTitle;

  /// No description provided for @introFeature3.
  ///
  /// In id, this message translates to:
  /// **'accountability partner'**
  String get introFeature3;

  /// No description provided for @introFeature2.
  ///
  /// In id, this message translates to:
  /// **'deteksi real-time berbasis konten'**
  String get introFeature2;

  /// No description provided for @introFeature4.
  ///
  /// In id, this message translates to:
  /// **'pattern interrupt visual'**
  String get introFeature4;

  /// No description provided for @introCtaTitle.
  ///
  /// In id, this message translates to:
  /// **'ambil kendali atas\\nhidup anda, sekarang.'**
  String get introCtaTitle;

  /// No description provided for @introCtaBtn.
  ///
  /// In id, this message translates to:
  /// **'unduh sekarang'**
  String get introCtaBtn;

  /// No description provided for @introCtaDesc.
  ///
  /// In id, this message translates to:
  /// **'aplikasi gratis, 100% privat, dirancang oleh dan untuk mahasiswa indonesia. putuskan siklus kecanduan hari ini.'**
  String get introCtaDesc;

  /// No description provided for @introCrisisSubtitle.
  ///
  /// In id, this message translates to:
  /// **'darurat nasional'**
  String get introCrisisSubtitle;

  /// No description provided for @introCrisisStat1.
  ///
  /// In id, this message translates to:
  /// **'5,5 jt+'**
  String get introCrisisStat1;

  /// No description provided for @introCrisisStat1Desc.
  ///
  /// In id, this message translates to:
  /// **'konten judi ditangani sejak 2017'**
  String get introCrisisStat1Desc;

  /// No description provided for @introCrisisStat2.
  ///
  /// In id, this message translates to:
  /// **'12,3 jt'**
  String get introCrisisStat2;

  /// No description provided for @introCrisisTitle.
  ///
  /// In id, this message translates to:
  /// **'judi online bukan hiburan.\\nini krisis generasi.'**
  String get introCrisisTitle;

  /// No description provided for @introCrisisSource.
  ///
  /// In id, this message translates to:
  /// **'(PPATK 2026 · Kemkomdigi 2025)'**
  String get introCrisisSource;

  /// No description provided for @introCrisisDesc.
  ///
  /// In id, this message translates to:
  /// **'440 rb pemain usia 10–20 tahun dan 520 rb usia 21–30 tahun terlibat. mahasiswa berada di jantung krisis ini.'**
  String get introCrisisDesc;

  /// No description provided for @introCrisisStat3Desc.
  ///
  /// In id, this message translates to:
  /// **'orang tercatat deposit judi'**
  String get introCrisisStat3Desc;

  /// No description provided for @introCrisisStat2Desc.
  ///
  /// In id, this message translates to:
  /// **'perputaran dana judi online 2025'**
  String get introCrisisStat2Desc;

  /// No description provided for @introStartBtn.
  ///
  /// In id, this message translates to:
  /// **'Mulai Sekarang'**
  String get introStartBtn;

  /// No description provided for @authWelcomeBack.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang\\nkembali.'**
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

  /// No description provided for @authPassword.
  ///
  /// In id, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authEmail.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authLoginDesc.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melanjutkan perlindungan Anda.'**
  String get authLoginDesc;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat akun\\nbaru.'**
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
  /// **'Buat Akun & Lanjut ke Grup'**
  String get authRegisterAndContinue;

  /// No description provided for @roleLecturerPartner.
  ///
  /// In id, this message translates to:
  /// **'Dosen / Pendamping'**
  String get roleLecturerPartner;

  /// No description provided for @authRegisterDesc.
  ///
  /// In id, this message translates to:
  /// **'100% gratis & privat — dirancang untuk mahasiswa Indonesia.'**
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

  /// No description provided for @msgErrUpdateMission.
  ///
  /// In id, this message translates to:
  /// **'Gagal memperbarui misi harian.'**
  String get msgErrUpdateMission;

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

  /// No description provided for @msgErrLoadPsychoeducation.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat modul psikoedukasi.'**
  String get msgErrLoadPsychoeducation;

  /// No description provided for @msgErrInvalidRequest.
  ///
  /// In id, this message translates to:
  /// **'Permintaan tidak valid. Periksa kembali isian Anda.'**
  String get msgErrInvalidRequest;

  /// No description provided for @msgErrDataConflict.
  ///
  /// In id, this message translates to:
  /// **'Konflik data. Silakan muat ulang dan coba lagi.'**
  String get msgErrDataConflict;

  /// No description provided for @msgErrGroupCodeRequired.
  ///
  /// In id, this message translates to:
  /// **'Kode grup wajib diisi.'**
  String get msgErrGroupCodeRequired;

  /// No description provided for @msgErrGoogleVerification.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi Google gagal. Silakan coba lagi.'**
  String get msgErrGoogleVerification;

  /// No description provided for @msgErrInvalidSession.
  ///
  /// In id, this message translates to:
  /// **'Sesi tidak valid. Silakan masuk kembali.'**
  String get msgErrInvalidSession;

  /// No description provided for @msgErrLoadTicket.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat tiket bantuan.'**
  String get msgErrLoadTicket;

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

  /// No description provided for @msgErrServerBusy.
  ///
  /// In id, this message translates to:
  /// **'Server sedang sibuk. Silakan coba beberapa saat lagi.'**
  String get msgErrServerBusy;

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

  /// No description provided for @msgErrDataNotFound.
  ///
  /// In id, this message translates to:
  /// **'Data yang diminta tidak ditemukan.'**
  String get msgErrDataNotFound;

  /// No description provided for @msgErrGroupNotFound.
  ///
  /// In id, this message translates to:
  /// **'Grup tidak ditemukan.'**
  String get msgErrGroupNotFound;

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

  /// No description provided for @msgErrSubmitRequest.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengajukan permohonan.'**
  String get msgErrSubmitRequest;

  /// No description provided for @msgErrLoadJournal.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat jurnal refleksi.'**
  String get msgErrLoadJournal;

  /// No description provided for @msgErrInvalidEmergencyKey.
  ///
  /// In id, this message translates to:
  /// **'Kunci darurat tidak valid.'**
  String get msgErrInvalidEmergencyKey;

  /// No description provided for @msgErrCreateGroup.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat grup.'**
  String get msgErrCreateGroup;

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

  /// No description provided for @msgErrGeneric.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kendala, silakan coba beberapa saat lagi.'**
  String get msgErrGeneric;

  /// No description provided for @msgErrReleaseNotFound.
  ///
  /// In id, this message translates to:
  /// **'Rilis tidak ditemukan.'**
  String get msgErrReleaseNotFound;

  /// No description provided for @msgErrInvalidCredentials.
  ///
  /// In id, this message translates to:
  /// **'Email atau kata sandi salah. Silakan periksa kembali.'**
  String get msgErrInvalidCredentials;

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

  /// No description provided for @msgErrModuleNotFound.
  ///
  /// In id, this message translates to:
  /// **'Modul tidak ditemukan.'**
  String get msgErrModuleNotFound;

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

  /// No description provided for @msgErrSendTicket.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengirim tiket bantuan.'**
  String get msgErrSendTicket;

  /// No description provided for @msgErrLogout.
  ///
  /// In id, this message translates to:
  /// **'Gagal keluar. Silakan coba lagi.'**
  String get msgErrLogout;

  /// No description provided for @msgErrLoadMembers.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat daftar anggota.'**
  String get msgErrLoadMembers;

  /// No description provided for @msgErrEmailNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Email dan nama wajib diisi.'**
  String get msgErrEmailNameRequired;

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

  /// No description provided for @msgErrUnauthorized.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak memiliki izin untuk aksi ini.'**
  String get msgErrUnauthorized;

  /// No description provided for @msgErrSendInvite.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengirim undangan pendamping.'**
  String get msgErrSendInvite;

  /// No description provided for @msgErrDevLogin.
  ///
  /// In id, this message translates to:
  /// **'Gagal masuk sebagai pengguna demo.'**
  String get msgErrDevLogin;

  /// No description provided for @msgErrGoogleTokenRequired.
  ///
  /// In id, this message translates to:
  /// **'Token Google wajib diisi.'**
  String get msgErrGoogleTokenRequired;

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

  /// No description provided for @msgErrActionRequired.
  ///
  /// In id, this message translates to:
  /// **'Jenis tindakan wajib dipilih.'**
  String get msgErrActionRequired;

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

  /// No description provided for @msgErrLoadAdminModules.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat modul admin.'**
  String get msgErrLoadAdminModules;

  /// No description provided for @msgErrLoadAdminModelReleases.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat rilis model.'**
  String get msgErrLoadAdminModelReleases;

  /// No description provided for @msgErrLoadAdminSupportCases.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat tiket admin.'**
  String get msgErrLoadAdminSupportCases;

  /// No description provided for @msgErrCreateModelRelease.
  ///
  /// In id, this message translates to:
  /// **'Gagal merilis model.'**
  String get msgErrCreateModelRelease;

  /// No description provided for @msgErrCreateRulesetRelease.
  ///
  /// In id, this message translates to:
  /// **'Gagal merilis ruleset.'**
  String get msgErrCreateRulesetRelease;

  /// No description provided for @msgErrCreateNetworkRelease.
  ///
  /// In id, this message translates to:
  /// **'Gagal merilis ruleset jaringan.'**
  String get msgErrCreateNetworkRelease;

  /// No description provided for @msgErrEmergencyKeyRequired.
  ///
  /// In id, this message translates to:
  /// **'Kunci darurat wajib diisi.'**
  String get msgErrEmergencyKeyRequired;
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

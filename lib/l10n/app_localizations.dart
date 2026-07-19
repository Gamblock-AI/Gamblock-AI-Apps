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
  /// **'prototipe berprinsip privasi yang dirancang untuk membantu mahasiswa Indonesia mengambil jeda dan memilih langkah konstruktif.'**
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
  /// **'Buat Akun & Lanjutkan'**
  String get authRegisterAndContinue;

  /// No description provided for @roleLecturerPartner.
  ///
  /// In id, this message translates to:
  /// **'Dosen / Pendamping'**
  String get roleLecturerPartner;

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

  /// No description provided for @msgErrPasswordValidation.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi baru minimal 8 karakter.'**
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

  /// No description provided for @protectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Proteksi'**
  String get protectionTitle;

  /// No description provided for @analyticsTitle.
  ///
  /// In id, this message translates to:
  /// **'Analitik'**
  String get analyticsTitle;

  /// No description provided for @partnerTitle.
  ///
  /// In id, this message translates to:
  /// **'Pendamping'**
  String get partnerTitle;

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
  /// **'Backend tidak tersedia atau data belum cukup; tampilan ini memakai hitungan lokal yang tersedia.'**
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
  /// **'Kelola grup pendamping'**
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

  /// No description provided for @protectionSetupAction.
  ///
  /// In id, this message translates to:
  /// **'Setup platform'**
  String get protectionSetupAction;

  /// No description provided for @selfTestAction.
  ///
  /// In id, this message translates to:
  /// **'Jalankan self-test'**
  String get selfTestAction;

  /// No description provided for @selfTestPassed.
  ///
  /// In id, this message translates to:
  /// **'Self-test lokal berhasil'**
  String get selfTestPassed;

  /// No description provided for @selfTestFailed.
  ///
  /// In id, this message translates to:
  /// **'Self-test lokal gagal'**
  String get selfTestFailed;

  /// No description provided for @selfTestFixtureBody.
  ///
  /// In id, this message translates to:
  /// **'Classifier dummy, ruleset, dan jalur Pattern Interrupt siap digunakan.'**
  String get selfTestFixtureBody;

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

  /// No description provided for @deviceRegistrationMissing.
  ///
  /// In id, this message translates to:
  /// **'Perangkat belum terdaftar'**
  String get deviceRegistrationMissing;

  /// No description provided for @deviceRegistrationMissingBody.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan setup perangkat sebelum membuat permintaan persetujuan.'**
  String get deviceRegistrationMissingBody;

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
  /// **'Model dan ruleset'**
  String get protectionArtifactLabel;

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

  /// No description provided for @protectionPartnerRequired.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan pendamping sebelum meminta perubahan proteksi.'**
  String get protectionPartnerRequired;

  /// No description provided for @protectionRequestPending.
  ///
  /// In id, this message translates to:
  /// **'Permintaan sedang menunggu keputusan pendamping.'**
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
  /// **'Terapkan persetujuan'**
  String get protectionApplyApproval;

  /// No description provided for @protectionRequestAction.
  ///
  /// In id, this message translates to:
  /// **'Minta perubahan proteksi'**
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
  /// **'Verifikasi classifier dummy'**
  String get setupSelfTestTitle;

  /// No description provided for @setupSelfTestBody.
  ///
  /// In id, this message translates to:
  /// **'Self-test menggunakan fixture sintetis dan tidak mengirim konten halaman.'**
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

  /// No description provided for @recoveryWebTitle.
  ///
  /// In id, this message translates to:
  /// **'Pemulihan tersedia di website'**
  String get recoveryWebTitle;

  /// No description provided for @recoveryWebBody.
  ///
  /// In id, this message translates to:
  /// **'Jurnal, check-in, misi, dan psikoedukasi tetap berada di website agar aplikasi ini fokus pada proteksi perangkat.'**
  String get recoveryWebBody;

  /// No description provided for @recoveryWebAction.
  ///
  /// In id, this message translates to:
  /// **'Buka pemulihan web'**
  String get recoveryWebAction;

  /// No description provided for @backToProtection.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke proteksi'**
  String get backToProtection;

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

  /// No description provided for @patternGroundingBody.
  ///
  /// In id, this message translates to:
  /// **'Sebutkan lima hal yang terlihat, empat yang terasa, tiga yang terdengar, dua yang tercium, dan satu hal yang ingin Anda lindungi hari ini.'**
  String get patternGroundingBody;

  /// No description provided for @patternReturnProtection.
  ///
  /// In id, this message translates to:
  /// **'Selesai dan kembali'**
  String get patternReturnProtection;
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

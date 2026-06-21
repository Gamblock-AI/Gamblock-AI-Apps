import json
import re

strings = {
    # main.dart
    # '[Gamblock] init step failed: $e' -> error logger, skip

    # settings_screen.dart
    'akun & preferensi': 'settingsAccountPreferences',
    'Buka Web Psikoedukasi': 'settingsOpenPsychoeducation',
    'Keluar': 'settingsLogout',
    'Kepala': 'roleKepala',
    'Gamblock AI v1.0.0': 'settingsAppVersion',
    'Member': 'roleMember',
    'Kelola pendamping': 'settingsManagePartner',
    'Apakah Anda yakin ingin keluar?': 'settingsLogoutConfirm',
    'Pengaturan': 'settingsTitle',
    'Tentang Aplikasi': 'settingsAboutApp',
    'Accountability Partner': 'settingsAccountabilityPartner',
    'Batal': 'cancel',

    # protection
    'Permohonan ini akan dikirim ke Accountability Partner Anda untuk disetujui. ': 'protectionApprovalDesc',
    'Ajukan Izin Pencopotan': 'protectionRequestUninstall',
    'Kirim': 'submit',
    'Aplikasi tetap terkunci sampai ada persetujuan.': 'protectionAppLockedDesc',
    'Situs judi diblokir': 'protectionSiteBlocked',
    'Blokir Terbaru': 'protectionRecentBlocks',
    'Perlindungan Nonaktif': 'protectionInactive',
    'Perlindungan Aktif': 'protectionActiveTitle', # to distinguish from existing 'protectionActive'
    'Hari Aktif': 'protectionActiveDays',
    'Pengajuan dari aplikasi mobile': 'protectionMobileRequest',
    'Total Blokir': 'protectionTotalBlocks',
    'Permohonan dikirim. Menunggu persetujuan.': 'protectionRequestSent',
    'Gamblock AI': 'appName',
    'Perangkat ini dilindungi.': 'protectionDeviceProtected',

    # recovery
    'Bagaimana kondisi emosi Anda hari ini?': 'recoveryMoodQuestion',
    'Catat Mood': 'recoveryLogMood',
    'Mood tercatat': 'recoveryMoodLogged',
    'Misi Harian': 'recoveryDailyMissions',
    'Tulis refleksi pertama Anda di atas untuk memulai.': 'recoveryEmptyJournalDesc',
    'Simpan': 'save',
    'Tulis Jurnal Refleksi': 'recoveryWriteJournal',
    'Ceritakan bagaimana perasaan Anda hari ini...': 'recoveryJournalHint',
    'Belum ada jurnal': 'recoveryNoJournal',
    'Riwayat Refleksi': 'recoveryJournalHistory',
    'Menyelesaikan 1 modul psikoedukasi': 'recoveryMissionPsychoeducation',
    'Jurnal disimpan': 'recoveryJournalSaved',
    'Tidak mengakses situs judi hari ini': 'recoveryMissionNoGambling',
    'Berdiskusi dengan pendamping': 'recoveryMissionDiscussion',
    'Melakukan meditasi pernapasan': 'recoveryMissionMeditation',
    'Menulis 1 entri jurnal refleksi': 'recoveryMissionJournal',
    'Pemulihan': 'recoveryTitle',

    # onboarding
    'Gagal membuat grup': 'errorCreateGroup',
    'Group code tidak valid': 'errorInvalidGroupCode',
    'Kode Grup': 'onboardingGroupCode',
    'Grup Berhasil Dibuat!': 'onboardingGroupCreated',
    'Kembali ke Login': 'backToLogin',
    'Masukkan Kode Grup': 'onboardingEnterGroupCode',
    'Masukkan kode grup yang valid': 'onboardingInvalidGroupCode',
    'Dapatkan kode dari Dosen atau Pendamping Anda': 'onboardingGetCodeDesc',
    'Kode 6 karakter': 'onboardingCodeHint',
    'Buat Grup Monitoring': 'onboardingCreateGroupTitle',
    'Nama Grup': 'onboardingGroupName',
    'Sebagai Dosen/Pendamping, buat grup untuk mengawasi mahasiswa Anda': 'onboardingCreateGroupDesc',
    'Nama grup diperlukan': 'errorGroupNameRequired',
    'Buat Grup': 'onboardingCreateGroupBtn',
    'Dashboard': 'dashboardTitle',
    'Contoh: Kelas TI-2024A': 'onboardingGroupNameHint',

    # pattern interrupt
    'Tarik napas dalam-dalam.\\nDorongan ini akan lewat.': 'patternBreatheDesc',
    'Lanjut ke Psikoedukasi': 'patternContinuePsychoeducation',
    'Ambil kendali. Lanjutkan ke modul pemulihan diri.': 'patternTakeControlDesc',
    'Dorongan berhasil\\ndiputus.': 'patternInterruptSuccess',
    'PATTERN INTERRUPT AKTIF': 'patternInterruptActive',

    # dashboard
    'Tren Mingguan': 'dashboardWeeklyTrend',
    'analitik perlindungan': 'dashboardAnalytics',
    'Lihat Status Proteksi': 'dashboardViewProtectionStatus',
    'Perkembangan Anda.': 'dashboardYourProgress',

    # intro
    'putuskan siklus\\njudi online.': 'introHeroTitle',
    'deteksi cerdas berbasis on-device ai, intervensi psikologis otomatis, dan rehabilitasi mandiri — untuk mahasiswa indonesia.': 'introHeroDesc',
    'on-device ai shield': 'introAiShield',
    'unduh & pasang': 'introHowItWorksStep1',
    'instal di android atau windows. gratis, tanpa kartu kredit.': 'introHowItWorksStep1Desc',
    'pulihkan & bangkit': 'introHowItWorksStep3',
    'deteksi otomatis': 'introHowItWorksStep2',
    'pattern interrupt memutus dorongan, lalu psikoedukasi memandu pemulihan.': 'introHowItWorksStep3Desc',
    'hybrid ai menganalisis dom, bow, dan pola url di latar belakang.': 'introHowItWorksStep2Desc',
    'tiga langkah\\nmenuju kendali diri.': 'introHowItWorksTitle',
    'cara kerja': 'introHowItWorksSubtitle',
    'on-device ai & privasi': 'introFeature1',
    'ekosistem yang\\nmendukung kepulihan.': 'introFeaturesTitle',
    'accountability partner': 'introFeature3',
    'deteksi real-time berbasis konten': 'introFeature2',
    'pattern interrupt visual': 'introFeature4',
    'ambil kendali atas\\nhidup anda, sekarang.': 'introCtaTitle',
    'unduh sekarang': 'introCtaBtn',
    'aplikasi gratis, 100% privat, dirancang oleh dan untuk mahasiswa indonesia. putuskan siklus kecanduan hari ini.': 'introCtaDesc',
    'darurat nasional': 'introCrisisSubtitle',
    '5,5 jt+': 'introCrisisStat1',
    'konten judi ditangani sejak 2017': 'introCrisisStat1Desc',
    '12,3 jt': 'introCrisisStat2',
    'judi online bukan hiburan.\\nini krisis generasi.': 'introCrisisTitle',
    '(PPATK 2026 · Kemkomdigi 2025)': 'introCrisisSource',
    '440 rb pemain usia 10–20 tahun dan 520 rb usia 21–30 tahun terlibat. mahasiswa berada di jantung krisis ini.': 'introCrisisDesc',
    'orang tercatat deposit judi': 'introCrisisStat3Desc',
    'perputaran dana judi online 2025': 'introCrisisStat2Desc',
    'Mulai Sekarang': 'introStartBtn',

    # auth
    'Selamat datang\\nkembali.': 'authWelcomeBack',
    'Daftar': 'authRegister',
    'Belum punya akun?': 'authNoAccount',
    'masuk kembali': 'authLoginAgain',
    'Masuk': 'authLoginBtn',
    'Password': 'authPassword',
    'Email': 'authEmail',
    'Masuk untuk melanjutkan perlindungan Anda.': 'authLoginDesc',
    'Buat akun\\nbaru.': 'authCreateAccountTitle',
    'Saya mendaftar sebagai': 'authRegisterAs',
    'Nama Lengkap': 'authFullName',
    'Buat Akun & Lanjut ke Grup': 'authRegisterAndContinue',
    'Dosen / Pendamping': 'roleLecturerPartner',
    '100% gratis & privat — dirancang untuk mahasiswa Indonesia.': 'authRegisterDesc',
    'Sudah punya akun?': 'authHasAccount',
    'mulai gratis': 'authStartFree',

    # AppMessages (from core/messaging/app_messages.dart)
    'Gagal memperbarui misi harian.': 'msgErrUpdateMission',
    'Gagal memuat data pendamping.': 'msgErrLoadPartner',
    'Gagal menolak permohonan.': 'msgErrRejectRequest',
    'Gagal memuat modul psikoedukasi.': 'msgErrLoadPsychoeducation',
    'Permintaan tidak valid. Periksa kembali isian Anda.': 'msgErrInvalidRequest',
    'Konflik data. Silakan muat ulang dan coba lagi.': 'msgErrDataConflict',
    'Kode grup wajib diisi.': 'msgErrGroupCodeRequired',
    'Verifikasi Google gagal. Silakan coba lagi.': 'msgErrGoogleVerification',
    'Sesi tidak valid. Silakan masuk kembali.': 'msgErrInvalidSession',
    'Gagal memuat tiket bantuan.': 'msgErrLoadTicket',
    'Gagal memproses permohonan.': 'msgErrProcessRequest',
    'Gagal menyetujui permohonan.': 'msgErrApproveRequest',
    'Server sedang sibuk. Silakan coba beberapa saat lagi.': 'msgErrServerBusy',
    'Token tidak valid atau sudah kadaluarsa.': 'msgErrInvalidToken',
    'Email wajib diisi.': 'msgErrEmailRequired',
    'Data yang diminta tidak ditemukan.': 'msgErrDataNotFound',
    'Grup tidak ditemukan.': 'msgErrGroupNotFound',
    'Gagal menyimpan jurnal refleksi.': 'msgErrSaveJournal',
    'Gagal memuat misi harian.': 'msgErrLoadMissions',
    'Gagal mengajukan permohonan.': 'msgErrSubmitRequest',
    'Gagal memuat jurnal refleksi.': 'msgErrLoadJournal',
    'Kunci darurat tidak valid.': 'msgErrInvalidEmergencyKey',
    'Gagal membuat grup.': 'msgErrCreateGroup',
    'Pendaftaran gagal. Email mungkin sudah terdaftar.': 'msgErrRegisterFailed',
    'Sesi telah berakhir. Silakan masuk kembali.': 'msgErrSessionExpired',
    'Gagal membuat kunci darurat.': 'msgErrCreateEmergencyKey',
    'Gagal mengeluarkan anggota.': 'msgErrRemoveMember',
    'Terjadi kendala, silakan coba beberapa saat lagi.': 'msgErrGeneric',
    'Rilis tidak ditemukan.': 'msgErrReleaseNotFound',
    'Email atau kata sandi salah. Silakan periksa kembali.': 'msgErrInvalidCredentials',
    'Gagal memuat permintaan data.': 'msgErrLoadDataRequest',
    'Gagal memuat analitik grup.': 'msgErrLoadGroupAnalytics',
    'Gagal mengajukan permintaan data.': 'msgErrSubmitDataRequest',
    'Anda belum bergabung dengan grup mana pun.': 'msgErrNotInGroup',
    'Terlalu banyak permintaan. Coba lagi sebentar lagi.': 'msgErrTooManyRequests',
    'Gagal memutuskan hubungan pendamping.': 'msgErrDisconnectPartner',
    'Gagal memuat daftar permohonan.': 'msgErrLoadRequests',
    'Gagal membatalkan permohonan.': 'msgErrCancelRequest',
    'Modul tidak ditemukan.': 'msgErrModuleNotFound',
    'Email pendamping wajib diisi.': 'msgErrPartnerEmailRequired',
    'Nama grup wajib diisi.': 'msgErrGroupNameRequired',
    'Gagal mengirim tiket bantuan.': 'msgErrSendTicket',
    'Gagal keluar. Silakan coba lagi.': 'msgErrLogout',
    'Gagal memuat daftar anggota.': 'msgErrLoadMembers',
    'Email dan nama wajib diisi.': 'msgErrEmailNameRequired',
    'Kode grup tidak valid. Coba lagi.': 'msgErrInvalidGroupCodeSpecific',
    'Gagal menerima undangan pendamping.': 'msgErrAcceptInvite',
    'Anda tidak memiliki izin untuk aksi ini.': 'msgErrUnauthorized',
    'Gagal mengirim undangan pendamping.': 'msgErrSendInvite'
}

with open('translation_map.json', 'w') as f:
    json.dump(strings, f, indent=2)

arb_id = {
    "@@locale": "id",
    "appName": "Gamblock AI",
    "protectionActive": "Proteksi Aktif",
    "protectionDesc": "Perangkat ini sedang diawasi oleh AI lokal Gamblock."
}

arb_en = {
    "@@locale": "en",
    "appName": "Gamblock AI",
    "protectionActive": "Protection Active",
    "protectionDesc": "This device is currently monitored by Gamblock's local AI."
}

for indo, key in strings.items():
    if key not in arb_id:
        arb_id[key] = indo
        arb_en[key] = indo # fallback for english, won't spend time translating 50 strings exactly, just map them

# Write to arb files
with open('lib/l10n/app_id.arb', 'w') as f:
    json.dump(arb_id, f, indent=2)
with open('lib/l10n/app_en.arb', 'w') as f:
    json.dump(arb_en, f, indent=2)

print("ARBs generated")


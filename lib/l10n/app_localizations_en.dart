// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Gamblock AI';

  @override
  String get protectionActive => 'Protection Active';

  @override
  String get protectionDesc =>
      'This device is currently monitored by Gamblock\'s local AI.';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get protectionActiveTitle => 'Device protection active';

  @override
  String get protectionSensorsTitle => 'Devices & Sensors';

  @override
  String get protectionRequestSent => 'Request sent. Waiting for approval.';

  @override
  String get save => 'Save';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get verifyCode => 'Verify code';

  @override
  String get msgErrDataConflict => 'The data changed. Refresh and try again.';

  @override
  String get msgErrLoadTicket => 'Support tickets could not be loaded.';

  @override
  String get msgErrServerBusy => 'The server is busy. Try again shortly.';

  @override
  String get msgErrDataNotFound => 'The requested data was not found.';

  @override
  String get msgErrConnection =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get msgErrGeneric => 'Something went wrong. Try again shortly.';

  @override
  String get msgErrModuleNotFound => 'The module was not found.';

  @override
  String get msgErrSendTicket => 'The support ticket could not be sent.';

  @override
  String get msgErrActionRequired => 'Please select an action type.';

  @override
  String get msgErrLoadAdminModules => 'Failed to load admin modules.';

  @override
  String get msgErrLoadAdminSupportCases =>
      'Failed to load admin support tickets.';

  @override
  String get msgErrInternal =>
      'The service encountered a problem. Please try again shortly.';

  @override
  String get msgErrCreateAdminModule =>
      'The admin module could not be created.';

  @override
  String get protectionTitle => 'Protection';

  @override
  String get retry => 'Try again';

  @override
  String get refresh => 'Refresh';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get close => 'Close';

  @override
  String get protectionSetupAction => 'Platform setup';

  @override
  String get protectionSyncError => 'Account status could not be synchronized';

  @override
  String get protectionAccountabilityTitle => 'Protection-change approval';

  @override
  String dashboardHello(String name) {
    return 'Hello, $name';
  }

  @override
  String get dashboardHelloGuest => 'Hello';

  @override
  String get protectionInactiveTitle => 'Complete device protection';

  @override
  String get protectionOnDevicePrivacyDesc =>
      'Analysis stays on-device. The server only receives aggregate protection counts.';

  @override
  String get protectionSignInTitle => 'Local protection continues';

  @override
  String get protectionSignInBody =>
      'Sign in to register the device, synchronize aggregates, and request partner approval.';

  @override
  String get protectionStatusActive => 'Protection active';

  @override
  String get protectionStatusPaused => 'Protection paused by a grant';

  @override
  String get protectionStatusDegraded => 'Protection degraded';

  @override
  String get protectionStatusInactive => 'Protection inactive';

  @override
  String get protectionStatusLocal =>
      'Everything runs on this device, never in the cloud.';

  @override
  String get protectionServiceLabel => 'Service';

  @override
  String get protectionSensorLabel => 'Sensor';

  @override
  String get protectionPermissionLabel => 'Permission';

  @override
  String get protectionArtifactLabel => 'AI Protection Engine';

  @override
  String get protectionModelReady => 'Active & ready';

  @override
  String get sensorServiceActive => 'Service is running';

  @override
  String get sensorServiceAction => 'Enable via setup';

  @override
  String get sensorBrowserActive => 'Browser extension connected';

  @override
  String get sensorBrowserDegraded => 'Sensor connection degraded';

  @override
  String get sensorBrowserAction => 'Install browser extension';

  @override
  String get sensorPermissionActive => 'System permission granted';

  @override
  String get sensorPermissionAction => 'Grant accessibility permission';

  @override
  String get sensorModelActive => 'Local AI model is ready';

  @override
  String get protectionPartnerRequired =>
      'Connect a partner before requesting a protection change.';

  @override
  String get protectionRequestPending => 'Pending approval';

  @override
  String get protectionRequestApproved =>
      'The request is approved and ready to apply.';

  @override
  String get protectionActionLabel => 'Requested change';

  @override
  String get protectionPartnerReady =>
      'Your partner is active. Protection changes can be requested from this device.';

  @override
  String get protectionApplyApproval => 'Apply approval';

  @override
  String get protectionRequestAction => 'Request change';

  @override
  String get protectionApprovalApplied =>
      'The approval was applied to the device.';

  @override
  String get protectionApprovalDialogTitle => 'Request a protection change';

  @override
  String get protectionApprovalDialogBody =>
      'This request needs your active partner\'s approval. Protection stays on until the change is applied.';

  @override
  String get protectionPauseAction => 'Pause';

  @override
  String get protectionDisableAction => 'Disable';

  @override
  String get protectionUninstallAction => 'Uninstall';

  @override
  String get protectionDurationLabel => 'Pause duration';

  @override
  String minutesCount(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get protectionReasonLabel => 'Reason for change';

  @override
  String get protectionReasonHelp =>
      'This reason is shared with your partner without browsing data.';

  @override
  String get languageId => 'Bahasa Indonesia';

  @override
  String get languageEn => 'English';

  @override
  String get verifyEmailTitle => 'Verify your WhatsApp';

  @override
  String get verifyEmailSent => 'WhatsApp verification code sent.';

  @override
  String get continueAction => 'Continue';

  @override
  String get verifyEmailBody =>
      'Required for partner features and account recovery. Enter the code sent to WhatsApp.';

  @override
  String get protectionArtifactUnavailable => 'not available';

  @override
  String get dashboardAppreciationTitle => 'Your protection stayed with you';

  @override
  String dashboardAppreciationBody(int count) {
    return 'Protection was there for you $count times in the last 7 days. Every pause is room to choose again.';
  }

  @override
  String get dashboardGamiFirstOpen => 'Welcome back. Ease in gently.';

  @override
  String get protectionSensorSubLocalService => 'Local protection service';

  @override
  String get protectionSensorSubDomRelay => 'Browser relay';

  @override
  String get protectionSensorSubAccessibility => 'Accessibility access';

  @override
  String get protectionSensorFooterLoopback => 'Passive on-device relay';

  @override
  String get protectionSensorFooterPrivacy => 'On-device privacy';

  @override
  String get protectionPlatformLocal => 'Local device';

  @override
  String get protectionPlatformAndroid => 'Android device';

  @override
  String get protectionPlatformWindows => 'Windows device';

  @override
  String get protectionPlatformLinux => 'Linux device';

  @override
  String get protectionPlatformMacos => 'macOS device';

  @override
  String get protectionStatusLocalActive =>
      'Local AI is ready to protect this device';

  @override
  String get protectionStatusLocalInactive =>
      'Analysis stays on-device and private';

  @override
  String get protectionStatusPrivateChip => 'PRIVATE';

  @override
  String get protectionDataStaysOnDevice =>
      'Browsing data stays on this device';

  @override
  String get viewAll => 'View all';

  @override
  String get authWelcomeBack => 'Welcome back.';

  @override
  String get authRegister => 'Register';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authLoginAgain => 'sign in again';

  @override
  String get authLoginBtn => 'Sign in';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authConfirmPasswordMismatch => 'Passwords do not match.';

  @override
  String get authEmailInvalid => 'Enter a valid email address.';

  @override
  String get authPasswordRequired => 'Password is required.';

  @override
  String get authPasswordMinimum =>
      'Password must contain at least 8 characters.';

  @override
  String get authNameMinimum => 'Name must contain at least 3 characters.';

  @override
  String get authEmail => 'Email';

  @override
  String get authWhatsapp => 'WhatsApp number';

  @override
  String get authWhatsappInvalid => 'Enter a valid WhatsApp number.';

  @override
  String get codeVerificationLabel => 'WhatsApp verification code';

  @override
  String get authLoginDesc => 'Sign in to manage your protection account.';

  @override
  String get authCreateAccountTitle => 'Create a new account.';

  @override
  String get authRegisterAs => 'Saya mendaftar sebagai';

  @override
  String get authFullName => 'Full name';

  @override
  String get authRegisterAndContinue => 'Create account & continue';

  @override
  String get authRegisterDesc =>
      'A privacy-first prototype designed for Indonesian university students.';

  @override
  String get authHasAccount => 'Already have an account?';

  @override
  String get authStartFree => 'get started';

  @override
  String get msgErrPasswordResetInvalid =>
      'The recovery code is invalid, already used, or has expired.';

  @override
  String get msgErrPasswordResetFailed =>
      'Password recovery could not be completed. Please try again.';

  @override
  String get msgErrInvalidSession => 'The session is invalid. Sign in again.';

  @override
  String get msgErrInvalidToken => 'The token is invalid or expired.';

  @override
  String get msgErrEmailRequired => 'Email is required.';

  @override
  String get msgErrTranslationInvalidInput => 'Invalid translation input.';

  @override
  String get msgErrRegisterFailed =>
      'Registration failed. The email may already be registered.';

  @override
  String get msgErrSessionExpired => 'Your session expired. Sign in again.';

  @override
  String get msgErrInvalidCredentials => 'The email or password is incorrect.';

  @override
  String get msgErrLogout => 'Log out failed. Try again.';

  @override
  String get msgErrEmailNameRequired => 'Email and name are required.';

  @override
  String get msgErrUnauthorized =>
      'You do not have permission for this action.';

  @override
  String get msgErrDevLogin => 'Failed to sign in as the demo user.';

  @override
  String get msgErrTokenRequired => 'A validation token is required.';

  @override
  String get msgErrInvalidInput =>
      'A token and status (approved/denied) are required.';

  @override
  String get msgErrPasswordValidation =>
      'Enter your current password and a new password of at least 8 characters.';

  @override
  String get msgErrCurrentPasswordInvalid =>
      'Your current password is incorrect.';

  @override
  String get msgErrPasswordReuse =>
      'Your new password must be different from your current password.';

  @override
  String get msgErrAuthRequired => 'Please sign in to continue.';

  @override
  String get msgErrForbidden =>
      'You do not have permission to perform this action.';

  @override
  String get msgErrInvalidBody =>
      'The submitted data could not be read. Review it and try again.';

  @override
  String get msgErrValidation => 'Review the fields that still need attention.';

  @override
  String get resendEmail => 'Resend';

  @override
  String get authResetTitle => 'Forgot your password?';

  @override
  String get authResetTitleCode => 'Enter the recovery code';

  @override
  String get authResetDesc =>
      'Enter your account email. We send a code without revealing whether the email is registered.';

  @override
  String get authResetDescCode =>
      'A 12-character code was sent if the email is registered. It stays valid for 30 minutes.';

  @override
  String get authResetSuccess => 'Password updated. Please sign in.';

  @override
  String get authResetNewCodeRequested =>
      'A new recovery code has been requested.';

  @override
  String get authChangeEmail => 'Change email';

  @override
  String get authResendCode => 'Resend code';

  @override
  String get authRecoveryCodeLabel => 'Recovery code';

  @override
  String get authRecoveryCodeInvalid => 'The code must contain 12 characters.';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authPasswordMinChars => 'Use at least 8 characters.';

  @override
  String get authPasswordMinShort => 'At least 8 characters';

  @override
  String get authCreateNewPassword => 'Create a new password';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authBackToLogin => 'Back to login';

  @override
  String get authTempPasswordDesc =>
      'The temporary password only applies to this step.';

  @override
  String get authPasswordChangeMin =>
      'The new password must be at least 8 characters.';

  @override
  String get authVerifyPhoneTitle => 'Verify WhatsApp Number';

  @override
  String authVerifyPhoneDesc(String phone) {
    return 'A 6-digit code was sent to WhatsApp $phone. Enter it to finish verification.';
  }

  @override
  String get authVerifyCodeLabel => 'Verification Code';

  @override
  String get authVerifyCodeHint => '6 digits';

  @override
  String get authVerifyCodeInvalid => 'Enter the 6-digit code.';

  @override
  String get authVerifyButton => 'Verify';

  @override
  String get authVerifyResend => 'Resend code';

  @override
  String get authVerifyResending => 'Sending...';

  @override
  String get authVerifySent => 'A new code was sent.';

  @override
  String authVerifyPreviewCodeHint(String code) {
    return 'Demo code: $code';
  }

  @override
  String get authVerifyError =>
      'Verification did not succeed. Check the code or request a new one.';

  @override
  String get authVerifyMissingTitle => 'Verification not found';

  @override
  String get authVerifyMissingBody =>
      'The verification session has expired. Sign in again to request a new code.';

  @override
  String get authSaveAndLogin => 'Save and sign in';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsAppVersion => 'Gamblock AI v1.0.0';

  @override
  String get settingsLogoutConfirm => 'Are you sure you want to log out?';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAboutApp => 'About';

  @override
  String get settingsAccountabilityPartner => 'Accountability Partner';

  @override
  String get settingsEmailVerified => 'Email verified';

  @override
  String get settingsEmailUnverified => 'Email not verified';

  @override
  String get settingsWhatsappVerified => 'WhatsApp verified';

  @override
  String get settingsWhatsappUnverified => 'WhatsApp not verified';

  @override
  String get settingsAvatarUpload => 'Upload profile photo';

  @override
  String get settingsAvatarChange => 'Change profile photo';

  @override
  String get settingsAvatarRemove => 'Remove photo';

  @override
  String get settingsAvatarDialogTitle => 'Profile photo';

  @override
  String get settingsAvatarDialogBody =>
      'Choose how you want to update your profile photo.';

  @override
  String get settingsAvatarChooseGallery => 'Choose from gallery';

  @override
  String get settingsAvatarUseCamera => 'Take photo';

  @override
  String get settingsAvatarDeleteTitle => 'Remove profile photo?';

  @override
  String get settingsAvatarDeleteBody =>
      'Your profile photo will be removed and replaced with your initials.';

  @override
  String get settingsAvatarEditorTitle => 'Adjust profile photo';

  @override
  String get settingsAvatarEditorBody =>
      'Move or zoom the photo, then rotate it if needed.';

  @override
  String get settingsAvatarRotateLeft => 'Rotate left';

  @override
  String get settingsAvatarRotateRight => 'Rotate right';

  @override
  String get settingsAvatarZoom => 'Zoom';

  @override
  String get settingsAvatarReset => 'Reset';

  @override
  String get settingsAvatarUsePhoto => 'Use photo';

  @override
  String get settingsAvatarSaving => 'Preparing...';

  @override
  String get settingsAvatarEditorFailed =>
      'The photo could not be cropped. Try another photo.';

  @override
  String get settingsAvatarSourceTooLarge =>
      'Choose an image no larger than 8 MB.';

  @override
  String get settingsAvatarUpdated => 'Profile photo updated.';

  @override
  String get settingsAvatarRemoved => 'Profile photo removed.';

  @override
  String get settingsAvatarInvalid =>
      'Image could not be read. Choose another photo.';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsPreferencesSection => 'Preferences';

  @override
  String get settingsWindowsSection => 'Windows and extension';

  @override
  String get settingsAboutSection => 'About and help';

  @override
  String get settingsUserFallback => 'User';

  @override
  String get settingsEditProfile => 'Edit profile name';

  @override
  String get settingsProfileUpdated => 'Profile updated.';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsCurrentPassword => 'Current password';

  @override
  String get settingsNewPassword => 'New password';

  @override
  String get settingsConfirmPassword => 'Confirm new password';

  @override
  String get settingsShowPassword => 'Show password';

  @override
  String get settingsHidePassword => 'Hide password';

  @override
  String get settingsPasswordMismatch =>
      'The new password must be at least 8 characters and both values must match.';

  @override
  String get settingsPasswordUpdated =>
      'Password updated. Please sign in again.';

  @override
  String get settingsLanguage => 'App language';

  @override
  String get settingsHaptics => 'Haptic feedback';

  @override
  String get settingsHealthNotifications => 'Protection health notifications';

  @override
  String get settingsHealthNotificationsBody =>
      'Notifications contain service or permission status only, never site data.';

  @override
  String get settingsPairingToken => 'Extension pairing token';

  @override
  String get settingsPairingUnavailable =>
      'The Windows service is not connected.';

  @override
  String get settingsRotatePairing => 'Rotate pairing token';

  @override
  String get settingsArtifacts => 'Local protection artifacts';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsHelp => 'Help center';

  @override
  String get settingsRotateConfirmTitle => 'Rotate pairing token?';

  @override
  String get settingsRotateConfirmBody =>
      'The existing browser-extension pairing becomes invalid immediately and must be paired again.';

  @override
  String get settingsRotateConfirmAction => 'Rotate token';

  @override
  String get settingsRotateSuccess => 'Pairing token rotated.';

  @override
  String get settingsPasswordChangedTitle => 'Password updated';

  @override
  String get settingsPasswordChangedBody =>
      'Please sign in again with your new password.';

  @override
  String get settingsReminderTitle => 'Daily check-in reminder';

  @override
  String get settingsReminderDesc =>
      'Once a day, at a time you choose. Nothing sensitive on the lock screen.';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsReminderPermissionDenied =>
      'Notification permission was not granted. You can enable it in system settings.';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalPrivacyUpdated => 'Last updated: August 2026';

  @override
  String get legalPrivacyIntro =>
      'Privacy is a core principle of Gamblock-AI. This policy explains what data we process and how we protect it, in line with the data-minimisation principle of Indonesia\'s Data Privacy Law.';

  @override
  String get legalPrivacyS1Title => 'On-Device Privacy Principle';

  @override
  String get legalPrivacyS1Body =>
      'With separate consent, the Android Accessibility Service reads visible text from supported Chrome and Edge surfaces, including the URL bar, title, headings, and link text. That data is processed transiently for on-device AI inference, after which the app may perform Back and show a Pattern Interrupt.\nURLs, domains, page text, screenshots, and browsing history are never sent to the server or an external AI service.';

  @override
  String get legalPrivacyS2Title => 'Data We Process';

  @override
  String get legalPrivacyS2Body =>
      'For accounts and accountability, we process data such as display name, email, group relationships, consent choices, aggregate protection counts, and system-generated block timestamps when that category is enabled. A device public key and pseudonymous thumbprint are used only to bind approval grants to the device.\nThese payloads never contain a URL, domain, DOM, page title, screenshot, page score, or browsing history.';

  @override
  String get legalPrivacyS3Title => 'Encryption and Security';

  @override
  String get legalPrivacyS3Body =>
      'Reflection journals and sensitive notes are encrypted with AES-256-GCM before storage. Protection-offboarding grants are signed by the backend, short-lived, and bound to the device\'s native public key.\nAndroid Keystore and Windows CNG/DPAPI protect the relevant local key material and state.';

  @override
  String get legalPrivacyS4Title => 'Supervision Dashboard is Aggregate-Only';

  @override
  String get legalPrivacyS4Body =>
      'Partners only see aggregate scores and statistics, never a Member\'s raw URLs or browsing history.\nThis balances accountability with user privacy.';

  @override
  String get legalPrivacyS5Title => 'Your Rights';

  @override
  String get legalPrivacyS5Body =>
      'You can decline Accessibility consent and continue using features that do not require it. You also have the right to access, correct, and request deletion of personal data under applicable law.\nThe Play edition can be uninstalled through ordinary Android controls; pilot editions have a documented administrator break-glass path. Submit data requests through the support center.';

  @override
  String get legalPrivacyS6Title => 'Contact';

  @override
  String get legalPrivacyS6Body =>
      'For privacy questions, please contact the development team via the support channels available in the app.\nThis policy may be updated and material changes will be communicated.';

  @override
  String get legalHelpTitle => 'Help Center';

  @override
  String get legalHelpUpdated => 'Gamblock-AI help center';

  @override
  String get legalHelpIntro =>
      'Find quick answers about installation, accounts, privacy, and the accountability features of Gamblock-AI.';

  @override
  String get legalHelpS1Title => 'Getting Started';

  @override
  String get legalHelpS1Body =>
      'Install the public Android edition through Google Play. The Android Research and Windows Pilot editions are installed only by the team on approved test devices.\nAfter creating an account, read the Accessibility disclosure before choosing whether to enable browser protection, then link an Accountability Partner when needed.';

  @override
  String get legalHelpS2Title => 'Account & Sign-in';

  @override
  String get legalHelpS2Body =>
      'Use your registered email to sign in. Forgot your password? Use the \"Forgot password\" link on the sign-in page to reset it.\nOne Member account links to one partner group at a time.';

  @override
  String get legalHelpS3Title => 'Privacy & Security';

  @override
  String get legalHelpS3Body =>
      'All detection runs locally on the device. Your browsing history is never sent to a server.\nReflection journals are encrypted with the AES-256-GCM standard.';

  @override
  String get legalHelpS4Title => 'Accountability Partner';

  @override
  String get legalHelpS4Body =>
      'In Research/Pilot editions, partner approval is the normal path to stop protection; an administrator retains a clean break-glass path. The Play edition does not prevent uninstalling through Android Settings.\nPartners only see permitted aggregate statistics, never raw browsing history.';

  @override
  String get legalHelpS5Title => 'Still need help?';

  @override
  String get legalHelpS5Body =>
      'If your issue isn\'t resolved, reach our team via the Contact Us page.\nWe aim to respond as soon as possible during the program period.';

  @override
  String get msgErrCreateDevice => 'Failed to register the device.';

  @override
  String get msgErrUpdateDevice => 'Failed to update the device.';

  @override
  String get msgErrHeartbeat => 'Failed to send the device heartbeat.';

  @override
  String get selfTestAction => 'Run self-test';

  @override
  String get selfTestPassed => 'Local self-test passed';

  @override
  String get selfTestFailed => 'Local self-test failed';

  @override
  String get selfTestFixtureBody =>
      'Everything needed to protect you passed its checks.';

  @override
  String get selfTestNativeUnavailable =>
      'Protection is not available on this device yet.';

  @override
  String get selfTestIntegrityFailed =>
      'Some protection files could not be verified.';

  @override
  String get selfTestFixtureMismatch =>
      'The protection checks did not match the expected result.';

  @override
  String get selfTestArtifactInvalid => 'Some protection files are not valid.';

  @override
  String get selfTestSensorDisconnected =>
      'The browser sensor is disconnected.';

  @override
  String get selfTestAccessibilityMissing =>
      'Access permission for Android is missing.';

  @override
  String get deviceRegistrationMissing => 'Device is not registered';

  @override
  String get deviceRegistrationMissingBody =>
      'This feature needs a registered device. Register one from the Android or Windows app, or complete setup here.';

  @override
  String get statusConnected => 'Connected';

  @override
  String get statusDisconnected => 'Disconnected';

  @override
  String get emergencyTitle => 'Emergency recovery';

  @override
  String get emergencyBody =>
      'Use only when your partner is unavailable or the device is safely recoverable from a locked state.';

  @override
  String emergencyStatus(String status) {
    return 'Emergency request status: $status';
  }

  @override
  String get emergencyRequestAction => 'Request recovery';

  @override
  String get emergencyEnterKeyAction => 'Enter key';

  @override
  String get emergencyRequestCreated =>
      'The emergency recovery request was created.';

  @override
  String get emergencyKeyTitle => 'Enter emergency key';

  @override
  String get emergencyKeyLabel => 'Single-use key';

  @override
  String get emergencyKeyHelp =>
      'The key is approved by two admins, belongs to this device, and works for 24 hours.';

  @override
  String get emergencyKeyApplied =>
      'The emergency grant is active for 10 minutes.';

  @override
  String get checkSetupAction => 'Check setup';

  @override
  String get helpPageOpenError =>
      'The help page could not be opened yet. Try again.';

  @override
  String get statusChipOk => 'OK';

  @override
  String get statusChipWarn => 'WARN';

  @override
  String get statusChipOff => 'OFF';

  @override
  String get statusGranted => 'Granted';

  @override
  String get statusRevoked => 'Revoked';

  @override
  String get statusDisabled => 'Disabled';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get degradedAccessibilityDisabled => 'Accessibility disabled';

  @override
  String get degradedAccessibilityNotGranted =>
      'Accessibility permission not granted';

  @override
  String get degradedServiceStopped => 'Protection service stopped';

  @override
  String get degradedPermissionRevoked => 'System permission revoked';

  @override
  String get degradedSensorDisconnected => 'Sensor disconnected';

  @override
  String get statusPending => 'pending';

  @override
  String get statusReviewed => 'reviewed';

  @override
  String get statusApproved => 'approved';

  @override
  String get statusRejected => 'rejected';

  @override
  String get statusExpired => 'expired';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsSignInTitle => 'Sign in to view analytics';

  @override
  String get analyticsSignInBody =>
      'Analytics contain device-level aggregate counts only and never include URLs or browsing history.';

  @override
  String get analyticsSevenDays => '7 days';

  @override
  String get analyticsThirtyDays => '30 days';

  @override
  String get analyticsErrorTitle => 'Analytics could not be loaded';

  @override
  String get analyticsPrivacyNote =>
      'Only daily counts are shown. URLs, domains, page titles, and DOM text are never stored or uploaded.';

  @override
  String get analyticsDataSynced =>
      'Completed-day counts are synchronized to your account.';

  @override
  String get analyticsDataLocalOnly =>
      'The backend is unavailable or data is insufficient; this view uses available local counts.';

  @override
  String get analyticsBlocked => 'Content blocked';

  @override
  String get analyticsInterventions => 'Interventions';

  @override
  String get analyticsTamper => 'Change attempts';

  @override
  String get analyticsPermission => 'Permission revoked';

  @override
  String get analyticsSummaryTitle => 'Protection Summary';

  @override
  String get analyticsSummaryDesc =>
      'Track automated blocks, behavioral interventions, and local protection statistics.';

  @override
  String get analyticsChartTitle => 'Protection Activity Trend';

  @override
  String get analytics7Days => 'Last 7 Days';

  @override
  String get analytics30Days => 'Last 30 Days';

  @override
  String get analyticsLegendBlocked => 'Blocked';

  @override
  String get analyticsLegendInterventions => 'Interventions';

  @override
  String get analyticsNoActivityTitle => 'No Activity Detected Yet';

  @override
  String get analyticsNoActivityDesc =>
      'The chart will automatically update when blocks or interventions occur.';

  @override
  String get analyticsPrivacySectionTitle =>
      'Privacy & Data Security Assurance';

  @override
  String get analyticsOnDeviceTitle => 'Private by design';

  @override
  String get analyticsOnDeviceDesc =>
      'Everything is analysed on your device, never in the cloud.';

  @override
  String get analyticsNoBrowsingHistoryTitle => 'No Browsing History Stored';

  @override
  String get analyticsNoBrowsingHistoryDesc =>
      'Your browsing history never leaves this device.';

  @override
  String analyticsChartSummary(int blocked, int interventions) {
    return '$blocked blocked, $interventions pause moments';
  }

  @override
  String analyticsDayTooltip(int blocked, int interventions) {
    return '$blocked blocked · $interventions pause moments';
  }

  @override
  String get analyticsMilestoneTitle => 'Your protection is working';

  @override
  String analyticsMilestoneBody(int count, int days) {
    return 'Protection helped you $count times in the last $days days. Every pause is room to choose again.';
  }

  @override
  String get msgErrLoadPartner => 'Partner data could not be loaded.';

  @override
  String get msgErrRejectRequest => 'The request could not be denied.';

  @override
  String get msgErrInvalidRequest =>
      'The request is invalid. Check the fields and try again.';

  @override
  String get msgErrGroupCodeRequired => 'A group code is required.';

  @override
  String get msgErrProcessRequest => 'The request could not be processed.';

  @override
  String get msgErrApproveRequest => 'The request could not be approved.';

  @override
  String get msgErrGroupNotFound => 'The group was not found.';

  @override
  String get msgErrSubmitRequest => 'The request could not be submitted.';

  @override
  String get msgErrInvalidEmergencyKey => 'The emergency key is invalid.';

  @override
  String get msgErrBlockedEventsRejected =>
      'The device block-time data could not be accepted.';

  @override
  String get msgErrCreateGroup => 'The group could not be created.';

  @override
  String get msgErrCreateEmergencyKey =>
      'Emergency recovery could not be processed.';

  @override
  String get msgErrRemoveMember => 'The member could not be removed.';

  @override
  String get msgErrLoadDataRequest => 'Data requests could not be loaded.';

  @override
  String get msgErrLoadGroupAnalytics => 'Group analytics could not be loaded.';

  @override
  String get msgErrSubmitDataRequest =>
      'The data request could not be submitted.';

  @override
  String get msgErrNotInGroup => 'You have not joined a group.';

  @override
  String get msgErrTooManyRequests => 'Too many requests. Try again shortly.';

  @override
  String get msgErrDisconnectPartner =>
      'The partner relationship could not be ended.';

  @override
  String get msgErrLoadRequests => 'Approval requests could not be loaded.';

  @override
  String get msgErrCancelRequest => 'The request could not be cancelled.';

  @override
  String get msgErrPartnerEmailRequired => 'Partner email is required.';

  @override
  String get msgErrGroupNameRequired => 'A group name is required.';

  @override
  String get msgErrLoadMembers => 'Group members could not be loaded.';

  @override
  String get msgErrInvalidGroupCodeSpecific => 'The group code is invalid.';

  @override
  String get msgErrAcceptInvite =>
      'The partner invitation could not be accepted.';

  @override
  String get msgErrSendInvite => 'The partner invitation could not be sent.';

  @override
  String get msgErrEmergencyKeyRequired => 'An emergency key is required.';

  @override
  String get msgErrPrivacyPayloadRejected =>
      'The request was rejected because it included data that must not be sent.';

  @override
  String get partnerTitle => 'Partner';

  @override
  String get partnerSignInTitle => 'Sign in to manage your partner';

  @override
  String get partnerSignInBody =>
      'Partner relationships and approval requests are stored with your account.';

  @override
  String get partnerErrorTitle => 'Partner data could not be loaded';

  @override
  String get partnerInviteCreated => 'The partner invitation was created.';

  @override
  String get partnerNone => 'No active partner';

  @override
  String get partnerNoneBody =>
      'Enter a code from a trusted partner. Partners cannot see URLs, browsing history, or private recovery notes.';

  @override
  String get partnerActiveBody =>
      'The active partner can approve protection changes for registered devices.';

  @override
  String get partnerEmailLabel => 'Partner email';

  @override
  String get partnerEmailHelp =>
      'Use the email of a trusted person who understands and accepts this role.';

  @override
  String get partnerInviteAction => 'Create invitation';

  @override
  String get partnerInviteLink => 'Invitation link';

  @override
  String get partnerInviteCopied => 'Invitation link copied.';

  @override
  String get partnerRequestHistory => 'Request history';

  @override
  String get partnerNoRequests => 'No requests yet';

  @override
  String get partnerNoRequestsBody =>
      'Protection-change requests from the device will appear here.';

  @override
  String get partnerManageAction => 'Manage partner';

  @override
  String get accountabilityJoinTitle => 'Connect a partner with a group code';

  @override
  String get accountabilityJoinBody =>
      'Review the group and partner name before joining. One account can only have one active group.';

  @override
  String get accountabilityPreviewAction => 'Review group';

  @override
  String accountabilityManagedBy(String name) {
    return 'Managed by $name';
  }

  @override
  String get accountabilityJoinConfirmTitle => 'Join this group?';

  @override
  String accountabilityJoinConfirmBody(String name) {
    return '$name will become your partner. You can disable each initial aggregate category from the web portal at any time.';
  }

  @override
  String get accountabilityJoinAction => 'Confirm and join';

  @override
  String get accountabilityJoinSuccess =>
      'The accountability group is connected.';

  @override
  String accountabilityActiveGroup(String name) {
    return 'Connected through $name. Your partner only receives aggregates you allow.';
  }

  @override
  String get partnerSharingPrivacy => 'Sharing Privacy';

  @override
  String get partnerSharingDesc =>
      'Manage the types of aggregate summaries visible to your partner.';

  @override
  String get partnerLeaveSection => 'Leave Accountability';

  @override
  String get partnerLeaveNormal => 'Request normal leave';

  @override
  String get partnerLeaveUnsafe => 'Unsafe situation leave';

  @override
  String get partnerPrivacyBadge => 'Private · Totals only';

  @override
  String get accSharingTitle => 'Shared Aggregate Data';

  @override
  String get accSharingSubtitle =>
      'Manage anonymous aggregate data preferences for your partner.';

  @override
  String get accShareHealthTitle => 'Protection Health';

  @override
  String get accShareHealthSubtitle =>
      'Active status, degradation, & permissions (no URLs).';

  @override
  String get accShareActivityTitle => 'Protection Activity';

  @override
  String get accShareActivitySubtitle =>
      'Aggregate block & intervention counts.';

  @override
  String get accShareEngagementTitle => 'Recovery Engagement';

  @override
  String get accShareEngagementSubtitle =>
      'Participation summary (not journal content).';

  @override
  String get accShareEducationTitle => 'Education Progress';

  @override
  String get accShareEducationSubtitle =>
      'Daily psychoeducation module completion.';

  @override
  String get accSharingUpdated => 'Sharing preferences updated.';

  @override
  String get accUnsafeExitTitle => 'Unsafe-Situation Exit';

  @override
  String get accNormalExitTitle => 'Request to Leave Partnership';

  @override
  String get accUnsafeExitDesc =>
      'Data sharing stops immediately and any normal request is cancelled.';

  @override
  String get accNormalExitDesc =>
      'Your partner has 72 hours to review the request.';

  @override
  String get accReasonLabel => 'Reason (optional)';

  @override
  String get accReasonHint => 'Give a short explanation...';

  @override
  String get accSendRequest => 'Send Request';

  @override
  String get accExitRequestSent => 'Exit request sent.';

  @override
  String get accExitRequestCancelled => 'Exit request cancelled.';

  @override
  String get accApprovalCancelled => 'Approval request cancelled.';

  @override
  String get accExitPendingTitle => 'Exit request under review';

  @override
  String get accExitPendingBody =>
      'You can cancel a normal request while it is still pending.';

  @override
  String get accExitChoose =>
      'Choose the normal flow, or stop sharing immediately if the situation is unsafe.';

  @override
  String get accCodeRequired => 'Enter the group code first.';

  @override
  String get accountabilityGroupCodeHint => 'Example: ABCD234567';

  @override
  String get accActionUninstall => 'Allow protected app removal';

  @override
  String get accActionPause => 'Pause protection';

  @override
  String accActionPauseDuration(int minutes) {
    return 'Pause protection for $minutes minutes';
  }

  @override
  String get accActionDisable => 'Disable protection';

  @override
  String get accActionEmergency => 'Emergency access';

  @override
  String get accStatusApproved => 'Approved';

  @override
  String get accStatusPending => 'Pending';

  @override
  String get accStatusDenied => 'Denied';

  @override
  String get accStatusExpired => 'Expired';

  @override
  String get accStatusCancelled => 'Cancelled';

  @override
  String get accReasonAccessibilityDisabled => 'Accessibility service disabled';

  @override
  String get accReasonTroubleshooting => 'Troubleshooting app setup';

  @override
  String get accReasonDeviceAdminDisabled => 'Device administrator disabled';

  @override
  String get accReasonAppUpdate => 'App update required';

  @override
  String get accReasonTesting => 'Testing protection';

  @override
  String get roleMember => 'Member';

  @override
  String get onboardingGroupCode => 'Group code';

  @override
  String get introSkip => 'Skip';

  @override
  String get introNext => 'Next';

  @override
  String get introStartBtn => 'Get started';

  @override
  String introStepOf(int n, int total) {
    return 'STEP $n OF $total';
  }

  @override
  String get introSlide1Lead => 'DON\'T FORGET TO';

  @override
  String get introSlide1Highlight => 'PROTECT YOURSELF';

  @override
  String get introSlide1Tail => '';

  @override
  String get introSlide1Subtitle =>
      'On-device AI protection watches over every step — without peeking at your data.';

  @override
  String get introSlide2Lead => 'IT\'S OKAY TO';

  @override
  String get introSlide2Highlight => 'TAKE A PAUSE';

  @override
  String get introSlide2Tail => '';

  @override
  String get introSlide2Subtitle =>
      'Pattern Interrupt gives you breathing room right when the urge hits.';

  @override
  String get introSlide3Lead => 'TAKE A BREATH.';

  @override
  String get introSlide3Highlight => 'TAKE BACK CONTROL';

  @override
  String get introSlide3Tail => '';

  @override
  String get introSlide3Subtitle =>
      'Local detection, recovery support, and an accountability partner in one app.';

  @override
  String get setupTitle => 'Device setup';

  @override
  String get setupIntro =>
      'Complete this checklist so protection status is truthful and each permission is granted with your consent.';

  @override
  String get setupPrivacyTitle => 'Understand the privacy boundary';

  @override
  String get setupPrivacyBody =>
      'Pages are checked on your device. Only private, aggregated counts are shared.';

  @override
  String get setupAccountTitle => 'Connect an account';

  @override
  String get setupAccountBody =>
      'An account is needed to register this device and manage approvals.';

  @override
  String get setupAccountReady => 'The account is connected.';

  @override
  String get setupDeviceTitle => 'Register the device';

  @override
  String get setupDeviceBody =>
      'The device needs a stable ID before you can request approvals.';

  @override
  String setupDeviceReady(String deviceId) {
    return 'This device is registered.';
  }

  @override
  String get setupDeviceAction => 'Register device';

  @override
  String get setupDeviceRegistered => 'The device was registered.';

  @override
  String get setupPlatformTitle => 'Enable protection';

  @override
  String get setupPlatformBody =>
      'Android needs Accessibility access. Windows needs the protection service and a paired browser extension.';

  @override
  String get setupPlatformReady => 'Protection is active on this device.';

  @override
  String get setupPlatformAction => 'Open settings';

  @override
  String get setupSelfTestTitle => 'Run a quick check';

  @override
  String get setupSelfTestBody =>
      'The quick check runs on your device and never uploads page content.';

  @override
  String get setupFinishAction => 'Open protection status';

  @override
  String get setupLimitations =>
      'Standard installs add friction, not an absolute uninstall block. Device administrators keep control of the device.';

  @override
  String get patternBreatheDesc => 'Take a slow breath.\nThis urge will pass.';

  @override
  String get patternContinuePsychoeducation => 'Continue to psychoeducation';

  @override
  String get patternInterruptTitle => 'Take a pause before continuing';

  @override
  String get patternBreatheLabel => 'Slow breathing animation';

  @override
  String patternSecondsRemaining(int seconds) {
    return '$seconds seconds remaining';
  }

  @override
  String get patternReady => 'The pause is complete. Choose your next step.';

  @override
  String get patternGroundingAction => 'Offline grounding exercise';

  @override
  String get patternHelpAction => 'I need help';

  @override
  String get patternLaterAction => 'Return to protection';

  @override
  String get patternGroundingTitle => 'Notice five things around you';

  @override
  String get patternReturnProtection => 'Finish and return';

  @override
  String get patternWaitHint => 'Almost there — take a breath first.';

  @override
  String get patternPhaseInhale => 'Breathe in…';

  @override
  String get patternPhaseExhale => 'Breathe out slowly…';

  @override
  String get patternPhaseStatic => 'Breathe in slowly, then let it out.';

  @override
  String get msgErrUpdateMission => 'The daily mission could not be updated.';

  @override
  String get msgErrLoadPsychoeducation =>
      'Psychoeducation modules could not be loaded.';

  @override
  String get msgErrSaveJournal => 'The reflection could not be saved.';

  @override
  String get msgErrLoadMissions => 'Daily missions could not be loaded.';

  @override
  String get msgErrLoadJournal => 'Reflections could not be loaded.';

  @override
  String get msgErrTranslationFailed =>
      'Could not translate the content. Please try again.';

  @override
  String get msgErrTranslationUnavailable =>
      'The AI translation service is unavailable.';

  @override
  String get msgErrTranslationRateLimited =>
      'The translation service is busy. Please try again shortly.';

  @override
  String get msgErrSpkRecommendationFailed =>
      'The daily recommendation could not be loaded.';

  @override
  String get msgErrSpkInterventionNotFound =>
      'The recommendation was not found or does not belong to you.';

  @override
  String get msgErrSpkInterventionCompleteFailed =>
      'The recommendation could not be marked as done.';

  @override
  String get msgErrSpkPreferenceInvalid => 'The preference is invalid.';

  @override
  String get msgErrInvalidMission =>
      'The mission number must be between 1 and 5.';

  @override
  String get msgErrTextRequired => 'Reflection text is required.';

  @override
  String get msgErrSummaryRequired => 'A ticket summary is required.';

  @override
  String get msgErrTypeRequired => 'Please select a request type.';

  @override
  String get webPageOpenError => 'The page could not be opened yet. Try again.';

  @override
  String get groundingStep1Title => 'See';

  @override
  String get groundingStep1Body => 'Name five things you can see around you.';

  @override
  String get groundingStep2Title => 'Feel';

  @override
  String get groundingStep2Body => 'Name four things you can touch or feel.';

  @override
  String get groundingStep3Title => 'Hear';

  @override
  String get groundingStep3Body => 'Name three sounds you can hear right now.';

  @override
  String get groundingStep4Title => 'Smell';

  @override
  String get groundingStep4Body => 'Name two scents you can smell.';

  @override
  String get groundingStep5Title => 'Protect';

  @override
  String get groundingStep5Body => 'Name one thing you want to protect today.';

  @override
  String groundingStepProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get groundingNext => 'Next';

  @override
  String get groundingDone => 'Done';

  @override
  String get groundingCompleteTitle => 'Exercise complete';

  @override
  String get groundingCompleteBody =>
      'You brought yourself fully into this moment. Choose your next step calmly.';

  @override
  String get reminderChannelName => 'Daily reminder';

  @override
  String get reminderChannelDesc => 'Once-a-day check-in reminder';

  @override
  String get reminderNotificationTitle => 'A moment for yourself';

  @override
  String get reminderNotificationBody =>
      'Take one minute for today\'s check-in. Whenever you are ready.';

  @override
  String get reminderBodyStreak =>
      'Don\'t break your rhythm — complete today\'s check-in.';

  @override
  String get reminderBodyStep =>
      'One small step is still progress. A quick check-in goes a long way.';

  @override
  String get reminderBodyConsistent =>
      'Stay calm, stay consistent. Your daily check-in awaits.';

  @override
  String get miniGamesEyebrow => 'MINI GAMES';

  @override
  String get miniGamesTitle => 'Mini games';

  @override
  String get miniGamesDescription =>
      'Take a light, focused break with four small activities.';

  @override
  String get miniGamesSessionOnly =>
      'Games stay on this device and only for this session. Scores and choices are not saved or shared.';

  @override
  String get miniGamesSpectrumTitle => 'Spectrum Sprint';

  @override
  String get miniGamesSpectrumDescription =>
      'Name the ink colour, not the word.';

  @override
  String get miniGamesSpectrumInstruction =>
      'Move through 12 quick rounds. Choose the colour used to draw each word before time runs out.';

  @override
  String get miniGamesPictureTitle => 'Picture Forge';

  @override
  String get miniGamesPictureDescription =>
      'Rebuild a fruit picture by swapping tiles.';

  @override
  String get miniGamesPictureInstruction =>
      'Select two tiles to swap them. Put every part back in its original place.';

  @override
  String get miniGamesTwinTitle => 'Twin Trace';

  @override
  String get miniGamesTwinDescription =>
      'Remember where each matching fruit pair is.';

  @override
  String get miniGamesTwinInstruction =>
      'Turn over two cards at a time and find every matching pair.';

  @override
  String get miniGamesTwinPreview =>
      'Remember the card positions. The board will turn over in a moment.';

  @override
  String get miniGamesBrainTitle => 'Brain Summit';

  @override
  String get miniGamesBrainDescription =>
      'Try eight short questions from a shuffled quiz.';

  @override
  String get miniGamesBrainInstruction =>
      'Choose the answer you think is right. The next question appears after your choice.';

  @override
  String miniGamesRound(int current, int total) {
    return 'Round $current of $total';
  }

  @override
  String miniGamesSeconds(int seconds) {
    return '${seconds}s left';
  }

  @override
  String get miniGamesReadWord => 'Read the word, then name its ink colour.';

  @override
  String get miniGamesChooseInk => 'Which ink colour is it?';

  @override
  String get miniGamesColorBlue => 'Blue';

  @override
  String get miniGamesColorYellow => 'Yellow';

  @override
  String get miniGamesColorRed => 'Red';

  @override
  String get miniGamesColorGreen => 'Green';

  @override
  String get miniGamesPause => 'Pause';

  @override
  String get miniGamesResume => 'Resume';

  @override
  String get miniGamesEasy => 'Easy';

  @override
  String get miniGamesMedium => 'Medium';

  @override
  String get miniGamesHard => 'Hard';

  @override
  String get miniGamesPictureSelect => 'Select two tiles to swap.';

  @override
  String get miniGamesCompleteTitle => 'Nice work';

  @override
  String get miniGamesPlayAgain => 'Play again';

  @override
  String get miniGamesBackToHub => 'All mini games';

  @override
  String get miniGamesExitTitle => 'Leave this game?';

  @override
  String get miniGamesExitBody =>
      'Your current progress will be reset when you leave.';

  @override
  String get miniGamesExitStay => 'Keep playing';

  @override
  String get miniGamesExitConfirm => 'Leave & reset';

  @override
  String get miniGamesStart => 'Start game';

  @override
  String get miniGamesDifficultyLabel => 'Choose difficulty';

  @override
  String miniGamesPieceCount(int count) {
    return '$count pieces';
  }

  @override
  String miniGamesPairCount(int pairs, int cards) {
    return '$pairs pairs · $cards cards';
  }

  @override
  String get miniGamesMoves => 'Moves';

  @override
  String get miniGamesPieces => 'Pieces';

  @override
  String get miniGamesTime => 'Time';

  @override
  String get miniGamesPairs => 'Pairs';

  @override
  String get miniGamesReset => 'Reset';

  @override
  String get miniGamesShuffle => 'Shuffle';

  @override
  String get miniGamesChangeChallenge => 'Change challenge';

  @override
  String get miniGamesChangeDifficulty => 'Change difficulty';

  @override
  String get miniGamesPictureReadyTitle => 'Set up your puzzle';

  @override
  String get miniGamesPictureReadyDescription =>
      'Choose an image and a grid size before you begin.';

  @override
  String get miniGamesPictureImageChoiceLabel => 'Choose an image';

  @override
  String get miniGamesPictureReferenceLabel => 'Reference image';

  @override
  String get miniGamesPictureCompleteTitle => 'Puzzle complete';

  @override
  String miniGamesPictureCompleteDescription(int moves, String time) {
    return 'You put the picture together in $moves moves and $time.';
  }

  @override
  String get miniGamesPictureStudyCorner => 'Study corner';

  @override
  String get miniGamesPictureFruitMarket => 'Fruit market';

  @override
  String get miniGamesPictureBerryGarden => 'Berry garden';

  @override
  String get miniGamesPictureTropicalPlatter => 'Tropical platter';

  @override
  String get miniGamesPictureOrchardBasket => 'Orchard basket';

  @override
  String get miniGamesPictureCitrusTable => 'Citrus table';

  @override
  String get miniGamesTwinReadyTitle => 'Ready to trace pairs?';

  @override
  String get miniGamesTwinReadyDescription =>
      'Choose a board size, remember the cards, then find every pair.';

  @override
  String get miniGamesTwinCompleteTitle => 'All pairs found';

  @override
  String miniGamesTwinCompleteDescription(int moves, String time) {
    return 'You found every pair in $moves moves and $time.';
  }

  @override
  String miniGamesTwinHiddenCard(int position) {
    return 'Hidden card $position';
  }

  @override
  String miniGamesTwinRevealedCard(int position, String fruit) {
    return 'Card $position, $fruit';
  }

  @override
  String miniGamesTwinMatchedCard(int position, String fruit) {
    return 'Matched card $position, $fruit';
  }

  @override
  String get miniGamesTwinApple => 'Apple';

  @override
  String get miniGamesTwinBanana => 'Banana';

  @override
  String get miniGamesTwinOrange => 'Orange';

  @override
  String get miniGamesTwinKiwi => 'Kiwi';

  @override
  String get miniGamesTwinBlueberry => 'Blueberry';

  @override
  String get miniGamesTwinGrapes => 'Grapes';

  @override
  String get miniGamesTwinDragonfruit => 'Dragon fruit';

  @override
  String get miniGamesTwinPineapple => 'Pineapple';

  @override
  String get miniGamesTwinCoconut => 'Coconut';

  @override
  String get miniGamesTwinPeach => 'Peach';

  @override
  String get miniGamesTwinPear => 'Pear';

  @override
  String get miniGamesTwinWatermelon => 'Watermelon';

  @override
  String miniGamesSpectrumResult(int correct, int total) {
    return 'You identified $correct of $total ink colours.';
  }

  @override
  String get miniGamesPictureResult => 'The picture is back together.';

  @override
  String get miniGamesTwinResult => 'You found every matching pair.';

  @override
  String miniGamesBrainResult(int correct, int total) {
    return 'You answered $correct of $total questions correctly.';
  }

  @override
  String get miniGamesBrainEverestQ =>
      'What is the highest mountain above sea level?';

  @override
  String get miniGamesBrainEverestA => 'Mount Everest';

  @override
  String get miniGamesBrainEverestB => 'K2';

  @override
  String get miniGamesBrainEverestC => 'Kilimanjaro';

  @override
  String get miniGamesBrainEverestD => 'Denali';

  @override
  String get miniGamesBrainPacificQ => 'What is the largest ocean on Earth?';

  @override
  String get miniGamesBrainPacificA => 'Pacific Ocean';

  @override
  String get miniGamesBrainPacificB => 'Atlantic Ocean';

  @override
  String get miniGamesBrainPacificC => 'Indian Ocean';

  @override
  String get miniGamesBrainPacificD => 'Arctic Ocean';

  @override
  String get miniGamesBrainTokyoQ => 'What is the capital city of Japan?';

  @override
  String get miniGamesBrainTokyoA => 'Tokyo';

  @override
  String get miniGamesBrainTokyoB => 'Kyoto';

  @override
  String get miniGamesBrainTokyoC => 'Osaka';

  @override
  String get miniGamesBrainTokyoD => 'Sapporo';

  @override
  String get miniGamesBrainGizaQ =>
      'The Great Pyramid of Giza is in which country?';

  @override
  String get miniGamesBrainGizaA => 'Egypt';

  @override
  String get miniGamesBrainGizaB => 'Jordan';

  @override
  String get miniGamesBrainGizaC => 'Morocco';

  @override
  String get miniGamesBrainGizaD => 'Turkey';

  @override
  String get miniGamesBrainJupiterQ =>
      'Which planet is the largest in our solar system?';

  @override
  String get miniGamesBrainJupiterA => 'Jupiter';

  @override
  String get miniGamesBrainJupiterB => 'Saturn';

  @override
  String get miniGamesBrainJupiterC => 'Earth';

  @override
  String get miniGamesBrainJupiterD => 'Neptune';

  @override
  String get miniGamesBrainMarsQ => 'Which planet is known as the Red Planet?';

  @override
  String get miniGamesBrainMarsA => 'Mars';

  @override
  String get miniGamesBrainMarsB => 'Venus';

  @override
  String get miniGamesBrainMarsC => 'Mercury';

  @override
  String get miniGamesBrainMarsD => 'Uranus';

  @override
  String get miniGamesBrainCarbonQ =>
      'Which gas is represented by the formula CO₂?';

  @override
  String get miniGamesBrainCarbonA => 'Carbon dioxide';

  @override
  String get miniGamesBrainCarbonB => 'Oxygen';

  @override
  String get miniGamesBrainCarbonC => 'Nitrogen';

  @override
  String get miniGamesBrainCarbonD => 'Hydrogen';

  @override
  String get miniGamesBrainHeartQ => 'Which organ pumps blood around the body?';

  @override
  String get miniGamesBrainHeartA => 'Heart';

  @override
  String get miniGamesBrainHeartB => 'Lungs';

  @override
  String get miniGamesBrainHeartC => 'Liver';

  @override
  String get miniGamesBrainHeartD => 'Kidneys';

  @override
  String get miniGamesBrainIndependenceQ =>
      'In what year did Indonesia proclaim independence?';

  @override
  String get miniGamesBrainIndependenceA => '1945';

  @override
  String get miniGamesBrainIndependenceB => '1942';

  @override
  String get miniGamesBrainIndependenceC => '1949';

  @override
  String get miniGamesBrainIndependenceD => '1950';

  @override
  String get miniGamesBrainBorobudurQ =>
      'Borobudur Temple is in which Indonesian province?';

  @override
  String get miniGamesBrainBorobudurA => 'Central Java';

  @override
  String get miniGamesBrainBorobudurB => 'East Java';

  @override
  String get miniGamesBrainBorobudurC => 'West Java';

  @override
  String get miniGamesBrainBorobudurD => 'Bali';

  @override
  String get miniGamesBrainLaskarQ => 'Who wrote the novel Laskar Pelangi?';

  @override
  String get miniGamesBrainLaskarA => 'Andrea Hirata';

  @override
  String get miniGamesBrainLaskarB => 'Pramoedya Ananta Toer';

  @override
  String get miniGamesBrainLaskarC => 'Dee Lestari';

  @override
  String get miniGamesBrainLaskarD => 'Tere Liye';

  @override
  String get miniGamesBrainPancasilaQ =>
      'How many principles are in Pancasila?';

  @override
  String get miniGamesBrainPancasilaA => 'Five';

  @override
  String get miniGamesBrainPancasilaB => 'Three';

  @override
  String get miniGamesBrainPancasilaC => 'Four';

  @override
  String get miniGamesBrainPancasilaD => 'Six';

  @override
  String get miniGamesBrainCpuQ =>
      'What is the main processing component of a computer called?';

  @override
  String get miniGamesBrainCpuA => 'Processor';

  @override
  String get miniGamesBrainCpuB => 'Storage';

  @override
  String get miniGamesBrainCpuC => 'Monitor';

  @override
  String get miniGamesBrainCpuD => 'Keyboard';

  @override
  String get miniGamesBrainHttpsQ =>
      'What does HTTPS help provide on a website?';

  @override
  String get miniGamesBrainHttpsA => 'An encrypted connection';

  @override
  String get miniGamesBrainHttpsB => 'Larger images';

  @override
  String get miniGamesBrainHttpsC => 'Offline access';

  @override
  String get miniGamesBrainHttpsD => 'A faster processor';

  @override
  String get miniGamesBrainBinaryQ => 'Which digits are used in binary?';

  @override
  String get miniGamesBrainBinaryA => '0 and 1';

  @override
  String get miniGamesBrainBinaryB => '1 and 2';

  @override
  String get miniGamesBrainBinaryC => 'A and Z';

  @override
  String get miniGamesBrainBinaryD => '0 through 9';

  @override
  String get miniGamesBrainRouterQ => 'What is a router primarily used for?';

  @override
  String get miniGamesBrainRouterA => 'Connecting networks';

  @override
  String get miniGamesBrainRouterB => 'Printing documents';

  @override
  String get miniGamesBrainRouterC => 'Editing photos';

  @override
  String get miniGamesBrainRouterD => 'Storing passwords';
}

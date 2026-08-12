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
  String get protectionArtifactLabel => 'Protection model';

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
  String get roleMember => 'Member';

  @override
  String get onboardingGroupCode => 'Group code';

  @override
  String get introHeroTitle => 'break the cycle of\nonline gambling.';

  @override
  String get introHeroDesc =>
      'on-device intelligent detection, timely behavioral intervention, and a self-regulation journey for university students.';

  @override
  String get introAiShield => 'On-device AI Shield';

  @override
  String get introHowItWorksStep1 => 'download & install';

  @override
  String get introHowItWorksStep1Desc =>
      'install on Android or Windows with transparent platform permissions.';

  @override
  String get introHowItWorksStep3 => 'pause & recover';

  @override
  String get introHowItWorksStep2 => 'detect locally';

  @override
  String get introHowItWorksStep3Desc =>
      'Pattern Interrupt creates a pause, then psychoeducation supports your next step.';

  @override
  String get introHowItWorksStep2Desc =>
      'Hybrid AI analyzes bounded URL and DOM signals on your device.';

  @override
  String get introHowItWorksTitle => 'three steps toward\nmore control.';

  @override
  String get introHowItWorksSubtitle => 'how it works';

  @override
  String get introFeature1 => 'on-device AI & privacy';

  @override
  String get introFeaturesTitle => 'an ecosystem that\nsupports recovery.';

  @override
  String get introFeature3 => 'accountability partner';

  @override
  String get introFeature2 => 'content-based local detection';

  @override
  String get introFeature4 => 'accessible Pattern Interrupt';

  @override
  String get introCtaTitle => 'take the next step\ntoward control.';

  @override
  String get introCtaBtn => 'get started';

  @override
  String get introCtaDesc =>
      'A privacy-first prototype designed to help Indonesian university students pause and choose a constructive next step.';

  @override
  String get introCrisisSubtitle => 'a national challenge';

  @override
  String get introCrisisStat1 => '5.5M+';

  @override
  String get introCrisisStat1Desc => 'gambling content handled since 2017';

  @override
  String get introCrisisStat2 => '12.3M';

  @override
  String get introCrisisTitle =>
      'online gambling is not harmless.\nit affects a generation.';

  @override
  String get introCrisisSource => '(PPATK 2026 · Kemkomdigi 2025)';

  @override
  String get introCrisisDesc =>
      'Young people are heavily represented in reported online-gambling activity. University students need practical, privacy-respecting support.';

  @override
  String get introCrisisStat3Desc => 'people recorded making gambling deposits';

  @override
  String get introCrisisStat2Desc =>
      'reported online-gambling turnover in 2025';

  @override
  String get introStartBtn => 'Get started';

  @override
  String get roleLecturerPartner => 'Dosen / Pendamping';

  @override
  String get introSkip => 'Skip';

  @override
  String get introNext => 'Next';

  @override
  String get introPlatformAndroid => 'android';

  @override
  String get introPlatformWindows => 'windows';

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
  String get recoveryWebTitle => 'Recovery is available on the website';

  @override
  String get recoveryWebBody =>
      'Journals, check-ins, missions, and psychoeducation stay on the website so this app can focus on device protection.';

  @override
  String get recoveryWebAction => 'Open web recovery';

  @override
  String get backToProtection => 'Back to protection';

  @override
  String get webPageOpenError => 'The page could not be opened yet. Try again.';

  @override
  String get recoveryPageOpenError =>
      'The recovery page could not be opened yet. Try again.';

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
  String get recoveryWebEyebrow => 'continue on the web';

  @override
  String get quickActionsTitle => 'Quick actions';

  @override
  String get quickActionBreathe => 'Pause & Breathe';

  @override
  String get quickActionBreatheSubtitle =>
      'A short breathing exercise before continuing';

  @override
  String get quickActionRecovery => 'Recovery & Support';

  @override
  String get quickActionRecoverySubtitle => 'Open recovery guides and support';

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
}

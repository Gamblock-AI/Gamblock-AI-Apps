import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../core/auth/auth_state.dart';
import '../../core/config/app_config.dart';
import '../../core/feedback/feedback.dart';
import '../../core/messaging/app_messages.dart';
import '../../core/platform/platform_bridge.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import 'presentation/widgets/edit_profile_dialog.dart';
import 'presentation/widgets/logout_confirmation_dialog.dart';
import 'presentation/widgets/password_change_dialog.dart';
import 'presentation/widgets/settings_about_section.dart';
import 'presentation/widgets/settings_account_section.dart';
import 'presentation/widgets/settings_preferences_section.dart';
import 'presentation/widgets/settings_profile_card.dart';
import 'presentation/widgets/windows_settings_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  ProtectionSnapshot _snapshot = ProtectionSnapshot.fallback;
  String? _pairingToken;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadNativeInfo);
  }

  Future<void> _loadNativeInfo() async {
    final values = await Future.wait<Object?>([
      PlatformBridge.getProtectionSnapshot(),
      if (Platform.isWindows)
        PlatformBridge.getPairingToken()
      else
        Future<String?>.value(),
    ]);
    if (!mounted) return;
    setState(() {
      _snapshot = values[0] as ProtectionSnapshot;
      _pairingToken = values[1] as String?;
    });
  }

  Future<void> _editProfile() async {
    final auth = ref.read(authProvider);
    final value = await showEditProfileDialog(
      context,
      displayName: auth.displayName,
    );
    if (value == null || value.isEmpty || !mounted) return;
    try {
      await ref.read(authProvider.notifier).updateDisplayName(value);
      if (mounted) {
        AppFeedback.success(
          context,
          AppLocalizations.of(context)!.settingsProfileUpdated,
        );
      }
    } catch (error) {
      if (mounted) {
        AppFeedback.error(context, AppMessages.friendlyMessage(context, error));
      }
    }
  }

  Future<void> _changePassword() async {
    final changed = await showPasswordChangeDialog(
      context,
      onSubmit: (passwordChange) => ref
          .read(authProvider.notifier)
          .updatePassword(
            currentPassword: passwordChange.currentPassword,
            newPassword: passwordChange.newPassword,
          ),
    );
    if (!changed || !mounted) return;
    AppFeedback.success(
      context,
      AppLocalizations.of(context)!.settingsPasswordUpdated,
    );
    context.go('/login');
  }

  Future<void> _linkGoogle() async {
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _LinkGoogleDialog(),
    );
    if (password == null || password.isEmpty || !mounted) {
      return;
    }
    try {
      await ref.read(authProvider.notifier).linkGoogle(password);
      if (mounted) {
        AppFeedback.success(context, 'Akun Google berhasil ditautkan.');
      }
    } catch (error) {
      if (mounted) {
        AppFeedback.error(context, AppMessages.friendlyMessage(context, error));
      }
    }
  }

  Future<void> _logout() async {
    if (!await showLogoutConfirmationDialog(context)) return;
    await ref.read(authProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  Future<void> _copyPairingToken() async {
    final pairingToken = _pairingToken;
    if (pairingToken == null) return;
    await Clipboard.setData(ClipboardData(text: pairingToken));
    if (mounted) {
      AppFeedback.success(context, AppLocalizations.of(context)!.copied);
    }
  }

  Future<void> _rotatePairingToken() async {
    final token = await PlatformBridge.rotatePairingToken();
    if (mounted) setState(() => _pairingToken = token);
  }

  Future<void> _setHealthNotifications(bool enabled) async {
    await ref
        .read(appSettingsProvider.notifier)
        .setHealthNotifications(enabled);
    await PlatformBridge.setHealthNotifications(enabled);
  }

  Future<void> _openWebPath(String path) async {
    final opened = await launchUrl(
      AppConfig.webUri('${Localizations.localeOf(context).languageCode}/$path'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      AppFeedback.error(context, 'Halaman belum dapat dibuka. Coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final settings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.settings_rounded,
                size: 18,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.settingsTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
          if (auth.isAuthenticated) SettingsProfileCard(auth: auth),
          SettingsAccountSection(
            auth: auth,
            onEditProfile: _editProfile,
            onChangePassword: _changePassword,
            onManagePartner: () => context.go('/accountability'),
            onLogin: () => context.go('/login'),
            onLinkGoogle: _linkGoogle,
          ),
          SettingsPreferencesSection(
            locale: settings.locale,
            hapticsEnabled: settings.hapticsEnabled,
            healthNotificationsEnabled: settings.healthNotificationsEnabled,
            showHealthNotifications: Platform.isAndroid,
            onLocaleChanged: (locale) =>
                ref.read(appSettingsProvider.notifier).setLocale(locale),
            onHapticsChanged: (enabled) =>
                ref.read(appSettingsProvider.notifier).setHaptics(enabled),
            onHealthNotificationsChanged: _setHealthNotifications,
          ),
          if (Platform.isWindows) ...[
            WindowsSettingsSection(
              pairingToken: _pairingToken,
              onCopyToken: _copyPairingToken,
              onRotateToken: _rotatePairingToken,
            ),
          ],
          SettingsAboutSection(
            snapshot: _snapshot,
            onOpenPrivacy: () => _openWebPath('privacy'),
            onOpenHelp: () => _openWebPath('help'),
          ),
          if (auth.isAuthenticated) ...[
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: AppColors.crimson.withValues(alpha: 0.05),
              child: ListTile(
                minTileHeight: 60,
                onTap: _logout,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.crimson.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: AppColors.crimson,
                  ),
                ),
                title: Text(
                  l10n.settingsLogout,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.crimson,
                      ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.crimson,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LinkGoogleDialog extends StatefulWidget {
  const _LinkGoogleDialog();

  @override
  State<_LinkGoogleDialog> createState() => _LinkGoogleDialogState();
}

class _LinkGoogleDialogState extends State<_LinkGoogleDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEA4335), Color(0xFFD93025)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEA4335).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_link_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.linkGoogleTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                          letterSpacing: -0.3,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              obscureText: true,
              autofocus: true,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: l10n.settingsCurrentPassword,
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.navy, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: AppColors.navy,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFEA4335),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, _controller.text),
                      child: Text(
                        l10n.continueAction,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

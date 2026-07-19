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
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tautkan akun Google'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          decoration: const InputDecoration(labelText: 'Kata sandi saat ini'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
    controller.dispose();
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
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
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
            const Divider(height: 24),
            ListTile(
              minTileHeight: 56,
              leading: const Icon(Icons.logout, color: AppColors.crimson),
              title: Text(
                l10n.settingsLogout,
                style: const TextStyle(color: AppColors.crimson),
              ),
              onTap: _logout,
            ),
          ],
        ],
      ),
    );
  }
}

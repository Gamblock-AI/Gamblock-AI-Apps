import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../core/widgets/app_bar_title.dart';
import '../../core/auth/auth_state.dart';
import '../../core/feedback/feedback.dart';
import '../../core/messaging/app_messages.dart';
import '../../core/platform/platform_bridge.dart';
import '../../core/platform/platform_info.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'presentation/widgets/edit_profile_dialog.dart';
import 'presentation/widgets/logout_confirmation_dialog.dart';
import 'presentation/widgets/password_change_dialog.dart';
import 'presentation/widgets/rotate_pairing_confirmation_dialog.dart';
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
  String? _pairingToken;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadNativeInfo);
  }

  Future<void> _loadNativeInfo() async {
    if (!PlatformInfo.isWindows) return;
    final token = await PlatformBridge.getPairingToken();
    if (!mounted) return;
    setState(() => _pairingToken = token);
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
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsPasswordChangedTitle),
        content: Text(l10n.settingsPasswordChangedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.continueAction),
          ),
        ],
      ),
    );
    if (mounted) context.go('/login');
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
    if (!await showRotatePairingConfirmationDialog(context)) return;
    final token = await PlatformBridge.rotatePairingToken();
    if (!mounted) return;
    setState(() => _pairingToken = token);
    AppFeedback.success(
      context,
      AppLocalizations.of(context)!.settingsRotateSuccess,
    );
  }

  Future<void> _setHealthNotifications(bool enabled) async {
    await ref
        .read(appSettingsProvider.notifier)
        .setHealthNotifications(enabled);
    await PlatformBridge.setHealthNotifications(enabled);
  }

  Future<void> _setCheckInReminder(bool enabled) async {
    final accepted = await ref
        .read(appSettingsProvider.notifier)
        .setCheckInReminder(enabled);
    if (!accepted && mounted) {
      final l10n = AppLocalizations.of(context)!;
      AppFeedback.error(context, l10n.settingsReminderPermissionDenied);
    }
  }

  Future<void> _pickCheckInReminderTime() async {
    final current = ref.read(appSettingsProvider).checkInReminderTime;
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) {
      await ref
          .read(appSettingsProvider.notifier)
          .setCheckInReminderTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final settings = ref.watch(appSettingsProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        titleSpacing: 16,
        title: AppBarTitle(
          icon: Icons.settings_rounded,
          title: l10n.settingsTitle,
        ),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          if (auth.isAuthenticated) SettingsProfileCard(auth: auth),
          SettingsAccountSection(
            auth: auth,
            onEditProfile: _editProfile,
            onChangePassword: _changePassword,
            onLogin: () => context.go('/login'),
          ),
          SettingsPreferencesSection(
            locale: settings.locale,
            hapticsEnabled: settings.hapticsEnabled,
            healthNotificationsEnabled: settings.healthNotificationsEnabled,
            showHealthNotifications: PlatformInfo.isAndroid,
            onLocaleChanged: (locale) =>
                ref.read(appSettingsProvider.notifier).setLocale(locale),
            onHapticsChanged: (enabled) =>
                ref.read(appSettingsProvider.notifier).setHaptics(enabled),
            onHealthNotificationsChanged: _setHealthNotifications,
            showCheckInReminder:
                PlatformInfo.isAndroid || PlatformInfo.isWindows,
            checkInReminderEnabled: settings.checkInReminderEnabled,
            checkInReminderTime: settings.checkInReminderTime,
            onCheckInReminderChanged: _setCheckInReminder,
            onCheckInReminderTimeTap: _pickCheckInReminderTime,
          ),
          if (PlatformInfo.isWindows) ...[
            WindowsSettingsSection(
              pairingToken: _pairingToken,
              onCopyToken: _copyPairingToken,
              onRotateToken: _rotatePairingToken,
            ),
          ],
          SettingsAboutSection(
            onOpenPrivacy: () => context.go('/settings/privacy'),
            onOpenHelp: () => context.go('/settings/help'),
          ),
          if (auth.isAuthenticated) ...[
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
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

import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_section_label.dart';

/// Account actions that vary between authenticated and anonymous sessions.
class SettingsAccountSection extends StatelessWidget {
  const SettingsAccountSection({
    super.key,
    required this.auth,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onManagePartner,
    required this.onLogin,
  });

  final AuthState auth;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onManagePartner;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionLabel(title: l10n.settingsAccountSection),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              if (auth.isAuthenticated) ...[
                _settingsTile(
                  context,
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.navyLight,
                  title: l10n.settingsEditProfile,
                  onTap: onEditProfile,
                ),
                Divider(
                  height: 1,
                  indent: 54,
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                _settingsTile(
                  context,
                  icon: Icons.lock_outline_rounded,
                  iconColor: AppColors.navy,
                  title: l10n.settingsChangePassword,
                  onTap: onChangePassword,
                ),
                Divider(
                  height: 1,
                  indent: 54,
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                _settingsTile(
                  context,
                  icon: Icons.people_outline_rounded,
                  iconColor: AppColors.sage,
                  title: l10n.settingsAccountabilityPartner,
                  onTap: onManagePartner,
                ),
              ] else
                _settingsTile(
                  context,
                  icon: Icons.login_rounded,
                  iconColor: AppColors.navy,
                  title: l10n.authLoginBtn,
                  onTap: onLogin,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      minTileHeight: 60,
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                    fontSize: 11,
                  ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.mutedForeground,
      ),
    );
  }
}

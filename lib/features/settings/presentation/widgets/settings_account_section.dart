import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';

/// Account actions that vary between authenticated and anonymous sessions.
class SettingsAccountSection extends StatelessWidget {
  const SettingsAccountSection({
    super.key,
    required this.auth,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onManagePartner,
    required this.onLogin,
    required this.onLinkGoogle,
  });

  final AuthState auth;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onManagePartner;
  final VoidCallback onLogin;
  final VoidCallback onLinkGoogle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
          child: Text(
            l10n.settingsAccountSection.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedForeground,
                  letterSpacing: 1.1,
                ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              if (auth.isAuthenticated) ...[
                _settingsTile(
                  context,
                  icon: Icons.person_outline_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: l10n.settingsEditProfile,
                  onTap: onEditProfile,
                ),
                if (!auth.googleLinked && auth.passwordEnabled) ...[
                  Divider(
                    height: 1,
                    indent: 54,
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                  _settingsTile(
                    context,
                    icon: Icons.add_link_rounded,
                    iconColor: const Color(0xFFEA4335),
                    title: l10n.settingsLinkGoogle,
                    subtitle: l10n.settingsLinkGoogleDesc,
                    onTap: onLinkGoogle,
                  ),
                ],
                Divider(
                  height: 1,
                  indent: 54,
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                _settingsTile(
                  context,
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFFA855F7),
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
                  iconColor: const Color(0xFF10B981),
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
              color: AppColors.navy,
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

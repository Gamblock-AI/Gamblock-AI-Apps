import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_section_label.dart';

/// Shows static support links.
class SettingsAboutSection extends StatelessWidget {
  const SettingsAboutSection({
    super.key,
    required this.onOpenPrivacy,
    required this.onOpenHelp,
  });

  final VoidCallback onOpenPrivacy;
  final VoidCallback onOpenHelp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionLabel(title: l10n.settingsAboutSection),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              _settingsTile(
                context,
                icon: Icons.privacy_tip_outlined,
                iconColor: AppColors.sage,
                title: l10n.settingsPrivacy,
                onTap: onOpenPrivacy,
              ),
              Divider(
                height: 1,
                indent: 54,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              _settingsTile(
                context,
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.skyDark,
                title: l10n.settingsHelp,
                onTap: onOpenHelp,
              ),
              Divider(
                height: 1,
                indent: 54,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              _settingsTile(
                context,
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.navyLight,
                title: l10n.settingsAboutApp,
                subtitle: l10n.settingsAppVersion,
                showChevron: false,
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
    VoidCallback? onTap,
    bool showChevron = true,
  }) {
    return ListTile(
      minTileHeight: subtitle != null ? 64 : 60,
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
      trailing: showChevron && onTap != null
          ? const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedForeground,
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/platform/platform_bridge.dart';
import '../../../../core/theme/app_colors.dart';

/// Shows local artifact provenance and static support links.
class SettingsAboutSection extends StatelessWidget {
  const SettingsAboutSection({
    super.key,
    required this.snapshot,
    required this.onOpenPrivacy,
    required this.onOpenHelp,
  });

  final ProtectionSnapshot snapshot;
  final VoidCallback onOpenPrivacy;
  final VoidCallback onOpenHelp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
          child: Text(
            l10n.settingsAboutSection.toUpperCase(),
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
              _settingsTile(
                context,
                icon: Icons.memory_rounded,
                iconColor: const Color(0xFF64748B),
                title: l10n.settingsArtifacts,
                subtitle: '${snapshot.modelVersion} · ${snapshot.rulesetVersion}',
                showChevron: false,
              ),
              Divider(
                height: 1,
                indent: 54,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              _settingsTile(
                context,
                icon: Icons.privacy_tip_outlined,
                iconColor: const Color(0xFF10B981),
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
                iconColor: const Color(0xFF06B6D4),
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
                iconColor: const Color(0xFF8B5CF6),
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
      trailing: showChevron && onTap != null
          ? const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedForeground,
            )
          : null,
    );
  }
}

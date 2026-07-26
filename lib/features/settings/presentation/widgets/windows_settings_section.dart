import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_section_label.dart';

/// Displays Windows-only extension pairing controls.
class WindowsSettingsSection extends StatelessWidget {
  const WindowsSettingsSection({
    super.key,
    required this.pairingToken,
    required this.onCopyToken,
    required this.onRotateToken,
  });

  final String? pairingToken;
  final VoidCallback onCopyToken;
  final VoidCallback onRotateToken;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionLabel(title: l10n.settingsWindowsSection),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              ListTile(
                minTileHeight: 64,
                leading: _leadingChip(
                  Icons.extension_outlined,
                  AppColors.navyLight,
                ),
                title: Text(
                  l10n.settingsPairingToken,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                ),
                subtitle: Text(
                  pairingToken ?? l10n.settingsPairingUnavailable,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                      ),
                ),
                trailing: IconButton(
                  tooltip: l10n.copy,
                  onPressed: pairingToken == null ? null : onCopyToken,
                  icon: const Icon(Icons.copy),
                ),
              ),
              Divider(
                height: 1,
                indent: 54,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              ListTile(
                minTileHeight: 56,
                leading: _leadingChip(Icons.refresh, AppColors.amber),
                title: Text(
                  l10n.settingsRotatePairing,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                ),
                onTap: onRotateToken,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _leadingChip(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

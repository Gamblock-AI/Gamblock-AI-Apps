import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_section_label.dart';

/// Collects locale, haptic, and optional health-notification preferences.
class SettingsPreferencesSection extends StatelessWidget {
  const SettingsPreferencesSection({
    super.key,
    required this.locale,
    required this.hapticsEnabled,
    required this.healthNotificationsEnabled,
    required this.showHealthNotifications,
    required this.onLocaleChanged,
    required this.onHapticsChanged,
    required this.onHealthNotificationsChanged,
  });

  final Locale locale;
  final bool hapticsEnabled;
  final bool healthNotificationsEnabled;
  final bool showHealthNotifications;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<bool> onHapticsChanged;
  final ValueChanged<bool> onHealthNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionLabel(title: l10n.settingsPreferencesSection),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              ListTile(
                minTileHeight: 60,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.navyLight.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    size: 20,
                    color: AppColors.navyLight,
                  ),
                ),
                title: Text(
                  l10n.settingsLanguage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: locale.languageCode,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                      items: [
                        DropdownMenuItem(
                          value: 'id',
                          child: Text(l10n.languageId),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(l10n.languageEn),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) onLocaleChanged(Locale(value));
                      },
                    ),
                  ),
                ),
              ),
              Divider(
                height: 1,
                indent: 54,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              SwitchListTile(
                minTileHeight: 60,
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.skyDark.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.vibration_rounded,
                    size: 20,
                    color: AppColors.skyDark,
                  ),
                ),
                title: Text(
                  l10n.settingsHaptics,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                ),
                value: hapticsEnabled,
                onChanged: onHapticsChanged,
                activeTrackColor: AppColors.navy,
              ),
              if (showHealthNotifications) ...[
                Divider(
                  height: 1,
                  indent: 54,
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                SwitchListTile(
                  minTileHeight: 64,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      size: 20,
                      color: AppColors.amber,
                    ),
                  ),
                  title: Text(
                    l10n.settingsHealthNotifications,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                  ),
                  subtitle: Text(
                    l10n.settingsHealthNotificationsBody,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                          fontSize: 11,
                        ),
                  ),
                  value: healthNotificationsEnabled,
                  onChanged: onHealthNotificationsChanged,
                  activeTrackColor: AppColors.navy,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

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
      children: [
        AppSectionLabel(title: l10n.settingsPreferencesSection),
        ListTile(
          minTileHeight: 56,
          leading: const Icon(Icons.language),
          title: Text(l10n.settingsLanguage),
          trailing: DropdownButton<String>(
            value: locale.languageCode,
            items: [
              DropdownMenuItem(value: 'id', child: Text(l10n.languageId)),
              DropdownMenuItem(value: 'en', child: Text(l10n.languageEn)),
            ],
            onChanged: (value) {
              if (value != null) onLocaleChanged(Locale(value));
            },
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.vibration),
          title: Text(l10n.settingsHaptics),
          value: hapticsEnabled,
          onChanged: onHapticsChanged,
        ),
        if (showHealthNotifications)
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l10n.settingsHealthNotifications),
            subtitle: Text(l10n.settingsHealthNotificationsBody),
            value: healthNotificationsEnabled,
            onChanged: onHealthNotificationsChanged,
          ),
      ],
    );
  }
}

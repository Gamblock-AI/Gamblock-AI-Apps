import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import 'settings_legal_screen.dart';

/// In-app Privacy Policy, mirroring the website's PrivacyPage content.
class SettingsPrivacyScreen extends StatelessWidget {
  const SettingsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsLegalScreen(
      icon: Icons.privacy_tip_outlined,
      title: l10n.legalPrivacyTitle,
      updatedLabel: l10n.legalPrivacyUpdated,
      intro: l10n.legalPrivacyIntro,
      sections: [
        for (var i = 1; i <= 6; i++)
          SettingsLegalSection(
            title: _title(l10n, i),
            body: _body(l10n, i),
          ),
      ],
    );
  }

  String _title(AppLocalizations l10n, int i) {
    switch (i) {
      case 1:
        return l10n.legalPrivacyS1Title;
      case 2:
        return l10n.legalPrivacyS2Title;
      case 3:
        return l10n.legalPrivacyS3Title;
      case 4:
        return l10n.legalPrivacyS4Title;
      case 5:
        return l10n.legalPrivacyS5Title;
      default:
        return l10n.legalPrivacyS6Title;
    }
  }

  List<String> _body(AppLocalizations l10n, int i) {
    final text = switch (i) {
      1 => l10n.legalPrivacyS1Body,
      2 => l10n.legalPrivacyS2Body,
      3 => l10n.legalPrivacyS3Body,
      4 => l10n.legalPrivacyS4Body,
      5 => l10n.legalPrivacyS5Body,
      _ => l10n.legalPrivacyS6Body,
    };
    return text.split('\n');
  }
}

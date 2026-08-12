import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import 'settings_legal_screen.dart';

/// In-app Help Center, mirroring the website's HelpPage content.
class SettingsHelpScreen extends StatelessWidget {
  const SettingsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsLegalScreen(
      icon: Icons.help_outline_rounded,
      title: l10n.legalHelpTitle,
      updatedLabel: l10n.legalHelpUpdated,
      intro: l10n.legalHelpIntro,
      sections: [
        for (var i = 1; i <= 5; i++)
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
        return l10n.legalHelpS1Title;
      case 2:
        return l10n.legalHelpS2Title;
      case 3:
        return l10n.legalHelpS3Title;
      case 4:
        return l10n.legalHelpS4Title;
      default:
        return l10n.legalHelpS5Title;
    }
  }

  List<String> _body(AppLocalizations l10n, int i) {
    final text = switch (i) {
      1 => l10n.legalHelpS1Body,
      2 => l10n.legalHelpS2Body,
      3 => l10n.legalHelpS3Body,
      4 => l10n.legalHelpS4Body,
      _ => l10n.legalHelpS5Body,
    };
    return text.split('\n');
  }
}

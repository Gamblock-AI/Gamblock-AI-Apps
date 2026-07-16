import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/platform/platform_bridge.dart';
import '../../../../core/widgets/app_section_label.dart';

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
      children: [
        AppSectionLabel(title: l10n.settingsAboutSection),
        ListTile(
          minTileHeight: 64,
          leading: const Icon(Icons.memory),
          title: Text(l10n.settingsArtifacts),
          subtitle: Text(
            '${snapshot.modelVersion} · ${snapshot.rulesetVersion}',
          ),
        ),
        ListTile(
          minTileHeight: 56,
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(l10n.settingsPrivacy),
          onTap: onOpenPrivacy,
        ),
        ListTile(
          minTileHeight: 56,
          leading: const Icon(Icons.help_outline),
          title: Text(l10n.settingsHelp),
          onTap: onOpenHelp,
        ),
        ListTile(
          minTileHeight: 56,
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.settingsAboutApp),
          subtitle: Text(l10n.settingsAppVersion),
        ),
      ],
    );
  }
}

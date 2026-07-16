import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

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
      children: [
        AppSectionLabel(title: l10n.settingsWindowsSection),
        ListTile(
          minTileHeight: 64,
          leading: const Icon(Icons.extension_outlined),
          title: Text(l10n.settingsPairingToken),
          subtitle: Text(
            pairingToken ?? l10n.settingsPairingUnavailable,
            maxLines: 2,
          ),
          trailing: IconButton(
            tooltip: l10n.copy,
            onPressed: pairingToken == null ? null : onCopyToken,
            icon: const Icon(Icons.copy),
          ),
        ),
        ListTile(
          minTileHeight: 56,
          leading: const Icon(Icons.refresh),
          title: Text(l10n.settingsRotatePairing),
          onTap: onRotateToken,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

/// Makes a generated partner-invitation URL visible and copyable.
class PartnerInviteLinkCard extends StatelessWidget {
  const PartnerInviteLinkCard({
    super.key,
    required this.inviteUrl,
    required this.onCopy,
  });

  final String inviteUrl;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.partnerInviteLink,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SelectableText(inviteUrl),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onCopy,
              icon: const Icon(Icons.copy),
              label: Text(l10n.copy),
            ),
          ],
        ),
      ),
    );
  }
}

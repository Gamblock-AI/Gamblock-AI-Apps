import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

/// Provides the two native protection maintenance actions.
class ProtectionActions extends StatelessWidget {
  const ProtectionActions({
    super.key,
    required this.isLoading,
    required this.onOpenSetup,
    required this.onRunSelfTest,
  });

  final bool isLoading;
  final VoidCallback onOpenSetup;
  final VoidCallback onRunSelfTest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onOpenSetup,
            icon: const Icon(Icons.tune),
            label: Text(l10n.protectionSetupAction),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onRunSelfTest,
            icon: const Icon(Icons.science_outlined),
            label: Text(l10n.selfTestAction),
          ),
        ),
      ],
    );
  }
}

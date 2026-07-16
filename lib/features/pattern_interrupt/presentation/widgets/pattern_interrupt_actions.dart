import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

/// Keeps the available recovery choices in a predictable vertical action group.
class PatternInterruptActions extends StatelessWidget {
  const PatternInterruptActions({
    super.key,
    required this.ready,
    required this.onContinue,
    required this.onOpenGrounding,
    required this.onOpenHelp,
    required this.onLater,
  });

  final bool ready;
  final VoidCallback onContinue;
  final VoidCallback onOpenGrounding;
  final VoidCallback onOpenHelp;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: ready ? onContinue : null,
          icon: const Icon(Icons.open_in_new),
          label: Text(l10n.patternContinuePsychoeducation),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
          ),
          onPressed: ready ? onOpenGrounding : null,
          icon: const Icon(Icons.self_improvement),
          label: Text(l10n.patternGroundingAction),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: onOpenHelp,
          icon: const Icon(Icons.support_agent),
          label: Text(l10n.patternHelpAction),
        ),
        if (ready)
          TextButton(onPressed: onLater, child: Text(l10n.patternLaterAction)),
      ],
    );
  }
}

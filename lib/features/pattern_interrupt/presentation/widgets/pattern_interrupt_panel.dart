import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import 'pattern_breathing_orb.dart';
import 'pattern_interrupt_actions.dart';

/// The timed breathing state shown before recovery choices become available.
class PatternInterruptPanel extends StatelessWidget {
  const PatternInterruptPanel({
    super.key,
    required this.breathingAnimation,
    required this.disableAnimations,
    required this.secondsRemaining,
    required this.onContinue,
    required this.onOpenGrounding,
    required this.onOpenHelp,
    required this.onLater,
  });

  final Animation<double> breathingAnimation;
  final bool disableAnimations;
  final int secondsRemaining;
  final VoidCallback onContinue;
  final VoidCallback onOpenGrounding;
  final VoidCallback onOpenHelp;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ready = secondsRemaining == 0;
    return Column(
      key: const ValueKey('interrupt'),
      children: [
        PatternBreathingOrb(
          animation: breathingAnimation,
          disableAnimations: disableAnimations,
          semanticsLabel: l10n.patternBreatheLabel,
        ),
        const SizedBox(height: 30),
        Text(
          l10n.patternInterruptTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.patternBreatheDesc,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        Semantics(
          liveRegion: true,
          label: l10n.patternSecondsRemaining(secondsRemaining),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              ready
                  ? l10n.patternReady
                  : l10n.patternSecondsRemaining(secondsRemaining),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.skyLight,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        PatternInterruptActions(
          ready: ready,
          onContinue: onContinue,
          onOpenGrounding: onOpenGrounding,
          onOpenHelp: onOpenHelp,
          onLater: onLater,
        ),
      ],
    );
  }
}

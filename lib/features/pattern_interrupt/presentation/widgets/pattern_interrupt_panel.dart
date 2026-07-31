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
    required this.pauseProgress,
    required this.inhaling,
    required this.disableAnimations,
    required this.secondsRemaining,
    required this.onContinue,
    required this.onOpenGrounding,
    required this.onOpenHelp,
    required this.onLater,
  });

  final Animation<double> breathingAnimation;
  final Animation<double> pauseProgress;
  final bool inhaling;
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
    final phaseCue = disableAnimations
        ? l10n.patternPhaseStatic
        : inhaling
        ? l10n.patternPhaseInhale
        : l10n.patternPhaseExhale;
    return Column(
      key: const ValueKey('interrupt'),
      children: [
        PatternBreathingOrb(
          animation: breathingAnimation,
          progress: pauseProgress,
          disableAnimations: disableAnimations,
          semanticsLabel: l10n.patternBreatheLabel,
        ),
        // Fixed-height slot: the breath-phase cue crossfades without moving
        // anything below it.
        SizedBox(
          height: 24,
          child: Center(
            child: AnimatedSwitcher(
              duration: disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              child: Text(
                phaseCue,
                key: ValueKey(phaseCue),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
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
          child: disableAnimations
              ? _statusLabel(context, l10n, ready, secondsRemaining)
              : AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: _statusLabel(context, l10n, ready, secondsRemaining),
                ),
        ),
        const SizedBox(height: 28),
        PatternInterruptActions(
          ready: ready,
          disableAnimations: disableAnimations,
          onContinue: onContinue,
          onOpenGrounding: onOpenGrounding,
          onOpenHelp: onOpenHelp,
          onLater: onLater,
        ),
      ],
    );
  }

  Widget _statusLabel(
    BuildContext context,
    AppLocalizations l10n,
    bool ready,
    int secondsRemaining,
  ) => Container(
    constraints: const BoxConstraints(minWidth: 180),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
    ),
    child: Text(
      ready
          ? l10n.patternReady
          : l10n.patternSecondsRemaining(secondsRemaining),
      key: ValueKey(ready),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.skyLight,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    ),
  );
}

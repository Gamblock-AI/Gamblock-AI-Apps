import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.banner),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          key: const ValueKey('interrupt'),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(AppRadius.banner),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
          PatternBreathingOrb(
            animation: breathingAnimation,
            progress: pauseProgress,
            disableAnimations: disableAnimations,
            semanticsLabel: l10n.patternBreatheLabel,
          ),
          const SizedBox(height: 12),
          // Fixed-height slot: the breath-phase cue crossfades without moving
          // anything below it.
          SizedBox(
            height: AppSpacing.xl,
            child: Center(
              child: AnimatedSwitcher(
                duration: disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                child: Text(
                  phaseCue,
                  key: ValueKey(phaseCue),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.skyLight.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.patternInterruptTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.patternBreatheDesc,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 24),
          PatternInterruptActions(
            ready: ready,
            disableAnimations: disableAnimations,
            onContinue: onContinue,
            onOpenGrounding: onOpenGrounding,
            onOpenHelp: onOpenHelp,
            onLater: onLater,
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _statusLabel(
    BuildContext context,
    AppLocalizations l10n,
    bool ready,
    int secondsRemaining,
  ) => Container(
    constraints: const BoxConstraints(minWidth: 180),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: 10,
    ),
    decoration: BoxDecoration(
      color: ready
          ? AppColors.sage.withValues(alpha: 0.20)
          : AppColors.sky.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      border: Border.all(
        color: ready
            ? AppColors.sageLight.withValues(alpha: 0.5)
            : AppColors.sky.withValues(alpha: 0.35),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: (ready ? AppColors.sage : AppColors.sky).withValues(alpha: 0.2),
          blurRadius: 12,
          spreadRadius: -2,
        ),
      ],
    ),
    child: Text(
      ready
          ? l10n.patternReady
          : l10n.patternSecondsRemaining(secondsRemaining),
      key: ValueKey(ready),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: ready ? AppColors.sageLight : AppColors.skyLight,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    ),
  );
}

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

    return Column(
      key: const ValueKey('interrupt'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Floating Focus: Breathing Orb, Phase Cue, and Typography
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            PatternBreathingOrb(
              animation: breathingAnimation,
              progress: pauseProgress,
              disableAnimations: disableAnimations,
              semanticsLabel: l10n.patternBreatheLabel,
            ),
            const SizedBox(height: 10),
            // Floating Breath Phase Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.50),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                child: Text(
                  phaseCue,
                  key: ValueKey(phaseCue),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.skyLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.patternInterruptTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 21,
                letterSpacing: -0.3,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.70),
                    blurRadius: 14,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.patternBreatheDesc,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                height: 1.4,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.65),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Open Viewport Spacer: Allows the center video to be fully visible and highlighted
        const Spacer(),

        // Bottom Floating Action Dock
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    liveRegion: true,
                    label: l10n.patternSecondsRemaining(secondsRemaining),
                    child: disableAnimations
                        ? _statusLabel(context, l10n, ready, secondsRemaining)
                        : AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: _statusLabel(
                              context,
                              l10n,
                              ready,
                              secondsRemaining,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
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
    constraints: const BoxConstraints(minWidth: 160),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: ready
          ? AppColors.sage.withValues(alpha: 0.22)
          : AppColors.sky.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      border: Border.all(
        color: ready
            ? AppColors.sageLight.withValues(alpha: 0.6)
            : AppColors.sky.withValues(alpha: 0.45),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: (ready ? AppColors.sage : AppColors.sky).withValues(alpha: 0.25),
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
        fontSize: 13,
        letterSpacing: 0.3,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    ),
  );
}

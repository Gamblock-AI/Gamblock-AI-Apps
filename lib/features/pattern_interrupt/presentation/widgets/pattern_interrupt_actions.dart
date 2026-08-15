import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/feedback/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Keeps the available recovery choices in a predictable vertical action
/// group. Every slot is height-reserved so nothing jumps when the pause ends.
class PatternInterruptActions extends StatelessWidget {
  const PatternInterruptActions({
    super.key,
    required this.ready,
    required this.disableAnimations,
    required this.onContinue,
    required this.onOpenGrounding,
    required this.onOpenHelp,
    required this.onLater,
  });

  final bool ready;
  final bool disableAnimations;
  final VoidCallback onContinue;
  final VoidCallback onOpenGrounding;
  final VoidCallback onOpenHelp;
  final VoidCallback onLater;

  VoidCallback _withHaptic(VoidCallback callback) => () {
    Haptics.light();
    callback();
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final animationDuration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 300);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary recovery CTA (unlocked after 7s pause)
        AnimatedContainer(
          duration: animationDuration,
          curve: Curves.easeOutCubic,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            gradient: ready
                ? const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: ready ? null : Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: ready
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: ready ? AppColors.accentGlow : null,
          ),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: ready ? Colors.white : Colors.white.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            onPressed: ready ? _withHaptic(onContinue) : null,
            icon: Icon(
              ready ? Icons.arrow_forward_rounded : Icons.lock_outline_rounded,
              size: 20,
            ),
            label: Text(
              l10n.patternContinuePsychoeducation,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: ready ? Colors.white : Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Secondary grounding exercise CTA
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: ready ? Colors.white : Colors.white.withValues(alpha: 0.4),
              backgroundColor: ready ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
              side: BorderSide(
                color: ready
                    ? Colors.white.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            onPressed: ready ? _withHaptic(onOpenGrounding) : null,
            icon: const Icon(Icons.self_improvement_rounded, size: 20),
            label: Text(
              l10n.patternGroundingAction,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
                color: ready ? Colors.white : Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Help CTA
        SizedBox(
          height: 44,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withValues(alpha: 0.8),
            ),
            onPressed: _withHaptic(onOpenHelp),
            icon: const Icon(Icons.support_agent_rounded, size: 19),
            label: Text(
              l10n.patternHelpAction,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
          ),
        ),
        // Reserved slot: the "later" option fades in at the end of the pause
        SizedBox(
          height: 44,
          child: AnimatedOpacity(
            opacity: ready ? 1 : 0,
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !ready,
              child: ExcludeSemantics(
                excluding: !ready,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.65),
                  ),
                  onPressed: _withHaptic(onLater),
                  child: Text(
                    l10n.patternLaterAction,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
        AnimatedContainer(
          duration: animationDuration,
          curve: Curves.easeOut,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            gradient: ready
                ? const LinearGradient(
                    colors: [AppColors.sky, AppColors.skyDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: ready ? null : Colors.white.withValues(alpha: 0.1),
          ),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            onPressed: ready ? _withHaptic(onContinue) : null,
            icon: const Icon(Icons.open_in_new, size: 20),
            label: Text(
              l10n.patternContinuePsychoeducation,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            onPressed: ready ? _withHaptic(onOpenGrounding) : null,
            icon: const Icon(Icons.self_improvement, size: 20),
            label: Text(
              l10n.patternGroundingAction,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 48,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withValues(alpha: 0.7),
            ),
            onPressed: _withHaptic(onOpenHelp),
            icon: const Icon(Icons.support_agent, size: 20),
            label: Text(
              l10n.patternHelpAction,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        // Reserved slot: the "later" option fades in at the end of the pause
        // instead of inserting itself and shifting the layout.
        SizedBox(
          height: 48,
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
                    foregroundColor: Colors.white.withValues(alpha: 0.7),
                  ),
                  onPressed: _withHaptic(onLater),
                  child: Text(
                    l10n.patternLaterAction,
                    style: const TextStyle(fontWeight: FontWeight.w600),
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

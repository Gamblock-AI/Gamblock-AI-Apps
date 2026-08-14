import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/feedback/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/gami_image.dart';

class _GroundingStep {
  const _GroundingStep(this.count, this.icon);

  final int count;
  final IconData icon;
}

const _steps = [
  _GroundingStep(5, Icons.visibility_outlined),
  _GroundingStep(4, Icons.back_hand_outlined),
  _GroundingStep(3, Icons.hearing_rounded),
  _GroundingStep(2, Icons.air_rounded),
  _GroundingStep(1, Icons.shield_outlined),
];

/// Interactive 5-4-3-2-1 grounding: one sense per step, gentle progress dots,
/// and a calm completion state. The return-to-protection exit stays available
/// on every step — the exercise never traps.
class PatternGroundingPanel extends StatefulWidget {
  const PatternGroundingPanel({
    super.key,
    required this.onReturnToProtection,
    this.onCompleted,
  });

  final VoidCallback onReturnToProtection;

  /// Invoked exactly once when the final step is completed, with the time
  /// spent in the exercise. The panel stays Riverpod-free.
  final void Function(Duration elapsed)? onCompleted;

  @override
  State<PatternGroundingPanel> createState() => _PatternGroundingPanelState();
}

class _PatternGroundingPanelState extends State<PatternGroundingPanel> {
  int _stepIndex = 0;
  final DateTime _startedAt = DateTime.now();

  bool get _completed => _stepIndex >= _steps.length;

  void _advance() {
    if (_completed) return;
    setState(() => _stepIndex += 1);
    if (_stepIndex >= _steps.length) {
      Haptics.success();
      widget.onCompleted?.call(DateTime.now().difference(_startedAt));
    } else {
      Haptics.selection();
    }
  }

  String _stepTitle(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.groundingStep1Title;
      case 1:
        return l10n.groundingStep2Title;
      case 2:
        return l10n.groundingStep3Title;
      case 3:
        return l10n.groundingStep4Title;
      default:
        return l10n.groundingStep5Title;
    }
  }

  String _stepBody(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.groundingStep1Body;
      case 1:
        return l10n.groundingStep2Body;
      case 2:
        return l10n.groundingStep3Body;
      case 3:
        return l10n.groundingStep4Body;
      default:
        return l10n.groundingStep5Body;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const ValueKey('grounding'),
      children: [
        Text(
          l10n.patternGroundingTitle,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!_completed)
          Text(
            l10n.groundingStepProgress(_stepIndex + 1, _steps.length),
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 220),
          child: _completed
              ? _CompletionContent(key: const ValueKey('done'), l10n: l10n)
              : _StepContent(
                  key: ValueKey(_stepIndex),
                  step: _steps[_stepIndex],
                  title: _stepTitle(l10n, _stepIndex),
                  body: _stepBody(l10n, _stepIndex),
                ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _steps.length; i++)
              AnimatedContainer(
                duration: disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                width: (!_completed && i == _stepIndex) ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _completed
                      ? AppColors.sage
                      : i < _stepIndex
                      ? AppColors.sky
                      : i == _stepIndex
                      ? AppColors.skyLight
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              gradient: _completed
                  ? const LinearGradient(
                      colors: [AppColors.sage, AppColors.sageDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [AppColors.sky, AppColors.skyDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              onPressed: _completed
                  ? () {
                      Haptics.light();
                      widget.onReturnToProtection();
                    }
                  : _advance,
              icon: Icon(
                _completed
                    ? Icons.home_rounded
                    : _stepIndex == _steps.length - 1
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
                size: 20,
              ),
              label: Text(
                _completed
                    ? l10n.patternReturnProtection
                    : _stepIndex == _steps.length - 1
                    ? l10n.groundingDone
                    : l10n.groundingNext,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        if (!_completed) ...[
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.6),
              ),
              onPressed: widget.onReturnToProtection,
              child: Text(
                l10n.patternReturnProtection,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    super.key,
    required this.step,
    required this.title,
    required this.body,
  });

  final _GroundingStep step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.skyLight.withValues(alpha: 0.14),
                border: Border.all(
                  color: AppColors.skyLight.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(step.icon, size: 40, color: AppColors.skyLight),
            ),
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sky,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${step.count}',
                  style: const TextStyle(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            body,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletionContent extends StatelessWidget {
  const _CompletionContent({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        const GamiImage(
          asset: 'assets/images/gami-meditate.webp',
          height: 110,
          cacheWidth: 330,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.groundingCompleteTitle,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            l10n.groundingCompleteBody,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../domain/tour_step.dart';
import 'dashboard_tour_controller.dart';
import 'tour_registry.dart';

const double _spotlightRadius = 14;
const double _spotlightGap = 12;
const double _margin = 16;

/// Resolves a tour copy key to its localized string.
String _tourTitle(AppLocalizations l10n, String key) {
  switch (key) {
    case 'tourWelcomeTitle':
      return l10n.tourWelcomeTitle;
    case 'tourHeroTitle':
      return l10n.tourHeroTitle;
    case 'tourProtectionTitle':
      return l10n.tourProtectionTitle;
    case 'tourFabTitle':
      return l10n.tourFabTitle;
    case 'tourNavTitle':
      return l10n.tourNavTitle;
    case 'tourProfileTitle':
      return l10n.tourProfileTitle;
  }
  return '';
}

String _tourBody(AppLocalizations l10n, String key) {
  switch (key) {
    case 'tourWelcomeBody':
      return l10n.tourWelcomeBody;
    case 'tourHeroBody':
      return l10n.tourHeroBody;
    case 'tourProtectionBody':
      return l10n.tourProtectionBody;
    case 'tourFabBody':
      return l10n.tourFabBody;
    case 'tourNavBody':
      return l10n.tourNavBody;
    case 'tourProfileBody':
      return l10n.tourProfileBody;
  }
  return '';
}

/// Dims everything except the rounded spotlight over the target widget.
class _SpotlightDimPainter extends CustomPainter {
  const _SpotlightDimPainter(this.spotlight);

  final Rect spotlight;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(spotlight, const Radius.circular(20)));
    canvas.drawPath(path, Paint()..color = const Color(0x8C0A1428));
    canvas.drawRRect(
      RRect.fromRectAndRadius(spotlight, const Radius.circular(20)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_SpotlightDimPainter oldDelegate) =>
      oldDelegate.spotlight != spotlight;
}

/// Full-screen tour overlay: interaction blocker + spotlight + bubble. The
/// owning host builds it only while the tour is open; targets whose widget is
/// not mounted (e.g. the center FAB on a wide layout) auto-skip.
class DashboardTourOverlay extends ConsumerStatefulWidget {
  const DashboardTourOverlay({super.key});

  @override
  ConsumerState<DashboardTourOverlay> createState() =>
      _DashboardTourOverlayState();
}

class _DashboardTourOverlayState extends ConsumerState<DashboardTourOverlay> {
  Rect? _rect;
  bool _skipAttempted = false;

  @override
  void initState() {
    super.initState();
    _measure();
  }

  @override
  void didUpdateWidget(covariant DashboardTourOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _skipAttempted = false;
    _measure();
  }

  void _measure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tour = ref.read(dashboardTourProvider);
      if (!tour.open) return;
      final step = kDashboardTourSteps[tour.index];
      final rect = ref.read(tourRegistryProvider).rectOf(step.targetKey);
      if (rect == null) {
        final canSkip = tour.index < kDashboardTourSteps.length - 1;
        if (canSkip && !_skipAttempted) {
          _skipAttempted = true;
          ref.read(dashboardTourProvider.notifier).next();
        } else {
          setState(() => _rect = null);
        }
        return;
      }
      setState(() => _rect = rect);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tour = ref.watch(dashboardTourProvider);
    ref.listen(dashboardTourProvider, (previous, next) {
      if (previous?.index != next.index) {
        _skipAttempted = false;
        _measure();
      }
    });
    final step = kDashboardTourSteps[tour.index];
    final l10n = AppLocalizations.of(context)!;
    final screen = MediaQuery.sizeOf(context);
    final rect = _rect;
    final spotlightRect = rect != null
        ? rect.inflate(_spotlightRadius)
        : const Rect.fromLTWH(0, 0, 1, 1);

    return Semantics(
      label: l10n.tourLabel,
      child: Stack(
        children: [
          // Interaction blocker: absorbs taps and dims the background.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: CustomPaint(painter: _SpotlightDimPainter(spotlightRect)),
            ),
          ),
          if (rect != null)
            _TourBubble(
              step: step,
              title: _tourTitle(l10n, step.titleKey),
              body: _tourBody(l10n, step.bodyKey),
              index: tour.index,
              total: kDashboardTourSteps.length,
              screenSize: screen,
              targetRect: rect,
              onSkip: () => ref.read(dashboardTourProvider.notifier).close(),
              onBack: () => ref.read(dashboardTourProvider.notifier).back(),
              onNext: () => tour.index >= kDashboardTourSteps.length - 1
                  ? ref.read(dashboardTourProvider.notifier).close()
                  : ref.read(dashboardTourProvider.notifier).next(),
            ),
        ],
      ),
    );
  }
}

class _TourBubble extends StatelessWidget {
  const _TourBubble({
    required this.step,
    required this.title,
    required this.body,
    required this.index,
    required this.total,
    required this.screenSize,
    required this.targetRect,
    required this.onSkip,
    required this.onBack,
    required this.onNext,
  });

  final TourStep step;
  final String title;
  final String body;
  final int index;
  final int total;
  final Size screenSize;
  final Rect targetRect;
  final VoidCallback onSkip;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bubbleWidth = (screenSize.width - _margin * 2).clamp(0.0, 360.0);
    final bubbleHeight = 190.0;
    final below = targetRect.bottom + _spotlightGap;
    final top = below + bubbleHeight > screenSize.height - _margin
        ? (targetRect.top - _spotlightGap - bubbleHeight).clamp(
            _margin,
            screenSize.height - bubbleHeight - _margin,
          )
        : below;
    final left = (targetRect.center.dx - bubbleWidth / 2)
        .clamp(_margin, screenSize.width - bubbleWidth - _margin)
        .toDouble();

    return Positioned(
      left: left,
      top: top.toDouble(),
      width: bubbleWidth,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardSoftShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                        height: 1.25,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onSkip,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.mutedForeground,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.tourStepOf(index + 1, total),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedForeground,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mutedForeground,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        decoration: TextDecoration.none,
                      ),
                    ),
                    child: Text(l10n.tourSkip),
                  ),
                  if (index > 0)
                    TextButton(
                      onPressed: onBack,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          decoration: TextDecoration.none,
                        ),
                      ),
                      child: Text(l10n.tourBack),
                    ),
                  FilledButton(
                    onPressed: onNext,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        decoration: TextDecoration.none,
                      ),
                    ),
                    child: Text(
                      index >= total - 1 ? l10n.tourDone : l10n.tourNext,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/feedback/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/language_toggle_button.dart';
import '../widgets/intro_arrow_button.dart';
import '../widgets/onboarding_slide.dart';
import '../../data/onboarding_state.dart';

/// Three-page motivational intro flow. Each page pairs a gradient wave header
/// (sky → navy → crimson) with an animated Gami pose; swiping triggers a
/// staggered entrance and a layered parallax so the flow feels alive.
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = 3;

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).complete();
    if (mounted) context.go('/login');
  }

  void _next() {
    if (_page < _pages - 1) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _ctrl.jumpToPage(_page + 1);
      } else {
        _ctrl.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    } else {
      _finish();
    }
  }

  void _onPageChanged(int i) {
    if (i != _page) Haptics.selection();
    setState(() => _page = i);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final slides = [
      (
        header: AppColors.sky,
        headerDark: const Color(0xFF2BB4D4),
        text: AppColors.navyDark,
        asset: 'assets/images/gami-hug-heart.webp',
        lead: l10n.introSlide1Lead,
        highlight: l10n.introSlide1Highlight,
        tail: l10n.introSlide1Tail,
        subtitle: l10n.introSlide1Subtitle,
        doodleColor: const Color(0xFF2BB4D4),
        showHeart: true,
      ),
      (
        header: AppColors.navy,
        headerDark: AppColors.navyDark,
        text: Colors.white,
        asset: 'assets/images/gami-relax.webp',
        lead: l10n.introSlide2Lead,
        highlight: l10n.introSlide2Highlight,
        tail: l10n.introSlide2Tail,
        subtitle: l10n.introSlide2Subtitle,
        doodleColor: AppColors.navy,
        showHeart: false,
      ),
      (
        header: AppColors.crimson,
        headerDark: AppColors.crimsonDark,
        text: Colors.white,
        asset: 'assets/images/gami-coffee.webp',
        lead: l10n.introSlide3Lead,
        highlight: l10n.introSlide3Highlight,
        tail: l10n.introSlide3Tail,
        subtitle: l10n.introSlide3Subtitle,
        doodleColor: AppColors.crimson,
        showHeart: false,
      ),
    ];

    final current = slides[_page];
    // Contrast color for overlay chrome (indicators, close icon) on the
    // colored header: dark ink on sky, white on navy/crimson.
    final onHeader = current.text;
    final isLast = _page == _pages - 1;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final page = _ctrl.hasClients ? (_ctrl.page ?? 0.0) : 0.0;
              return PageView(
                controller: _ctrl,
                onPageChanged: _onPageChanged,
                children: [
                  for (final (i, slide) in slides.indexed)
                    OnboardingSlide(
                      headerColor: slide.header,
                      headerDark: slide.headerDark,
                      textColor: slide.text,
                      markerColor: slide.text == Colors.white
                          ? (slide.header == AppColors.navy
                                ? AppColors.sky
                                : Colors.white)
                          : AppColors.navyDark,
                      asset: slide.asset,
                      lead: slide.lead,
                      highlight: slide.highlight,
                      tail: slide.tail,
                      subtitle: slide.subtitle,
                      doodleColor: slide.doodleColor,
                      showHeart: slide.showHeart,
                      stepBadge: l10n.introStepOf(i + 1, _pages),
                      isActive: i == _page,
                      parallax: (page - i).clamp(-1.0, 1.0),
                    ),
                ],
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const LanguageToggleButton(),
                  IconButton(
                    onPressed: _finish,
                    tooltip: l10n.introSkip,
                    icon: Icon(Icons.close_rounded, color: onHeader),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 64),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_pages, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 26,
                      height: 4,
                      decoration: BoxDecoration(
                        color: active
                            ? onHeader
                            : onHeader.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntroArrowButton(
                      color: current.header,
                      iconColor: current.text,
                      onPressed: _next,
                      semanticLabel: isLast
                          ? l10n.introStartBtn
                          : l10n.introNext,
                      pulse: isLast,
                    ),
                    if (isLast) ...[
                      const SizedBox(height: 10),
                      Text(
                        l10n.introStartBtn,
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

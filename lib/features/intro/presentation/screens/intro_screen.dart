import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/feedback/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/language_toggle_button.dart';
import '../../data/onboarding_state.dart';
import '../widgets/intro_arrow_button.dart';
import '../widgets/onboarding_slide.dart';

/// Three-page motivational intro flow with responsive, full-bleed Gami art.
/// Flutter owns all copy and controls so localization and accessibility remain
/// independent from the generated background assets.
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  static const _pages = 3;
  static const _portraitAssets = [
    'assets/images/onboarding-protect-portrait.webp',
    'assets/images/onboarding-pause-portrait.webp',
    'assets/images/onboarding-control-portrait.webp',
  ];
  static const _landscapeAssets = [
    'assets/images/onboarding-protect-landscape.webp',
    'assets/images/onboarding-pause-landscape.webp',
    'assets/images/onboarding-control-landscape.webp',
  ];

  final _ctrl = PageController();
  int _page = 0;
  bool? _precacheLandscape;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final useLandscape = OnboardingSlide.usesLandscapeLayout(
      MediaQuery.sizeOf(context),
    );
    if (_precacheLandscape == useLandscape) return;

    _precacheLandscape = useLandscape;
    final assets = useLandscape ? _landscapeAssets : _portraitAssets;
    for (final asset in assets) {
      unawaited(precacheImage(AssetImage(asset), context));
    }
  }

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
      unawaited(_finish());
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
        portraitAsset: _portraitAssets[0],
        landscapeAsset: _landscapeAssets[0],
        lead: l10n.introSlide1Lead,
        highlight: l10n.introSlide1Highlight,
        tail: l10n.introSlide1Tail,
        subtitle: l10n.introSlide1Subtitle,
        markerColor: AppColors.sky,
        actionColor: AppColors.sky,
        actionForeground: AppColors.navyDark,
      ),
      (
        portraitAsset: _portraitAssets[1],
        landscapeAsset: _landscapeAssets[1],
        lead: l10n.introSlide2Lead,
        highlight: l10n.introSlide2Highlight,
        tail: l10n.introSlide2Tail,
        subtitle: l10n.introSlide2Subtitle,
        markerColor: AppColors.sky,
        actionColor: AppColors.sky,
        actionForeground: AppColors.navyDark,
      ),
      (
        portraitAsset: _portraitAssets[2],
        landscapeAsset: _landscapeAssets[2],
        lead: l10n.introSlide3Lead,
        highlight: l10n.introSlide3Highlight,
        tail: l10n.introSlide3Tail,
        subtitle: l10n.introSlide3Subtitle,
        markerColor: AppColors.amber,
        actionColor: AppColors.crimson,
        actionForeground: Colors.white,
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.navyDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.navyDark,
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
                        portraitAsset: slide.portraitAsset,
                        landscapeAsset: slide.landscapeAsset,
                        markerColor: slide.markerColor,
                        lead: slide.lead,
                        highlight: slide.highlight,
                        tail: slide.tail,
                        subtitle: slide.subtitle,
                        isActive: i == _page,
                        parallax: (page - i).clamp(-1.0, 1.0),
                        action: IntroArrowButton(
                          color: slide.actionColor,
                          iconColor: slide.actionForeground,
                          onPressed: _next,
                          semanticLabel: i == _pages - 1
                              ? l10n.introStartBtn
                              : l10n.introNext,
                          label: i == _pages - 1 ? l10n.introStartBtn : null,
                          pulse: i == _page && i == _pages - 1,
                        ),
                      ),
                  ],
                );
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: const LanguageToggleButton(),
                    ),
                    TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.navyDark.withValues(
                          alpha: 0.56,
                        ),
                        overlayColor: Colors.white,
                        minimumSize: const Size(72, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(l10n.introSkip),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 68),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_pages, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 3.5),
                          width: active ? 28 : 8,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.24,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

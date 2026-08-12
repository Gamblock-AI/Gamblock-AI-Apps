import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_helpers.dart';
import '../../../../core/widgets/language_toggle_button.dart';
import '../../../../core/widgets/mesh_background.dart';
import '../widgets/hero_slide.dart';
import '../widgets/how_it_works_slide.dart';
import '../widgets/cta_slide.dart';
import '../../data/onboarding_state.dart';

/// Light intro flow mirroring the web landing page (pastel mesh + brand accents).
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

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: MeshBackground(
        child: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [HeroSlide(), HowItWorksSlide(), CtaSlide()],
              ),
              Positioned(
                top: 10,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const LanguageToggleButton(),
                    TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        minimumSize: const Size(48, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
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
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_pages, (i) {
                              final active = i == _page;
                              return AnimatedContainer(
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                    ? Duration.zero
                                    : const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: active ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.blueAccent
                                      : AppColors.navy.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 18),
                          darkCtaButton(
                            context,
                            _page == _pages - 1
                                ? l10n.introStartBtn
                                : l10n.introNext,
                            _next,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

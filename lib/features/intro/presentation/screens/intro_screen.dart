import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_helpers.dart';
import '../../../../core/widgets/mesh_background.dart';
import '../widgets/hero_slide.dart';
import '../widgets/crisis_slide.dart';
import '../widgets/how_it_works_slide.dart';
import '../widgets/features_slide.dart';
import '../widgets/cta_slide.dart';

/// Light intro flow mirroring the web landing page (pastel mesh + brand accents).
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = 5;

  void _next() {
    if (_page < _pages - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeshBackground(
        child: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  HeroSlide(),
                  CrisisSlide(),
                  HowItWorksSlide(),
                  FeaturesSlide(),
                  CtaSlide(),
                ],
              ),
              Positioned(
                top: 12,
                right: 12,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Lewati',
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.crimson
                                : AppColors.navy.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    darkCtaButton(
                      context,
                      _page == _pages - 1
                          ? AppLocalizations.of(context)!.introStartBtn
                          : 'Lanjut',
                      _next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/pattern_grounding_panel.dart';
import '../widgets/pattern_interrupt_panel.dart';

class PatternInterruptScreen extends StatefulWidget {
  const PatternInterruptScreen({super.key});

  @override
  State<PatternInterruptScreen> createState() => _PatternInterruptScreenState();
}

class _PatternInterruptScreenState extends State<PatternInterruptScreen>
    with SingleTickerProviderStateMixin {
  static const _durationSeconds = 7;

  late final AnimationController _breathingController;
  Timer? _timer;
  int _remaining = _durationSeconds;
  bool _groundingOpen = false;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0,
      upperBound: 1,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _remaining = (_remaining - 1).clamp(0, _durationSeconds));
      if (_remaining == 0) timer.cancel();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _breathingController.stop();
    } else if (!_breathingController.isAnimating) {
      _breathingController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    super.dispose();
  }

  Future<void> _openWeb(String path) async {
    await launchUrl(
      AppConfig.webUri(
        '${Localizations.localeOf(context).languageCode}/$path',
        queryParameters: path == 'post-intervention'
            ? const {'source': 'pattern_interrupt'}
            : const {},
      ),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _remaining == 0;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return PopScope(
      canPop: ready,
      child: Scaffold(
        backgroundColor: AppColors.navyDark,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: AnimatedSwitcher(
                  duration: disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  child: _groundingOpen
                      ? PatternGroundingPanel(
                          onReturnToProtection: () => context.go('/protection'),
                        )
                      : PatternInterruptPanel(
                          breathingAnimation: _breathingController,
                          disableAnimations: disableAnimations,
                          secondsRemaining: _remaining,
                          onContinue: () => _openWeb('post-intervention'),
                          onOpenGrounding: () =>
                              setState(() => _groundingOpen = true),
                          onOpenHelp: () => _openWeb('help'),
                          onLater: () => context.go('/protection'),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

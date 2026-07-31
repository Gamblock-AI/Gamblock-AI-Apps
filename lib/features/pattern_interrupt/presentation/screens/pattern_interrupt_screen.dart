import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/feedback/feedback.dart';
import '../../../../core/feedback/haptics.dart';

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
    with TickerProviderStateMixin {
  static const _durationSeconds = 7;

  late final AnimationController _breathingController;
  late final AnimationController _ringController;
  Timer? _timer;
  int _remaining = _durationSeconds;
  bool _groundingOpen = false;
  bool _showWaitHint = false;
  bool _inhaling = true;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0,
      upperBound: 1,
    );
    _breathingController.addStatusListener((status) {
      if (!mounted) return;
      if (status == AnimationStatus.forward) {
        setState(() => _inhaling = true);
      } else if (status == AnimationStatus.reverse) {
        setState(() => _inhaling = false);
      }
    });
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _durationSeconds),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _remaining = (_remaining - 1).clamp(0, _durationSeconds));
      if (_remaining == 0) {
        timer.cancel();
        Haptics.success();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _breathingController.stop();
      _ringController.stop();
    } else {
      if (!_breathingController.isAnimating) {
        _breathingController.repeat(reverse: true);
      }
      if (_remaining > 0 && !_ringController.isAnimating) {
        _ringController.forward();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  /// Normal path: the 7s controller sweeps the ring. Reduced motion: a
  /// discrete once-per-second value with no decorative motion.
  Animation<double> get _pauseProgress =>
      MediaQuery.disableAnimationsOf(context)
      ? AlwaysStoppedAnimation(
          (_durationSeconds - _remaining) / _durationSeconds,
        )
      : _ringController;

  Future<void> _openWeb(String path) async {
    final opened = await launchUrl(
      AppConfig.webUri(
        '${Localizations.localeOf(context).languageCode}/$path',
        queryParameters: path == 'post-intervention'
            ? const {'source': 'pattern_interrupt'}
            : const {},
      ),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      AppFeedback.error(
        context,
        AppLocalizations.of(context)!.helpPageOpenError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _remaining == 0;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return PopScope(
      canPop: ready,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_showWaitHint) setState(() => _showWaitHint = true);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.calmDarkGradient),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      disableAnimations
                          ? _interruptContent(disableAnimations)
                          : AnimatedSize(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.topCenter,
                              child: _interruptContent(disableAnimations),
                            ),
                      // Fixed-height slot: the back-press hint fades in without
                      // shifting the panel above it.
                      SizedBox(
                        height: 36,
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: _showWaitHint && !ready && !_groundingOpen
                                ? 1.0
                                : 0.0,
                            duration: disableAnimations
                                ? Duration.zero
                                : const Duration(milliseconds: 250),
                            child: Text(
                              AppLocalizations.of(context)!.patternWaitHint,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _interruptContent(bool disableAnimations) => AnimatedSwitcher(
    duration: disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220),
    child: _groundingOpen
        ? PatternGroundingPanel(
            onReturnToProtection: () => context.go('/dashboard'),
          )
        : PatternInterruptPanel(
            breathingAnimation: _breathingController,
            pauseProgress: _pauseProgress,
            inhaling: _inhaling,
            disableAnimations: disableAnimations,
            secondsRemaining: _remaining,
            onContinue: () => _openWeb('post-intervention'),
            onOpenGrounding: () => setState(() => _groundingOpen = true),
            onOpenHelp: () => _openWeb('help'),
            onLater: () => context.go('/dashboard'),
          ),
  );
}

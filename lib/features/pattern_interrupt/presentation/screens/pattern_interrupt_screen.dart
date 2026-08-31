import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/feedback/feedback.dart';
import '../../../../core/feedback/haptics.dart';
import '../../../../core/platform/platform_bridge.dart';
import '../../../../core/platform/protection_timing_contract.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_dimens.dart';
import '../widgets/pattern_grounding_panel.dart';
import '../widgets/pattern_interrupt_panel.dart';
import '../widgets/pattern_video_background.dart';

class PatternInterruptScreen extends StatefulWidget {
  const PatternInterruptScreen({super.key, this.interventionId = ''});

  final String interventionId;

  @override
  State<PatternInterruptScreen> createState() => _PatternInterruptScreenState();
}

class _PatternInterruptScreenState extends State<PatternInterruptScreen>
    with TickerProviderStateMixin {
  static const _durationSeconds =
      ProtectionTimingContract.patternInterruptSeconds;

  late final AnimationController _breathingController;
  late final AnimationController _ringController;
  Timer? _timer;
  int _remaining = _durationSeconds;
  bool _groundingOpen = false;
  bool _showWaitHint = false;
  bool _inhaling = true;
  bool _visibleAcknowledged = false;
  bool _completed = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_ackVisible());
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _remaining = (_remaining - 1).clamp(0, _durationSeconds));
      if (_remaining == 0) {
        timer.cancel();
        Haptics.success();
      }
    });
  }

  Future<void> _ackVisible() async {
    if (_visibleAcknowledged || widget.interventionId.isEmpty) return;
    _visibleAcknowledged = true;
    final accepted = await _retryNativeConfirmation(
      () => PlatformBridge.ackInterventionVisible(widget.interventionId),
    );
    if (!accepted && mounted) context.go('/dashboard');
  }

  Future<void> _completeIntervention() async {
    if (_completed || widget.interventionId.isEmpty) return;
    _completed = true;
    await _retryNativeConfirmation(
      () => PlatformBridge.completeIntervention(widget.interventionId),
    );
  }

  Future<bool> _retryNativeConfirmation(
    Future<bool> Function() operation,
  ) async {
    for (var attempt = 0; attempt < 4; attempt++) {
      if (await operation()) return true;
      if (attempt < 3) {
        await Future<void>.delayed(Duration(milliseconds: 200 * (attempt + 1)));
      }
    }
    return false;
  }

  Future<void> _completeAndGo(String location) async {
    await _completeIntervention();
    if (mounted) context.go(location);
  }

  Future<void> _completeAndOpenWeb(String path) async {
    await _completeIntervention();
    if (mounted) await _openWeb(path);
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
        if (didPop) {
          unawaited(_completeIntervention());
          return;
        }
        if (!didPop && !_showWaitHint) setState(() => _showWaitHint = true);
      },
      child: Scaffold(
        body: PatternVideoBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const horizontalPadding = AppSpacing.lg;
                const verticalPadding = 16.0;
                final availableHeight =
                    constraints.maxHeight - (verticalPadding * 2);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: availableHeight > 0 ? availableHeight : 0,
                        maxWidth: 480,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _interruptContent(disableAnimations),
                            ),
                            // Fixed-height slot: the back-press hint fades in without
                            // shifting the panel above it.
                            SizedBox(
                              height: 32,
                              child: Center(
                                child: AnimatedOpacity(
                                  opacity:
                                      _showWaitHint && !ready && !_groundingOpen
                                      ? 1.0
                                      : 0.0,
                                  duration: disableAnimations
                                      ? Duration.zero
                                      : const Duration(milliseconds: 250),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.patternWaitHint,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.65,
                                          ),
                                          blurRadius: 8,
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
                  ),
                );
              },
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
            onReturnToProtection: () {
              unawaited(_completeAndGo('/dashboard'));
            },
          )
        : PatternInterruptPanel(
            breathingAnimation: _breathingController,
            pauseProgress: _pauseProgress,
            inhaling: _inhaling,
            disableAnimations: disableAnimations,
            secondsRemaining: _remaining,
            onContinue: () {
              unawaited(_completeAndOpenWeb('post-intervention'));
            },
            onOpenGrounding: () => setState(() => _groundingOpen = true),
            onOpenHelp: () => _openWeb('help'),
            onLater: () {
              unawaited(_completeAndGo('/dashboard'));
            },
          ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/feedback/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../widgets/pattern_breathing_orb.dart';

enum _BreathingPattern { box, relax478 }

class _Phase {
  const _Phase(this.kind, this.seconds);

  /// 'inhale' | 'hold' | 'exhale'
  final String kind;
  final int seconds;
}

const _patterns = <_BreathingPattern, List<_Phase>>{
  _BreathingPattern.box: [
    _Phase('inhale', 4),
    _Phase('hold', 4),
    _Phase('exhale', 4),
    _Phase('hold', 4),
  ],
  _BreathingPattern.relax478: [
    _Phase('inhale', 4),
    _Phase('hold', 7),
    _Phase('exhale', 8),
  ],
};

const _totalCycles = 3;

/// Standalone calm breathing exercise, reachable from the dashboard — fully
/// separate from the Pattern Interrupt screen (whose 7-second contract stays
/// untouched). Reuses the breathing orb; reduced motion parks the orb and
/// leans on the text cues; completion records a local pause moment.
class BreathingExerciseScreen extends ConsumerStatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  ConsumerState<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState
    extends ConsumerState<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbController;
  late final AnimationController _progressController;

  _BreathingPattern _pattern = _BreathingPattern.box;
  int _phaseIndex = 0;
  int _cycle = 0;
  bool _running = false;
  bool _done = false;
  DateTime? _startedAt;

  List<_Phase> get _phases => _patterns[_pattern]!;

  int get _sessionSeconds =>
      _phases.fold<int>(0, (total, phase) => total + phase.seconds) *
      _totalCycles;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _sessionSeconds),
    );
  }

  @override
  void dispose() {
    _orbController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _start() {
    Haptics.selection();
    setState(() {
      _running = true;
      _done = false;
      _phaseIndex = 0;
      _cycle = 0;
      _startedAt = DateTime.now();
    });
    _progressController.duration = Duration(seconds: _sessionSeconds);
    _progressController.forward(from: 0);
    _runPhase();
  }

  Future<void> _runPhase() async {
    if (!mounted || !_running) return;
    final phase = _phases[_phaseIndex];
    final reduce = MediaQuery.disableAnimationsOf(context);
    Haptics.light();
    _orbController.duration = Duration(seconds: phase.seconds);
    if (!reduce) {
      if (phase.kind == 'inhale') {
        await _orbController.forward(from: _orbController.value);
      } else if (phase.kind == 'exhale') {
        await _orbController.reverse(from: _orbController.value);
      } else {
        await Future<void>.delayed(Duration(seconds: phase.seconds));
      }
    } else {
      await Future<void>.delayed(Duration(seconds: phase.seconds));
    }
    if (!mounted || !_running) return;

    if (_phaseIndex + 1 < _phases.length) {
      setState(() => _phaseIndex += 1);
      await _runPhase();
      return;
    }
    if (_cycle + 1 < _totalCycles) {
      setState(() {
        _phaseIndex = 0;
        _cycle += 1;
      });
      await _runPhase();
      return;
    }
    _finish();
  }

  void _finish() {
    Haptics.success();
    setState(() {
      _running = false;
      _done = true;
    });
    final started = _startedAt;
    final elapsed = started == null
        ? Duration(seconds: _sessionSeconds)
        : DateTime.now().difference(started);
    ref.read(pauseMomentsRepositoryProvider).record('breathing', elapsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final phase = _phases[_phaseIndex];

    return Scaffold(
      backgroundColor: AppColors.navyDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              Text(
                l10n.breathingEntryTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: _done
                      ? _CompletionContent(
                          onDone: () => context.go('/dashboard'),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PatternBreathingOrb(
                              animation: _orbController,
                              progress: _progressController,
                              disableAnimations: reduce,
                              semanticsLabel: l10n.breathingEntrySubtitle,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 24,
                              child: _running
                                  ? Text(
                                      switch (phase.kind) {
                                        'inhale' => l10n.breathingPhaseInhale,
                                        'hold' => l10n.breathingPhaseHold,
                                        _ => l10n.breathingPhaseExhale,
                                      },
                                      style: const TextStyle(
                                        color: AppColors.skyLight,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 20,
                              child: _running
                                  ? Text(
                                      l10n.breathingCyclesProgress(
                                        _cycle + 1,
                                        _totalCycles,
                                      ),
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.65,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                ),
              ),
              if (!_done) ...[
                SegmentedButton<_BreathingPattern>(
                  segments: [
                    ButtonSegment(
                      value: _BreathingPattern.box,
                      label: Text(l10n.breathingPatternBox),
                    ),
                    ButtonSegment(
                      value: _BreathingPattern.relax478,
                      label: Text(l10n.breathingPattern478),
                    ),
                  ],
                  selected: {_pattern},
                  onSelectionChanged: _running
                      ? null
                      : (selection) {
                          Haptics.selection();
                          setState(() => _pattern = selection.first);
                        },
                  style: SegmentedButton.styleFrom(
                    foregroundColor: Colors.white,
                    selectedForegroundColor: AppColors.navy,
                    selectedBackgroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.navy,
                    ),
                    onPressed: _running ? null : _start,
                    child: Text(
                      l10n.breathingStart,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletionContent extends StatelessWidget {
  const _CompletionContent({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/gami-meditate.webp',
          height: 110,
          cacheWidth: 330,
          excludeFromSemantics: true,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/gami.webp',
            height: 110,
            cacheWidth: 330,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.breathingDoneTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.breathingDoneBody,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.navy,
          ),
          onPressed: onDone,
          child: Text(l10n.patternReturnProtection),
        ),
      ],
    );
  }
}

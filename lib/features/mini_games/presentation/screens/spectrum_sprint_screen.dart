import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/feedback/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../domain/mini_game_engines.dart';
import '../mini_game_exit.dart';
import '../mini_game_session.dart';
import '../widgets/color_choice_button.dart';
import '../widgets/mini_game_action_button.dart';
import '../widgets/mini_game_exit_guard.dart';
import '../widgets/mini_game_header.dart';
import '../widgets/mini_game_result_panel.dart';

class SpectrumSprintScreen extends ConsumerStatefulWidget {
  const SpectrumSprintScreen({super.key});

  @override
  ConsumerState<SpectrumSprintScreen> createState() =>
      _SpectrumSprintScreenState();
}

class _SpectrumSprintScreenState extends ConsumerState<SpectrumSprintScreen> {
  static const _roundDuration = 5;
  final _random = Random();
  final ScrollController _scrollController = ScrollController();
  late List<ColorSprintRound> _rounds;
  Timer? _timer;
  Timer? _advanceTimer;
  int _roundIndex = 0;
  int _secondsLeft = _roundDuration;
  int _correct = 0;
  String? _selectedColorId;
  bool _paused = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _rounds = MiniGameEngines.colorSprintRounds(_random);
    _roundIndex = 0;
    _secondsLeft = _roundDuration;
    _correct = 0;
    _selectedColorId = null;
    _paused = false;
    _finished = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(miniGameSessionProvider.notifier).setActive(true);
      }
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _advanceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _restart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(miniGameSessionProvider.notifier).setActive(true);
      }
    });
    _timer?.cancel();
    _advanceTimer?.cancel();
    setState(() {
      _rounds = MiniGameEngines.colorSprintRounds(_random);
      _roundIndex = 0;
      _secondsLeft = _roundDuration;
      _correct = 0;
      _selectedColorId = null;
      _paused = false;
      _finished = false;
    });
    _startTimer();
    _scrollToTop();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused || _finished || _selectedColorId != null || !mounted) return;
      if (_secondsLeft == 1) {
        _nextRound();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _answer(String colorId) {
    if (_paused || _finished || _selectedColorId != null) return;
    final currentRound = _rounds[_roundIndex];
    final isCorrect = currentRound.isCorrect(colorId);
    if (isCorrect) {
      Haptics.selection();
    } else {
      Haptics.heavy();
    }

    setState(() {
      _selectedColorId = colorId;
      if (isCorrect) _correct++;
    });

    _advanceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _nextRound();
    });
  }

  void _nextRound() {
    _advanceTimer?.cancel();
    if (_roundIndex + 1 == _rounds.length) {
      _timer?.cancel();
      setState(() {
        _selectedColorId = null;
        _finished = true;
      });
      ref.read(miniGameSessionProvider.notifier).setActive(false);
      _scrollToTop();
      return;
    }
    setState(() {
      _selectedColorId = null;
      _roundIndex++;
      _secondsLeft = _roundDuration;
    });
  }

  Widget _buildColorButton(
    AppLocalizations l10n,
    String colorId,
    String targetInkId,
  ) {
    final isSelected = _selectedColorId == colorId;
    final hasAnswered = _selectedColorId != null;
    final isCorrectOption = colorId == targetInkId;

    bool? isCorrect;
    if (isSelected) {
      isCorrect = isCorrectOption;
    } else if (hasAnswered && isCorrectOption) {
      isCorrect = true;
    }

    final isDimmed = hasAnswered && !isSelected && !isCorrectOption;

    return ColorChoiceButton(
      label: _colorLabel(l10n, colorId),
      color: _color(colorId),
      enabled: !_paused && !hasAnswered,
      selected: isSelected,
      isCorrect: isCorrect,
      isDimmed: isDimmed,
      onTap: () => _answer(colorId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final round = _rounds[_roundIndex];
    return MiniGameExitGuard(
      child: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: AppSpacing.screenPadding,
          children: [
            MiniGameHeader(
              title: l10n.miniGamesSpectrumTitle,
              onBack: () => exitMiniGameTo(context, ref, '/mini-games'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.miniGamesSpectrumInstruction,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_finished)
              MiniGameResultPanel(
                title: l10n.miniGamesCompleteTitle,
                body: l10n.miniGamesSpectrumResult(_correct, _rounds.length),
                action: l10n.miniGamesPlayAgain,
                onAction: _restart,
                secondaryAction: l10n.miniGamesBackToHub,
                onSecondaryAction: () =>
                    exitMiniGameTo(context, ref, '/mini-games'),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.miniGamesRound(_roundIndex + 1, _rounds.length),
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    l10n.miniGamesSeconds(_secondsLeft),
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: _secondsLeft / _roundDuration,
                minHeight: 8,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                color: AppColors.skyDark,
                backgroundColor: AppColors.azure,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.miniGamesReadWord,
                      style: const TextStyle(color: AppColors.mutedForeground),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _colorLabel(l10n, round.wordId),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _color(round.inkId),
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.miniGamesChooseInk,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildColorButton(
                          l10n,
                          MiniGameEngines.colorIds[0],
                          round.inkId,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildColorButton(
                          l10n,
                          MiniGameEngines.colorIds[1],
                          round.inkId,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildColorButton(
                          l10n,
                          MiniGameEngines.colorIds[2],
                          round.inkId,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildColorButton(
                          l10n,
                          MiniGameEngines.colorIds[3],
                          round.inkId,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              MiniGameActionButton(
                onTap: () => setState(() => _paused = !_paused),
                icon: _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                label: _paused ? l10n.miniGamesResume : l10n.miniGamesPause,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _colorLabel(AppLocalizations l10n, String id) => switch (id) {
    'blue' => l10n.miniGamesColorBlue,
    'yellow' => l10n.miniGamesColorYellow,
    'red' => l10n.miniGamesColorRed,
    _ => l10n.miniGamesColorGreen,
  };

  Color _color(String id) => switch (id) {
    'blue' => AppColors.skyDark,
    'yellow' => AppColors.amber,
    'red' => AppColors.crimson,
    _ => AppColors.sage,
  };
}

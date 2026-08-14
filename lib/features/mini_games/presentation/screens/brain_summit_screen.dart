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
import '../widgets/mini_game_header.dart';
import '../widgets/mini_game_exit_guard.dart';
import '../widgets/mini_game_result_panel.dart';
import '../widgets/brain_answer_option.dart';

class BrainSummitScreen extends ConsumerStatefulWidget {
  const BrainSummitScreen({super.key});

  @override
  ConsumerState<BrainSummitScreen> createState() => _BrainSummitScreenState();
}

class _BrainSummitScreenState extends ConsumerState<BrainSummitScreen> {
  final _random = Random();
  final ScrollController _scrollController = ScrollController();
  Timer? _nextTimer;
  List<_BrainRound> _rounds = const [];
  int _roundIndex = 0;
  int _correct = 0;
  int? _selectedOption;
  bool _finished = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_rounds.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      _rounds = MiniGameEngines.brainSummitQuestionIds(
        _random,
      ).map((id) => _round(l10n, id)).toList();
      _roundIndex = 0;
      _correct = 0;
      _selectedOption = null;
      _finished = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(miniGameSessionProvider.notifier).setActive(true);
        }
      });
    }
  }

  @override
  void dispose() {
    _nextTimer?.cancel();
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
    _nextTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(miniGameSessionProvider.notifier).setActive(true);
      }
    });
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _rounds = MiniGameEngines.brainSummitQuestionIds(
        _random,
      ).map((id) => _round(l10n, id)).toList();
      _roundIndex = 0;
      _correct = 0;
      _selectedOption = null;
      _finished = false;
    });
    _scrollToTop();
  }

  void _answer(int option) {
    if (_selectedOption != null || _finished) return;
    final isCorrect = option == _rounds[_roundIndex].correctOption;
    if (isCorrect) {
      Haptics.selection();
    } else {
      Haptics.heavy();
    }
    setState(() {
      _selectedOption = option;
      if (isCorrect) _correct++;
    });
    _nextTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      if (_roundIndex + 1 == _rounds.length) {
        setState(() => _finished = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(miniGameSessionProvider.notifier).setActive(false);
          }
        });
        _scrollToTop();
      } else {
        setState(() {
          _roundIndex++;
          _selectedOption = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final round = _rounds.isEmpty ? null : _rounds[_roundIndex];
    return MiniGameExitGuard(
      child: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: AppSpacing.screenPadding,
          children: [
            MiniGameHeader(
              title: l10n.miniGamesBrainTitle,
              onBack: () => exitMiniGameTo(context, ref, '/mini-games'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.miniGamesBrainInstruction,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_finished)
              MiniGameResultPanel(
                title: l10n.miniGamesCompleteTitle,
                body: l10n.miniGamesBrainResult(_correct, _rounds.length),
                action: l10n.miniGamesPlayAgain,
                onAction: _restart,
                secondaryAction: l10n.miniGamesBackToHub,
                onSecondaryAction: () =>
                    exitMiniGameTo(context, ref, '/mini-games'),
              )
            else if (round != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.miniGamesRound(_roundIndex + 1, _rounds.length),
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sageLight.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.sageDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_correct / ${_rounds.length}',
                          style: const TextStyle(
                            color: AppColors.sageDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: (_roundIndex + 1) / _rounds.length,
                  minHeight: 6,
                  backgroundColor: AppColors.navyLight.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.skyDark,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: AppColors.navy.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        'PERTANYAAN ${_roundIndex + 1}',
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      round.question,
                      style: const TextStyle(
                        color: AppColors.navyDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var index = 0; index < round.options.length; index++) ...[
                BrainAnswerOption(
                  label: round.options[index],
                  state: _optionState(round, index),
                  onTap: () => _answer(index),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ],
        ),
      ),
    );
  }

  BrainAnswerState _optionState(_BrainRound round, int option) {
    if (_selectedOption == null) return BrainAnswerState.idle;
    if (option == round.correctOption) return BrainAnswerState.correct;
    if (option == _selectedOption) return BrainAnswerState.incorrect;
    return BrainAnswerState.idle;
  }

  _BrainRound _round(AppLocalizations l10n, String id) {
    final copy = _copy(l10n, id);
    final order = List<int>.generate(copy.options.length, (index) => index)
      ..shuffle(_random);
    return _BrainRound(
      question: copy.question,
      options: [for (final index in order) copy.options[index]],
      correctOption: order.indexOf(0),
    );
  }

  _BrainCopy _copy(AppLocalizations l10n, String id) => switch (id) {
    'everest' => _BrainCopy(l10n.miniGamesBrainEverestQ, [
      l10n.miniGamesBrainEverestA,
      l10n.miniGamesBrainEverestB,
      l10n.miniGamesBrainEverestC,
      l10n.miniGamesBrainEverestD,
    ]),
    'pacific' => _BrainCopy(l10n.miniGamesBrainPacificQ, [
      l10n.miniGamesBrainPacificA,
      l10n.miniGamesBrainPacificB,
      l10n.miniGamesBrainPacificC,
      l10n.miniGamesBrainPacificD,
    ]),
    'tokyo' => _BrainCopy(l10n.miniGamesBrainTokyoQ, [
      l10n.miniGamesBrainTokyoA,
      l10n.miniGamesBrainTokyoB,
      l10n.miniGamesBrainTokyoC,
      l10n.miniGamesBrainTokyoD,
    ]),
    'giza' => _BrainCopy(l10n.miniGamesBrainGizaQ, [
      l10n.miniGamesBrainGizaA,
      l10n.miniGamesBrainGizaB,
      l10n.miniGamesBrainGizaC,
      l10n.miniGamesBrainGizaD,
    ]),
    'jupiter' => _BrainCopy(l10n.miniGamesBrainJupiterQ, [
      l10n.miniGamesBrainJupiterA,
      l10n.miniGamesBrainJupiterB,
      l10n.miniGamesBrainJupiterC,
      l10n.miniGamesBrainJupiterD,
    ]),
    'mars' => _BrainCopy(l10n.miniGamesBrainMarsQ, [
      l10n.miniGamesBrainMarsA,
      l10n.miniGamesBrainMarsB,
      l10n.miniGamesBrainMarsC,
      l10n.miniGamesBrainMarsD,
    ]),
    'carbon' => _BrainCopy(l10n.miniGamesBrainCarbonQ, [
      l10n.miniGamesBrainCarbonA,
      l10n.miniGamesBrainCarbonB,
      l10n.miniGamesBrainCarbonC,
      l10n.miniGamesBrainCarbonD,
    ]),
    'heart' => _BrainCopy(l10n.miniGamesBrainHeartQ, [
      l10n.miniGamesBrainHeartA,
      l10n.miniGamesBrainHeartB,
      l10n.miniGamesBrainHeartC,
      l10n.miniGamesBrainHeartD,
    ]),
    'independence' => _BrainCopy(l10n.miniGamesBrainIndependenceQ, [
      l10n.miniGamesBrainIndependenceA,
      l10n.miniGamesBrainIndependenceB,
      l10n.miniGamesBrainIndependenceC,
      l10n.miniGamesBrainIndependenceD,
    ]),
    'borobudur' => _BrainCopy(l10n.miniGamesBrainBorobudurQ, [
      l10n.miniGamesBrainBorobudurA,
      l10n.miniGamesBrainBorobudurB,
      l10n.miniGamesBrainBorobudurC,
      l10n.miniGamesBrainBorobudurD,
    ]),
    'laskarPelangi' => _BrainCopy(l10n.miniGamesBrainLaskarQ, [
      l10n.miniGamesBrainLaskarA,
      l10n.miniGamesBrainLaskarB,
      l10n.miniGamesBrainLaskarC,
      l10n.miniGamesBrainLaskarD,
    ]),
    'pancasila' => _BrainCopy(l10n.miniGamesBrainPancasilaQ, [
      l10n.miniGamesBrainPancasilaA,
      l10n.miniGamesBrainPancasilaB,
      l10n.miniGamesBrainPancasilaC,
      l10n.miniGamesBrainPancasilaD,
    ]),
    'cpu' => _BrainCopy(l10n.miniGamesBrainCpuQ, [
      l10n.miniGamesBrainCpuA,
      l10n.miniGamesBrainCpuB,
      l10n.miniGamesBrainCpuC,
      l10n.miniGamesBrainCpuD,
    ]),
    'https' => _BrainCopy(l10n.miniGamesBrainHttpsQ, [
      l10n.miniGamesBrainHttpsA,
      l10n.miniGamesBrainHttpsB,
      l10n.miniGamesBrainHttpsC,
      l10n.miniGamesBrainHttpsD,
    ]),
    'binary' => _BrainCopy(l10n.miniGamesBrainBinaryQ, [
      l10n.miniGamesBrainBinaryA,
      l10n.miniGamesBrainBinaryB,
      l10n.miniGamesBrainBinaryC,
      l10n.miniGamesBrainBinaryD,
    ]),
    _ => _BrainCopy(l10n.miniGamesBrainRouterQ, [
      l10n.miniGamesBrainRouterA,
      l10n.miniGamesBrainRouterB,
      l10n.miniGamesBrainRouterC,
      l10n.miniGamesBrainRouterD,
    ]),
  };
}

class _BrainRound {
  const _BrainRound({
    required this.question,
    required this.options,
    required this.correctOption,
  });

  final String question;
  final List<String> options;
  final int correctOption;
}

class _BrainCopy {
  const _BrainCopy(this.question, this.options);

  final String question;
  final List<String> options;
}

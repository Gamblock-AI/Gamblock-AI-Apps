import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../data/mini_games_catalog.dart';
import '../../domain/mini_game_engines.dart';
import '../../domain/mini_game_time.dart';
import '../mini_game_exit.dart';
import '../mini_game_session.dart';
import '../widgets/game_stat_tile.dart';
import '../widgets/mini_game_action_button.dart';
import '../widgets/mini_game_header.dart';
import '../widgets/mini_game_exit_guard.dart';
import '../widgets/mini_game_result_panel.dart';
import '../widgets/twin_trace_card.dart';
import '../widgets/twin_trace_configuration.dart';

class TwinTraceScreen extends ConsumerStatefulWidget {
  const TwinTraceScreen({super.key});

  @override
  ConsumerState<TwinTraceScreen> createState() => _TwinTraceScreenState();
}

class _TwinTraceScreenState extends ConsumerState<TwinTraceScreen> {
  final _random = Random();
  final ScrollController _scrollController = ScrollController();
  Timer? _previewTimer;
  Timer? _mismatchTimer;
  Timer? _elapsedTimer;
  late TwinTraceDifficulty _selectedDifficulty;
  late TwinTraceDifficulty _activeDifficulty;
  List<String?> _board = const [];
  final Set<int> _selected = {};
  final Set<int> _matched = {};
  _TwinTracePhase _phase = _TwinTracePhase.ready;
  bool _previewing = false;
  bool _locked = false;
  bool _timerStarted = false;
  int _moves = 0;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = MiniGamesCatalog.twinTraceDifficulties.first;
    _activeDifficulty = _selectedDifficulty;
  }

  @override
  void dispose() {
    _cancelTimers();
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

  void _startGame() {
    _cancelTimers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(miniGameSessionProvider.notifier).setActive(true);
      }
    });
    setState(() {
      _activeDifficulty = _selectedDifficulty;
      _board = MiniGameEngines.twinTraceBoard(
        _random,
        pairCount: _activeDifficulty.pairCount,
        hasCenterGap: _activeDifficulty.hasCenterGap,
      );
      _selected.clear();
      _matched.clear();
      _phase = _TwinTracePhase.playing;
      _previewing = true;
      _locked = true;
      _timerStarted = false;
      _moves = 0;
      _elapsedSeconds = 0;
    });
    _previewTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _phase != _TwinTracePhase.playing) return;
      setState(() {
        _previewing = false;
        _locked = false;
      });
    });
  }

  void _startElapsedTimer() {
    if (_timerStarted) return;
    _timerStarted = true;
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _phase != _TwinTracePhase.playing || _previewing) {
        if (!mounted || _phase != _TwinTracePhase.playing) {
          timer.cancel();
        }
        return;
      }
      setState(() => _elapsedSeconds++);
    });
  }

  void _changeDifficulty() {
    _cancelTimers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(miniGameSessionProvider.notifier).setActive(false);
      }
    });
    setState(() {
      _selectedDifficulty = _activeDifficulty;
      _selected.clear();
      _matched.clear();
      _phase = _TwinTracePhase.ready;
      _previewing = false;
      _locked = false;
      _timerStarted = false;
      _moves = 0;
      _elapsedSeconds = 0;
    });
  }

  void _select(int index) {
    if (_locked ||
        _phase != _TwinTracePhase.playing ||
        _board[index] == null ||
        _matched.contains(index) ||
        _selected.contains(index)) {
      return;
    }
    _startElapsedTimer();
    setState(() => _selected.add(index));
    if (_selected.length != 2) return;

    final picks = _selected.toList();
    setState(() => _moves++);
    if (_board[picks.first] == _board[picks.last]) {
      setState(() {
        _matched.addAll(picks);
        _selected.clear();
        if (_matched.length == _activeDifficulty.pairCount * 2) {
          _phase = _TwinTracePhase.completed;
          _elapsedTimer?.cancel();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(miniGameSessionProvider.notifier).setActive(false);
            }
          });
          _scrollToTop();
        }
      });
      return;
    }

    setState(() => _locked = true);
    _mismatchTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted || _phase != _TwinTracePhase.playing) return;
      setState(() {
        _selected.clear();
        _locked = false;
      });
    });
  }

  void _cancelTimers() {
    _previewTimer?.cancel();
    _mismatchTimer?.cancel();
    _elapsedTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MiniGameExitGuard(
      child: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: AppSpacing.screenPadding,
          children: [
            MiniGameHeader(
              title: l10n.miniGamesTwinTitle,
              onBack: () => exitMiniGameTo(context, ref, '/mini-games'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.miniGamesTwinInstruction,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_phase == _TwinTracePhase.ready)
              TwinTraceConfiguration(
                title: l10n.miniGamesTwinReadyTitle,
                description: l10n.miniGamesTwinReadyDescription,
                difficultyLabel: l10n.miniGamesDifficultyLabel,
                startLabel: l10n.miniGamesStart,
                selectedDifficulty: _selectedDifficulty,
                difficulties: MiniGamesCatalog.twinTraceDifficulties,
                pairCount: (difficulty) => l10n.miniGamesPairCount(
                  difficulty.pairCount,
                  difficulty.cardCount,
                ),
                onDifficultyChanged: (difficulty) =>
                    setState(() => _selectedDifficulty = difficulty),
                onStart: _startGame,
              )
            else
              _buildGame(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildGame(AppLocalizations l10n) {
    final completed = _phase == _TwinTracePhase.completed;
    final gridSize = _activeDifficulty.gridSize;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (completed) ...[
          MiniGameResultPanel(
            title: l10n.miniGamesTwinCompleteTitle,
            body: l10n.miniGamesTwinCompleteDescription(
              _moves,
              MiniGameTime.formatElapsed(_elapsedSeconds),
            ),
            action: l10n.miniGamesPlayAgain,
            onAction: _startGame,
            secondaryAction: l10n.miniGamesBackToHub,
            onSecondaryAction: () =>
                exitMiniGameTo(context, ref, '/mini-games'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (_previewing) ...[
          Text(
            l10n.miniGamesTwinPreview,
            style: const TextStyle(
              color: AppColors.amberDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: AppSpacing.sm,
          spacing: AppSpacing.sm,
          children: [
            GameStatTile(
              icon: Icons.touch_app_outlined,
              label: l10n.miniGamesMoves,
              value: _moves.toString(),
              color: AppColors.amberDark,
            ),
            GameStatTile(
              icon: Icons.timer_outlined,
              label: l10n.miniGamesTime,
              value: MiniGameTime.formatElapsed(_elapsedSeconds),
              color: AppColors.amberDark,
            ),
            GameStatTile(
              icon: Icons.check_circle_outline_rounded,
              label: l10n.miniGamesPairs,
              value: '${_matched.length ~/ 2}/${_activeDifficulty.pairCount}',
              color: AppColors.amberDark,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            MiniGameActionButton(
              onTap: _startGame,
              icon: Icons.refresh_rounded,
              label: l10n.miniGamesReset,
            ),
            MiniGameActionButton(
              onTap: _changeDifficulty,
              icon: Icons.tune_rounded,
              label: l10n.miniGamesChangeDifficulty,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _board.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: AppSpacing.xs,
              mainAxisSpacing: AppSpacing.xs,
            ),
            itemBuilder: (context, index) => TwinTraceCard(
              fruitId: _board[index],
              showFace:
                  _previewing ||
                  _selected.contains(index) ||
                  _matched.contains(index),
              semanticLabel: _cardLabel(l10n, index),
              onTap: completed ? null : () => _select(index),
            ),
          ),
        ),
      ],
    );
  }

  String? _cardLabel(AppLocalizations l10n, int index) {
    final fruitId = _board[index];
    if (fruitId == null) return null;
    if (_matched.contains(index)) {
      return l10n.miniGamesTwinMatchedCard(
        index + 1,
        _fruitName(l10n, fruitId),
      );
    }
    if (_previewing || _selected.contains(index)) {
      return l10n.miniGamesTwinRevealedCard(
        index + 1,
        _fruitName(l10n, fruitId),
      );
    }
    return l10n.miniGamesTwinHiddenCard(index + 1);
  }

  String _fruitName(AppLocalizations l10n, String fruitId) => switch (fruitId) {
    'apple' => l10n.miniGamesTwinApple,
    'banana' => l10n.miniGamesTwinBanana,
    'orange' => l10n.miniGamesTwinOrange,
    'kiwi' => l10n.miniGamesTwinKiwi,
    'blueberry' => l10n.miniGamesTwinBlueberry,
    'grapes' => l10n.miniGamesTwinGrapes,
    'dragonfruit' => l10n.miniGamesTwinDragonfruit,
    'pineapple' => l10n.miniGamesTwinPineapple,
    'coconut' => l10n.miniGamesTwinCoconut,
    'peach' => l10n.miniGamesTwinPeach,
    'pear' => l10n.miniGamesTwinPear,
    _ => l10n.miniGamesTwinWatermelon,
  };
}

enum _TwinTracePhase { ready, playing, completed }

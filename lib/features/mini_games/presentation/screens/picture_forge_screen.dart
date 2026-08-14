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
import '../widgets/mini_game_header.dart';
import '../widgets/mini_game_exit_guard.dart';
import '../widgets/mini_game_result_panel.dart';
import '../widgets/picture_forge_configuration.dart';
import '../widgets/picture_forge_reference_card.dart';
import '../widgets/picture_forge_tile.dart';
import '../widgets/picture_forge_toolbar.dart';

class PictureForgeScreen extends ConsumerStatefulWidget {
  const PictureForgeScreen({super.key});

  @override
  ConsumerState<PictureForgeScreen> createState() => _PictureForgeScreenState();
}

class _PictureForgeScreenState extends ConsumerState<PictureForgeScreen> {
  final _random = Random();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  late PictureForgePuzzle _selectedPuzzle;
  late PictureForgePuzzle _activePuzzle;
  int _selectedGridSize = 3;
  int _activeGridSize = 3;
  List<int> _board = const [];
  List<int> _initialBoard = const [];
  int? _selectedPosition;
  int _moves = 0;
  int _elapsedSeconds = 0;
  _PictureForgePhase _phase = _PictureForgePhase.ready;

  @override
  void initState() {
    super.initState();
    _selectedPuzzle = MiniGamesCatalog.picturePuzzles.first;
    _activePuzzle = _selectedPuzzle;
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  void _startChallenge() {
    final board = MiniGameEngines.pictureForgeBoard(_random, _selectedGridSize);
    _timer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(miniGameSessionProvider.notifier).setActive(true);
      }
    });
    setState(() {
      _activePuzzle = _selectedPuzzle;
      _activeGridSize = _selectedGridSize;
      _board = board;
      _initialBoard = List<int>.of(board);
      _selectedPosition = null;
      _moves = 0;
      _elapsedSeconds = 0;
      _phase = _PictureForgePhase.playing;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _phase != _PictureForgePhase.playing) {
        timer.cancel();
        return;
      }
      setState(() => _elapsedSeconds++);
    });
  }

  void _resetBoard() {
    _restartTimer();
    setState(() {
      _board = List<int>.of(_initialBoard);
      _selectedPosition = null;
      _moves = 0;
      _elapsedSeconds = 0;
      _phase = _PictureForgePhase.playing;
    });
  }

  void _shuffleBoard() {
    final board = MiniGameEngines.pictureForgeBoard(_random, _activeGridSize);
    _restartTimer();
    setState(() {
      _board = board;
      _initialBoard = List<int>.of(board);
      _selectedPosition = null;
      _moves = 0;
      _elapsedSeconds = 0;
      _phase = _PictureForgePhase.playing;
    });
  }

  void _changeChallenge() {
    _timer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(miniGameSessionProvider.notifier).setActive(false);
      }
    });
    setState(() {
      _selectedPuzzle = _activePuzzle;
      _selectedGridSize = _activeGridSize;
      _selectedPosition = null;
      _phase = _PictureForgePhase.ready;
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    _startTimer();
  }

  void _select(int position) {
    if (_phase != _PictureForgePhase.playing) return;
    if (_selectedPosition == null) {
      setState(() => _selectedPosition = position);
      return;
    }
    if (_selectedPosition == position) {
      setState(() => _selectedPosition = null);
      return;
    }
    setState(() {
      final first = _selectedPosition!;
      final value = _board[first];
      _board[first] = _board[position];
      _board[position] = value;
      _selectedPosition = null;
      _moves++;
      if (MiniGameEngines.isPictureForgeSolved(_board)) {
        _phase = _PictureForgePhase.completed;
        _timer?.cancel();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(miniGameSessionProvider.notifier).setActive(false);
          }
        });
        _scrollToTop();
      }
    });
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
              title: l10n.miniGamesPictureTitle,
              onBack: () => exitMiniGameTo(context, ref, '/mini-games'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.miniGamesPictureInstruction,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_phase == _PictureForgePhase.ready)
              PictureForgeConfiguration(
                title: l10n.miniGamesPictureReadyTitle,
                description: l10n.miniGamesPictureReadyDescription,
                imageChoiceLabel: l10n.miniGamesPictureImageChoiceLabel,
                difficultyLabel: l10n.miniGamesDifficultyLabel,
                startLabel: l10n.miniGamesStart,
                selectedPuzzle: _selectedPuzzle,
                selectedGridSize: _selectedGridSize,
                puzzles: MiniGamesCatalog.picturePuzzles,
                puzzleName: _puzzleName,
                pieceCount: l10n.miniGamesPieceCount,
                onPuzzleChanged: (puzzle) =>
                    setState(() => _selectedPuzzle = puzzle),
                onGridSizeChanged: (size) =>
                    setState(() => _selectedGridSize = size),
                onStart: _startChallenge,
              )
            else
              _buildChallenge(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildChallenge(AppLocalizations l10n) {
    final completed = _phase == _PictureForgePhase.completed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (completed) ...[
          MiniGameResultPanel(
            title: l10n.miniGamesPictureCompleteTitle,
            body: l10n.miniGamesPictureCompleteDescription(
              _moves,
              MiniGameTime.formatElapsed(_elapsedSeconds),
            ),
            action: l10n.miniGamesPlayAgain,
            onAction: _shuffleBoard,
            secondaryAction: l10n.miniGamesBackToHub,
            onSecondaryAction: () =>
                exitMiniGameTo(context, ref, '/mini-games'),
          ),
          const SizedBox(height: AppSpacing.lg),
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
            ),
            GameStatTile(
              icon: Icons.grid_view_rounded,
              label: l10n.miniGamesPieces,
              value: (_activeGridSize * _activeGridSize).toString(),
            ),
            GameStatTile(
              icon: Icons.timer_outlined,
              label: l10n.miniGamesTime,
              value: MiniGameTime.formatElapsed(_elapsedSeconds),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        PictureForgeToolbar(
          resetLabel: l10n.miniGamesReset,
          changeChallengeLabel: l10n.miniGamesChangeChallenge,
          shuffleLabel: l10n.miniGamesShuffle,
          resetEnabled: _moves > 0 || completed,
          onReset: _resetBoard,
          onChangeChallenge: _changeChallenge,
          onShuffle: _shuffleBoard,
        ),
        const SizedBox(height: AppSpacing.xl),
        LayoutBuilder(
          builder: (context, constraints) {
            final reference = PictureForgeReferenceCard(
              title: l10n.miniGamesPictureReferenceLabel,
              imageName: _puzzleName(_activePuzzle),
              assetPath: _activePuzzle.assetPath,
            );
            final board = _buildBoard(completed);
            if (constraints.maxWidth >= 720) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 210, child: reference),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: board),
                ],
              );
            }
            return Column(
              children: [
                reference,
                const SizedBox(height: AppSpacing.lg),
                board,
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBoard(bool completed) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _board.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _activeGridSize,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemBuilder: (context, position) => PictureForgeTile(
          assetPath: _activePuzzle.assetPath,
          gridSize: _activeGridSize,
          tileIndex: _board[position],
          selected: _selectedPosition == position,
          onTap: completed ? null : () => _select(position),
        ),
      ),
    );
  }

  String _puzzleName(PictureForgePuzzle puzzle) => switch (puzzle.id) {
    'studyCorner' => AppLocalizations.of(context)!.miniGamesPictureStudyCorner,
    'fruitMarket' => AppLocalizations.of(context)!.miniGamesPictureFruitMarket,
    'berryGarden' => AppLocalizations.of(context)!.miniGamesPictureBerryGarden,
    'tropicalPlatter' => AppLocalizations.of(
      context,
    )!.miniGamesPictureTropicalPlatter,
    'orchardBasket' => AppLocalizations.of(
      context,
    )!.miniGamesPictureOrchardBasket,
    _ => AppLocalizations.of(context)!.miniGamesPictureCitrusTable,
  };
}

enum _PictureForgePhase { ready, playing, completed }

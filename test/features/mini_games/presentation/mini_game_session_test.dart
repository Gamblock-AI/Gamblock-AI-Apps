import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/mini_game_session.dart';

void main() {
  test('an active game can be discarded after opening the exit dialog', () {
    final notifier = MiniGameSessionNotifier();

    notifier.setActive(true);
    expect(notifier.state.isActive, isTrue);
    expect(notifier.openExitDialog(), isTrue);
    expect(notifier.state.isExitDialogOpen, isTrue);

    notifier.discard();

    expect(notifier.state.isActive, isFalse);
    expect(notifier.state.isExitDialogOpen, isFalse);
  });

  test('inactive configurations do not request an exit confirmation', () {
    final notifier = MiniGameSessionNotifier();

    expect(notifier.openExitDialog(), isFalse);
    expect(notifier.state.isActive, isFalse);
  });
}

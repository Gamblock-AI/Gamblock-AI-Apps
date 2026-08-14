import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mini_game_exit.dart';
import '../mini_game_session.dart';

class MiniGameExitGuard extends ConsumerWidget {
  const MiniGameExitGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(miniGameSessionProvider);
    return PopScope(
      canPop: !session.isActive,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) exitMiniGameTo(context, ref, '/mini-games');
      },
      child: child,
    );
  }
}

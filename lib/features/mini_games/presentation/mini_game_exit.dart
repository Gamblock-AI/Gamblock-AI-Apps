import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'mini_game_session.dart';
import 'widgets/mini_game_exit_dialog.dart';

Future<bool> requestMiniGameExit(BuildContext context, WidgetRef ref) async {
  final notifier = ref.read(miniGameSessionProvider.notifier);
  if (!notifier.openExitDialog()) {
    return !ref.read(miniGameSessionProvider).isActive;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => const MiniGameExitDialog(),
  );
  notifier.closeExitDialog();
  if (confirmed == true) notifier.discard();
  return confirmed == true;
}

Future<void> exitMiniGameTo(
  BuildContext context,
  WidgetRef ref,
  String path,
) async {
  final canExit = await requestMiniGameExit(context, ref);
  if (canExit && context.mounted) context.go(path);
}

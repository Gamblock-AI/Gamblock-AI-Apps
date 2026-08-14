import 'package:flutter_riverpod/flutter_riverpod.dart';

class MiniGameSessionState {
  const MiniGameSessionState({
    this.isActive = false,
    this.isExitDialogOpen = false,
  });

  final bool isActive;
  final bool isExitDialogOpen;
}

class MiniGameSessionNotifier extends StateNotifier<MiniGameSessionState> {
  MiniGameSessionNotifier() : super(const MiniGameSessionState());

  void setActive(bool isActive) {
    if (state.isActive == isActive && !state.isExitDialogOpen) return;
    state = MiniGameSessionState(isActive: isActive);
  }

  bool openExitDialog() {
    if (!state.isActive || state.isExitDialogOpen) return false;
    state = MiniGameSessionState(isActive: true, isExitDialogOpen: true);
    return true;
  }

  void closeExitDialog() {
    if (!state.isExitDialogOpen) return;
    state = MiniGameSessionState(isActive: state.isActive);
  }

  void discard() {
    state = const MiniGameSessionState();
  }
}

final miniGameSessionProvider =
    StateNotifierProvider<MiniGameSessionNotifier, MiniGameSessionState>((ref) {
      return MiniGameSessionNotifier();
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_state.dart';
import '../domain/tour_step.dart';
import '../data/tour_seen_store.dart';

class DashboardTourState {
  const DashboardTourState({this.open = false, this.index = 0});

  final bool open;
  final int index;

  DashboardTourState copyWith({bool? open, int? index}) {
    return DashboardTourState(
      open: open ?? this.open,
      index: index ?? this.index,
    );
  }
}

/// State machine for the first-time guided dashboard tour. Mirrors the
/// website's `useDashboardTour` hook: owns the current index, clamps it to the
/// step list, and persists the seen flag when the tour starts.
class DashboardTourNotifier extends StateNotifier<DashboardTourState> {
  DashboardTourNotifier(this._ref) : super(const DashboardTourState());

  final Ref _ref;

  int get _lastIndex => kDashboardTourSteps.length - 1;

  Future<void> start() async {
    await _ref.read(tourSeenStoreProvider).markSeen();
    state = const DashboardTourState(open: true, index: 0);
  }

  void next() {
    if (!state.open || state.index >= _lastIndex) return;
    state = state.copyWith(index: state.index + 1);
  }

  void back() {
    if (!state.open || state.index <= 0) return;
    state = state.copyWith(index: state.index - 1);
  }

  void close() {
    state = const DashboardTourState(open: false, index: 0);
  }
}

final dashboardTourProvider =
    StateNotifierProvider<DashboardTourNotifier, DashboardTourState>((ref) {
      return DashboardTourNotifier(ref);
    });

/// Gate for the first-time tour: an authenticated student who has not seen the
/// tour yet. The host combines this with the current route path.
final dashboardTourEligibleProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return false;
  final seen = await ref.watch(tourSeenProvider.future);
  return !seen;
});

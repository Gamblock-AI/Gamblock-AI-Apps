import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_tour_controller.dart';
import 'dashboard_tour_overlay.dart';

/// Waits for the dashboard shell to settle on `/dashboard`, then starts the
/// first-time tour once. Appears above the whole shell (content + bottom
/// navigation) so it can spotlight shell-level targets. The seen flag is
/// persisted when the tour starts, mirroring the website.
class DashboardTourHost extends ConsumerStatefulWidget {
  const DashboardTourHost({super.key, required this.currentPath});

  final String currentPath;

  @override
  ConsumerState<DashboardTourHost> createState() => _DashboardTourHostState();
}

class _DashboardTourHostState extends ConsumerState<DashboardTourHost> {
  static const Duration _startDelay = Duration(milliseconds: 300);

  bool _triggered = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _maybeStart() {
    if (_triggered) return;
    if (widget.currentPath != '/dashboard') return;
    final eligible = ref.read(dashboardTourEligibleProvider).valueOrNull;
    if (eligible != true) return;

    _triggered = true;
    _timer = Timer(_startDelay, () {
      if (mounted) ref.read(dashboardTourProvider.notifier).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eligible = ref.watch(dashboardTourEligibleProvider);
    final tour = ref.watch(dashboardTourProvider);

    if (eligible.valueOrNull == null) return const SizedBox.shrink();
    if (eligible.value != true) {
      if (_triggered) {
        _triggered = false;
        _timer?.cancel();
        _timer = null;
      }
      return const SizedBox.shrink();
    }

    if (!tour.open) {
      _maybeStart();
      return const SizedBox.shrink();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) ref.read(dashboardTourProvider.notifier).close();
      },
      child: const DashboardTourOverlay(),
    );
  }
}

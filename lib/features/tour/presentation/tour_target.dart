import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tour_registry.dart';

/// Registers [id] with a fresh [GlobalKey] while the wrapped [child] is
/// mounted, so the tour overlay can measure and spotlight it. Equivalent to
/// the website's `data-tour` attribute on a DOM element.
class TourTarget extends ConsumerStatefulWidget {
  const TourTarget({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  ConsumerState<TourTarget> createState() => _TourTargetState();
}

class _TourTargetState extends ConsumerState<TourTarget> {
  final GlobalKey _key = GlobalKey();
  late final TourRegistry _registry;

  @override
  void initState() {
    super.initState();
    _registry = ref.read(tourRegistryProvider);
    _registry.register(widget.id, _key);
  }

  @override
  void dispose() {
    _registry.unregister(widget.id, _key);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

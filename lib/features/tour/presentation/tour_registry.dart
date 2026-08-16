import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the [GlobalKey] registered by each [TourTarget] so the tour overlay
/// can measure the highlighted widget's bounding box, mirroring the website's
/// `data-tour` + `getBoundingClientRect` mechanism.
class TourRegistry {
  final Map<String, GlobalKey> _keys = {};

  void register(String id, GlobalKey key) {
    _keys[id] = key;
  }

  void unregister(String id, GlobalKey key) {
    if (_keys[id] == key) _keys.remove(id);
  }

  /// BuildContext of the target widget, or null when it is not mounted yet.
  BuildContext? contextOf(String id) => _keys[id]?.currentContext;

  /// GlobalKey of the target widget, or null when it is not registered.
  GlobalKey? keyOf(String id) => _keys[id];

  /// Global rect of the target widget, or null when it is not mounted yet.
  Rect? rectOf(String id) {
    final context = _keys[id]?.currentContext;
    if (context == null) return null;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    return Rect.fromLTWH(origin.dx, origin.dy, box.size.width, box.size.height);
  }
}

final tourRegistryProvider = Provider<TourRegistry>((ref) => TourRegistry());

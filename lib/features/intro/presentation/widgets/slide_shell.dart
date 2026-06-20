import 'package:flutter/material.dart';

/// Shared scrollable shell that centers and constrains an intro slide's content.
class SlideShell extends StatelessWidget {
  final Widget child;
  const SlideShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 130),
      child: Center(
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: child)),
    );
  }
}

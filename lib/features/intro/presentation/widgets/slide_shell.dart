import 'package:flutter/material.dart';

/// Shared scrollable shell that centers and constrains an intro slide's content.
class SlideShell extends StatelessWidget {
  final Widget child;
  const SlideShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final compactHeight = screenSize.height < 720;
    final horizontalPadding = screenSize.width >= 600 ? 32.0 : 24.0;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        compactHeight ? 28 : 46,
        horizontalPadding,
        compactHeight ? 116 : 132,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Round monogram avatar — a colored circle with a single initial letter.
/// Mirrors the wireframe profile avatar (48px, monogram, soft shadow).
class MonogramAvatar extends StatelessWidget {
  final String label;
  final Color color;
  final double size;
  final double? fontSize;
  final Widget? child;
  final List<BoxShadow>? boxShadow;

  const MonogramAvatar({
    super.key,
    required this.label,
    this.color = const Color(0xFF16294C),
    this.size = 48,
    this.fontSize,
    this.child,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: boxShadow,
      ),
      alignment: Alignment.center,
      child: child ??
          Text(
            label.isEmpty ? '?' : label.characters.first.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize ?? size * 0.42,
              fontWeight: FontWeight.w700,
            ),
          ),
    );
  }
}

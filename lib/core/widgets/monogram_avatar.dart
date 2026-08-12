import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Round monogram avatar — a beautifully styled avatar with layered gradient depth,
/// inner highlight ring, and crisp typography.
class MonogramAvatar extends StatelessWidget {
  final String label;
  final Color color;
  final double size;
  final double? fontSize;
  final Widget? child;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final ImageProvider? image;
  final BoxBorder? border;

  const MonogramAvatar({
    super.key,
    required this.label,
    this.color = AppColors.navy,
    this.size = 48,
    this.fontSize,
    this.child,
    this.boxShadow,
    this.gradient,
    this.image,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final letter = label.trim().isEmpty
        ? '?'
        : label.trim().characters.first.toUpperCase();

    final defaultGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.18) ?? color,
            color,
            Color.lerp(color, Colors.black, 0.20) ?? color,
          ],
          stops: const [0.0, 0.45, 1.0],
        );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        gradient: image == null ? defaultGradient : null,
        shape: BoxShape.circle,
        image: image != null
            ? DecorationImage(image: image!, fit: BoxFit.cover)
            : null,
        border: border ??
            Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: size >= 40 ? 1.75 : 1.2,
            ),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: size * 0.20,
                offset: Offset(0, size * 0.08),
              ),
            ],
      ),
      alignment: Alignment.center,
      child: child ??
          (image == null
              ? Text(
                  letter,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize ?? size * 0.42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    shadows: const [
                      Shadow(
                        color: Color(0x33000000),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                )
              : null),
    );
  }
}

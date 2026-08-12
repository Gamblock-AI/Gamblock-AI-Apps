import 'package:flutter/material.dart';

/// Left-aligned display headline for the intro slides: a lead line, a
/// highlight line swept with a hand-drawn marker underline, and an optional
/// tail line. Empty parts are skipped so a slide can use two or three lines.
class HighlightHeadline extends StatelessWidget {
  final String lead;
  final String highlight;
  final String tail;
  final Color textColor;
  final Color markerColor;
  final double fontSize;

  const HighlightHeadline({
    super.key,
    required this.lead,
    required this.highlight,
    required this.tail,
    required this.textColor,
    required this.markerColor,
    this.fontSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
      height: 1.14,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lead.isNotEmpty) Text(lead, style: style),
        if (highlight.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: lead.isNotEmpty ? 2 : 0),
            child: CustomPaint(
              painter: _MarkerUnderlinePainter(color: markerColor),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(highlight, style: style),
              ),
            ),
          ),
        if (tail.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(tail, style: style),
          ),
      ],
    );
  }
}

/// Two overlapping bezier sweeps under the text, like a broad highlighter
/// stroke made by hand.
class _MarkerUnderlinePainter extends CustomPainter {
  final Color color;

  const _MarkerUnderlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final baseY = size.height - 4;

    canvas.save();
    canvas.translate(width / 2, baseY);
    canvas.rotate(-0.018);
    canvas.translate(-width / 2, -baseY);

    // Main broad sweep.
    final main = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final mainPath = Path()
      ..moveTo(width * 0.02, 0)
      ..quadraticBezierTo(width * 0.5, -3, width * 0.98, 0);
    canvas.drawPath(mainPath, main);

    // Lighter echo just below, slightly more curved for a hand-drawn feel.
    final echo = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final echoPath = Path()
      ..moveTo(width * 0.06, 3)
      ..quadraticBezierTo(width * 0.5, 2, width * 0.94, 3);
    canvas.drawPath(echoPath, echo);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MarkerUnderlinePainter oldDelegate) =>
      oldDelegate.color != color;
}

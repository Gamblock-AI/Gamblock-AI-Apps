import 'package:flutter/material.dart';

import '../../../../core/feedback/haptics.dart';

/// Accessible circular or pill-shaped CTA for advancing the intro flow.
class IntroArrowButton extends StatefulWidget {
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;
  final String semanticLabel;
  final String? label;
  final bool pulse;

  const IntroArrowButton({
    super.key,
    required this.color,
    required this.iconColor,
    required this.onPressed,
    required this.semanticLabel,
    this.label,
    this.pulse = false,
  });

  @override
  State<IntroArrowButton> createState() => _IntroArrowButtonState();
}

class _IntroArrowButtonState extends State<IntroArrowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant IntroArrowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulse != widget.pulse) _syncPulse();
  }

  void _syncPulse() {
    final enabled = widget.pulse && !MediaQuery.disableAnimationsOf(context);
    if (enabled && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat();
    } else if (!enabled) {
      _pulseCtrl.stop();
      _pulseCtrl.value = 0;
    }
  }

  void _handlePressed() {
    Haptics.light();
    widget.onPressed();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final hasLabel = widget.label != null && widget.label!.trim().isNotEmpty;
    final width = hasLabel ? 192.0 : 56.0;
    final borderRadius = BorderRadius.circular(28);

    final button = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.42),
            blurRadius: 20,
            offset: const Offset(0, 7),
            spreadRadius: -3,
          ),
        ],
      ),
      child: SizedBox(
        width: width,
        height: 56,
        child: FilledButton(
          onPressed: _handlePressed,
          style: FilledButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: widget.iconColor,
            disabledBackgroundColor: widget.color,
            disabledForegroundColor: widget.iconColor,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: hasLabel ? 20 : 0),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasLabel) ...[
                Flexible(child: Text(widget.label!)),
                const SizedBox(width: 10),
              ],
              Icon(Icons.arrow_forward_rounded, size: hasLabel ? 22 : 24),
            ],
          ),
        ),
      ),
    );

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (widget.pulse && !disableAnimations)
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + 0.34 * _pulseCtrl.value,
                child: Opacity(
                  opacity: (1 - _pulseCtrl.value) * 0.48,
                  child: child,
                ),
              );
            },
            child: Container(
              width: width,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(color: widget.color, width: 2),
              ),
            ),
          ),
        Semantics(
          button: true,
          label: widget.semanticLabel,
          child: Tooltip(message: widget.semanticLabel, child: button),
        ),
      ],
    );
  }
}

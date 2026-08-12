import 'package:flutter/material.dart';

import '../../../../core/widgets/pressable.dart';

/// Circular accent button that advances the intro flow (or finishes it on the
/// last slide). Color matches the active slide header. When [pulse] is on, an
/// expanding ring loops behind the button to signal the final step.
class IntroArrowButton extends StatefulWidget {
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;
  final String semanticLabel;
  final bool pulse;

  const IntroArrowButton({
    super.key,
    required this.color,
    required this.iconColor,
    required this.onPressed,
    required this.semanticLabel,
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
    final enabled =
        widget.pulse && !MediaQuery.disableAnimationsOf(context);
    if (enabled && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat();
    } else if (!enabled && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _pulseCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (widget.pulse && !disableAnimations)
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + 0.55 * _pulseCtrl.value,
                child: Opacity(
                  opacity: (1 - _pulseCtrl.value) * 0.55,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: widget.color, width: 2),
              ),
            ),
          ),
        Pressable(
          onTap: widget.onPressed,
          semanticLabel: widget.semanticLabel,
          child: AnimatedContainer(
            width: 56,
            height: 56,
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: widget.iconColor,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'monogram_avatar.dart';

/// Overlapping stack of small round avatars with a white ring on each —
/// mirrors the website workspace-card avatar stack (20px, ring border).
class AvatarStack extends StatelessWidget {
  final List<String> labels;
  final Color color;
  final double size;
  final int maxShown;

  const AvatarStack({
    super.key,
    required this.labels,
    this.color = AppColors.sky,
    this.size = 20,
    this.maxShown = 3,
  });

  @override
  Widget build(BuildContext context) {
    final shown = labels.take(maxShown).toList();
    if (shown.isEmpty) return const SizedBox.shrink();
    final ring = Border.all(color: Colors.white, width: 1.5);
    return SizedBox(
      height: size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < shown.length; i++)
            Transform.translate(
              offset: Offset(i == 0 ? 0 : -size * 0.3, 0),
              child: Padding(
                padding: EdgeInsets.only(right: i == 0 ? 0 : size * 0.3),
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: ring),
                  child: MonogramAvatar(
                    label: shown[i],
                    color: color,
                    size: size,
                    fontSize: size * 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

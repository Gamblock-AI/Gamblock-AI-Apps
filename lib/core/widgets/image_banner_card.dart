import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Wireframe overview banner: white rounded card, headline + description on
/// the left (66%), an illustration on the right blended in with a white
/// gradient fade overlay.
class ImageBannerCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget image;
  final VoidCallback? onTap;
  final double height;

  const ImageBannerCard({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    this.onTap,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final card = Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.banner),
        border: Border.all(color: AppColors.background),
        boxShadow: AppColors.cardSoftShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            height: height,
            width: 230,
            child: image,
          ),
          Positioned(
            top: 0,
            right: 0,
            height: height,
            width: 230,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xCCFFFFFF),
                    Color(0x00FFFFFF),
                  ],
                  stops: [0, 0.5, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: t.titleSmall?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 210),
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.375,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.banner),
        child: card,
      ),
    );
  }
}

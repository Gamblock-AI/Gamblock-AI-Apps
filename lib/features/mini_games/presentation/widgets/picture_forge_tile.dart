import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

class PictureForgeTile extends StatelessWidget {
  const PictureForgeTile({
    super.key,
    required this.assetPath,
    required this.gridSize,
    required this.tileIndex,
    required this.selected,
    required this.onTap,
  });

  final String assetPath;
  final int gridSize;
  final int tileIndex;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final column = tileIndex % gridSize;
    final row = tileIndex ~/ gridSize;
    final alignmentX = gridSize == 1 ? 0.0 : -1 + (2 * column / (gridSize - 1));
    final alignmentY = gridSize == 1 ? 0.0 : -1 + (2 * row / (gridSize - 1));
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? AppColors.skyDark : Colors.white,
                width: selected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return OverflowBox(
                    maxWidth: constraints.maxWidth * gridSize,
                    maxHeight: constraints.maxHeight * gridSize,
                    alignment: Alignment(alignmentX, alignmentY),
                    child: Image.asset(
                      assetPath,
                      width: constraints.maxWidth * gridSize,
                      height: constraints.maxHeight * gridSize,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

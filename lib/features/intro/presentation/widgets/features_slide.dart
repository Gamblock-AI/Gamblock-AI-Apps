import 'package:flutter/material.dart';
import 'slide_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/icon_chip.dart';
import '../../../../core/widgets/brand_helpers.dart';

/// Fourth intro slide: feature ecosystem overview.
class FeaturesSlide extends StatelessWidget {
  const FeaturesSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      (Icons.document_scanner, 'deteksi real-time berbasis konten', AppColors.crimson),
      (Icons.remove_red_eye, 'pattern interrupt visual', AppColors.amber),
      (Icons.people, 'accountability partner', AppColors.sageLight),
      (Icons.shield, 'on-device ai & privasi', AppColors.navyLight),
    ];
    return SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowPill(label: 'fitur', color: AppColors.sageLight),
          const SizedBox(height: 20),
          Text('ekosistem yang\nmendukung kepulihan.', style: displayStyle(context)),
          const SizedBox(height: 24),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    IconChip(icon: f.$1, color: f.$3),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Text(f.$2,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
                  ]),
                ),
              )),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'slide_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/icon_chip.dart';
import '../../../../core/widgets/brand_helpers.dart';

/// Third intro slide: the three-step how-it-works flow.
class HowItWorksSlide extends StatelessWidget {
  const HowItWorksSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('01', Icons.download, 'unduh & pasang', 'instal di android atau windows. gratis, tanpa kartu kredit.'),
      ('02', Icons.auto_awesome, 'deteksi otomatis', 'hybrid ai menganalisis dom, bow, dan pola url di latar belakang.'),
      ('03', Icons.favorite, 'pulihkan & bangkit', 'pattern interrupt memutus dorongan, lalu psikoedukasi memandu pemulihan.'),
    ];
    return SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowPill(label: 'cara kerja', color: AppColors.navyLight),
          const SizedBox(height: 20),
          Text('tiga langkah\nmenuju kendali diri.', style: displayStyle(context)),
          const SizedBox(height: 24),
          ...steps.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconChip(icon: s.$2, color: AppColors.crimson),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.$1,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                            const SizedBox(height: 4),
                            Text(s.$3, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(s.$4, style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

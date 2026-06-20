import 'package:flutter/material.dart';
import 'slide_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/brand_helpers.dart';

/// Second intro slide: the gambling crisis statistics.
class CrisisSlide extends StatelessWidget {
  const CrisisSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Rp286T', 'perputaran dana judi online 2025', AppColors.crimson),
      ('12,3 jt', 'orang tercatat deposit judi', AppColors.amber),
      ('5,5 jt+', 'konten judi ditangani sejak 2017', AppColors.crimson),
    ];
    return SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowPill(label: 'darurat nasional', color: AppColors.crimson),
          const SizedBox(height: 20),
          Text('judi online bukan hiburan.\nini krisis generasi.', style: displayStyle(context)),
          const SizedBox(height: 14),
          Text(
            '440 rb pemain usia 10–20 tahun dan 520 rb usia 21–30 tahun terlibat. mahasiswa berada di jantung krisis ini.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          ...stats.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(children: [
                    Text(s.$1,
                        style: TextStyle(color: s.$3, fontSize: 28, fontWeight: FontWeight.w800)),
                    Container(width: 16),
                    Expanded(
                        child: Text(s.$2,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4))),
                  ]),
                ),
              )),
          Text('(PPATK 2026 · Kemkomdigi 2025)',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
        ],
      ),
    );
  }
}

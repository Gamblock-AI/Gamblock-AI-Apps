import 'package:flutter/material.dart';
import 'slide_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/eyebrow_pill.dart';
import '../../../../core/widgets/brand_helpers.dart';

/// First intro slide: brand hero.
class HeroSlide extends StatelessWidget {
  const HeroSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Image.asset('assets/images/gami.png', height: 240),
          const SizedBox(height: 28),
          EyebrowPill(label: 'on-device ai shield', color: AppColors.crimson),
          const SizedBox(height: 20),
          Text('putuskan siklus\njudi online.',
              textAlign: TextAlign.center, style: displayStyle(context)),
          const SizedBox(height: 16),
          Text(
            'deteksi cerdas berbasis on-device ai, intervensi psikologis otomatis, dan rehabilitasi mandiri — untuk mahasiswa indonesia.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}

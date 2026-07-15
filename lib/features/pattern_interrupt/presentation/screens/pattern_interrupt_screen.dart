import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

/// Pattern Interrupt — dark cinematic intervention screen.
/// Shows for ~5s to break the impulsive urge, then offers redirect to psychoeducation.
class PatternInterruptScreen extends StatefulWidget {
  const PatternInterruptScreen({super.key});
  @override
  State<PatternInterruptScreen> createState() => _PatternInterruptScreenState();
}

class _PatternInterruptScreenState extends State<PatternInterruptScreen> {
  bool _showRedirect = false;
  int _count = 5;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _count--);
      if (_count <= 0) {
        setState(() => _showRedirect = true);
      } else {
        _tick();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.navy,
                AppColors.navyDark,
                AppColors.crimsonDark,
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: _showRedirect ? _buildRedirect() : _buildInterrupt(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterrupt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/gami.webp', height: 180),
        const SizedBox(height: 28),
        const Text(
          'BERHENTI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.crimson.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.crimson.withValues(alpha: 0.4)),
          ),
          child: Text(
            AppLocalizations.of(context)!.patternInterruptActive.toUpperCase(),
            style: const TextStyle(
              color: AppColors.crimsonLight,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.patternBreatheDesc,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 17,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: _count / 5,
                strokeWidth: 4,
                color: AppColors.amber,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
              ),
              Center(
                child: Text(
                  '$_count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRedirect() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.sage.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.sage,
            size: 64,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.patternInterruptSuccess,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.patternTakeControlDesc,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.crimson,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => launchUrl(
              Uri.parse('https://gamblock-ai.vercel.app/id/post-intervention?source=pattern_interrupt'),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(
              AppLocalizations.of(context)!.patternContinuePsychoeducation,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

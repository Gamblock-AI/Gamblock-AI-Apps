import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/feedback/feedback.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_widgets.dart';

/// Hands the recovery journey off to the website with a warm, branded pause
/// instead of a bare utility card.
class RecoveryHandoffScreen extends StatelessWidget {
  const RecoveryHandoffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final card = SurfaceCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Image.asset(
            'assets/images/gami-point.webp',
            height: 96,
            cacheWidth: 288,
            excludeFromSemantics: true,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/gami.webp',
              height: 96,
              cacheWidth: 288,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(height: 16),
          EyebrowPill(label: l10n.recoveryWebEyebrow, color: AppColors.blueAccent),
          const SizedBox(height: 14),
          Text(
            l10n.recoveryWebTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.recoveryWebBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.inkMuted,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () async {
              final opened = await launchUrl(
                AppConfig.webUri(
                  '${Localizations.localeOf(context).languageCode}/recovery',
                ),
                mode: LaunchMode.externalApplication,
              );
              if (!opened && context.mounted) {
                AppFeedback.error(
                  context,
                  AppLocalizations.of(context)!.recoveryPageOpenError,
                );
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.recoveryWebAction),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.go('/dashboard'),
            child: Text(l10n.backToProtection),
          ),
        ],
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlobBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: disableAnimations
                    ? card
                    : card
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(
                            begin: 0.04,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

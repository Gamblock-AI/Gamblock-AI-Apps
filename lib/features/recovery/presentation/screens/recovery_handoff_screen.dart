import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';

class RecoveryHandoffScreen extends StatelessWidget {
  const RecoveryHandoffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recoveryWebTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.open_in_browser,
                      size: 64,
                      color: AppColors.navy,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.recoveryWebTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.recoveryWebBody,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedForeground,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: () => launchUrl(
                        AppConfig.webUri(
                          '${Localizations.localeOf(context).languageCode}/recovery',
                        ),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.open_in_new),
                      label: Text(l10n.recoveryWebAction),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => context.go('/protection'),
                      child: Text(l10n.backToProtection),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

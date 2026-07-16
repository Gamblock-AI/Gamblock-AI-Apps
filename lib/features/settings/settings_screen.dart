import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_config.dart';
import '../../core/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: EyebrowPill(
              label: AppLocalizations.of(context)!.settingsAccountPreferences,
              color: AppColors.navy,
            ),
          ),
          // Profile
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.navy.withValues(alpha: 0.1),
                      child: Text(
                        (auth.displayName ?? '?').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.displayName ?? 'Pengguna',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.navy),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            auth.email ?? '',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.navy.withValues(alpha: 0.5),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.sage.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              auth.role == 'partner'
                                  ? AppLocalizations.of(context)!.roleKepala
                                  : AppLocalizations.of(context)!.roleMember,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.sage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.people, color: AppColors.navy),
            title: Text(
              AppLocalizations.of(context)!.settingsAccountabilityPartner,
            ),
            subtitle: Text(AppLocalizations.of(context)!.settingsManagePartner),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.notifications, color: AppColors.navy),
            title: Text('Notifikasi'),
            trailing: Switch(value: true, onChanged: null),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.navy),
            title: Text(
              AppLocalizations.of(context)!.settingsOpenPsychoeducation,
            ),
            onTap: () => launchUrl(
              AppConfig.webUri(
                '${Localizations.localeOf(context).languageCode}/education',
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.info, color: AppColors.navy),
            title: Text(AppLocalizations.of(context)!.settingsAboutApp),
            subtitle: Text(AppLocalizations.of(context)!.settingsAppVersion),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.crimson),
            title: Text(
              AppLocalizations.of(context)!.settingsLogout,
              style: TextStyle(color: AppColors.crimson),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.settingsLogout),
                  content: Text(
                    AppLocalizations.of(context)!.settingsLogoutConfirm,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.crimson,
                      ),
                      child: Text(AppLocalizations.of(context)!.settingsLogout),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

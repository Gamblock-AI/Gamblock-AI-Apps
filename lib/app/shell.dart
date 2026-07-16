import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../core/feedback/haptics.dart';
import '../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.navy.withValues(alpha: 0.08)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index(location),
          onDestinationSelected: (index) {
            Haptics.selection();
            context.go(
              const [
                '/protection',
                '/analytics',
                '/accountability',
                '/settings',
              ][index],
            );
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.shield_outlined),
              selectedIcon: const Icon(Icons.shield),
              label: l10n.protectionTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.insights_outlined),
              selectedIcon: const Icon(Icons.insights),
              label: l10n.analyticsTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: l10n.partnerTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.settingsTitle,
            ),
          ],
        ),
      ),
    );
  }

  int _index(String path) {
    if (path.startsWith('/analytics')) return 1;
    if (path.startsWith('/accountability')) return 2;
    if (path.startsWith('/settings')) return 3;
    return 0;
  }
}

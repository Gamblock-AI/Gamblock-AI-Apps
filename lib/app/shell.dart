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
    final destinations = [
      _Destination(
        Icons.space_dashboard_outlined,
        Icons.space_dashboard,
        l10n.dashboardTitle,
        '/dashboard',
      ),
      _Destination(
        Icons.insights_outlined,
        Icons.insights,
        l10n.analyticsTitle,
        '/analytics',
      ),
      _Destination(
        Icons.people_outline,
        Icons.people,
        l10n.partnerTitle,
        '/accountability',
      ),
      _Destination(
        Icons.settings_outlined,
        Icons.settings,
        l10n.settingsTitle,
        '/settings',
      ),
    ];
    final selectedIndex = _index(location);
    void select(int index) {
      Haptics.selection();
      context.go(destinations[index].path);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 720;
        final content = Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: child,
          ),
        );
        if (useRail) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: select,
                    labelType: constraints.maxWidth >= 1000
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    extended: constraints.maxWidth >= 1000,
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.navy,
                        child: Icon(Icons.shield_rounded, color: Colors.white),
                      ),
                    ),
                    destinations: [
                      for (final destination in destinations)
                        NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                  VerticalDivider(
                    width: 1,
                    color: AppColors.navy.withValues(alpha: .08),
                  ),
                  Expanded(child: content),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: content,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.navy.withValues(alpha: 0.08)),
              ),
            ),
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: select,
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _index(String path) {
    if (path.startsWith('/analytics')) return 1;
    if (path.startsWith('/accountability')) return 2;
    if (path.startsWith('/settings')) return 3;
    return 0;
  }
}

class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label, this.path);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;
}

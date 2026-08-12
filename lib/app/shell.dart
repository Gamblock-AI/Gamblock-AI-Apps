import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../core/feedback/haptics.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/widgets/brand_widgets.dart';

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

    void openQuickActions() {
      Haptics.selection();
      showQuickActionsSheet(
        context,
        title: l10n.quickActionsTitle,
        actions: [
          QuickAction(
            icon: Icons.self_improvement_rounded,
            label: l10n.quickActionBreathe,
            subtitle: l10n.quickActionBreatheSubtitle,
            color: AppColors.navy,
            onTap: () => context.go('/pattern-interrupt'),
          ),
          QuickAction(
            icon: Icons.support_agent_rounded,
            label: l10n.quickActionRecovery,
            subtitle: l10n.quickActionRecoverySubtitle,
            color: AppColors.blueAccent,
            onTap: () => context.go('/recovery'),
          ),
        ],
      );
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
          extendBody: true,
          body: content,
          bottomNavigationBar: _GlassBottomNav(
            selectedIndex: selectedIndex,
            destinations: destinations,
            onSelect: select,
            onFab: openQuickActions,
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

/// Floating glass bottom bar with four destinations and a raised center FAB —
/// mirrors the wireframe bottom navigation (blur, hairline border, active dot).
class _GlassBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<_Destination> destinations;
  final ValueChanged<int> onSelect;
  final VoidCallback onFab;

  const _GlassBottomNav({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelect,
    required this.onFab,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 76,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.banner),
                  ),
                  border: const Border(
                    top: BorderSide(color: AppColors.glassBorder),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 40,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < destinations.length; i++)
                      Expanded(
                        child: _NavItem(
                          destination: destinations[i],
                          selected: i == selectedIndex,
                          onTap: () => onSelect(i),
                          // Keep the two items beside the center FAB clear of
                          // the 60px raised button (16px symmetric inset).
                          padding: i == 1
                              ? const EdgeInsets.only(right: AppSpacing.lg)
                              : i == 2
                              ? const EdgeInsets.only(left: AppSpacing.lg)
                              : EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              child: Center(child: _CenterFab(onTap: onFab)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsets padding;

  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Icon(
              selected ? destination.selectedIcon : destination.icon,
              size: AppIconSize.lg,
              color: selected ? AppColors.navy : AppColors.inkMuted,
            ),
            const SizedBox(height: 4),
            Text(
              destination.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.navy : AppColors.inkMuted,
              ),
            ),
            const Spacer(),
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.blueAccent : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterFab extends StatelessWidget {
  final VoidCallback onTap;
  const _CenterFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.blueAccentGradient,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: AppColors.fabGlow,
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

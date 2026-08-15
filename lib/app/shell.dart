import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../core/feedback/haptics.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/widgets/brand_widgets.dart';
import '../features/mini_games/presentation/mini_game_exit.dart';
import '../features/tour/presentation/dashboard_tour_host.dart';
import '../features/tour/presentation/tour_target.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    Future<void> navigateTo(String path) async {
      if (location == path) return;
      Haptics.selection();
      await exitMiniGameTo(context, ref, path);
    }

    void select(int index) {
      unawaited(navigateTo(destinations[index].path));
    }

    void openMiniGames() {
      unawaited(navigateTo('/mini-games'));
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
          return Stack(
            children: [
              MeshBackground(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SafeArea(
                    child: Row(
                      children: [
                        NavigationRail(
                          backgroundColor: Colors.white.withValues(alpha: 0.74),
                          selectedIndex: selectedIndex,
                          onDestinationSelected: select,
                          labelType: constraints.maxWidth >= 1000
                              ? NavigationRailLabelType.none
                              : NavigationRailLabelType.all,
                          extended: constraints.maxWidth >= 1000,
                          leading: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 12,
                            ),
                            child: constraints.maxWidth >= 1000
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/images/gamblock-1.png',
                                        key: const ValueKey('sidebar-brand-logo'),
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Gamblock AI',
                                        key: ValueKey('sidebar-brand-title'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.navy,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  )
                                : Image.asset(
                                    'assets/images/gamblock-1.png',
                                    key: const ValueKey('sidebar-brand-logo'),
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.contain,
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
                ),
              ),
              Positioned.fill(
                child: DashboardTourHost(currentPath: location),
              ),
            ],
          );
        }
        return Stack(
          children: [
            MeshBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                extendBody: true,
                body: content,
                bottomNavigationBar: _GlassBottomNav(
                  selectedIndex: selectedIndex,
                  destinations: destinations,
                  onSelect: select,
                  onMiniGames: openMiniGames,
                  miniGamesActive: location.startsWith('/mini-games'),
                  miniGamesLabel: l10n.miniGamesTitle,
                ),
              ),
            ),
            Positioned.fill(
              child: DashboardTourHost(currentPath: location),
            ),
          ],
        );
      },
    );
  }

  int? _index(String path) {
    if (path.startsWith('/mini-games')) return null;
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
  final int? selectedIndex;
  final List<_Destination> destinations;
  final ValueChanged<int> onSelect;
  final VoidCallback onMiniGames;
  final bool miniGamesActive;
  final String miniGamesLabel;

  const _GlassBottomNav({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelect,
    required this.onMiniGames,
    required this.miniGamesActive,
    required this.miniGamesLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: SizedBox(
          height: 80,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 64,
                child: TourTarget(
                  id: 'tour-nav',
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.banner),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.cardSoftShadow,
                    ),
                    child: Row(
                      children: [
                        for (var i = 0; i < destinations.length; i++)
                          Expanded(
                            child: _NavItem(
                              destination: destinations[i],
                              selected: i == selectedIndex,
                              onTap: () => onSelect(i),
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
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: TourTarget(
                    id: 'tour-fab',
                    child: _CenterFab(
                      onTap: onMiniGames,
                      active: miniGamesActive,
                      label: miniGamesLabel,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      borderRadius: BorderRadius.circular(AppRadius.banner),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? destination.selectedIcon : destination.icon,
              size: 21,
              color: selected ? AppColors.navy : AppColors.inkMuted,
            ),
            const SizedBox(height: 2),
            Text(
              destination.label,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.navy : AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 4,
              height: 4,
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
  final bool active;
  final String label;

  const _CenterFab({
    required this.onTap,
    required this.active,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.blueAccentGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? AppColors.navy : Colors.white,
                  width: active ? 3 : 4,
                ),
                boxShadow: AppColors.fabGlow,
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

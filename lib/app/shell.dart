import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/feedback/haptics.dart';
import '../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _getIndex(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.navy.withValues(alpha: 0.08))),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) {
            Haptics.selection();
            _navigate(context, i);
          },
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          height: 68,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'Proteksi',
            ),
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.self_improvement_outlined),
              selectedIcon: Icon(Icons.self_improvement),
              label: 'Pemulihan',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }

  int _getIndex(String path) {
    if (path.startsWith('/dashboard')) return 1;
    if (path.startsWith('/recovery')) return 2;
    if (path.startsWith('/settings')) return 3;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    final routes = ['/protection', '/dashboard', '/recovery', '/settings'];
    context.go(routes[index]);
  }
}

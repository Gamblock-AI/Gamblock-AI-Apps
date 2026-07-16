import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/accountability/presentation/screens/accountability_screen.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/intro/presentation/screens/intro_screen.dart';
import '../features/pattern_interrupt/presentation/screens/pattern_interrupt_screen.dart';
import '../features/protection/presentation/screens/protection_screen.dart';
import '../features/recovery/presentation/screens/recovery_handoff_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/setup/presentation/screens/setup_screen.dart';
import 'shell.dart';

Page<void> _page({required LocalKey key, required Widget child}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, 0.025),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 220),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/protection',
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/dashboard') return '/analytics';
      if (path == '/onboarding' || path == '/onboarding/create-group') {
        return '/setup';
      }
      if (authState.isLoading) return null;
      final authEntry =
          path == '/login' || path == '/register' || path == '/intro';
      if (authState.isAuthenticated && authEntry) return '/protection';
      return null;
    },
    routes: [
      GoRoute(
        path: '/intro',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const IntroScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const RegisterScreen()),
      ),
      GoRoute(
        path: '/setup',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const SetupScreen()),
      ),
      GoRoute(
        path: '/pattern-interrupt',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const PatternInterruptScreen()),
      ),
      GoRoute(
        path: '/recovery',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const RecoveryHandoffScreen()),
      ),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/protection',
            pageBuilder: (_, state) =>
                _page(key: state.pageKey, child: const ProtectionScreen()),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (_, state) =>
                _page(key: state.pageKey, child: const AnalyticsScreen()),
          ),
          GoRoute(
            path: '/accountability',
            pageBuilder: (_, state) =>
                _page(key: state.pageKey, child: const AccountabilityScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (_, state) =>
                _page(key: state.pageKey, child: const SettingsScreen()),
          ),
        ],
      ),
    ],
  );
});

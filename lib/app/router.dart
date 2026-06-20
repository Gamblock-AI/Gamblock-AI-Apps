import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/onboarding/presentation/screens/group_code_screen.dart';
import '../features/onboarding/presentation/screens/create_group_screen.dart';
import '../features/protection/presentation/screens/protection_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/recovery/presentation/screens/recovery_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/pattern_interrupt/presentation/screens/pattern_interrupt_screen.dart';
import '../features/intro/presentation/screens/intro_screen.dart';
import 'shell.dart';

// Custom page builder: fade + slight slide transition for every route. Keeps
// navigation feeling smooth and consistent. (Framework disables animations when
// the user requests reduced motion via platform accessibility settings.)
Page<void> _fadeSlidePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
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
      final isAuth = authState.isAuthenticated;
      final isPublic = state.uri.path == '/login' ||
          state.uri.path == '/register' ||
          state.uri.path == '/intro';
      final isLoading = authState.isLoading;

      if (isLoading) return null;
      if (!isAuth && !isPublic) return '/intro';
      if (isAuth && isPublic) return '/protection';
      return null;
    },
    routes: [
      GoRoute(
        path: '/intro',
        pageBuilder: (_, state) =>
            _fadeSlidePage(key: state.pageKey, child: const IntroScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, state) =>
            _fadeSlidePage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (_, state) =>
            _fadeSlidePage(key: state.pageKey, child: const RegisterScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, state) =>
            _fadeSlidePage(key: state.pageKey, child: const GroupCodeScreen()),
      ),
      GoRoute(
        path: '/onboarding/create-group',
        pageBuilder: (_, state) =>
            _fadeSlidePage(key: state.pageKey, child: const CreateGroupScreen()),
      ),
      GoRoute(
        path: '/pattern-interrupt',
        pageBuilder: (_, state) =>
            _fadeSlidePage(key: state.pageKey, child: const PatternInterruptScreen()),
      ),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/protection',
            pageBuilder: (_, state) =>
                _fadeSlidePage(key: state.pageKey, child: const ProtectionScreen()),
          ),
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, state) =>
                _fadeSlidePage(key: state.pageKey, child: const DashboardScreen()),
          ),
          GoRoute(
            path: '/recovery',
            pageBuilder: (_, state) =>
                _fadeSlidePage(key: state.pageKey, child: const RecoveryScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (_, state) =>
                _fadeSlidePage(key: state.pageKey, child: const SettingsScreen()),
          ),
        ],
      ),
    ],
  );
});

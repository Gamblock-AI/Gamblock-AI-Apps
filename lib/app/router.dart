import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_state.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/onboarding/group_code_screen.dart';
import '../features/onboarding/create_group_screen.dart';
import '../features/protection/protection_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/recovery/recovery_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/pattern_interrupt/pattern_interrupt_screen.dart';
import 'shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/protection',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLogin = state.uri.path == '/login' || state.uri.path == '/register';
      final isLoading = authState.isLoading;

      if (isLoading) return null;
      if (!isAuth && !isLogin) return '/login';
      if (isAuth && isLogin) return '/protection';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const GroupCodeScreen()),
      GoRoute(path: '/onboarding/create-group', builder: (_, __) => const CreateGroupScreen()),
      GoRoute(path: '/pattern-interrupt', builder: (_, __) => const PatternInterruptScreen()),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/protection', builder: (_, __) => const ProtectionScreen()),
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/recovery', builder: (_, __) => const RecoveryScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/device/aggregate_sync.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/providers.dart';
import '../../domain/entities/protection_analytics.dart';
import '../widgets/analytics_data_state_notice.dart';
import '../widgets/analytics_period_selector.dart';
import '../widgets/analytics_totals_grid.dart';
import '../widgets/protection_trend_chart.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _days = 7;
  bool _loading = false;
  ProtectionAnalytics? _analytics;
  Object? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated || auth.deviceId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AggregateSync.flushCompletedDays(auth.deviceId);
      final analytics = await ref
          .read(analyticsRepositoryProvider)
          .fetch(deviceId: auth.deviceId!, days: _days);
      if (mounted) setState(() => _analytics = analytics);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated || auth.deviceId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.analyticsTitle)),
        body: EmptyState(
          icon: Icons.lock_outline,
          title: l10n.analyticsSignInTitle,
          hint: l10n.analyticsSignInBody,
          actionLabel: l10n.authLoginBtn,
          onAction: () => context.go('/login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.auto_graph_rounded,
                size: 18,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.analyticsTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            AnalyticsPeriodSelector(
              selectedDays: _days,
              onChanged: (days) {
                setState(() => _days = days);
                _load();
              },
            ),
            const SizedBox(height: 12),
            if (_loading && _analytics == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              EmptyState(
                icon: Icons.cloud_off,
                title: l10n.analyticsErrorTitle,
                hint: AppMessages.friendlyMessage(context, _error!),
                actionLabel: l10n.retry,
                onAction: _load,
              )
            else ...[
              AnalyticsTotalsGrid(
                totals:
                    _analytics?.totals ??
                    const ProtectionAnalyticsTotals(
                      blocked: 0,
                      interventions: 0,
                      tamperEvents: 0,
                      permissionRevoked: 0,
                    ),
              ),
              const SizedBox(height: 14),
              ProtectionTrendChart(days: _analytics?.daily ?? const []),
              const SizedBox(height: 10),
              AnalyticsDataStateNotice(dataState: _analytics?.dataState),
              const SizedBox(height: 14),
              _buildPrivacyInfoSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyInfoSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.analyticsPrivacySectionTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _privacyInfoRow(
                  context,
                  icon: Icons.shield_outlined,
                  title: l10n.analyticsOnDeviceTitle,
                  description: l10n.analyticsOnDeviceDesc,
                ),
                const Divider(height: 24),
                _privacyInfoRow(
                  context,
                  icon: Icons.lock_outline,
                  title: l10n.analyticsNoBrowsingHistoryTitle,
                  description: l10n.analyticsNoBrowsingHistoryDesc,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _privacyInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.navy),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

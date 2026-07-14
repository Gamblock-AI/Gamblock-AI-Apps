import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/weekly_progress.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/repositories/dashboard_repository.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_widgets.dart';
import '../widgets/summary_card.dart';
import '../widgets/weekly_trend_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl();
});

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardSummary? _summary;
  WeeklyProgress? _progress;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final repo = ref.read(dashboardRepositoryProvider);
    try {
      final summary = await repo.fetchSummary();
      final progress = await repo.fetchProgress();
      setState(() {
        _summary = summary;
        _progress = progress;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.dashboardTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SkeletonBox(width: 120, height: 24),
            const SizedBox(height: 12),
            const SkeletonBox(width: double.infinity, height: 32),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(
                  child: SkeletonBox(width: double.infinity, height: 96),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SkeletonBox(width: double.infinity, height: 96),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: SkeletonBox(width: double.infinity, height: 96),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SkeletonBox(width: double.infinity, height: 96),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SkeletonBox(width: double.infinity, height: 160),
          ],
        ),
      );
    }

    final blocked = _summary?.blockedAttempts ?? 0;
    final days = _summary?.activeDays ?? 0;
    final streak = _summary?.currentStreak ?? 0;
    final weeklyBlocks = _progress?.weeklyBlocks ?? [0, 0, 0, 0, 0, 0, 0];

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.dashboardTitle)),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            EyebrowPill(
              label: AppLocalizations.of(context)!.dashboardAnalytics,
              color: AppColors.crimson,
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.dashboardYourProgress,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.navy,
                letterSpacing: -0.8,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    icon: Icons.block,
                    label: AppLocalizations.of(context)!.protectionTotalBlocks,
                    value: '$blocked',
                    color: AppColors.crimson,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    icon: Icons.local_fire_department,
                    label: 'Streak',
                    value: '$streak hari',
                    color: AppColors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    icon: Icons.calendar_today,
                    label: AppLocalizations.of(context)!.protectionActiveDays,
                    value: '$days',
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    icon: Icons.self_improvement,
                    label: 'Mood',
                    value: '🙂',
                    color: AppColors.sage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.dashboardWeeklyTrend,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 12),
            WeeklyTrendChart(weeklyBlocks: weeklyBlocks),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/protection'),
              icon: const Icon(Icons.shield),
              label: Text(
                AppLocalizations.of(context)!.dashboardViewProtectionStatus,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

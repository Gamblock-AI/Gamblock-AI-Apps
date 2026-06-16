import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? _summary;
  Map<String, dynamic>? _progress;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final results = await Future.wait([
        ApiClient.dio.get('/v1/client/dashboard-summary'),
        ApiClient.dio.get('/v1/client/progress'),
      ]);
      setState(() {
        _summary = results[0].data['data'] as Map<String, dynamic>?;
        _progress = results[1].data['data'] as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final blocked = _summary?['blocked_attempts'] ?? 0;
    final days = _summary?['active_days'] ?? 0;
    final streak = _summary?['current_streak'] ?? 0;
    final weeklyBlocks = (_progress?['weekly_blocks'] as List<dynamic>?)?.cast<int>() ?? [0, 0, 0, 0, 0, 0, 0];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary cards
            Row(children: [
              Expanded(child: _DashCard(icon: Icons.block, label: 'Total Blokir', value: '$blocked', color: AppColors.crimson)),
              const SizedBox(width: 12),
              Expanded(child: _DashCard(icon: Icons.local_fire_department, label: 'Streak', value: '$streak hari', color: AppColors.amber)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _DashCard(icon: Icons.calendar_today, label: 'Hari Aktif', value: '$days', color: AppColors.navy)),
              const SizedBox(width: 12),
              Expanded(child: _DashCard(icon: Icons.self_improvement, label: 'Mood', value: '🙂', color: AppColors.sage)),
            ]),
            const SizedBox(height: 24),

            // Weekly trend
            Text('Tren Mingguan', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.navy)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.navy.withValues(alpha: 0.08)),
              ),
              child: Column(children: [
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (i) {
                      final maxVal = weeklyBlocks.isEmpty ? 1 : weeklyBlocks.reduce((a, b) => a > b ? a : b);
                      final h = maxVal > 0 ? (weeklyBlocks[i] / maxVal * 80).clamp(4.0, 80.0) : 4.0;
                      final isToday = i == 6;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('${weeklyBlocks[i]}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isToday ? AppColors.crimson : AppColors.navy.withValues(alpha: 0.5))),
                              const SizedBox(height: 4),
                              Container(height: h, decoration: BoxDecoration(color: isToday ? AppColors.crimson : AppColors.navy.withValues(alpha: 0.3), borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'].map((d) => Expanded(child: Text(d, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.navy.withValues(alpha: 0.4))))).toList(),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // Recent interventions
            Text('Intervensi Terakhir', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.navy)),
            const SizedBox(height: 8),
            ...List.generate(5, (i) => ListTile(
              leading: CircleAvatar(backgroundColor: AppColors.crimson.withValues(alpha: 0.1), child: Text('${i + 1}', style: const TextStyle(color: AppColors.crimson, fontWeight: FontWeight.w700))),
              title: Text('Situs diblokir: contoh-${i + 1}.com', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text('${i + 1} hari lalu', style: TextStyle(fontSize: 12, color: AppColors.navy.withValues(alpha: 0.5))),
            )),
          ],
        ),
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _DashCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.navy.withValues(alpha: 0.5)), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

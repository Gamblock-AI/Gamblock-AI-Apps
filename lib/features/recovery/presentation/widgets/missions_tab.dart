import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Daily self-regulation missions checklist (PRD §3.4-B / Self-Regulation Theory).
class MissionsTab extends StatelessWidget {
  final List<String> missions;
  final List<bool> checked;
  final ValueChanged<int> onToggle;

  const MissionsTab({
    super.key,
    required this.missions,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final done = checked.where((c) => c).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(AppLocalizations.of(context)!.recoveryDailyMissions,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.navy)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20)),
            child: Text('$done/${missions.length} Selesai',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy)),
          ),
        ]),
        const SizedBox(height: 12),
        ...List.generate(
          missions.length,
          (i) => CheckboxListTile(
            title: Text(missions[i],
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: checked[i]
                        ? AppColors.navy.withValues(alpha: 0.3)
                        : AppColors.navy,
                    decoration: checked[i] ? TextDecoration.lineThrough : null)),
            value: checked[i],
            onChanged: (_) => onToggle(i),
            activeColor: AppColors.sage,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
      ],
    );
  }
}

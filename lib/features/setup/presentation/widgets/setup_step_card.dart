import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/setup_step.dart';

/// Renders one numbered, optionally actionable setup checklist item.
class SetupStepCard extends StatelessWidget {
  const SetupStepCard({
    super.key,
    required this.index,
    required this.step,
    required this.isLoading,
  });

  final int index;
  final SetupStep step;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final color = step.isComplete ? AppColors.sage : AppColors.navy;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    step.isComplete ? Icons.check : step.icon,
                    color: color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${step.title}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        step.body,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedForeground,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (step.onAction != null && step.actionLabel != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: isLoading ? null : step.onAction,
                child: Text(step.actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

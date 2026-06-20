import 'package:flutter/material.dart';
import '../../domain/repositories/recovery_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/feedback/feedback.dart';

/// Mood tracker tab. Submits a mood as a reflection entry via the repository.
class MoodTab extends StatefulWidget {
  final RecoveryRepository repository;
  final VoidCallback onSubmitted;

  const MoodTab({super.key, required this.repository, required this.onSubmitted});

  @override
  State<MoodTab> createState() => _MoodTabState();
}

class _MoodTabState extends State<MoodTab> {
  int? _selected;
  bool _submitting = false;

  static const _moods = [
    ('😫', 'Stres'),
    ('😟', 'Cemas'),
    ('😐', 'Biasa'),
    ('🙂', 'Baik'),
    ('😊', 'Hebat'),
  ];

  Future<void> _submit() async {
    if (_selected == null) return;
    final label = _moods[_selected!].$2;
    setState(() => _submitting = true);
    try {
      await widget.repository
          .submitReflection(text: 'Mood hari ini: $label', mood: label);
      widget.onSubmitted();
      if (mounted) {
        AppFeedback.success(context, 'Mood tercatat');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.error(context, AppMessages.friendlyMessage(e));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Bagaimana kondisi emosi Anda hari ini?',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.navy)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            5,
            (i) => GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: Column(children: [
                Text(_moods[i].$1,
                    style: TextStyle(fontSize: _selected == i ? 48 : 36)),
                const SizedBox(height: 4),
                Text(_moods[i].$2,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: _selected == i ? FontWeight.w700 : FontWeight.w500,
                        color: _selected == i
                            ? AppColors.navy
                            : AppColors.navy.withValues(alpha: 0.5))),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: (_selected != null && !_submitting) ? _submit : null,
          child: _submitting
              ? const SizedBox(
                  height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Catat Mood'),
        ),
      ],
    );
  }
}

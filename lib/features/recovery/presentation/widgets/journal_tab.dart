import 'package:flutter/material.dart';
import '../../domain/entities/reflection_entry.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';

/// Journal reflection tab: write a new entry and list history.
class JournalTab extends StatelessWidget {
  final List<ReflectionEntry> entries;
  final TextEditingController controller;
  final String mood;
  final ValueChanged<String> onMoodChanged;
  final VoidCallback onSubmit;
  final bool loading;
  final Future<void> Function() onRefresh;

  const JournalTab({
    super.key,
    required this.entries,
    required this.controller,
    required this.mood,
    required this.onMoodChanged,
    required this.onSubmit,
    required this.loading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    const moods = ['Baik', 'Biasa', 'Cemas'];
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('Tulis Jurnal Refleksi',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.navy)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      hintText: 'Ceritakan bagaimana perasaan Anda hari ini...'),
                ),
                const SizedBox(height: 12),
                Row(
                    children: moods.map((m) {
                  final selected = mood == m;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(m),
                      selected: selected,
                      onSelected: (_) => onMoodChanged(m),
                      selectedColor: AppColors.navy.withValues(alpha: 0.12),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 12),
                FilledButton.icon(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Simpan')),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text('Riwayat Refleksi',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.navy)),
          const SizedBox(height: 8),
          if (loading)
            ...List.generate(3, (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: SkeletonBox(width: double.infinity, height: 56),
                ))
          else if (entries.isEmpty)
            const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Belum ada jurnal',
              hint: 'Tulis refleksi pertama Anda di atas untuk memulai.',
            )
          else
            ...entries.map((e) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: AppColors.sage.withValues(alpha: 0.1),
                        child: Text('J', style: TextStyle(color: AppColors.sage))),
                    title: Text(e.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Text(e.mood,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.navy.withValues(alpha: 0.5))),
                  ),
                )),
        ],
      ),
    );
  }
}

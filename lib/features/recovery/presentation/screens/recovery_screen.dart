import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/recovery_repository_impl.dart';
import '../../domain/entities/reflection_entry.dart';
import '../../domain/repositories/recovery_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/journal_tab.dart';
import '../widgets/mood_tab.dart';
import '../widgets/missions_tab.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/feedback/feedback.dart';

class RecoveryScreen extends ConsumerStatefulWidget {
  const RecoveryScreen({super.key});
  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

final recoveryRepositoryProvider = Provider<RecoveryRepository>((ref) {
  return RecoveryRepositoryImpl();
});

class _RecoveryScreenState extends ConsumerState<RecoveryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<ReflectionEntry> _entries = [];
  final _journalCtrl = TextEditingController();
  String _mood = 'Biasa';
  bool _loading = true;
  final _missions = [
    'Tidak mengakses situs judi hari ini',
    'Menulis 1 entri jurnal refleksi',
    'Melakukan meditasi pernapasan',
    'Berdiskusi dengan pendamping',
    'Menyelesaikan 1 modul psikoedukasi',
  ];
  final List<bool> _checked = List.filled(5, false);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _fetchReflections();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _journalCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchReflections() async {
    final repo = ref.read(recoveryRepositoryProvider);
    try {
      final entries = await repo.fetchReflections();
      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitJournal() async {
    final text = _journalCtrl.text.trim();
    if (text.isEmpty) return;
    final repo = ref.read(recoveryRepositoryProvider);
    try {
      await repo.submitReflection(text: text, mood: _mood);
      _journalCtrl.clear();
      await _fetchReflections();
      if (mounted) {
        AppFeedback.success(context, 'Jurnal disimpan');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.error(context, AppMessages.friendlyMessage(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(recoveryRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemulihan'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.navy,
          unselectedLabelColor: AppColors.navy.withValues(alpha: 0.5),
          indicatorColor: AppColors.navy,
          tabs: const [
            Tab(text: 'Jurnal'),
            Tab(text: 'Mood'),
            Tab(text: 'Misi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          JournalTab(
            entries: _entries,
            controller: _journalCtrl,
            mood: _mood,
            onMoodChanged: (m) => setState(() => _mood = m),
            onSubmit: _submitJournal,
            loading: _loading,
            onRefresh: _fetchReflections,
          ),
          MoodTab(repository: repo, onSubmitted: _fetchReflections),
          MissionsTab(
            missions: _missions,
            checked: _checked,
            onToggle: (i) => setState(() => _checked[i] = !_checked[i]),
          ),
        ],
      ),
    );
  }
}

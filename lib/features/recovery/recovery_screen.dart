import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';

class RecoveryScreen extends ConsumerStatefulWidget {
  const RecoveryScreen({super.key});
  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends ConsumerState<RecoveryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  // Journal
  List<Map<String, dynamic>> _entries = [];
  final _journalCtrl = TextEditingController();
  String _mood = 'Biasa';
  bool _loading = true;
  // Misi
  final _missions = [
    'Tidak mengakses situs judi hari ini',
    'Menulis 1 entri jurnal refleksi',
    'Melakukan meditasi pernapasan',
    'Berdiskusi dengan pendamping',
    'Menyelesaikan 1 modul psikoedukasi',
  ];
  List<bool> _checked = List.filled(5, false);

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
    try {
      final response = await ApiClient.dio.get('/v1/reflections');
      final data = response.data['data'] as List<dynamic>?;
      setState(() {
        _entries = data?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitJournal() async {
    final text = _journalCtrl.text.trim();
    if (text.isEmpty) return;
    try {
      await ApiClient.dio.post('/v1/reflections', data: {'text': text, 'mood': _mood});
      _journalCtrl.clear();
      await _fetchReflections();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jurnal disimpan')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _JournalTab(entries: _entries, controller: _journalCtrl, mood: _mood, onMoodChanged: (m) => setState(() => _mood = m), onSubmit: _submitJournal, loading: _loading, onRefresh: _fetchReflections),
          _MoodTab(onSubmitted: _fetchReflections),
          _MissionsTab(missions: _missions, checked: _checked, onToggle: (i) => setState(() => _checked[i] = !_checked[i])),
        ],
      ),
    );
  }
}

class _JournalTab extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final TextEditingController controller;
  final String mood;
  final ValueChanged<String> onMoodChanged;
  final VoidCallback onSubmit;
  final bool loading;
  final Future<void> Function() onRefresh;

  const _JournalTab({required this.entries, required this.controller, required this.mood, required this.onMoodChanged, required this.onSubmit, required this.loading, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final moods = ['Baik', 'Biasa', 'Cemas'];
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('Tulis Jurnal Refleksi', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.navy)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Ceritakan bagaimana perasaan Anda hari ini...'),
                ),
                const SizedBox(height: 12),
                Row(children: moods.map((m) {
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
                FilledButton.icon(onPressed: onSubmit, icon: const Icon(Icons.send, size: 18), label: const Text('Simpan')),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text('Riwayat Refleksi', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.navy)),
          const SizedBox(height: 8),
          if (loading) const Center(child: CircularProgressIndicator()),
          ...entries.map((e) => Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: AppColors.sage.withValues(alpha: 0.1), child: Text('J', style: TextStyle(color: AppColors.sage))),
              title: Text(e['text']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
              subtitle: Text(e['mood']?.toString() ?? '', style: TextStyle(fontSize: 12, color: AppColors.navy.withValues(alpha: 0.5))),
            ),
          )),
        ],
      ),
    );
  }
}

class _MoodTab extends StatefulWidget {
  final VoidCallback onSubmitted;
  const _MoodTab({required this.onSubmitted});
  @override
  State<_MoodTab> createState() => _MoodTabState();
}

class _MoodTabState extends State<_MoodTab> {
  int? _selected;

  Future<void> _submit() async {
    if (_selected == null) return;
    final moods = ['Stres', 'Cemas', 'Biasa', 'Baik', 'Hebat'];
    try {
      await ApiClient.dio.post('/v1/reflections', data: {'text': 'Mood hari ini: ${moods[_selected!]}', 'mood': moods[_selected!]});
      widget.onSubmitted();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mood tercatat')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mencatat mood')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final moods = [
      ('😫', 'Stres'),
      ('😟', 'Cemas'),
      ('😐', 'Biasa'),
      ('🙂', 'Baik'),
      ('😊', 'Hebat'),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Bagaimana kondisi emosi Anda hari ini?', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.navy)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) => GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Column(children: [
              Text(moods[i].$1, style: TextStyle(fontSize: _selected == i ? 48 : 36)),
              const SizedBox(height: 4),
              Text(moods[i].$2, style: TextStyle(fontSize: 11, fontWeight: _selected == i ? FontWeight.w700 : FontWeight.w500, color: _selected == i ? AppColors.navy : AppColors.navy.withValues(alpha: 0.5))),
            ]),
          )),
        ),
        const SizedBox(height: 32),
        FilledButton(onPressed: _selected != null ? _submit : null, child: const Text('Catat Mood')),
      ],
    );
  }
}

class _MissionsTab extends StatelessWidget {
  final List<String> missions;
  final List<bool> checked;
  final ValueChanged<int> onToggle;

  const _MissionsTab({required this.missions, required this.checked, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final done = checked.where((c) => c).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Misi Harian', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.navy)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
            child: Text('$done/5 Selesai', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy)),
          ),
        ]),
        const SizedBox(height: 12),
        ...List.generate(5, (i) => CheckboxListTile(
          title: Text(missions[i], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: checked[i] ? AppColors.navy.withValues(alpha: 0.3) : AppColors.navy, decoration: checked[i] ? TextDecoration.lineThrough : null)),
          value: checked[i],
          onChanged: (_) => onToggle(i),
          activeColor: AppColors.sage,
          controlAffinity: ListTileControlAffinity.leading,
        )),
      ],
    );
  }
}

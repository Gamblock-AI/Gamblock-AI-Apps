import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/recovery/domain/entities/reflection_entry.dart';

void main() {
  test('parses reflection entry', () {
    final e = ReflectionEntry.fromJson({
      'id': 'ref_1',
      'text': 'saya hampir buka https://x.com',
      'mood': 'cemas',
      'created_at': '2026-06-19T10:00:00Z',
    });
    expect(e.id, 'ref_1');
    expect(e.mood, 'cemas');
    expect(e.text, contains('https://x.com'));
    expect(e.createdAt.year, 2026);
  });
  test('falls back to now for bad date', () {
    final e = ReflectionEntry.fromJson({'id': 'x', 'text': '', 'mood': '', 'created_at': 'nope'});
    expect(e.createdAt, isNotNull);
  });
}

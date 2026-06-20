import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/onboarding/domain/entities/organization.dart';

void main() {
  test('parses organization', () {
    final o = Organization.fromJson({
      'id': 'org_1', 'name': 'Kelas TI', 'slug': 'ti', 'group_code': 'ABC123',
      'status': 'active', 'members': 30,
    });
    expect(o.groupCode, 'ABC123');
    expect(o.members, 30);
  });
  test('defaults members to 0 when absent', () {
    final o = Organization.fromJson({'id': 'o', 'name': 'n', 'slug': 's'});
    expect(o.members, 0);
    expect(o.status, 'active');
  });
}

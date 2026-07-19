import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/accountability/domain/entities/accountability_models.dart';

void main() {
  test('workspace membership parses aggregate-sharing consent', () {
    final membership = AccountabilityMembership.fromWorkspace(
      {
        'id': 'mbr_1',
        'group_id': 'grp_1',
        'status': 'leave_pending',
        'sharing': {
          'protection_health': true,
          'protection_activity': false,
          'recovery_engagement': false,
          'education_progress': true,
        },
      },
      {'name': 'Kelompok Pulih', 'owner_name': 'Pendamping'},
    );

    expect(membership.groupName, 'Kelompok Pulih');
    expect(membership.sharing.protectionHealth, isTrue);
    expect(membership.sharing.protectionActivity, isFalse);
    expect(membership.sharing.toJson()['education_progress'], isTrue);
  });

  test('only pending normal exit can be cancelled', () {
    expect(
      const AccountabilityExitRequest(
        id: 'exit_1',
        kind: 'normal',
        status: 'pending',
      ).canCancel,
      isTrue,
    );
    expect(
      const AccountabilityExitRequest(
        id: 'exit_2',
        kind: 'unsafe',
        status: 'pending',
      ).canCancel,
      isFalse,
    );
  });
}

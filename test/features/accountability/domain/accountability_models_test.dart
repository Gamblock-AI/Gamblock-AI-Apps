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
      {
        'name': 'Kelompok Pulih',
        'owner_name': 'Pendamping',
        'owner_avatar_url': '/v1/users/partner/avatar',
      },
    );

    expect(membership.groupName, 'Kelompok Pulih');
    expect(membership.partnerName, 'Pendamping');
    expect(membership.partnerAvatarUrl, '/v1/users/partner/avatar');
    expect(membership.sharing.protectionHealth, isTrue);
    expect(membership.sharing.protectionActivity, isFalse);
    expect(membership.sharing.toJson()['education_progress'], isTrue);
  });

  test('workspace membership keeps avatar optional for monogram fallback', () {
    final membership = AccountabilityMembership.fromWorkspace(
      {'id': 'mbr_2', 'group_id': 'grp_2', 'sharing': const <String, bool>{}},
      {'name': 'Kelompok Aman', 'owner_name': 'Suci'},
    );

    expect(membership.partnerAvatarUrl, isNull);
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

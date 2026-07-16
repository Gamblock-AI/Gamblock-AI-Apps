import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/accountability/domain/entities/accountability_models.dart';

void main() {
  test('approval request keeps stable machine codes separate from labels', () {
    final request = ApprovalRequest.fromJson({
      'id': 'approval-1',
      'device_id': 'device-1',
      'partner_link_id': 'partner-1',
      'action': 'uninstall',
      'action_label': 'Copot aplikasi',
      'status': 'approved',
      'status_label': 'Disetujui',
      'reason': 'Perpindahan perangkat',
      'requested_duration_minutes': 0,
      'resolved_at': '2026-07-16T01:00:00Z',
      'grant_expires_at': '2026-07-16T01:10:00Z',
    });

    expect(request.action, 'uninstall');
    expect(request.actionLabel, 'Copot aplikasi');
    expect(request.status, 'approved');
    expect(request.canApply, isTrue);
    expect(request.deviceId, 'device-1');
  });

  test('applied approval cannot be applied a second time in the client', () {
    final request = ApprovalRequest.fromJson({
      'status': 'approved',
      'applied_at': '2026-07-16T01:02:00Z',
    });

    expect(request.canApply, isFalse);
  });
}

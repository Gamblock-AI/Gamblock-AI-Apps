import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/protection/domain/entities/protection_status.dart';

void main() {
  test('isActive true when mode Active', () {
    final s = ProtectionStatus.fromJson({'mode': 'Active'});
    expect(s.isActive, isTrue);
  });
  test('isActive false otherwise', () {
    final s = ProtectionStatus.fromJson({'mode': 'Paused'});
    expect(s.isActive, isFalse);
  });
  test('defaults', () {
    final s = ProtectionStatus.fromJson({});
    expect(s.mode, 'Active');
    expect(s.runtimeStatus, 'Local runtime ready');
  });
}

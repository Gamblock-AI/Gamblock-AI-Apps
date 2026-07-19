import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accountability/data/providers.dart';
import '../../accountability/domain/entities/accountability_models.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/device/aggregate_sync.dart';
import '../../../core/device/device_registry.dart';
import '../data/providers.dart';
import '../domain/entities/protection_status.dart';

/// Keeps screen-only orchestration separate from protection presentation widgets.
class ProtectionCoordinator {
  const ProtectionCoordinator(this._ref);

  final WidgetRef _ref;

  Future<ProtectionStatus> fetchLocalStatus() {
    return _ref.read(protectionRepositoryProvider).fetchLocalStatus();
  }

  Future<ProtectionAccountabilityData> loadAccountability(
    AuthState auth,
  ) async {
    if (!auth.isAuthenticated || auth.deviceId == null) {
      return const ProtectionAccountabilityData();
    }

    try {
      try {
        await AggregateSync.flushCompletedDays(auth.deviceId);
      } catch (_) {
        // Native counters remain queued for a later authenticated sync.
      }
      try {
        await DeviceRegistry.heartbeat(auth.userId);
      } catch (_) {
        // Local protection remains available while the backend is offline.
      }
      final accountability = _ref.read(accountabilityRepositoryProvider);
      final results = await Future.wait<Object?>([
        accountability.fetchWorkspace(),
        accountability.fetchApprovalRequests(),
        accountability.currentEmergency(auth.deviceId!),
      ]);
      return ProtectionAccountabilityData(
        accountability: results[0] as AccountabilityOverview,
        requests: (results[1] as List<ApprovalRequest>)
            .where((request) => request.deviceId == auth.deviceId)
            .toList(),
        emergencyRequest: results[2] as EmergencyRequest?,
      );
    } catch (error) {
      return ProtectionAccountabilityData(error: error);
    }
  }

  Future<void> openPlatformSetup() {
    return _ref.read(protectionRepositoryProvider).openPlatformSetup();
  }

  Future<Map<String, dynamic>> runLocalSelfTest() {
    return _ref.read(protectionRepositoryProvider).runLocalSelfTest();
  }

  Future<void> requestApproval({
    required String deviceId,
    required String membershipId,
    required String action,
    required String reason,
    required int durationMinutes,
  }) {
    return _ref
        .read(accountabilityRepositoryProvider)
        .requestApproval(
          deviceId: deviceId,
          membershipId: membershipId,
          action: action,
          reason: reason,
          durationMinutes: durationMinutes,
        );
  }

  Future<void> applyApproval({
    required String requestId,
    required String deviceId,
  }) {
    return _ref
        .read(accountabilityRepositoryProvider)
        .applyApproval(requestId: requestId, deviceId: deviceId);
  }

  Future<void> requestEmergency(String deviceId) {
    return _ref
        .read(accountabilityRepositoryProvider)
        .requestEmergency(deviceId);
  }

  Future<void> applyEmergencyKey({
    required String deviceId,
    required String emergencyKey,
  }) {
    return _ref
        .read(accountabilityRepositoryProvider)
        .applyEmergencyKey(deviceId: deviceId, emergencyKey: emergencyKey);
  }
}

class ProtectionAccountabilityData {
  const ProtectionAccountabilityData({
    this.accountability,
    this.requests = const [],
    this.emergencyRequest,
    this.error,
  });

  final AccountabilityOverview? accountability;
  final List<ApprovalRequest> requests;
  final EmergencyRequest? emergencyRequest;
  final Object? error;
}

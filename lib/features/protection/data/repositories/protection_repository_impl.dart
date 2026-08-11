import '../../../../core/platform/platform_bridge.dart';
import '../../domain/entities/protection_status.dart';
import '../../domain/repositories/protection_repository.dart';

class ProtectionRepositoryImpl implements ProtectionRepository {
  @override
  Future<ProtectionStatus> fetchLocalStatus() async {
    final snapshot = await PlatformBridge.getProtectionSnapshot();
    return ProtectionStatus(
      platform: snapshot.platform,
      status: snapshot.status,
      serviceRunning: snapshot.serviceRunning,
      sensorStatus: snapshot.sensorStatus,
      permissionStatus: snapshot.permissionStatus,
      rulesetVersion: snapshot.rulesetVersion,
      modelVersion: snapshot.modelVersion,
      degradedReasonCode: snapshot.degradedReasonCode,
      lastEventAt: snapshot.lastEventAt,
    );
  }

  @override
  Future<bool> openPlatformSetup() => PlatformBridge.openPlatformSetup();

  @override
  Future<Map<String, dynamic>> runLocalSelfTest() =>
      PlatformBridge.runLocalSelfTest();

}

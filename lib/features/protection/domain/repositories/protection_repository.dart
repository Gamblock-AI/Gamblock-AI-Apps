import '../entities/protection_status.dart';
import '../../../../core/platform/platform_models.dart';

abstract class ProtectionRepository {
  Future<ProtectionStatus> fetchLocalStatus();
  Future<bool> openPlatformSetup();
  Future<Map<String, dynamic>> runLocalSelfTest();
  Future<RemovalStartResult> beginApprovedRemoval();
}

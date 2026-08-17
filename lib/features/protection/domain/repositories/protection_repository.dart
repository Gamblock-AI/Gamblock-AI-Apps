import '../entities/protection_status.dart';

abstract class ProtectionRepository {
  Future<ProtectionStatus> fetchLocalStatus();
  Future<bool> openPlatformSetup();
  Future<Map<String, dynamic>> runLocalSelfTest();
  Future<bool> beginApprovedRemoval();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/protection_repository.dart';
import 'repositories/protection_repository_impl.dart';

final protectionRepositoryProvider = Provider<ProtectionRepository>((ref) {
  return ProtectionRepositoryImpl();
});

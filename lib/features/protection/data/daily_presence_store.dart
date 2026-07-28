import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

const _lastOpenKey = 'dashboard_last_open_date';

/// True exactly once per local day: the first dashboard open writes today's
/// date and reports `true`; every later open (and every storage failure)
/// reports `false`. Not auto-disposed so the answer stays stable for the
/// whole app session.
final firstOpenTodayProvider = FutureProvider<bool>((ref) async {
  const storage = FlutterSecureStorage();
  try {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final last = await storage.read(key: _lastOpenKey);
    if (last == today) return false;
    await storage.write(key: _lastOpenKey, value: today);
    return true;
  } catch (_) {
    return false;
  }
});

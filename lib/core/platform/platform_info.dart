import 'package:flutter/foundation.dart';

import 'platform_os_version_stub.dart'
    if (dart.library.io) 'platform_os_version_io.dart';

/// Web-safe platform detection used across the app.
///
/// The native targets are Android and Windows; the web build is a lightweight
/// developer convenience. Unlike `dart:io`'s `Platform`, these helpers compile
/// and stay false on the web so native-only UI and registration paths simply
/// degrade instead of crashing.
class PlatformInfo {
  PlatformInfo._();

  /// Whether the app runs on a native Android device.
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Whether the app runs on native Windows.
  static bool get isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// The device operating-system version, or `"web"` on the web build.
  static String get osVersion => deviceOsVersion();
}

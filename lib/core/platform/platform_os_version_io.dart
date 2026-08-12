import 'dart:io';

/// Native implementation of [deviceOsVersion] using `dart:io`.
String deviceOsVersion() => Platform.operatingSystemVersion;

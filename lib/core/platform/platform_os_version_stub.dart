/// Web-safe fallback of [deviceOsVersion].
///
/// `dart:io` is unavailable on the web, so the browser build reports a fixed
/// platform marker instead of an OS version.
String deviceOsVersion() => 'web';

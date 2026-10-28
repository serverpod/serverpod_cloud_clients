/// A target platform of a Flutter app, with its code in a directory of the
/// same name at the root of the app package.
enum FlutterPlatform {
  android,
  ios,
  linux,
  macos,
  windows;

  /// The directory of the platform code, relative to the app package.
  String get directoryName => name;
}

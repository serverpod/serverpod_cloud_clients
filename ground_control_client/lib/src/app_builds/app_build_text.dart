import '../protocol/protocol.dart' show AppBuildStage, AppPlatform;

/// The names users see for an app platform.
extension AppPlatformText on AppPlatform {
  /// The store a build of this platform is sent to.
  String get storeName => switch (this) {
    AppPlatform.ios => 'TestFlight',
    AppPlatform.android => 'Google Play',
  };
}

/// The names and descriptions users see for an app build stage.
extension AppBuildStageText on AppBuildStage {
  /// The name of the stage, such as `Build`.
  String get label => switch (this) {
    AppBuildStage.upload => 'Prepare',
    AppBuildStage.build => 'Build',
    AppBuildStage.publish => 'Upload',
  };

  /// The name of the stage while it runs, such as `Building`.
  String get activeLabel => switch (this) {
    AppBuildStage.upload => 'Preparing',
    AppBuildStage.build => 'Building',
    AppBuildStage.publish => 'Uploading',
  };

  /// What the stage does for a build of [platform].
  String descriptionFor(AppPlatform platform) => switch (this) {
    AppBuildStage.upload =>
      'Gets a machine, checks out your code and installs dependencies.',
    AppBuildStage.build => 'Compiles and signs your app.',
    AppBuildStage.publish => 'Sends the signed build to ${platform.storeName}.',
  };
}

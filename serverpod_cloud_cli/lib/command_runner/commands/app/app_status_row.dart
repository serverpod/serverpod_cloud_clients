import 'package:ground_control_client/ground_control_client.dart';

import 'app_build_output.dart';

/// A store an app is published to.
enum AppStore { appStore, googlePlay }

/// A platform with a connected store and its latest build, as shown by
/// `app status`.
class AppStatusRow implements SerializableModel {
  /// The platform.
  final AppPlatform platform;

  /// The store the platform publishes to.
  final AppStore store;

  /// The most recent build of the platform. Null when it has no build yet.
  final AppBuildSummary? latestBuild;

  const AppStatusRow({
    required this.platform,
    required this.store,
    required this.latestBuild,
  });

  @override
  Map<String, Object?> toJson() {
    final build = latestBuild;
    return {
      'platform': platform,
      'store': store,
      'latestBuild': build == null ? null : appBuildOutput(build),
    };
  }
}

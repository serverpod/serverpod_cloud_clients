import '../protocol/protocol.dart' show AppPlatform;

/// Official route paths to entry pages in the console.
/// Used for example by `scloud` to open the intended page in the console
/// on login or project creation.
abstract final class ConsoleRoutes {
  static const String login = '/cli/signin';
  static const String createProject = '/project/create';

  /// The plan and settings page of the project with [projectId].
  static String projectPlanAndSettings(String projectId) =>
      '/project/${Uri.encodeComponent(projectId)}/plan-and-settings';

  /// The page of the store that [platform] publishes to in the project with
  /// [projectId], with its setup guide open at the first unfinished step.
  static String appStoreSetup(String projectId, AppPlatform platform) {
    final store = switch (platform) {
      AppPlatform.ios => 'appStore',
      AppPlatform.android => 'googlePlay',
    };
    return '/project/${Uri.encodeComponent(projectId)}/app-stores/$store'
        '?setup=$store';
  }
}

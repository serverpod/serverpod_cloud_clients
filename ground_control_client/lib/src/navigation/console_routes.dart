/// Official route paths to entry pages in the console.
/// Used for example by `scloud` to open the intended page in the console
/// on login or project creation.
abstract final class ConsoleRoutes {
  static const String login = '/cli/signin';
  static const String createProject = '/project/create';
}

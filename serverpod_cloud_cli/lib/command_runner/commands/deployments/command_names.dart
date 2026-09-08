/// The command paths of the deployment and build commands.
///
/// Several of these commands are reachable through more than one path.
/// User-facing text uses the paths of the invocation the command was reached
/// through.
class CommandNames {
  const CommandNames({
    required this.deploymentShow,
    required this.deploymentList,
    required this.buildLog,
    required this.buildSecret,
  });

  final String deploymentShow;
  final String deploymentList;
  final String buildLog;
  final String buildSecret;

  /// The public paths, with the build log under the `status` command.
  static const public = CommandNames(
    deploymentShow: 'status deployment show',
    deploymentList: 'status deployment list',
    buildLog: 'status deployment log',
    buildSecret: 'build secret',
  );

  /// The public paths, with the build log under the `build` command.
  static const viaBuild = CommandNames(
    deploymentShow: 'status deployment show',
    deploymentList: 'status deployment list',
    buildLog: 'build log',
    buildSecret: 'build secret',
  );

  /// The paths under the hidden `deployment` command.
  static const legacy = CommandNames(
    deploymentShow: 'deployment show',
    deploymentList: 'deployment list',
    buildLog: 'deployment build-log',
    buildSecret: 'deployment build-secret',
  );
}

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';

class VersionCommand extends CloudCliCommand {
  static const usageDescription =
      'Prints the version of the Serverpod Cloud CLI.';

  @override
  bool get requireLogin => false;

  @override
  final name = 'version';

  @override
  final description = usageDescription;

  VersionCommand({required super.logger});

  @override
  Future<void> run() async {
    logger.info('Serverpod Cloud CLI version: ${runner.version}');
  }
}

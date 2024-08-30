import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';

class VersionCommand extends CloudCliCommand {
  @override
  final name = 'version';

  @override
  final description = 'Prints the version of the Serverpod Cloud CLI.';

  VersionCommand({required super.logger});

  @override
  void run() {
    logger.info(
        'Serverpod Cloud CLI version: ${(runner as CloudCliCommandRunner).version}');
  }
}

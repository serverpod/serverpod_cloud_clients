import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/version/version_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/version/version_ui.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

class VersionCommand extends CloudCliCommand {
  static const usageDescription =
      'Prints the version of the Serverpod Cloud CLI.';

  @override
  bool get requireLogin => false;

  @override
  bool get warnIfBillingOverdue => false;

  @override
  final name = 'version';

  @override
  final description = usageDescription;

  VersionCommand({required super.logger});

  @override
  Future<void> runWithOutput(
    final Configuration commandConfig,
    final CommandOutput output,
  ) async {
    await renderCommand(
      output,
      operation: () async =>
          VersionOperations.currentVersion(runner.version.toString()),
      textOutputUi: const VersionTextUi(),
    );
  }
}

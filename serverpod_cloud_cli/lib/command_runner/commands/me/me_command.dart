import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:serverpod_cloud_cli/command_runner/commands/me/me_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/me/me_ui.dart';

import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';

class CloudMeCommand extends CloudCliCommand {
  @override
  final name = 'me';

  @override
  final description = 'Show information about the current user.';

  @override
  String get category => CommandCategories.manage;

  CloudMeCommand({required super.logger});

  @override
  Future<void> runWithOutput(
    final Configuration commandConfig,
    final CommandOutput output,
  ) async {
    await renderCommand(
      output,
      operation: () => MeCommands.showCurrentUserOperation(
        runner.serviceProvider.cloudApiClient,
      ),
      textOutputUi: MeTextUi(),
    );
  }
}

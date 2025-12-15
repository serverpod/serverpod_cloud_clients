import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/commands/me/me.dart';

import 'categories.dart';

class CloudMeCommand extends CloudCliCommand {
  @override
  final name = 'me';

  @override
  final description = 'Show information about the current user.';

  @override
  String get category => CommandCategories.manage;

  CloudMeCommand({required super.logger}) : super(options: []);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    await MeCommands.showCurrentUser(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
    );
  }
}

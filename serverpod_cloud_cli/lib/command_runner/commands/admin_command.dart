import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';

enum DeleteAllProjectsCommandOption implements OptionDefinition {
  confirmFlag(
    ConfigOption(
      argName: 'confirmation-flag',
      helpText: 'Confirmation flag',
      defaultsTo: 'no',
      hide: true,
    ),
  );

  const DeleteAllProjectsCommandOption(this.option);

  @override
  final ConfigOption option;
}

class CloudAdminDeleteAllProjectsCommand extends CloudCliCommand {
  @override
  final name = 'admin-delete-all-projects';

  @override
  final description = 'Deletes all projects.';

  CloudAdminDeleteAllProjectsCommand({required super.logger})
      : super(options: DeleteAllProjectsCommandOption.values);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final cloudClient = runner.serviceProvider.cloudApiClient;
    final confirmFlag =
        commandConfig.value(DeleteAllProjectsCommandOption.confirmFlag);

    if (confirmFlag != 'yes') {
      logger.error(
        'You must confirm the deletion of all projects by passing the --confirmation-flag=yes flag.',
      );
      throw ErrorExitException();
    }

    try {
      await cloudClient.admin.deleteAllProjects();
    } catch (e) {
      logger.error(
        'Request to delete all projects failed: $e',
      );
      throw ErrorExitException();
    }

    logger.info('Successfully deleted all projects.');
  }
}

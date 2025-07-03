import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/admin/project_admin.dart';

enum AdminListProjectsOption<V> implements OptionDefinition<V> {
  includeArchived(FlagOption(
    argName: 'include-archived',
    helpText: 'Include archived projects.',
    defaultsTo: false,
    negatable: false,
  )),
  utc(UtcOption());

  const AdminListProjectsOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminListProjectsCommand
    extends CloudCliCommand<AdminListProjectsOption> {
  @override
  final name = 'list-projects';

  @override
  final description = 'List Serverpod Cloud projects.';

  AdminListProjectsCommand({required super.logger})
      : super(options: AdminListProjectsOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AdminListProjectsOption> commandConfig,
  ) async {
    final includeArchived =
        commandConfig.value(AdminListProjectsOption.includeArchived);
    final inUtc = commandConfig.value(AdminListProjectsOption.utc);

    await ProjectAdminCommands.listProjects(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      inUtc: inUtc,
      includeArchived: includeArchived,
    );
  }
}

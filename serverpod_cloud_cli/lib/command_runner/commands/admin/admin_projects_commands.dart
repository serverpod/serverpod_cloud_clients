import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/admin/project_admin.dart';
import 'package:serverpod_cloud_cli/commands/admin/project_admin_ui.dart';
import 'package:serverpod_cloud_cli/commands/status/status.dart'
    show deploymentListRows;
import 'package:serverpod_cloud_cli/commands/status/status_ui.dart';
import 'package:serverpod_cloud_cli/util/output/command_output.dart';

class AdminProjectCommand extends CloudCliCommand {
  @override
  final name = 'project';

  @override
  final description = 'Manage Serverpod Cloud projects.';

  AdminProjectCommand({required super.logger}) {
    addSubcommand(AdminListProjectsCommand(logger: logger));
    addSubcommand(AdminProjectStatusCommand(logger: logger));
    addSubcommand(AdminProjectDeleteCommand(logger: logger));
  }
}

enum AdminListProjectsOption<V> implements OptionDefinition<V> {
  includeArchived(
    FlagOption(
      argName: 'include-archived',
      helpText: 'Include archived projects.',
      defaultsTo: false,
      negatable: false,
    ),
  ),
  utc(UtcOption()),
  format(FormatOption());

  const AdminListProjectsOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminListProjectsCommand
    extends CloudCliCommand<AdminListProjectsOption> {
  @override
  final name = 'list';

  @override
  final description = 'List Serverpod Cloud projects.';

  AdminListProjectsCommand({required super.logger})
    : super(options: AdminListProjectsOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AdminListProjectsOption> commandConfig,
  ) async {
    final includeArchived = commandConfig.value(
      AdminListProjectsOption.includeArchived,
    );
    final inUtc = commandConfig.value(AdminListProjectsOption.utc);
    final format = commandConfig.value(AdminListProjectsOption.format);

    final output = CommandOutput(format: format, logger: logger);
    await output.render(
      operation: () => ProjectAdminCommands.listProjectsOperation(
        runner.serviceProvider.cloudApiClient,
        includeArchived: includeArchived,
      ),
      ui: AdminProjectListUi(utc: inUtc),
    );
  }
}

enum AdminProjectStatusOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true)),
  limit(
    IntOption(
      argName: 'limit',
      helpText: 'The maximum number of records to fetch.',
      defaultsTo: 10,
      min: 1,
    ),
  ),
  utc(UtcOption()),
  format(FormatOption());

  const AdminProjectStatusOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminProjectStatusCommand
    extends CloudCliCommand<AdminProjectStatusOption> {
  @override
  final name = 'status';

  @override
  final description = 'Show the status of a project.';

  AdminProjectStatusCommand({required super.logger})
    : super(options: AdminProjectStatusOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AdminProjectStatusOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(AdminProjectStatusOption.projectId);
    final limit = commandConfig.value(AdminProjectStatusOption.limit);
    final inUtc = commandConfig.value(AdminProjectStatusOption.utc);
    final format = commandConfig.value(AdminProjectStatusOption.format);

    final output = CommandOutput(format: format, logger: logger);
    await output.render(
      operation: () async {
        final statuses = await runner
            .serviceProvider
            .cloudApiClient
            .adminProjects
            .getDeployAttempts(cloudCapsuleId: projectId, limit: limit);
        return deploymentListRows(statuses);
      },
      ui: DeploymentListUi(utc: inUtc),
    );
  }
}

enum AdminProjectDeleteOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true));

  const AdminProjectDeleteOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminProjectDeleteCommand
    extends CloudCliCommand<AdminProjectDeleteOption> {
  @override
  final name = 'delete';

  @override
  final description = 'Delete a Serverpod Cloud project.';

  AdminProjectDeleteCommand({required super.logger})
    : super(options: AdminProjectDeleteOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AdminProjectDeleteOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(AdminProjectDeleteOption.projectId);

    await ProjectAdminCommands.deleteProject(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
    );
  }
}

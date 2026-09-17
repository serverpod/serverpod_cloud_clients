import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart' show PlanType;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/project_admin_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/project_admin_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployments_ui.dart';

class AdminProjectCommand extends CloudCliCommand {
  @override
  final name = 'project';

  @override
  final description = 'Manage Serverpod Cloud projects.';

  AdminProjectCommand({required super.logger}) {
    addSubcommand(AdminListProjectsCommand(logger: logger));
    addSubcommand(AdminProjectStatusCommand(logger: logger));
    addSubcommand(AdminProjectDeleteCommand(logger: logger));
    addSubcommand(AdminProjectChangeOwnerCommand(logger: logger));
    addSubcommand(AdminProjectUpdatePlanCommand(logger: logger));
  }
}

enum AdminListProjectsOption<V> implements OptionDefinition<V> {
  includePaymentsStatus(
    FlagOption(
      argName: 'include-payments',
      helpText: 'Include payments status for each project.',
      defaultsTo: false,
      negatable: false,
    ),
  ),
  includeArchived(
    FlagOption(
      argName: 'include-archived',
      helpText: 'Include archived projects.',
      defaultsTo: false,
      negatable: false,
    ),
  ),
  utc(UtcOption());

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
  Future<void> runWithOutput(
    final Configuration<AdminListProjectsOption> commandConfig,
    final CommandOutput output,
  ) async {
    final includeArchived = commandConfig.value(
      AdminListProjectsOption.includeArchived,
    );
    final includePaymentsStatus = commandConfig.value(
      AdminListProjectsOption.includePaymentsStatus,
    );
    final inUtc = commandConfig.value(AdminListProjectsOption.utc);

    await renderCommand(
      output,
      operation: () async => ProjectAdminCommands.listProjectsOperation(
        runner.serviceProvider.cloudApiClient,
        includeArchived: includeArchived,
        includePaymentsStatus: includePaymentsStatus,
      ),
      textOutputUi: AdminProjectListTextUi(
        utc: inUtc,
        includeArchived: includeArchived,
        includePaymentsStatus: includePaymentsStatus,
      ),
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
  utc(UtcOption());

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
  Future<void> runWithOutput(
    final Configuration<AdminProjectStatusOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(AdminProjectStatusOption.projectId);
    final limit = commandConfig.value(AdminProjectStatusOption.limit);
    final inUtc = commandConfig.value(AdminProjectStatusOption.utc);

    await renderCommand(
      output,
      operation: () => ProjectAdminCommands.listDeployAttemptsOperation(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        limit: limit,
      ),
      textOutputUi: DeploymentListTextUi(utc: inUtc, baseCommand: baseCommand),
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
  Future<void> runWithOutput(
    final Configuration<AdminProjectDeleteOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(AdminProjectDeleteOption.projectId);

    await confirmToContinue(
      output,
      message: 'Are you sure you want to delete the project "$projectId"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => ProjectAdminCommands.deleteProject(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: const AdminProjectDeleteTextUi(),
    );
  }
}

enum AdminProjectChangeOwnerOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true)),
  user(UserEmailOption(argPos: 1, mandatory: true));

  const AdminProjectChangeOwnerOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminProjectChangeOwnerCommand
    extends CloudCliCommand<AdminProjectChangeOwnerOption> {
  @override
  final name = 'change-owner';

  @override
  final description = 'Change the owner of a Serverpod Cloud project.';

  AdminProjectChangeOwnerCommand({required super.logger})
    : super(options: AdminProjectChangeOwnerOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminProjectChangeOwnerOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(
      AdminProjectChangeOwnerOption.projectId,
    );
    final ownerEmail = commandConfig.value(AdminProjectChangeOwnerOption.user);

    await confirmToContinue(
      output,
      message:
          'Are you sure you want to change the owner of project '
          '"$projectId" to "$ownerEmail"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => ProjectAdminCommands.changeProjectOwner(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        ownerEmail: ownerEmail,
      ),
      textOutputUi: const AdminProjectChangeOwnerTextUi(),
    );
  }
}

enum AdminProjectUpdatePlanOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true)),
  planType(
    EnumOption(
      enumParser: EnumParser([PlanType.starter, PlanType.growth]),
      argName: 'plan',
      argPos: 1,
      mandatory: true,
      helpText: 'The plan type. Can be passed as the second argument.',
    ),
  );

  const AdminProjectUpdatePlanOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminProjectUpdatePlanCommand
    extends CloudCliCommand<AdminProjectUpdatePlanOption> {
  @override
  final name = 'update-plan';

  @override
  final description = 'Update the plan of a Serverpod Cloud project.';

  AdminProjectUpdatePlanCommand({required super.logger})
    : super(options: AdminProjectUpdatePlanOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminProjectUpdatePlanOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(
      AdminProjectUpdatePlanOption.projectId,
    );
    final planType = commandConfig.value(AdminProjectUpdatePlanOption.planType);

    await confirmToContinue(
      output,
      message:
          'Are you sure you want to update the plan of project '
          '"$projectId" to "$planType"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => ProjectAdminCommands.updateProjectPlan(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        planType: planType,
      ),
      textOutputUi: const AdminProjectUpdatePlanTextUi(),
    );
  }
}

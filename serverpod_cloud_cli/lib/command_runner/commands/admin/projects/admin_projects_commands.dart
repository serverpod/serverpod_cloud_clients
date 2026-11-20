import 'package:config/command.dart' show CommandContext;
import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show PlanType, ProjectLifecycleStatus, ProjectListFilter;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/project_admin_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/project_admin_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/project_admin_status_ui.dart';

class AdminProjectCommand extends CloudCliCommand {
  @override
  final name = 'project';

  @override
  final description = 'Manage Serverpod Cloud projects.';

  AdminProjectCommand({required super.logger}) {
    addSubcommand(AdminListProjectsCommand(logger: logger));
    addSubcommand(AdminProjectStatusCommand(logger: logger));
    addSubcommand(AdminProjectDeleteCommand(logger: logger));
    addSubcommand(AdminProjectSuspendCommand(logger: logger));
    addSubcommand(AdminProjectReactivateCommand(logger: logger));
    addSubcommand(AdminProjectChangeOwnerCommand(logger: logger));
    addSubcommand(AdminProjectUpdatePlanCommand(logger: logger));
    addSubcommand(AdminProjectReprocureCommand(logger: logger));
    addSubcommand(AdminProjectSetGrantCommand(logger: logger));
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
  includeArchived(IncludeArchivedProjectsOption()),
  phase(ProjectPhaseOptions.option),
  createdSince(ProjectCreatedSinceOption()),
  createdUntil(ProjectCreatedUntilOption()),
  suspendedSince(ProjectSuspendedSinceOption()),
  suspendedUntil(ProjectSuspendedUntilOption()),
  archivedSince(ProjectArchivedSinceOption()),
  archivedUntil(ProjectArchivedUntilOption()),
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
    final CommandContext<AdminListProjectsOption, void> context,
    final CommandOutput output,
  ) async {
    final includeArchived = context.config.value(
      AdminListProjectsOption.includeArchived,
    );
    final includePaymentsStatus = context.config.value(
      AdminListProjectsOption.includePaymentsStatus,
    );
    final phase = context.config.optionalValue(AdminListProjectsOption.phase);
    final createdSince = context.config.optionalValue(
      AdminListProjectsOption.createdSince,
    );
    final createdUntil = context.config.optionalValue(
      AdminListProjectsOption.createdUntil,
    );
    final suspendedSince = context.config.optionalValue(
      AdminListProjectsOption.suspendedSince,
    );
    final suspendedUntil = context.config.optionalValue(
      AdminListProjectsOption.suspendedUntil,
    );
    final archivedSince = context.config.optionalValue(
      AdminListProjectsOption.archivedSince,
    );
    final archivedUntil = context.config.optionalValue(
      AdminListProjectsOption.archivedUntil,
    );
    final inUtc = context.config.value(AdminListProjectsOption.utc);
    final filter = ProjectListFilter(
      phase: phase,
      createdSince: createdSince,
      createdUntil: createdUntil,
      suspendedSince: suspendedSince,
      suspendedUntil: suspendedUntil,
      archivedSince: archivedSince,
      archivedUntil: archivedUntil,
    );
    final showArchivedAt =
        includeArchived ||
        phase == ProjectLifecycleStatus.archived ||
        archivedSince != null ||
        archivedUntil != null;

    await renderCommand(
      output,
      operation: () async => ProjectAdminCommands.listProjectsOperation(
        context.serviceProvider.cloudApiClient,
        includeArchived: includeArchived,
        includePaymentsStatus: includePaymentsStatus,
        filter: filter,
      ),
      textOutputUi: AdminProjectListTextUi(
        utc: inUtc,
        showArchivedAt: showArchivedAt,
        includePaymentsStatus: includePaymentsStatus,
      ),
    );
  }
}

enum AdminProjectStatusOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true)),
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
  final description = 'Show project overview status.';

  AdminProjectStatusCommand({required super.logger})
    : super(options: AdminProjectStatusOption.values);

  @override
  Future<void> runWithOutput(
    final CommandContext<AdminProjectStatusOption, void> context,
    final CommandOutput output,
  ) async {
    final projectId = context.config.value(AdminProjectStatusOption.projectId);
    final inUtc = context.config.value(AdminProjectStatusOption.utc);

    await renderCommand(
      output,
      operation: () => ProjectAdminCommands.getProjectStatusOperation(
        context.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: AdminProjectStatusTextUi(utc: inUtc),
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
    final CommandContext<AdminProjectDeleteOption, void> context,
    final CommandOutput output,
  ) async {
    final projectId = context.config.value(AdminProjectDeleteOption.projectId);

    await confirmToContinue(
      context,
      output,
      message: 'Are you sure you want to delete the project "$projectId"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => ProjectAdminCommands.deleteProject(
        context.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: const AdminProjectDeleteTextUi(),
    );
  }
}

enum AdminProjectSuspendOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true));

  const AdminProjectSuspendOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminProjectSuspendCommand
    extends CloudCliCommand<AdminProjectSuspendOption> {
  @override
  final name = 'suspend';

  @override
  final description =
      'Suspend a Serverpod Cloud project. This pauses its deployment.';

  AdminProjectSuspendCommand({required super.logger})
    : super(options: AdminProjectSuspendOption.values);

  @override
  Future<void> runWithOutput(
    final CommandContext<AdminProjectSuspendOption, void> context,
    final CommandOutput output,
  ) async {
    final projectId = context.config.value(AdminProjectSuspendOption.projectId);

    await confirmToContinue(
      context,
      output,
      message: 'Are you sure you want to suspend the project "$projectId"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => ProjectAdminCommands.suspendProject(
        context.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: const AdminProjectSuspendTextUi(),
    );
  }
}

enum AdminProjectReactivateOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true));

  const AdminProjectReactivateOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminProjectReactivateCommand
    extends CloudCliCommand<AdminProjectReactivateOption> {
  @override
  final name = 'reactivate';

  @override
  final description =
      'Reactivate a suspended Serverpod Cloud project. '
      'This resumes its last successful deployment, if any.';

  AdminProjectReactivateCommand({required super.logger})
    : super(options: AdminProjectReactivateOption.values);

  @override
  Future<void> runWithOutput(
    final CommandContext<AdminProjectReactivateOption, void> context,
    final CommandOutput output,
  ) async {
    final projectId = context.config.value(
      AdminProjectReactivateOption.projectId,
    );

    await confirmToContinue(
      context,
      output,
      message: 'Are you sure you want to reactivate the project "$projectId"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => ProjectAdminCommands.reactivateProject(
        context.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: const AdminProjectReactivateTextUi(),
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
    final CommandContext<AdminProjectChangeOwnerOption, void> context,
    final CommandOutput output,
  ) async {
    final projectId = context.config.value(
      AdminProjectChangeOwnerOption.projectId,
    );
    final ownerEmail = context.config.value(AdminProjectChangeOwnerOption.user);

    await confirmToContinue(
      context,
      output,
      message:
          'Are you sure you want to change the owner of project '
          '"$projectId" to "$ownerEmail"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => ProjectAdminCommands.changeProjectOwner(
        context.serviceProvider.cloudApiClient,
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
    final CommandContext<AdminProjectUpdatePlanOption, void> context,
    final CommandOutput output,
  ) async {
    final projectId = context.config.value(
      AdminProjectUpdatePlanOption.projectId,
    );
    final planType = context.config.value(
      AdminProjectUpdatePlanOption.planType,
    );

    await confirmToContinue(
      context,
      output,
      message:
          'Are you sure you want to update the plan of project '
          '"$projectId" to "$planType"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => ProjectAdminCommands.updateProjectPlan(
        context.serviceProvider.cloudApiClient,
        projectId: projectId,
        planType: planType,
      ),
      textOutputUi: const AdminProjectUpdatePlanTextUi(),
    );
  }
}

enum AdminProjectReprocureOption<V> implements OptionDefinition<V> {
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

  const AdminProjectReprocureOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminProjectReprocureCommand
    extends CloudCliCommand<AdminProjectReprocureOption> {
  @override
  final name = 'reprocure-subscription';

  @override
  final description =
      'Re-procure the subscription and products of an existing project. '
      'This should only be done for projects missing product allocations and a '
      'billing system subscription.';

  AdminProjectReprocureCommand({required super.logger})
    : super(options: AdminProjectReprocureOption.values);

  @override
  Future<void> runWithOutput(
    final CommandContext<AdminProjectReprocureOption, void> context,
    final CommandOutput output,
  ) async {
    final projectId = context.config.value(
      AdminProjectReprocureOption.projectId,
    );
    final planType = context.config.value(AdminProjectReprocureOption.planType);

    await confirmToContinue(
      context,
      output,
      message:
          'Are you sure you want to re-procure a new subscription for project '
          '"$projectId" on plan "$planType"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => ProjectAdminCommands.reprocureExistingProject(
        context.serviceProvider.cloudApiClient,
        projectId: projectId,
        planType: planType,
      ),
      textOutputUi: const AdminProjectReprocureTextUi(),
    );
  }
}

enum AdminProjectSetGrantOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true)),
  grant(
    StringOption(
      argName: 'grant',
      argPos: 1,
      helpText: 'The grant to set. Can be passed as the second argument.',
      valueHelp:
          'databaseBackups|futureCalls|bucketStorageBytes|'
          'bucketEgressBytesPerMonth|bucketOpsPerMonth',
      mandatory: true,
    ),
  ),
  amount(
    IntOption(
      argName: 'amount',
      helpText:
          'The allowance amount. For binary grants, '
          '1 enables the grant and 0 disables it.',
      mandatory: true,
      min: 0,
    ),
  );

  const AdminProjectSetGrantOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminProjectSetGrantCommand
    extends CloudCliCommand<AdminProjectSetGrantOption> {
  @override
  final name = 'set-grant';

  @override
  final description = 'Set a grant amount on a project/capsule.';

  AdminProjectSetGrantCommand({required super.logger})
    : super(options: AdminProjectSetGrantOption.values);

  @override
  Future<void> runWithOutput(
    final CommandContext<AdminProjectSetGrantOption, void> context,
    final CommandOutput output,
  ) async {
    final projectId = context.config.value(
      AdminProjectSetGrantOption.projectId,
    );
    final grant = context.config.value(AdminProjectSetGrantOption.grant);
    final amount = context.config.value(AdminProjectSetGrantOption.amount);

    await confirmToContinue(
      context,
      output,
      message:
          'Are you sure you want to set $grant to $amount '
          'for project "$projectId"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => ProjectAdminCommands.setGrant(
        context.serviceProvider.cloudApiClient,
        projectId: projectId,
        grant: grant,
        amount: amount,
      ),
      textOutputUi: const AdminProjectSetGrantTextUi(),
    );
  }
}

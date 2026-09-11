import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/builds/builds_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy_command.dart'
    show AwaitOption;
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployments_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployments_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/command_names.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class CloudDeploymentsCommand extends CloudCliCommand {
  @override
  final name = 'deployment';

  @override
  final bool hidden;

  @override
  String get description =>
      hidden ? 'Manage deployments.' : 'Show deployment status.';

  @override
  String get category => hidden ? CommandCategories.control : super.category;

  CloudDeploymentsCommand({
    required super.logger,
    final bool asOldAlias = false,
  }) : hidden = asOldAlias {
    addSubcommand(
      CloudDeploymentsShowCommand(logger: logger, asOldAlias: asOldAlias),
    );
    addSubcommand(
      CloudDeploymentsListCommand(logger: logger, asOldAlias: asOldAlias),
    );
    if (asOldAlias) {
      addSubcommand(
        CloudBuildLogCommand(
          logger: logger,
          name: 'build-log',
          commandNames: CommandNames.legacy,
        ),
      );
      addSubcommand(
        CloudBuildSecretCommand(
          logger: logger,
          name: 'build-secret',
          commandNames: CommandNames.legacy,
        ),
      );
    } else {
      addSubcommand(
        CloudBuildLogCommand(logger: logger, commandNames: CommandNames.public),
      );
    }
  }
}

abstract final class _DeploymentsShowOptions {
  static const projectId = ProjectIdOption();
  static const utc = UtcOption();
  static const deploy = StringOption(
    argName: 'deploy',
    argPos: 0,
    helpText:
        'View a specific deployment, with uuid or sequence number, 0 for latest. Can be passed as the first argument.',
    valueHelp: '<uuid|integer>',
    defaultsTo: '0',
  );
  static const overallStatus = FlagOption(
    argName: 'output-overall-status',
    defaultsTo: false,
    helpText:
        "View a deployment's overall status as a single word, one of: "
        "success, failure, awaiting, running, cancelled, unknown.",
    negatable: false,
  );
  static const wait = AwaitOption();
}

enum DeploymentsShowOption<V> implements OptionDefinition<V> {
  projectId(_DeploymentsShowOptions.projectId),
  utc(_DeploymentsShowOptions.utc),
  deploy(_DeploymentsShowOptions.deploy),
  overallStatus(_DeploymentsShowOptions.overallStatus),
  wait(_DeploymentsShowOptions.wait);

  const DeploymentsShowOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDeploymentsShowCommand
    extends CloudCliCommand<DeploymentsShowOption> {
  @override
  String get name => 'show';

  @override
  String get description => 'Show the status of a deployment.';

  final CommandNames _commandNames;

  @override
  String get usageExamples =>
      '''\n
Examples

  Show the status of the latest deployment and wait for it to finish.
  
    \$ $baseCommand ${_commandNames.deploymentShow}

  Show the status of the latest deployment without waiting for it to finish.
  
    \$ $baseCommand ${_commandNames.deploymentShow} --no-await

  Show the status of a specific deployment by sequence number.
  
    \$ $baseCommand ${_commandNames.deploymentShow} 3

  Show the status of a specific deployment by UUID.
  
    \$ $baseCommand ${_commandNames.deploymentShow} 550e8400-e29b-41d4-a716-446655440000
''';

  CloudDeploymentsShowCommand({
    required super.logger,
    final bool asOldAlias = false,
  }) : _commandNames = asOldAlias ? CommandNames.legacy : CommandNames.public,
       super(options: DeploymentsShowOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<DeploymentsShowOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(DeploymentsShowOption.projectId);
    final inUtc = commandConfig.value(DeploymentsShowOption.utc);
    final wait = commandConfig.value(DeploymentsShowOption.wait);
    final deploymentArg = commandConfig.optionalValue(
      DeploymentsShowOption.deploy,
    );
    final overallStatus = commandConfig.value(
      DeploymentsShowOption.overallStatus,
    );

    if (wait && !overallStatus) {
      await DeploymentCommands.tailDeployment(
        runner.serviceProvider.cloudApiClient,
        logger: logger,
        baseCommand: baseCommand,
        commandNames: _commandNames,
        projectId: projectId,
        deploymentArg: deploymentArg,
      );
      return;
    }

    await renderCommand(
      output,
      operation: () => DeploymentCommands.fetchDeploymentStatus(
        runner.serviceProvider.cloudApiClient,
        baseCommand: baseCommand,
        commandNames: _commandNames,
        projectId: projectId,
        deploymentArg: deploymentArg,
      ),
      textOutputUi: DeploymentShowTextUi(
        utc: inUtc,
        overallStatus: overallStatus,
      ),
    );
  }
}

abstract final class _DeploymentsListOptions {
  static const projectId = ProjectIdOption();
  static const limit = IntOption(
    argName: 'limit',
    helpText: 'The maximum number of records to fetch.',
    defaultsTo: 10,
    min: 1,
  );
  static const utc = UtcOption();
}

enum DeploymentsListOption<V> implements OptionDefinition<V> {
  projectId(_DeploymentsListOptions.projectId),
  limit(_DeploymentsListOptions.limit),
  utc(_DeploymentsListOptions.utc);

  const DeploymentsListOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDeploymentsListCommand
    extends CloudCliCommand<DeploymentsListOption> {
  @override
  String get name => 'list';

  @override
  String get description => 'List recent deployments.';

  final CommandNames _commandNames;

  @override
  String get usageExamples =>
      '''\n
Examples

  List the 10 most recent deployments.
  
    \$ $baseCommand ${_commandNames.deploymentList}

  List the 20 most recent deployments.
  
    \$ $baseCommand ${_commandNames.deploymentList} --limit 20
''';

  CloudDeploymentsListCommand({
    required super.logger,
    final bool asOldAlias = false,
  }) : _commandNames = asOldAlias ? CommandNames.legacy : CommandNames.public,
       super(options: DeploymentsListOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<DeploymentsListOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(DeploymentsListOption.projectId);
    final limit = commandConfig.value(DeploymentsListOption.limit);
    final inUtc = commandConfig.value(DeploymentsListOption.utc);

    await renderCommand(
      output,
      operation: () => DeploymentCommands.listDeployAttemptsOperation(
        runner.serviceProvider.cloudApiClient,
        cloudCapsuleId: projectId,
        limit: limit,
      ),
      textOutputUi: DeploymentListTextUi(utc: inUtc, baseCommand: baseCommand),
    );
  }
}

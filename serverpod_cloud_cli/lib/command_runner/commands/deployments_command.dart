import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/status/status.dart';
import 'package:serverpod_cloud_cli/commands/logs/logs.dart';
import 'package:serverpod_cloud_cli/commands/status/status_feature.dart';

import 'categories.dart';

class CloudDeploymentsCommand extends CloudCliCommand {
  @override
  final name = 'deployments';

  @override
  final description = 'Manage deployments.';

  @override
  String get category => CommandCategories.observe;

  CloudDeploymentsCommand({required super.logger}) {
    addSubcommand(CloudDeploymentsShowCommand(logger: logger));
    addSubcommand(CloudDeploymentsListCommand(logger: logger));
    addSubcommand(CloudDeploymentsBuildLogCommand(logger: logger));
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
    helpText: "View a deployment's overall status as a single word, one of: "
        "success, failure, awaiting, running, cancelled, unknown.",
    negatable: false,
  );
}

enum DeploymentsShowOption<V> implements OptionDefinition<V> {
  projectId(_DeploymentsShowOptions.projectId),
  utc(_DeploymentsShowOptions.utc),
  deploy(_DeploymentsShowOptions.deploy),
  overallStatus(_DeploymentsShowOptions.overallStatus);

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

  @override
  String get usageExamples => '''\n
Examples

  Show the status of the latest deployment.
  
    \$ scloud deployments show


  Show the status of a specific deployment by sequence number.
  
    \$ scloud deployments show 3


  Show the status of a specific deployment by UUID.
  
    \$ scloud deployments show 550e8400-e29b-41d4-a716-446655440000

''';

  CloudDeploymentsShowCommand({required super.logger})
      : super(options: DeploymentsShowOption.values);

  @override
  Future<void> runWithConfig(
      final Configuration<DeploymentsShowOption> commandConfig) async {
    final projectId = commandConfig.value(DeploymentsShowOption.projectId);
    final inUtc = commandConfig.value(DeploymentsShowOption.utc);
    final deploymentArg =
        commandConfig.optionalValue(DeploymentsShowOption.deploy);
    final overallStatus =
        commandConfig.value(DeploymentsShowOption.overallStatus);

    try {
      final attemptId = await _getDeployAttemptId(
        runner.serviceProvider.cloudApiClient,
        projectId,
        deploymentArg,
      );

      await StatusCommands.showDeploymentStatus(
        runner.serviceProvider.cloudApiClient,
        logger: logger,
        cloudCapsuleId: projectId,
        attemptId: attemptId,
        inUtc: inUtc,
        outputOverallStatus: overallStatus,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get deployment status');
    }
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

  @override
  String get usageExamples => '''\n
Examples

  List the 10 most recent deployments.
  
    \$ scloud deployments list


  List the 20 most recent deployments.
  
    \$ scloud deployments list --limit 20

''';

  CloudDeploymentsListCommand({required super.logger})
      : super(options: DeploymentsListOption.values);

  @override
  Future<void> runWithConfig(
      final Configuration<DeploymentsListOption> commandConfig) async {
    final projectId = commandConfig.value(DeploymentsListOption.projectId);
    final limit = commandConfig.value(DeploymentsListOption.limit);
    final inUtc = commandConfig.value(DeploymentsListOption.utc);

    try {
      await StatusCommands.listDeployAttempts(
        runner.serviceProvider.cloudApiClient,
        logger: logger,
        cloudCapsuleId: projectId,
        limit: limit,
        inUtc: inUtc,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get deployments list');
    }
  }
}

abstract final class _DeploymentsBuildLogOptions {
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
}

enum DeploymentsBuildLogOption<V> implements OptionDefinition<V> {
  projectId(_DeploymentsBuildLogOptions.projectId),
  utc(_DeploymentsBuildLogOptions.utc),
  deploy(_DeploymentsBuildLogOptions.deploy);

  const DeploymentsBuildLogOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDeploymentsBuildLogCommand
    extends CloudCliCommand<DeploymentsBuildLogOption> {
  @override
  String get name => 'build-log';

  @override
  String get description => "View a deployment's build log.";

  @override
  String get usageExamples => '''\n
Examples

  View the build log of the latest deployment.
  
    \$ scloud deployments build-log


  View the build log of a specific deployment by sequence number.
  
    \$ scloud deployments build-log 3


  View the build log of a specific deployment by UUID.
  
    \$ scloud deployments build-log 550e8400-e29b-41d4-a716-446655440000

''';

  CloudDeploymentsBuildLogCommand({required super.logger})
      : super(options: DeploymentsBuildLogOption.values);

  @override
  Future<void> runWithConfig(
      final Configuration<DeploymentsBuildLogOption> commandConfig) async {
    final projectId = commandConfig.value(DeploymentsBuildLogOption.projectId);
    final inUtc = commandConfig.value(DeploymentsBuildLogOption.utc);
    final deploymentArg =
        commandConfig.optionalValue(DeploymentsBuildLogOption.deploy);

    try {
      final attemptId = await _getDeployAttemptId(
        runner.serviceProvider.cloudApiClient,
        projectId,
        deploymentArg,
      );

      await LogsFeature.fetchBuildLog(
        runner.serviceProvider.cloudApiClient,
        writeln: logger.line,
        projectId: projectId,
        attemptId: attemptId,
        inUtc: inUtc,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get build log');
    }
  }
}

Future<String> _getDeployAttemptId(
  final Client cloudApiClient,
  final String projectId,
  String? deploymentArg,
) async {
  deploymentArg ??= '0';
  final attemptNumber = int.tryParse(deploymentArg);
  if (attemptNumber == null) {
    return deploymentArg;
  }
  try {
    return await StatusFeature.getDeployAttemptId(
      cloudApiClient,
      cloudCapsuleId: projectId,
      attemptNumber: attemptNumber,
    );
  } on NotFoundException catch (_) {
    if (deploymentArg == '0') {
      throw FailureException(
        error: 'No deployment status found.',
        hint: 'Run this command to deploy: scloud deploy',
      );
    }
    throw FailureException(
      error: 'No such deployment status found.',
      hint: 'Run this command to see recent deployments: '
          'scloud deployments list',
    );
  }
}

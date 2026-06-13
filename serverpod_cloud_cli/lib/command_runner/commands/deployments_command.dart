import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy_command.dart'
    show AwaitOption;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/status/status.dart';
import 'package:serverpod_cloud_cli/commands/logs/logs.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

import 'categories.dart';

class CloudDeploymentsCommand extends CloudCliCommand {
  @override
  final name = 'deployment';

  @override
  final description = 'Manage deployments.';

  @override
  String get category => CommandCategories.control;

  CloudDeploymentsCommand({required super.logger}) {
    addSubcommand(CloudDeploymentsShowCommand(logger: logger));
    addSubcommand(CloudDeploymentsListCommand(logger: logger));
    addSubcommand(CloudDeploymentsBuildLogCommand(logger: logger));
    addSubcommand(CloudDeploymentsBuildSecretCommand(logger: logger));
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

  @override
  String get usageExamples => '''\n
Examples

  Show the status of the latest deployment and wait for it to finish.
  
    \$ scloud deployment show


  Show the status of the latest deployment without waiting for it to finish.
  
    \$ scloud deployment show --no-await


  Show the status of a specific deployment by sequence number.
  
    \$ scloud deployment show 3


  Show the status of a specific deployment by UUID.
  
    \$ scloud deployment show 550e8400-e29b-41d4-a716-446655440000

''';

  CloudDeploymentsShowCommand({required super.logger})
    : super(options: DeploymentsShowOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DeploymentsShowOption> commandConfig,
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

    try {
      final attemptId = await _getDeployAttemptId(
        runner.serviceProvider.cloudApiClient,
        projectId,
        deploymentArg,
      );

      if (wait && !overallStatus) {
        await StatusCommands.tailDeploymentStatus(
          runner.serviceProvider.cloudApiClient,
          logger: logger,
          cloudCapsuleId: projectId,
          attemptId: attemptId,
          inUtc: inUtc,
        );

        return;
      }

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
  
    \$ scloud deployment list


  List the 20 most recent deployments.
  
    \$ scloud deployment list --limit 20

''';

  CloudDeploymentsListCommand({required super.logger})
    : super(options: DeploymentsListOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DeploymentsListOption> commandConfig,
  ) async {
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
  
    \$ scloud deployment build-log


  View the build log of a specific deployment by sequence number.
  
    \$ scloud deployment build-log 3


  View the build log of a specific deployment by UUID.
  
    \$ scloud deployment build-log 550e8400-e29b-41d4-a716-446655440000

''';

  CloudDeploymentsBuildLogCommand({required super.logger})
    : super(options: DeploymentsBuildLogOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DeploymentsBuildLogOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(DeploymentsBuildLogOption.projectId);
    final inUtc = commandConfig.value(DeploymentsBuildLogOption.utc);
    final deploymentArg = commandConfig.optionalValue(
      DeploymentsBuildLogOption.deploy,
    );

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

Future<UuidValue> _getDeployAttemptId(
  final Client cloudApiClient,
  final String projectId,
  String? deploymentArg,
) async {
  deploymentArg ??= '0';
  final attemptNumber = int.tryParse(deploymentArg);
  if (attemptNumber == null) {
    try {
      return UuidValue.withValidation(deploymentArg);
    } on FormatException catch (_) {
      throw FailureException(
        error: 'The requested resource did not exist.',
        hint: 'Validate the attempt id is correct.',
      );
    }
  }
  try {
    return await cloudApiClient.status.getDeployAttemptId(
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
      hint:
          'Run this command to see recent deployments: '
          'scloud deployment list',
    );
  }
}

const _buildSecretsExplanation = """
Build secrets are used to securely store sensitive information that needs to be
available when building your server, for example SSH keys.

Build secrets are not available at runtime.
(See `scloud secret` for managing runtime secrets: ${CloudCliCommand.commandDocBaseUrl}secret)""";

class CloudDeploymentsBuildSecretCommand extends CloudCliCommand {
  @override
  String get name => 'build-secret';

  @override
  String get description => """Manage build secrets.

$_buildSecretsExplanation""";

  @override
  String get usageExamples => """

Examples

  List the current build secrets.

    \$ scloud deployment build-secret list

  Add or modify a build secret.

    \$ scloud deployment build-secret set MY_SECRET_NAME "my-secret-value"
""";

  CloudDeploymentsBuildSecretCommand({required super.logger}) {
    addSubcommand(BuildSecretSetCommand(logger: logger));
    addSubcommand(BuildSecretsListCommand(logger: logger));
    addSubcommand(BuildSecretUnsetCommand(logger: logger));
  }
}

abstract final class _BuildSecretCommandConfig {
  static const projectId = ProjectIdOption();

  static const name = NameOption(
    argPos: 0,
    helpText:
        'The name of the build secret. Can be passed as the first argument.',
  );

  static const value = ValueOption(
    argPos: 1,
    helpText:
        'The value of the build secret. Can be passed as the second argument.',
  );

  static const valueFile = ValueFileOption(
    helpText: 'The name of the file with the build secret value.',
  );
}

enum BuildSecretSetCommandConfig<V> implements OptionDefinition<V> {
  projectId(_BuildSecretCommandConfig.projectId),
  name(_BuildSecretCommandConfig.name),
  value(_BuildSecretCommandConfig.value),
  valueFile(_BuildSecretCommandConfig.valueFile),
  buildSecretType(
    EnumOption<BuildSecretType>(
      argName: 'type',
      helpText: 'The type of the build secret.',
      enumParser: EnumParser(BuildSecretType.values),
      defaultsTo: BuildSecretType.ssh,
    ),
  );

  const BuildSecretSetCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class BuildSecretSetCommand
    extends CloudCliCommand<BuildSecretSetCommandConfig> {
  @override
  String get description => """Set a build secret (create or update).
  
$_buildSecretsExplanation""";

  @override
  String get name => 'set';

  BuildSecretSetCommand({required super.logger})
    : super(options: BuildSecretSetCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<BuildSecretSetCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(
      BuildSecretSetCommandConfig.projectId,
    );
    final name = commandConfig.value(BuildSecretSetCommandConfig.name);
    final value = commandConfig.optionalValue(
      BuildSecretSetCommandConfig.value,
    );
    final valueFile = commandConfig.optionalValue(
      BuildSecretSetCommandConfig.valueFile,
    );
    final buildSecretType = commandConfig.value(
      BuildSecretSetCommandConfig.buildSecretType,
    );

    String valueToSet;
    if (value != null) {
      valueToSet = value;
    } else if (valueFile != null) {
      valueToSet = valueFile.readAsStringSync();
    } else {
      throw StateError('Expected one of the value options to be set.');
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.secrets.upsertBuildSecret(
        cloudCapsuleId: projectId,
        secretKey: name,
        secretValue: valueToSet,
        buildSecretType: buildSecretType,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to set build secret');
    }

    logger.success('Successfully set build secret: $name.');
  }
}

enum BuildSecretsListCommandConfig<V> implements OptionDefinition<V> {
  projectId(_BuildSecretCommandConfig.projectId);

  const BuildSecretsListCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class BuildSecretsListCommand
    extends CloudCliCommand<BuildSecretsListCommandConfig> {
  @override
  String get description => """List all build secrets.
  
$_buildSecretsExplanation""";

  @override
  String get name => 'list';

  BuildSecretsListCommand({required super.logger})
    : super(options: BuildSecretsListCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<BuildSecretsListCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(
      BuildSecretsListCommandConfig.projectId,
    );

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    late List<String> secrets;
    try {
      secrets = await apiCloudClient.secrets.listBuild(projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to list build secrets');
    }

    final secretsPrinter = TablePrinter();
    secretsPrinter.addHeaders(['Secret name']);

    for (var secret in secrets) {
      secretsPrinter.addRow([secret]);
    }

    secretsPrinter.writeLines(logger.line);
  }
}

enum BuildSecretUnsetCommandConfig<V> implements OptionDefinition<V> {
  projectId(_BuildSecretCommandConfig.projectId),
  name(_BuildSecretCommandConfig.name);

  const BuildSecretUnsetCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class BuildSecretUnsetCommand
    extends CloudCliCommand<BuildSecretUnsetCommandConfig> {
  @override
  String get description => """Remove a build secret.

$_buildSecretsExplanation""";

  @override
  String get name => 'unset';

  BuildSecretUnsetCommand({required super.logger})
    : super(options: BuildSecretUnsetCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<BuildSecretUnsetCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(
      BuildSecretUnsetCommandConfig.projectId,
    );
    final name = commandConfig.value(BuildSecretUnsetCommandConfig.name);

    final shouldUnset = await logger.confirm(
      'Are you sure you want to remove the build secret "$name"?',
      defaultValue: false,
    );

    if (!shouldUnset) {
      throw UserAbortException();
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.secrets.deleteBuild(
        cloudCapsuleId: projectId,
        key: name,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to remove the build secret');
    }

    logger.success('Successfully removed build secret: $name.');
  }
}

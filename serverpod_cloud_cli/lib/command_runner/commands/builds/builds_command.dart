import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show BuildSecretType;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/builds/builds_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/builds/builds_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployments_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log/log_ui.dart'
    show BuildLogListTextUi;
import 'package:serverpod_cloud_cli/command_runner/commands/log/logs_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/command_names.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class CloudBuildCommand extends CloudCliCommand {
  @override
  final name = 'build';

  @override
  final description = 'View build logs and manage build secrets.';

  @override
  String get category => CommandCategories.control;

  @override
  String get usageExamples =>
      '''\n
Examples

  View the build log of the latest deployment.

    \$ $baseCommand build log


  List the current build secrets.

    \$ $baseCommand build secret list

''';

  CloudBuildCommand({required super.logger}) {
    addSubcommand(CloudBuildLogCommand(logger: logger));
    addSubcommand(CloudBuildSecretCommand(logger: logger));
  }
}

abstract final class _BuildLogOptions {
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

enum BuildLogOption<V> implements OptionDefinition<V> {
  projectId(_BuildLogOptions.projectId),
  utc(_BuildLogOptions.utc),
  deploy(_BuildLogOptions.deploy);

  const BuildLogOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudBuildLogCommand extends CloudCliCommand<BuildLogOption> {
  @override
  final String name;

  final CommandNames _commandNames;

  @override
  String get description => "View a deployment's build log.";

  @override
  String get usageExamples =>
      '''\n
Examples

  View the build log of the latest deployment.
  
    \$ $baseCommand ${_commandNames.buildLog}

  View the build log of a specific deployment by sequence number.
  
    \$ $baseCommand ${_commandNames.buildLog} 3

  View the build log of a specific deployment by UUID.
  
    \$ $baseCommand ${_commandNames.buildLog} 550e8400-e29b-41d4-a716-446655440000
''';

  CloudBuildLogCommand({
    required super.logger,
    this.name = 'log',
    final CommandNames commandNames = CommandNames.viaBuild,
  }) : _commandNames = commandNames,
       super(options: BuildLogOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<BuildLogOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(BuildLogOption.projectId);
    final inUtc = commandConfig.value(BuildLogOption.utc);
    final deploymentArg = commandConfig.optionalValue(BuildLogOption.deploy);

    final client = runner.serviceProvider.cloudApiClient;
    final attemptId = await DeploymentCommands.getDeployAttemptId(
      client,
      baseCommand: baseCommand,
      commandNames: _commandNames,
      projectId: projectId,
      deploymentArg: deploymentArg,
    );

    await renderCommand(
      output,
      operation: () => LogsOperations.fetchBuildLog(
        client,
        projectId: projectId,
        attemptId: attemptId,
      ),
      textOutputUi: BuildLogListTextUi(utc: inUtc, attemptId: attemptId),
    );
  }
}

String _buildSecretsExplanation(final String baseCommand) => """
Build secrets are used to securely store sensitive information that needs to be
available when building your server, for example SSH keys.

Build secrets are not available at runtime.
(See `$baseCommand variable set --secret` for managing runtime secrets: ${CloudCliCommand.commandDocBaseUrl}variable)""";

class CloudBuildSecretCommand extends CloudCliCommand {
  @override
  final String name;

  final CommandNames _commandNames;

  @override
  String get description => """Manage build secrets.

${_buildSecretsExplanation(baseCommand)}""";

  @override
  String get usageExamples =>
      """

Examples

  List the current build secrets.

    \$ $baseCommand ${_commandNames.buildSecret} list

  Add or modify a build secret.

    \$ $baseCommand ${_commandNames.buildSecret} set MY_SECRET_NAME "my-secret-value"
""";

  CloudBuildSecretCommand({
    required super.logger,
    this.name = 'secret',
    final CommandNames commandNames = CommandNames.public,
  }) : _commandNames = commandNames {
    addSubcommand(BuildSecretSetCommand(logger: logger));
    addSubcommand(BuildSecretsListCommand(logger: logger));
    addSubcommand(BuildSecretUnsetCommand(logger: logger));
  }
}

abstract final class _BuildSecretOptions {
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
  projectId(_BuildSecretOptions.projectId),
  name(_BuildSecretOptions.name),
  value(_BuildSecretOptions.value),
  valueFile(_BuildSecretOptions.valueFile),
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
  
${_buildSecretsExplanation(baseCommand)}""";

  @override
  String get name => 'set';

  BuildSecretSetCommand({required super.logger})
    : super(options: BuildSecretSetCommandConfig.values);

  @override
  Future<void> runWithOutput(
    final Configuration<BuildSecretSetCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(
      BuildSecretSetCommandConfig.projectId,
    );
    final name = commandConfig.value(BuildSecretSetCommandConfig.name);
    final buildSecretType = commandConfig.value(
      BuildSecretSetCommandConfig.buildSecretType,
    );

    final valueToSet = commandConfig.valueOrFileContent(
      value: BuildSecretSetCommandConfig.value,
      valueFile: BuildSecretSetCommandConfig.valueFile,
    );

    await renderCommand(
      output,
      operation: () => BuildsOperations.setBuildSecret(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        name: name,
        value: valueToSet,
        buildSecretType: buildSecretType,
      ),
      textOutputUi: const BuildSecretSetTextUi(),
    );
  }
}

enum BuildSecretsListCommandConfig<V> implements OptionDefinition<V> {
  projectId(_BuildSecretOptions.projectId);

  const BuildSecretsListCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class BuildSecretsListCommand
    extends CloudCliCommand<BuildSecretsListCommandConfig> {
  @override
  String get description => """List all build secrets.
  
${_buildSecretsExplanation(baseCommand)}""";

  @override
  String get name => 'list';

  BuildSecretsListCommand({required super.logger})
    : super(options: BuildSecretsListCommandConfig.values);

  @override
  Future<void> runWithOutput(
    final Configuration<BuildSecretsListCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(
      BuildSecretsListCommandConfig.projectId,
    );

    await renderCommand(
      output,
      operation: () => BuildsOperations.listBuildSecretsOperation(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: const StringColumnListWidget(heading: 'Secret name'),
    );
  }
}

enum BuildSecretUnsetCommandConfig<V> implements OptionDefinition<V> {
  projectId(_BuildSecretOptions.projectId),
  name(_BuildSecretOptions.name);

  const BuildSecretUnsetCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class BuildSecretUnsetCommand
    extends CloudCliCommand<BuildSecretUnsetCommandConfig> {
  @override
  String get description => """Remove a build secret.

${_buildSecretsExplanation(baseCommand)}""";

  @override
  String get name => 'unset';

  BuildSecretUnsetCommand({required super.logger})
    : super(options: BuildSecretUnsetCommandConfig.values);

  @override
  Future<void> runWithOutput(
    final Configuration<BuildSecretUnsetCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(
      BuildSecretUnsetCommandConfig.projectId,
    );
    final name = commandConfig.value(BuildSecretUnsetCommandConfig.name);

    await confirmToContinue(
      output,
      message: 'Are you sure you want to remove the build secret "$name"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => BuildsOperations.unsetBuildSecret(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        name: name,
      ),
      textOutputUi: const BuildSecretUnsetTextUi(),
    );
  }
}

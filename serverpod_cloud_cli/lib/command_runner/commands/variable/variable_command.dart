import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/variable/variable_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/variable/variable_ui.dart';

import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';

class CloudVariableCommand extends CloudCliCommand {
  @override
  final name = 'variable';

  @override
  final description =
      'Manage Serverpod Cloud environment variables and secrets for a project.';

  @override
  String get category => CommandCategories.control;

  CloudVariableCommand({required super.logger}) {
    addSubcommand(CloudVariableListCommand(logger: logger));
    addSubcommand(CloudVariableSetCommand(logger: logger));
    addSubcommand(CloudVariableUnsetCommand(logger: logger));
  }
}

abstract final class VariableCommandConfig {
  static const projectId = ProjectIdOption();

  static const variableName = NameOption(
    argPos: 0,
    helpText:
        'The name of the environment variable. Can be passed as the first argument.',
  );

  static const variableValue = ValueOption(
    argPos: 1,
    helpText:
        'The value of the environment variable. Can be passed as the second argument.',
  );

  static const valueFile = ValueFileOption(
    helpText: 'The name of the file with the environment variable value.',
  );

  static const secret = FlagOption(
    argName: 'secret',
    helpText:
        'Store the value as a secret. The value is encrypted and masked. '
        'Without this flag the value is unmasked and visible.',
    negatable: true,
  );
}

enum SetVariableCommandConfig<V> implements OptionDefinition<V> {
  projectId(VariableCommandConfig.projectId),
  variableName(VariableCommandConfig.variableName),
  variableValue(VariableCommandConfig.variableValue),
  valueFile(VariableCommandConfig.valueFile),
  secret(VariableCommandConfig.secret);

  const SetVariableCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

enum UnsetVariableCommandConfig<V> implements OptionDefinition<V> {
  projectId(VariableCommandConfig.projectId),
  variableName(VariableCommandConfig.variableName);

  const UnsetVariableCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

enum ListVariableCommandConfig<V> implements OptionDefinition<V> {
  projectId(VariableCommandConfig.projectId);

  const ListVariableCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudVariableSetCommand
    extends CloudCliCommand<SetVariableCommandConfig> {
  @override
  String get description =>
      'Set an environment variable or secret (create or update).';

  @override
  String get name => 'set';

  @override
  String? get usageExamples =>
      '''\n
Examples

  Set an environment variable called SERVICE_EMAIL to support@example.com.
  
    \$ $baseCommand variable set SERVICE_EMAIL support@example.com

  Set a secret environment variable. The value is encrypted and masked.
  
    \$ $baseCommand variable set --secret API_KEY sk-...

  To set the variable from a file, use the --from-file option.
  The full content of the file will be used as the value.

    \$ $baseCommand variable set SERVICE_EMAIL --from-file email.txt
''';

  CloudVariableSetCommand({required super.logger})
    : super(options: SetVariableCommandConfig.values);

  @override
  Future<void> runWithOutput(
    final Configuration<SetVariableCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(SetVariableCommandConfig.projectId);
    final variableName = commandConfig.value(
      SetVariableCommandConfig.variableName,
    );
    final valueToSet = commandConfig.valueOrFileContent(
      value: SetVariableCommandConfig.variableValue,
      valueFile: SetVariableCommandConfig.valueFile,
    );
    final secretFlag = commandConfig.optionalValue(
      SetVariableCommandConfig.secret,
    );

    await VariableCommands.setVariable(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      baseCommand: baseCommand,
      projectId: projectId,
      name: variableName,
      value: valueToSet,
      secret: secretFlag,
    );
  }
}

class CloudVariableUnsetCommand
    extends CloudCliCommand<UnsetVariableCommandConfig> {
  @override
  String get description => 'Remove an environment variable or secret.';

  @override
  String get name => 'unset';

  @override
  String? get usageExamples =>
      '''\n
Examples

  Remove an environment variable called SERVICE_EMAIL.
  
    \$ $baseCommand variable unset SERVICE_EMAIL
''';

  CloudVariableUnsetCommand({required super.logger})
    : super(options: UnsetVariableCommandConfig.values);

  @override
  Future<void> runWithOutput(
    final Configuration<UnsetVariableCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(UnsetVariableCommandConfig.projectId);
    final variableName = commandConfig.value(
      UnsetVariableCommandConfig.variableName,
    );

    await VariableCommands.unsetVariable(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      baseCommand: baseCommand,
      projectId: projectId,
      name: variableName,
    );
  }
}

class CloudVariableListCommand
    extends CloudCliCommand<ListVariableCommandConfig> {
  @override
  String get description =>
      'Lists all environment variables and secrets for the project.';

  @override
  String get name => 'list';

  CloudVariableListCommand({required super.logger})
    : super(options: ListVariableCommandConfig.values);

  @override
  Future<void> runWithOutput(
    final Configuration<ListVariableCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(ListVariableCommandConfig.projectId);

    await renderCommand(
      output,
      operation: () => VariableCommands.listVariablesOperation(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: VariableListTextUi(),
    );
  }
}

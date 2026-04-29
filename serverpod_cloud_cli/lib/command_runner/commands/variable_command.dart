import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

import 'categories.dart';

class CloudVariableCommand extends CloudCliCommand {
  @override
  final name = 'variable';

  @override
  final description =
      'Manage Serverpod Cloud environment variables for a project.';

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
}

enum SetVariableCommandConfig<V> implements OptionDefinition<V> {
  projectId(VariableCommandConfig.projectId),
  variableName(VariableCommandConfig.variableName),
  variableValue(VariableCommandConfig.variableValue),
  valueFile(VariableCommandConfig.valueFile);

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
  String get description => 'Set an environment variable (create or update).';

  @override
  String get name => 'set';

  @override
  String? get usageExamples => '''\n
Examples

  Set an environment variable called SERVICE_EMAIL to support@example.com.
  
    \$ scloud variable set SERVICE_EMAIL support@example.com

  To set the variable from a file, use the --from-file option.
  The full content of the file will be used as the value.

    \$ scloud variable set SERVICE_EMAIL --from-file email.txt
''';

  CloudVariableSetCommand({required super.logger})
    : super(options: SetVariableCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<SetVariableCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(SetVariableCommandConfig.projectId);
    final variableName = commandConfig.value(
      SetVariableCommandConfig.variableName,
    );
    final variableValue = commandConfig.optionalValue(
      SetVariableCommandConfig.variableValue,
    );
    final valueFile = commandConfig.optionalValue(
      SetVariableCommandConfig.valueFile,
    );

    String valueToSet;
    if (variableValue != null) {
      valueToSet = variableValue;
    } else if (valueFile != null) {
      valueToSet = valueFile.readAsStringSync();
    } else {
      throw StateError('Expected one of the value options to be set.');
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.environmentVariables.create(
        variableName,
        valueToSet,
        projectId,
      );
    } on DuplicateEntryException {
      try {
        await apiCloudClient.environmentVariables.update(
          name: variableName,
          value: valueToSet,
          cloudCapsuleId: projectId,
        );
      } on Exception catch (e, s) {
        throw FailureException.nested(
          e,
          s,
          'Failed to set the environment variable',
        );
      }
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to set the environment variable',
      );
    }

    logger.success('Successfully set environment variable: $variableName.');
  }
}

class CloudVariableUnsetCommand
    extends CloudCliCommand<UnsetVariableCommandConfig> {
  @override
  String get description => 'Remove an environment variable.';

  @override
  String get name => 'unset';

  @override
  String? get usageExamples => '''\n
Examples

  Remove an environment variable called SERVICE_EMAIL.
  
    \$ scloud variable unset SERVICE_EMAIL
''';

  CloudVariableUnsetCommand({required super.logger})
    : super(options: UnsetVariableCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<UnsetVariableCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(UnsetVariableCommandConfig.projectId);
    final variableName = commandConfig.value(
      UnsetVariableCommandConfig.variableName,
    );

    final shouldUnset = await logger.confirm(
      'Are you sure you want to remove the environment variable "$variableName"?',
      defaultValue: false,
    );

    if (!shouldUnset) {
      throw UserAbortException();
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.environmentVariables.delete(
        name: variableName,
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to remove the environment variable',
      );
    }

    logger.success('Successfully removed environment variable: $variableName.');
  }
}

class CloudVariableListCommand
    extends CloudCliCommand<ListVariableCommandConfig> {
  @override
  String get description => 'Lists all environment variables for the project.';

  @override
  String get name => 'list';

  CloudVariableListCommand({required super.logger})
    : super(options: ListVariableCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ListVariableCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(ListVariableCommandConfig.projectId);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    late List<EnvironmentVariable> environmentVariables;
    try {
      environmentVariables = await apiCloudClient.environmentVariables.list(
        projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to list environment variables',
      );
    }

    final tablePrinter = TablePrinter();
    tablePrinter.addHeaders(['Name', 'Value']);
    for (var variable in environmentVariables) {
      tablePrinter.addRow([variable.name, variable.value]);
    }

    tablePrinter.writeLines(logger.line);
  }
}

import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:ground_control_client/ground_control_client.dart';

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
    addSubcommand(CloudVariableCreateCommand(logger: logger));
    addSubcommand(CloudVariableUpdateCommand(logger: logger));
    addSubcommand(CloudVariableDeleteCommand(logger: logger));
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

enum CreateVariableCommandConfig<V> implements OptionDefinition<V> {
  projectId(VariableCommandConfig.projectId),
  variableName(VariableCommandConfig.variableName),
  variableValue(VariableCommandConfig.variableValue),
  valueFile(VariableCommandConfig.valueFile);

  const CreateVariableCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

enum UpdateVariableCommandConfig<V> implements OptionDefinition<V> {
  projectId(VariableCommandConfig.projectId),
  variableName(VariableCommandConfig.variableName),
  variableValue(VariableCommandConfig.variableValue),
  valueFile(VariableCommandConfig.valueFile);

  const UpdateVariableCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

enum DeleteVariableCommandConfig<V> implements OptionDefinition<V> {
  projectId(VariableCommandConfig.projectId),
  variableName(VariableCommandConfig.variableName);

  const DeleteVariableCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

enum ListVariableCommandConfig<V> implements OptionDefinition<V> {
  projectId(VariableCommandConfig.projectId);

  const ListVariableCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudVariableCreateCommand
    extends CloudCliCommand<CreateVariableCommandConfig> {
  @override
  String get description => 'Create an environment variable.';

  @override
  String get name => 'create';

  @override
  String get usageFooter => '''\n
Examples

  Create an environment variable called SERVICE_EMAIL with the value support@example.com.
  
    \$ scloud variable create SERVICE_EMAIL support@example.com

  To create the variable from a file, use the --from-file option.
  The full content of the file will be used as the value.

    \$ scloud variable create SERVICE_EMAIL --from-file email.txt
''';

  CloudVariableCreateCommand({required super.logger})
    : super(options: CreateVariableCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<CreateVariableCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(
      CreateVariableCommandConfig.projectId,
    );
    final variableName = commandConfig.value(
      CreateVariableCommandConfig.variableName,
    );
    final variableValue = commandConfig.optionalValue(
      CreateVariableCommandConfig.variableValue,
    );
    final valueFile = commandConfig.optionalValue(
      CreateVariableCommandConfig.valueFile,
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
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to create a new environment variable',
      );
    }

    logger.success('Successfully created environment variable.');
  }
}

class CloudVariableUpdateCommand
    extends CloudCliCommand<UpdateVariableCommandConfig> {
  @override
  String get description => 'Update an environment variable.';

  @override
  String get name => 'update';

  @override
  String get usageFooter => '''\n
Examples

  Update an environment variable called SERVICE_EMAIL with a new value.
  
    \$ scloud variable update SERVICE_EMAIL "noreply@example.com"

  To update the variable from a file, use the --from-file option.
  The full content of the file will be used as the value.

    \$ scloud variable update SERVICE_EMAIL --from-file email.txt
''';

  CloudVariableUpdateCommand({required super.logger})
    : super(options: UpdateVariableCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<UpdateVariableCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(
      UpdateVariableCommandConfig.projectId,
    );
    final variableName = commandConfig.value(
      UpdateVariableCommandConfig.variableName,
    );
    final variableValue = commandConfig.optionalValue(
      UpdateVariableCommandConfig.variableValue,
    );
    final valueFile = commandConfig.optionalValue(
      UpdateVariableCommandConfig.valueFile,
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
      await apiCloudClient.environmentVariables.update(
        name: variableName,
        value: valueToSet,
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to update the environment variable',
      );
    }

    logger.success('Successfully updated environment variable: $variableName.');
  }
}

class CloudVariableDeleteCommand
    extends CloudCliCommand<DeleteVariableCommandConfig> {
  @override
  String get description => 'Delete an environment variable.';

  @override
  String get name => 'delete';

  @override
  String get usageFooter => '''\n
Examples

  Delete an environment variable called SERVICE_EMAIL.
  
    \$ scloud variable delete SERVICE_EMAIL
''';

  CloudVariableDeleteCommand({required super.logger})
    : super(options: DeleteVariableCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DeleteVariableCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(
      DeleteVariableCommandConfig.projectId,
    );
    final variableName = commandConfig.value(
      DeleteVariableCommandConfig.variableName,
    );

    final shouldDelete = await logger.confirm(
      'Are you sure you want to delete the environment variable "$variableName"?',
      defaultValue: false,
    );

    if (!shouldDelete) {
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
        'Failed to delete the environment variable',
      );
    }

    logger.success('Successfully deleted environment variable: $variableName.');
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

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_cloud_cli/util/table_printer.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

class CloudEnvCommand extends CloudCliCommand {
  @override
  final name = 'env';

  @override
  final description =
      'Manage Serverpod Cloud environment variables for a project.';

  CloudEnvCommand({required super.logger}) {
    addSubcommand(CloudEnvCreateCommand(logger: logger));
    addSubcommand(CloudEnvListCommand(logger: logger));
    addSubcommand(CloudEnvUpdateCommand(logger: logger));
    addSubcommand(CloudEnvDeleteCommand(logger: logger));
  }
}

abstract final class EnvCommandConfig {
  static const projectId = ConfigOption(
    argName: 'project-id',
    argAbbrev: 'i',
    helpText: 'The ID of the project.',
    mandatory: true,
    envName: 'SERVERPOD_CLOUD_PROJECT_ID',
  );

  static const variableName = ConfigOption(
    argName: 'name',
    argAbbrev: 'n',
    argPos: 0,
    helpText:
        'The name of the environment variable. Can also be specified as the first argument.',
    mandatory: true,
  );

  static const variableValue = ConfigOption(
    argName: 'value',
    argAbbrev: 'v',
    argPos: 1,
    helpText:
        'The value of the environment variable. Can also be specified as the second argument.',
    mandatory: true,
  );
}

enum CreateEnvCommandConfig implements OptionDefinition {
  projectId(EnvCommandConfig.projectId),
  variableName(EnvCommandConfig.variableName),
  variableValue(EnvCommandConfig.variableValue);

  const CreateEnvCommandConfig(this.option);

  @override
  final ConfigOption option;
}

enum UpdateEnvCommandConfig implements OptionDefinition {
  projectId(EnvCommandConfig.projectId),
  variableName(EnvCommandConfig.variableName),
  variableValue(EnvCommandConfig.variableValue);

  const UpdateEnvCommandConfig(this.option);

  @override
  final ConfigOption option;
}

enum DeleteEnvCommandConfig implements OptionDefinition {
  projectId(EnvCommandConfig.projectId),
  variableName(EnvCommandConfig.variableName);

  const DeleteEnvCommandConfig(this.option);

  @override
  final ConfigOption option;
}

enum ListEnvCommandConfig implements OptionDefinition {
  projectId(EnvCommandConfig.projectId);

  const ListEnvCommandConfig(this.option);

  @override
  final ConfigOption option;
}

class CloudEnvCreateCommand extends CloudCliCommand<CreateEnvCommandConfig> {
  @override
  String get description => 'Create an environment variable.';

  @override
  String get name => 'create';

  CloudEnvCreateCommand({required super.logger})
      : super(options: CreateEnvCommandConfig.values);

  @override
  Future<void> runWithConfig(
      final Configuration<CreateEnvCommandConfig> commandConfig) async {
    final projectId = commandConfig.value(CreateEnvCommandConfig.projectId);
    final variableName =
        commandConfig.value(CreateEnvCommandConfig.variableName);
    final variableValue =
        commandConfig.value(CreateEnvCommandConfig.variableValue);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.environmentVariables.create(
        variableName,
        variableValue,
        projectId,
      );
    } catch (e) {
      logger.error(
        'Failed to create a new environment variable: $e',
      );

      throw ExitException();
    }

    logger.info('Successfully created environment variable.');
  }
}

class CloudEnvUpdateCommand extends CloudCliCommand<UpdateEnvCommandConfig> {
  @override
  String get description => 'Update an environment variable.';

  @override
  String get name => 'update';

  CloudEnvUpdateCommand({required super.logger})
      : super(options: UpdateEnvCommandConfig.values);

  @override
  Future<void> runWithConfig(
      final Configuration<UpdateEnvCommandConfig> commandConfig) async {
    final projectId = commandConfig.value(UpdateEnvCommandConfig.projectId);
    final variableName =
        commandConfig.value(UpdateEnvCommandConfig.variableName);
    final variableValue =
        commandConfig.value(UpdateEnvCommandConfig.variableValue);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.environmentVariables.update(
        name: variableName,
        value: variableValue,
        cloudEnvironmentId: projectId,
      );
    } catch (e) {
      logger.error(
        'Failed to update a the environment variable: $e',
      );

      throw ExitException();
    }

    logger.info('Successfully updated environment variable: $variableName.');
  }
}

class CloudEnvDeleteCommand extends CloudCliCommand<DeleteEnvCommandConfig> {
  @override
  String get description => 'Delete an environment variable.';

  @override
  String get name => 'delete';

  CloudEnvDeleteCommand({required super.logger})
      : super(options: DeleteEnvCommandConfig.values);

  @override
  Future<void> runWithConfig(
      final Configuration<DeleteEnvCommandConfig> commandConfig) async {
    final projectId = commandConfig.value(DeleteEnvCommandConfig.projectId);
    final variableName =
        commandConfig.value(DeleteEnvCommandConfig.variableName);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.environmentVariables.delete(
        name: variableName,
        cloudEnvironmentId: projectId,
      );
    } catch (e) {
      logger.error(
        'Failed to delete the environment variable: $e',
      );

      throw ExitException();
    }

    logger.info('Successfully deleted environment variable: $variableName.');
  }
}

class CloudEnvListCommand extends CloudCliCommand<ListEnvCommandConfig> {
  @override
  String get description => 'Lists all environment variables for the project.';

  @override
  String get name => 'list';

  CloudEnvListCommand({required super.logger})
      : super(options: ListEnvCommandConfig.values);

  @override
  Future<void> runWithConfig(
      final Configuration<ListEnvCommandConfig> commandConfig) async {
    final projectId = commandConfig.value(ListEnvCommandConfig.projectId);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    late List<EnvironmentVariable> environmentVariables;
    try {
      environmentVariables = await apiCloudClient.environmentVariables.list(
        projectId,
      );
    } catch (e) {
      logger.error(
        'Failed to list environment variables: $e',
      );

      throw ExitException();
    }

    final tablePrinter = TablePrinter();
    tablePrinter.addHeaders(['Name', 'Value']);
    for (var variable in environmentVariables) {
      tablePrinter.addRow([variable.name, variable.value]);
    }

    logger.info(tablePrinter.toString());
  }
}

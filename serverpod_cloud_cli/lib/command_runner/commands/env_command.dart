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
      'Manage Serverpod Cloud environment variables for a tenant project.';

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
    helpText:
        'The ID of the project. Can also be specified as the first argument.',
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
    envName: 'SERVERPOD_CLOUD_ENVIRONMENT_VARIABLE_NAME',
  );

  static const variableValue = ConfigOption(
    argName: 'value',
    argAbbrev: 'v',
    argPos: 1,
    helpText:
        'The value of the environment variable. Can also be specified as the second argument.',
    mandatory: true,
    envName: 'SERVERPOD_CLOUD_ENVIRONMENT_VARIABLE_VALUE',
  );
}

class CloudEnvCreateCommand extends CloudCliCommand {
  @override
  String get description => 'Create an environment variable.';

  @override
  String get name => 'create';

  CloudEnvCreateCommand({required super.logger})
      : super(options: [
          EnvCommandConfig.projectId,
          EnvCommandConfig.variableName,
          EnvCommandConfig.variableValue
        ]);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final projectId = commandConfig.value(EnvCommandConfig.projectId);
    final variableName = commandConfig.value(EnvCommandConfig.variableName);
    final variableValue = commandConfig.value(EnvCommandConfig.variableValue);

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

class CloudEnvUpdateCommand extends CloudCliCommand {
  @override
  String get description => 'Update an environment variable.';

  @override
  String get name => 'update';

  CloudEnvUpdateCommand({required super.logger})
      : super(options: [
          EnvCommandConfig.projectId,
          EnvCommandConfig.variableName,
          EnvCommandConfig.variableValue
        ]);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final projectId = commandConfig.value(EnvCommandConfig.projectId);
    final variableName = commandConfig.value(EnvCommandConfig.variableName);
    final variableValue = commandConfig.value(EnvCommandConfig.variableValue);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.environmentVariables.update(
        name: variableName,
        value: variableValue,
        envId: projectId,
      );
    } catch (e) {
      logger.error(
        'Failed to update a the environment variable: $e',
      );

      throw ExitException();
    }

    logger.info('Successfully updated environment variable.');
  }
}

class CloudEnvDeleteCommand extends CloudCliCommand {
  @override
  String get description => 'Delete an environment variable.';

  @override
  String get name => 'delete';

  CloudEnvDeleteCommand({required super.logger})
      : super(options: [
          EnvCommandConfig.projectId,
          EnvCommandConfig.variableName,
        ]);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final projectId = commandConfig.value(EnvCommandConfig.projectId);
    final variableName = commandConfig.value(EnvCommandConfig.variableName);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.environmentVariables.delete(
        name: variableName,
        envId: projectId,
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

class CloudEnvListCommand extends CloudCliCommand {
  @override
  String get description => 'Lists all environment variables for the project.';

  @override
  String get name => 'list';

  CloudEnvListCommand({required super.logger})
      : super(options: [
          EnvCommandConfig.projectId,
        ]);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final projectId = commandConfig.value(EnvCommandConfig.projectId);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    late List<EnvironmentVariable> environmentVariables;
    try {
      environmentVariables = await apiCloudClient.environmentVariables.all(
        projectId,
      );
    } catch (e) {
      logger.error(
        'Failed to delete the environment variable: $e',
      );

      throw ExitException();
    }

    var tablePrinter = TablePrinter();
    tablePrinter.addHeaders(['Name', 'Value']);
    for (var variable in environmentVariables) {
      tablePrinter.addRow([variable.name, variable.value]);
    }

    logger.info(tablePrinter.toString());
  }
}

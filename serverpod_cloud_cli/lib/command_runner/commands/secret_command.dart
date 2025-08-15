import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

import 'categories.dart';

class CloudSecretCommand extends CloudCliCommand {
  @override
  final name = 'secret';

  @override
  final description = 'Manage Serverpod Cloud secrets.';

  @override
  String get category => CommandCategories.control;

  CloudSecretCommand({required super.logger}) {
    addSubcommand(CloudCreateSecretCommand(logger: logger));
    addSubcommand(CloudListSecretsCommand(logger: logger));
    addSubcommand(CloudDeleteSecretCommand(logger: logger));
  }
}

abstract final class SecretCommandConfig {
  static const projectId = ProjectIdOption();

  static const name = NameOption(
    argPos: 0,
    helpText: 'The name of the secret. Can be passed as the first argument.',
  );

  static const value = ValueOption(
    argPos: 1,
    helpText: 'The value of the secret. Can be passed as the second argument.',
  );

  static const valueFile = ValueFileOption(
    helpText: 'The name of the file with the secret value.',
  );
}

enum CreateSecretCommandConfig<V> implements OptionDefinition<V> {
  projectId(SecretCommandConfig.projectId),
  name(SecretCommandConfig.name),
  value(SecretCommandConfig.value),
  valueFile(SecretCommandConfig.valueFile);

  const CreateSecretCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudCreateSecretCommand
    extends CloudCliCommand<CreateSecretCommandConfig> {
  @override
  String get description => 'Create a secret.';

  @override
  String get name => 'create';

  CloudCreateSecretCommand({required super.logger})
      : super(options: CreateSecretCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<CreateSecretCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(CreateSecretCommandConfig.projectId);
    final name = commandConfig.value(CreateSecretCommandConfig.name);
    final value = commandConfig.optionalValue(CreateSecretCommandConfig.value);
    final valueFile =
        commandConfig.optionalValue(CreateSecretCommandConfig.valueFile);

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
      await apiCloudClient.secrets.create(
        secrets: {name: valueToSet},
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to create a new secret');
    }

    logger.success('Successfully created secret.');
  }
}

enum ListSecretsCommandConfig<V> implements OptionDefinition<V> {
  projectId(SecretCommandConfig.projectId);

  const ListSecretsCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudListSecretsCommand
    extends CloudCliCommand<ListSecretsCommandConfig> {
  @override
  String get description => 'List all secrets.';

  @override
  String get name => 'list';

  CloudListSecretsCommand({required super.logger})
      : super(options: ListSecretsCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ListSecretsCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(ListSecretsCommandConfig.projectId);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    late List<String> secrets;
    try {
      secrets = await apiCloudClient.secrets.list(
        projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to list secrets');
    }

    final secretsPrinter = TablePrinter();
    secretsPrinter.addHeaders(['Secret name']);

    for (var secret in secrets) {
      secretsPrinter.addRow([
        secret,
      ]);
    }

    secretsPrinter.writeLines(logger.line);
  }
}

enum DeleteSecretCommandConfig<V> implements OptionDefinition<V> {
  projectId(SecretCommandConfig.projectId),
  name(SecretCommandConfig.name);

  const DeleteSecretCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDeleteSecretCommand
    extends CloudCliCommand<DeleteSecretCommandConfig> {
  @override
  String get description => 'Delete a secret.';

  @override
  String get name => 'delete';

  CloudDeleteSecretCommand({required super.logger})
      : super(options: DeleteSecretCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DeleteSecretCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(DeleteSecretCommandConfig.projectId);
    final name = commandConfig.value(DeleteSecretCommandConfig.name);

    final shouldDelete = await logger.confirm(
      'Are you sure you want to delete the secret "$name"?',
      defaultValue: false,
    );

    if (!shouldDelete) {
      throw UserAbortException();
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.secrets.delete(
        cloudCapsuleId: projectId,
        key: name,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to delete the secret');
    }

    logger.success('Successfully deleted secret: $name.');
  }
}

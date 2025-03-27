import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/shared/helpers/common_exceptions_handler.dart';
import 'package:serverpod_cloud_cli/util/config/config.dart';
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
    helpText: 'The name of the secret. Can be passed as the first argument.',
    argPos: 0,
  );

  static const value = ValueOption(
    argPos: 1,
    helpText: 'The value of the secret. Can be passed as the second argument.',
  );
}

enum CreateSecretCommandConfig<V> implements OptionDefinition<V> {
  projectId(SecretCommandConfig.projectId),
  name(SecretCommandConfig.name),
  value(SecretCommandConfig.value);

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
    final value = commandConfig.value(CreateSecretCommandConfig.value);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    await handleCommonClientExceptions(logger, () async {
      await apiCloudClient.secrets.create(
        secrets: {name: value},
        cloudCapsuleId: projectId,
      );
    }, (final e) {
      logger.error(
        'Failed to create a new secret',
        exception: e,
      );

      throw ErrorExitException();
    });

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
    await handleCommonClientExceptions(logger, () async {
      secrets = await apiCloudClient.secrets.list(
        projectId,
      );
    }, (final e) {
      logger.error(
        'Failed to list secrets',
        exception: e,
      );

      throw ErrorExitException();
    });

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
      throw ErrorExitException();
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    await handleCommonClientExceptions(logger, () async {
      await apiCloudClient.secrets.delete(
        cloudCapsuleId: projectId,
        key: name,
      );
    }, (final e) {
      logger.error(
        'Failed to delete the secret',
        exception: e,
      );

      throw ErrorExitException();
    });

    logger.success('Successfully deleted secret: $name.');
  }
}

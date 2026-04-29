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
    addSubcommand(CloudSecretSetCommand(logger: logger));
    addSubcommand(CloudListSecretsCommand(logger: logger));
    addSubcommand(CloudSecretUnsetCommand(logger: logger));
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

enum SetSecretCommandConfig<V> implements OptionDefinition<V> {
  projectId(SecretCommandConfig.projectId),
  name(SecretCommandConfig.name),
  value(SecretCommandConfig.value),
  valueFile(SecretCommandConfig.valueFile);

  const SetSecretCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudSecretSetCommand extends CloudCliCommand<SetSecretCommandConfig> {
  @override
  String get description => 'Set a secret (create or update).';

  @override
  String get name => 'set';

  CloudSecretSetCommand({required super.logger})
    : super(options: SetSecretCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<SetSecretCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(SetSecretCommandConfig.projectId);
    final name = commandConfig.value(SetSecretCommandConfig.name);
    final value = commandConfig.optionalValue(SetSecretCommandConfig.value);
    final valueFile = commandConfig.optionalValue(
      SetSecretCommandConfig.valueFile,
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
      await apiCloudClient.secrets.upsert(
        secrets: {name: valueToSet},
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to set secret');
    }

    logger.success('Successfully set secret: $name.');
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
      secrets = await apiCloudClient.secrets.list(projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to list secrets');
    }

    final secretsPrinter = TablePrinter();
    secretsPrinter.addHeaders(['Secret name']);

    for (var secret in secrets) {
      secretsPrinter.addRow([secret]);
    }

    secretsPrinter.writeLines(logger.line);
  }
}

enum UnsetSecretCommandConfig<V> implements OptionDefinition<V> {
  projectId(SecretCommandConfig.projectId),
  name(SecretCommandConfig.name);

  const UnsetSecretCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudSecretUnsetCommand
    extends CloudCliCommand<UnsetSecretCommandConfig> {
  @override
  String get description => 'Remove a secret.';

  @override
  String get name => 'unset';

  CloudSecretUnsetCommand({required super.logger})
    : super(options: UnsetSecretCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<UnsetSecretCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(UnsetSecretCommandConfig.projectId);
    final name = commandConfig.value(UnsetSecretCommandConfig.name);

    final shouldUnset = await logger.confirm(
      'Are you sure you want to remove the secret "$name"?',
      defaultValue: false,
    );

    if (!shouldUnset) {
      throw UserAbortException();
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.secrets.delete(cloudCapsuleId: projectId, key: name);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to remove the secret');
    }

    logger.success('Successfully removed secret: $name.');
  }
}

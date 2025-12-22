import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

import 'categories.dart';

class CloudPasswordCommand extends CloudCliCommand {
  @override
  final name = 'password';

  @override
  final description =
      'Manage Serverpod Cloud passwords (automatically prefixed with SERVERPOD_PASSWORD_).';

  @override
  String get category => CommandCategories.control;

  CloudPasswordCommand({required super.logger}) {
    addSubcommand(CloudCreatePasswordCommand(logger: logger));
    addSubcommand(CloudListPasswordsCommand(logger: logger));
    addSubcommand(CloudDeletePasswordCommand(logger: logger));
  }
}

abstract final class PasswordCommandConfig {
  static const projectId = ProjectIdOption();

  static const name = NameOption(
    argPos: 0,
    helpText: 'The name of the password. Can be passed as the first argument.',
  );

  static const value = ValueOption(
    argPos: 1,
    helpText:
        'The value of the password. Can be passed as the second argument.',
  );

  static const valueFile = ValueFileOption(
    helpText: 'The name of the file with the password value.',
  );
}

enum CreatePasswordCommandConfig<V> implements OptionDefinition<V> {
  projectId(PasswordCommandConfig.projectId),
  name(PasswordCommandConfig.name),
  value(PasswordCommandConfig.value),
  valueFile(PasswordCommandConfig.valueFile);

  const CreatePasswordCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudCreatePasswordCommand
    extends CloudCliCommand<CreatePasswordCommandConfig> {
  @override
  String get description => 'Create a Serverpod password.';

  @override
  String get name => 'create';

  CloudCreatePasswordCommand({required super.logger})
    : super(options: CreatePasswordCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<CreatePasswordCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(
      CreatePasswordCommandConfig.projectId,
    );
    final name = commandConfig.value(CreatePasswordCommandConfig.name);
    final value = commandConfig.optionalValue(
      CreatePasswordCommandConfig.value,
    );
    final valueFile = commandConfig.optionalValue(
      CreatePasswordCommandConfig.valueFile,
    );

    String valueToSet;
    if (value != null) {
      valueToSet = value;
    } else if (valueFile != null) {
      valueToSet = valueFile.readAsStringSync();
    } else {
      throw StateError('Expected one of the value options to be set.');
    }

    final prefixedKey = 'SERVERPOD_PASSWORD_$name';
    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.secrets.create(
        secrets: {prefixedKey: valueToSet},
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to create a new password');
    }

    logger.success('Successfully created password.');
  }
}

enum ListPasswordsCommandConfig<V> implements OptionDefinition<V> {
  projectId(PasswordCommandConfig.projectId);

  const ListPasswordsCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudListPasswordsCommand
    extends CloudCliCommand<ListPasswordsCommandConfig> {
  @override
  String get description => 'List all passwords.';

  @override
  String get name => 'list';

  CloudListPasswordsCommand({required super.logger})
    : super(options: ListPasswordsCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ListPasswordsCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(ListPasswordsCommandConfig.projectId);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    late List<String> secrets;
    try {
      secrets = await apiCloudClient.secrets.list(projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to list passwords');
    }

    const prefix = 'SERVERPOD_PASSWORD_';
    final passwordSecrets =
        secrets
            .where((final secret) => secret.startsWith(prefix))
            .map((final secret) => secret.substring(prefix.length))
            .toList()
          ..sort();

    final passwordsPrinter = TablePrinter();
    passwordsPrinter.addHeaders(['Password name']);

    for (var password in passwordSecrets) {
      passwordsPrinter.addRow([password]);
    }

    passwordsPrinter.writeLines(logger.line);
  }
}

enum DeletePasswordCommandConfig<V> implements OptionDefinition<V> {
  projectId(PasswordCommandConfig.projectId),
  name(PasswordCommandConfig.name);

  const DeletePasswordCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDeletePasswordCommand
    extends CloudCliCommand<DeletePasswordCommandConfig> {
  @override
  String get description => 'Delete a password.';

  @override
  String get name => 'delete';

  CloudDeletePasswordCommand({required super.logger})
    : super(options: DeletePasswordCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DeletePasswordCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(
      DeletePasswordCommandConfig.projectId,
    );
    final name = commandConfig.value(DeletePasswordCommandConfig.name);

    final prefixedKey = 'SERVERPOD_PASSWORD_$name';

    final shouldDelete = await logger.confirm(
      'Are you sure you want to delete the password "$name"?',
      defaultValue: false,
    );

    if (!shouldDelete) {
      throw UserAbortException();
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.secrets.delete(
        cloudCapsuleId: projectId,
        key: prefixedKey,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to delete the password');
    }

    logger.success('Successfully deleted password: $name.');
  }
}

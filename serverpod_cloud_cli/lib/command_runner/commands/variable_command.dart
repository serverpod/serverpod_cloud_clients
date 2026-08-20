import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/password/password.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

import 'categories.dart';

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

enum _VariableStore { unmasked, secret }

abstract final class _EnvironmentVariables {
  static const nameMaxLength = 255;
  static final namePattern = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
  static const maskedValue = '••••••••';

  static void validateName(final String name) {
    if (name.startsWith(PasswordDefinitions.prefix)) {
      throw FailureException(
        error: "Names can't start with '${PasswordDefinitions.prefix}'.",
        hint: 'Use `scloud password set` to manage passwords.',
      );
    }

    if (name.isEmpty ||
        name.length > nameMaxLength ||
        !namePattern.hasMatch(name)) {
      throw FailureException(
        error:
            'Use letters, digits and underscores, starting with a letter or '
            'an underscore.',
      );
    }
  }

  static Future<({List<EnvironmentVariable> unmasked, List<String> secrets})>
  fetch(final Client client, final String projectId) async {
    try {
      final unmasked = await client.environmentVariables.list(projectId);
      final secrets = await client.secrets.list(projectId);
      return (unmasked: unmasked, secrets: secrets);
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to list environment variables',
      );
    }
  }

  static _VariableStore? storeOf(
    final String name, {
    required final List<EnvironmentVariable> unmasked,
    required final List<String> secrets,
  }) {
    if (secrets.contains(name)) {
      return _VariableStore.secret;
    }
    if (unmasked.any((final variable) => variable.name == name)) {
      return _VariableStore.unmasked;
    }
    return null;
  }
}

class CloudVariableSetCommand
    extends CloudCliCommand<SetVariableCommandConfig> {
  @override
  String get description =>
      'Set an environment variable or secret (create or update).';

  @override
  String get name => 'set';

  @override
  String? get usageExamples => '''\n
Examples

  Set an environment variable called SERVICE_EMAIL to support@example.com.
  
    \$ scloud variable set SERVICE_EMAIL support@example.com

  Set a secret environment variable. The value is encrypted and masked.
  
    \$ scloud variable set --secret API_KEY sk-...

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
    final valueToSet = commandConfig.valueOrFileContent(
      value: SetVariableCommandConfig.variableValue,
      valueFile: SetVariableCommandConfig.valueFile,
    );
    final secretFlag = commandConfig.optionalValue(
      SetVariableCommandConfig.secret,
    );

    _EnvironmentVariables.validateName(variableName);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;
    final listed = await _EnvironmentVariables.fetch(apiCloudClient, projectId);
    final existingStore = _EnvironmentVariables.storeOf(
      variableName,
      unmasked: listed.unmasked,
      secrets: listed.secrets,
    );

    if (existingStore == _VariableStore.unmasked && secretFlag == true) {
      throw FailureException(
        error:
            '"$variableName" already exists as an unmasked variable. '
            'To recreate it as a secret:',
        hint:
            'scloud variable unset $variableName\n'
            '  scloud variable set --secret $variableName <value>',
      );
    }
    if (existingStore == _VariableStore.secret && secretFlag == false) {
      throw FailureException(
        error:
            '"$variableName" already exists as a secret. '
            'To recreate it as an unmasked variable:',
        hint:
            'scloud variable unset $variableName\n'
            '  scloud variable set --no-secret $variableName <value>',
      );
    }

    final store =
        existingStore ??
        (secretFlag == true ? _VariableStore.secret : _VariableStore.unmasked);

    try {
      switch (store) {
        case _VariableStore.unmasked:
          if (existingStore == null) {
            await apiCloudClient.environmentVariables.create(
              variableName,
              valueToSet,
              projectId,
            );
          } else {
            await apiCloudClient.environmentVariables.update(
              name: variableName,
              value: valueToSet,
              cloudCapsuleId: projectId,
            );
          }
        case _VariableStore.secret:
          if (existingStore == null) {
            await apiCloudClient.secrets.create(
              secrets: {variableName: valueToSet},
              cloudCapsuleId: projectId,
            );
          } else {
            await apiCloudClient.secrets.upsert(
              secrets: {variableName: valueToSet},
              cloudCapsuleId: projectId,
            );
          }
      }
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to set the environment variable',
      );
    }

    logger.success(
      store == _VariableStore.secret
          ? 'Successfully set secret: $variableName.'
          : 'Successfully set environment variable: $variableName.',
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

    _EnvironmentVariables.validateName(variableName);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;
    final listed = await _EnvironmentVariables.fetch(apiCloudClient, projectId);
    final existingStore = _EnvironmentVariables.storeOf(
      variableName,
      unmasked: listed.unmasked,
      secrets: listed.secrets,
    );

    if (existingStore == null) {
      throw FailureException(
        error: 'The environment variable "$variableName" was not found.',
      );
    }

    final shouldUnset = await logger.confirm(
      'Are you sure you want to remove the environment variable "$variableName"?',
      defaultValue: false,
    );

    if (!shouldUnset) {
      throw UserAbortException();
    }

    try {
      switch (existingStore) {
        case _VariableStore.unmasked:
          await apiCloudClient.environmentVariables.delete(
            name: variableName,
            cloudCapsuleId: projectId,
          );
        case _VariableStore.secret:
          await apiCloudClient.secrets.delete(
            key: variableName,
            cloudCapsuleId: projectId,
          );
      }
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to remove the environment variable',
      );
    }

    logger.success(
      existingStore == _VariableStore.secret
          ? 'Successfully removed secret: $variableName.'
          : 'Successfully removed environment variable: $variableName.',
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
  Future<void> runWithConfig(
    final Configuration<ListVariableCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(ListVariableCommandConfig.projectId);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;
    final listed = await _EnvironmentVariables.fetch(apiCloudClient, projectId);

    final tablePrinter = TablePrinter();
    tablePrinter.addHeaders(['Name', 'Value']);
    for (final variable in listed.unmasked) {
      tablePrinter.addRow([variable.name, variable.value]);
    }
    for (final secretName in listed.secrets) {
      if (secretName.startsWith(PasswordDefinitions.prefix)) {
        continue;
      }
      tablePrinter.addRow([secretName, _EnvironmentVariables.maskedValue]);
    }

    tablePrinter.writeLines(logger.line);
  }
}

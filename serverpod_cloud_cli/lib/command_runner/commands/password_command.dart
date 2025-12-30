import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/password/password.dart';

import 'categories.dart';

class CloudPasswordCommand extends CloudCliCommand {
  @override
  final name = 'password';

  @override
  final description = '''Manage Serverpod Cloud passwords.

The passwords are automatically prefixed with SERVERPOD_PASSWORD_ and will be injected as environment variables.
Passwords defined by this command can be accessed with the getPassword function.

If you need to set a secret without the SERVERPOD_PASSWORD_ prefix, you can do so by using the secret create command.
''';

  @override
  String get category => CommandCategories.control;

  CloudPasswordCommand({required super.logger}) {
    addSubcommand(CloudPasswordListCommand(logger: logger));
    addSubcommand(CloudPasswordSetCommand(logger: logger));
    addSubcommand(CloudPasswordUnsetCommand(logger: logger));
  }
}

abstract final class PasswordCommandConfig {
  static const projectId = ProjectIdOption();
  static const name = NameOption(
    argPos: 0,
    helpText:
        'The name of the password (without SERVERPOD_PASSWORD_ prefix). '
        'Can be passed as the first argument.',
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

enum PasswordListCommandConfig<V> implements OptionDefinition<V> {
  projectId(PasswordCommandConfig.projectId);

  const PasswordListCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudPasswordListCommand
    extends CloudCliCommand<PasswordListCommandConfig> {
  @override
  String get description =>
      '''List all passwords, both user-set and platform-managed.

  Passwords are grouped by category:
  - Custom: User-defined passwords that are not part of the platform.
  - Services: Passwords for services like databases, insights, etc.
  - Auth: Passwords for authentication like JWT, email, for package serverpod_auth_idp_server.
  - Legacy Auth: Passwords for the legacy authentication module.
  ''';

  @override
  String get name => 'list';

  CloudPasswordListCommand({required super.logger})
    : super(options: PasswordListCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<PasswordListCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(PasswordListCommandConfig.projectId);

    await PasswordCommands.listPasswords(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
    );
  }
}

enum PasswordSetCommandConfig<V> implements OptionDefinition<V> {
  projectId(PasswordCommandConfig.projectId),
  name(PasswordCommandConfig.name),
  value(PasswordCommandConfig.value),
  valueFile(PasswordCommandConfig.valueFile);

  const PasswordSetCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudPasswordSetCommand
    extends CloudCliCommand<PasswordSetCommandConfig> {
  @override
  String get description => '''Set a password.
  
  Setting a platform-managed password will override the existing password.
  The original password will not be lost and can be activated again by unsetting the password.
  ''';

  @override
  String get name => 'set';

  CloudPasswordSetCommand({required super.logger})
    : super(options: PasswordSetCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<PasswordSetCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(PasswordSetCommandConfig.projectId);
    final name = commandConfig.value(PasswordSetCommandConfig.name);
    final value = commandConfig.optionalValue(PasswordSetCommandConfig.value);
    final valueFile = commandConfig.optionalValue(
      PasswordSetCommandConfig.valueFile,
    );

    String valueToSet;
    if (value != null) {
      valueToSet = value;
    } else if (valueFile != null) {
      valueToSet = valueFile.readAsStringSync();
    } else {
      throw ErrorExitException(
        'Either a value or --from-file must be provided.',
      );
    }

    await PasswordCommands.setPassword(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
      name: name,
      value: valueToSet,
    );
  }
}

enum PasswordUnsetCommandConfig<V> implements OptionDefinition<V> {
  projectId(PasswordCommandConfig.projectId),
  name(PasswordCommandConfig.name);

  const PasswordUnsetCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudPasswordUnsetCommand
    extends CloudCliCommand<PasswordUnsetCommandConfig> {
  @override
  String get description =>
      'Unset a password, can only unset user-set passwords.';

  @override
  String get name => 'unset';

  CloudPasswordUnsetCommand({required super.logger})
    : super(options: PasswordUnsetCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<PasswordUnsetCommandConfig> commandConfig,
  ) async {
    final projectId = commandConfig.value(PasswordUnsetCommandConfig.projectId);
    final name = commandConfig.value(PasswordUnsetCommandConfig.name);

    final shouldDelete = await logger.confirm(
      'Are you sure you want to unset the password "$name"?',
      defaultValue: false,
    );

    if (!shouldDelete) {
      throw UserAbortException();
    }

    await PasswordCommands.unsetPassword(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
      name: name,
    );
  }
}

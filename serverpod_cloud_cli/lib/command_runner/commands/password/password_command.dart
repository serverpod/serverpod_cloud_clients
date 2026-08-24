import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/password/password_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/password/password_ui.dart';
import 'package:serverpod_cloud_cli/util/output/command_output.dart';

import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';

class CloudPasswordCommand extends CloudCliCommand {
  @override
  final name = 'password';

  @override
  final description = '''Manage Serverpod Cloud passwords.

The passwords are automatically prefixed with SERVERPOD_PASSWORD_ and will be injected as environment variables.
Passwords defined by this command can be accessed with the getPassword function.

If you need to set a secret without the SERVERPOD_PASSWORD_ prefix, you can do so by using `scloud variable set --secret`.
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
  projectId(PasswordCommandConfig.projectId),
  format(FormatOption());

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
    final format = commandConfig.value(PasswordListCommandConfig.format);

    final output = CommandOutput(format: format, logger: logger);
    await output.render(
      operation: () => PasswordOperations.listPasswords(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      ui: PasswordListUi(),
    );
  }
}

enum PasswordSetCommandConfig<V> implements OptionDefinition<V> {
  projectId(PasswordCommandConfig.projectId),
  name(PasswordCommandConfig.name),
  value(PasswordCommandConfig.value),
  valueFile(PasswordCommandConfig.valueFile),
  format(FormatOption());

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
    final valueToSet = commandConfig.valueOrFileContent(
      value: PasswordSetCommandConfig.value,
      valueFile: PasswordSetCommandConfig.valueFile,
    );
    final format = commandConfig.value(PasswordSetCommandConfig.format);

    final output = CommandOutput(format: format, logger: logger);
    await output.render(
      operation: () => PasswordOperations.setPassword(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        name: name,
        value: valueToSet,
      ).then((final _) => {'name': name}),
      ui: PasswordSetUi(),
    );
  }
}

enum PasswordUnsetCommandConfig<V> implements OptionDefinition<V> {
  projectId(PasswordCommandConfig.projectId),
  name(PasswordCommandConfig.name),
  format(FormatOption());

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
    final format = commandConfig.value(PasswordUnsetCommandConfig.format);

    final shouldDelete = await logger.confirm(
      'Are you sure you want to unset the password "$name"?',
      defaultValue: false,
    );

    if (!shouldDelete) {
      throw UserAbortException();
    }

    final output = CommandOutput(format: format, logger: logger);
    await output.render(
      operation: () => PasswordOperations.unsetPassword(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        name: name,
      ).then((final _) => {'name': name}),
      ui: PasswordUnsetUi(),
    );
  }
}

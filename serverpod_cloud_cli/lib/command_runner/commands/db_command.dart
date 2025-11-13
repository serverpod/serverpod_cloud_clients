import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';

import 'categories.dart';

class CloudDbCommand extends CloudCliCommand {
  @override
  final name = 'db';

  @override
  final description = 'Manage Serverpod Cloud DBs.';

  @override
  String get category => CommandCategories.control;

  CloudDbCommand({required super.logger}) {
    addSubcommand(CloudDbConnectionDetailsCommand(logger: logger));
    addSubcommand(CloudDbUserCommand(logger: logger));
  }
}

class CloudDbUserCommand extends CloudCliCommand {
  @override
  final name = 'user';

  @override
  final description = 'Manage database users.';

  CloudDbUserCommand({required super.logger}) {
    addSubcommand(CloudDbUserCreateCommand(logger: logger));
    addSubcommand(CloudDbUserResetPasswordCommand(logger: logger));
  }
}

abstract final class _CommonDbOptions {
  static const dbUsername = StringOption(
    argName: 'username',
    argPos: 0,
    helpText: 'The username of the DB user to create.',
    mandatory: true,
  );
}

enum DbConnectionDetailsOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption());

  const DbConnectionDetailsOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDbConnectionDetailsCommand
    extends CloudCliCommand<DbConnectionDetailsOption> {
  @override
  final name = 'connection';

  @override
  final description = 'Show the connection details for a Serverpod Cloud DB.';

  CloudDbConnectionDetailsCommand({required super.logger})
      : super(options: DbConnectionDetailsOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbConnectionDetailsOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(DbConnectionDetailsOption.projectId);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      final connection = await apiCloudClient.database.getConnectionDetails(
        cloudCapsuleId: projectId,
      );

      final portString = connection.port == 5432 ? '' : ':${connection.port}';
      final connectionString =
          'postgresql://${connection.host}$portString/${connection.name}'
          '?sslmode=${connection.requiresSsl ? 'require' : 'disable'}';
      logger.success(
        '''
Connection details:
  Host: ${connection.host}
  Port: ${connection.port}
  Database: ${connection.name}''',
        followUp: '''
This psql command can be used to connect to the database (it will prompt for the password):
  psql "$connectionString" --user <username>''',
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
          e, stackTrace, 'Failed to get connection details');
    }
  }
}

enum DbUserCreateOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  username(_CommonDbOptions.dbUsername);

  const DbUserCreateOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDbUserCreateCommand extends CloudCliCommand<DbUserCreateOption> {
  @override
  final name = 'create';

  @override
  final description = 'Create a new superuser in the Serverpod Cloud DB.';

  CloudDbUserCreateCommand({required super.logger})
      : super(options: DbUserCreateOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbUserCreateOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(DbUserCreateOption.projectId);
    final username = commandConfig.value(DbUserCreateOption.username);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      final password = await apiCloudClient.database.createSuperUser(
        cloudCapsuleId: projectId,
        username: username,
      );

      logger.success(
        '''
DB superuser created. The password is only shown this once:
$password''',
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
          e, stackTrace, 'Failed to create superuser');
    }
  }
}

enum DbUserResetPasswordOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  username(_CommonDbOptions.dbUsername);

  const DbUserResetPasswordOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDbUserResetPasswordCommand
    extends CloudCliCommand<DbUserResetPasswordOption> {
  @override
  final name = 'reset-password';

  @override
  final description = 'Reset a password in the Serverpod Cloud DB.';

  CloudDbUserResetPasswordCommand({required super.logger})
      : super(options: DbUserResetPasswordOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbUserResetPasswordOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(DbUserResetPasswordOption.projectId);
    final username = commandConfig.value(DbUserResetPasswordOption.username);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      final password = await apiCloudClient.database.resetDatabasePassword(
        cloudCapsuleId: projectId,
        username: username,
      );

      logger.success(
        '''
DB password is reset. The new password is only shown this once:
$password''',
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(e, stackTrace, 'Failed to reset password');
    }
  }
}

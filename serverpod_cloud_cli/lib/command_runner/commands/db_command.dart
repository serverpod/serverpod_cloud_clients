import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/common_exceptions_handler.dart';
import 'package:serverpod_cloud_cli/util/config/configuration.dart';

class CloudDbCommand extends CloudCliCommand {
  @override
  final name = 'db';

  @override
  final description = 'Manage Serverpod Cloud DBs.';

  CloudDbCommand({required super.logger}) {
    addSubcommand(CloudDbConnectionDetailsCommand(logger: logger));
    addSubcommand(CloudDbCreateSuperuserCommand(logger: logger));
    addSubcommand(CloudDbResetPasswordCommand(logger: logger));
  }
}

abstract final class _CommonDbOptions {
  static const dbUsername = ConfigOption(
    argName: 'username',
    argPos: 0,
    helpText: 'The username of the DB user to create.',
    mandatory: true,
  );
}

enum DbConnectionDetailsOption implements OptionDefinition {
  projectId(ProjectIdOption());

  const DbConnectionDetailsOption(this.option);

  @override
  final ConfigOption option;
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

    await handleCommonClientExceptions(
      logger,
      () async {
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
      },
      (final e) {
        logger.error('Failed to get connection details: $e');

        throw ErrorExitException();
      },
    );
  }
}

enum DbCreateSuperuserOption implements OptionDefinition {
  projectId(ProjectIdOption()),
  username(_CommonDbOptions.dbUsername);

  const DbCreateSuperuserOption(this.option);

  @override
  final ConfigOption option;
}

class CloudDbCreateSuperuserCommand
    extends CloudCliCommand<DbCreateSuperuserOption> {
  @override
  final name = 'create-superuser';

  @override
  final description = 'Create a new superuser in the Serverpod Cloud DB.';

  CloudDbCreateSuperuserCommand({required super.logger})
      : super(options: DbCreateSuperuserOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbCreateSuperuserOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(DbCreateSuperuserOption.projectId);
    final username = commandConfig.value(DbCreateSuperuserOption.username);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    await handleCommonClientExceptions(
      logger,
      () async {
        final password = await apiCloudClient.database.createSuperUser(
          cloudCapsuleId: projectId,
          username: username,
        );

        logger.success(
          '''
DB superuser created. The password on the next line is only shown this once:
$password''',
        );
      },
      (final e) {
        logger.error('Failed to create superuser: $e');

        throw ErrorExitException();
      },
    );
  }
}

enum DbResetPasswordOption implements OptionDefinition {
  projectId(ProjectIdOption()),
  username(_CommonDbOptions.dbUsername);

  const DbResetPasswordOption(this.option);

  @override
  final ConfigOption option;
}

class CloudDbResetPasswordCommand
    extends CloudCliCommand<DbResetPasswordOption> {
  @override
  final name = 'reset-password';

  @override
  final description = 'Reset a password in the Serverpod Cloud DB.';

  CloudDbResetPasswordCommand({required super.logger})
      : super(options: DbResetPasswordOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbResetPasswordOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(DbResetPasswordOption.projectId);
    final username = commandConfig.value(DbResetPasswordOption.username);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    await handleCommonClientExceptions(
      logger,
      () async {
        final password = await apiCloudClient.database.resetDatabasePassword(
          cloudCapsuleId: projectId,
          username: username,
        );

        logger.success(
          '''
DB password is reset. The new password on the next line is only shown this once:
$password''',
        );
      },
      (final e) {
        logger.error('Failed to reset password: $e');

        throw ErrorExitException();
      },
    );
  }
}

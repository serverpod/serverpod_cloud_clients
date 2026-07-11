import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/db/db.dart';
import 'package:serverpod_cloud_cli/commands/db/db_backup.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

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
    addSubcommand(CloudDbBackupCommand(logger: logger));
    addSubcommand(CloudDbScheduleCommand(logger: logger));
    addSubcommand(CloudDbWipeCommand(logger: logger));
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
        e,
        stackTrace,
        'Failed to get connection details',
      );
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

      logger.success('''
DB superuser created. The password is only shown this once:
$password''');
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to create superuser',
      );
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

      logger.success('''
DB password is reset. The new password is only shown this once:
$password''');
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(e, stackTrace, 'Failed to reset password');
    }
  }
}

enum DbWipeOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption());

  const DbWipeOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDbWipeCommand extends CloudCliCommand<DbWipeOption> {
  @override
  final name = 'wipe';

  @override
  final description =
      'Irreversibly wipe and recreate the database, deleting all data and schema changes.';

  @override
  String get category => CommandCategories.dangerZone;

  CloudDbWipeCommand({required super.logger})
    : super(options: DbWipeOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbWipeOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(DbWipeOption.projectId);
    final skipConfirmation = globalConfiguration.skipConfirmation;

    await DbCommands.wipeDatabase(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
      skipConfirmation: skipConfirmation,
    );
  }
}

class CloudDbBackupCommand extends CloudCliCommand {
  @override
  final name = 'backup';

  @override
  final description = 'Manage database backup snapshots.';

  @override
  String get category => CommandCategories.service;

  CloudDbBackupCommand({required super.logger}) {
    addSubcommand(CloudDbBackupCreateCommand(logger: logger));
    addSubcommand(CloudDbBackupListCommand(logger: logger));
    addSubcommand(CloudDbBackupDeleteCommand(logger: logger));
    addSubcommand(CloudDbBackupRestoreCommand(logger: logger));
  }
}

class CloudDbScheduleCommand extends CloudCliCommand {
  @override
  final name = 'schedule';

  @override
  final description = 'Manage the automated database backup schedule.';

  @override
  String get category => CommandCategories.service;

  CloudDbScheduleCommand({required super.logger}) {
    addSubcommand(CloudDbScheduleSetCommand(logger: logger));
    addSubcommand(CloudDbScheduleShowCommand(logger: logger));
    addSubcommand(CloudDbScheduleUnsetCommand(logger: logger));
  }
}

abstract final class _BackupOptions {
  static const snapshotId = StringOption(
    argName: 'snapshot',
    argPos: 0,
    helpText: 'The ID of the snapshot.',
    mandatory: true,
  );

  static const utc = UtcOption();
}

enum DbBackupCreateOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  name(
    StringOption(
      argName: 'name',
      helpText: 'An optional name for the snapshot.',
    ),
  ),
  expireIn(
    DurationOption(
      argName: 'expire-in',
      helpText:
          'How long to keep the snapshot before it is automatically deleted '
          '(e.g. "7d", "24h"). Kept indefinitely if omitted.',
    ),
  ),
  utc(_BackupOptions.utc);

  const DbBackupCreateOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDbBackupCreateCommand extends CloudCliCommand<DbBackupCreateOption> {
  @override
  final name = 'create';

  @override
  final description = 'Create a manual database backup snapshot.';

  CloudDbBackupCreateCommand({required super.logger})
    : super(options: DbBackupCreateOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbBackupCreateOption> commandConfig,
  ) async {
    await DbBackupCommands.createSnapshot(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: commandConfig.value(DbBackupCreateOption.projectId),
      name: commandConfig.optionalValue(DbBackupCreateOption.name),
      expireIn: commandConfig.optionalValue(DbBackupCreateOption.expireIn),
      utc: commandConfig.value(DbBackupCreateOption.utc),
    );
  }
}

enum DbBackupListOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  utc(_BackupOptions.utc);

  const DbBackupListOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDbBackupListCommand extends CloudCliCommand<DbBackupListOption> {
  @override
  final name = 'list';

  @override
  final description = 'List the database backup snapshots.';

  CloudDbBackupListCommand({required super.logger})
    : super(options: DbBackupListOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbBackupListOption> commandConfig,
  ) async {
    await DbBackupCommands.listSnapshots(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: commandConfig.value(DbBackupListOption.projectId),
      utc: commandConfig.value(DbBackupListOption.utc),
    );
  }
}

enum DbBackupDeleteOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  snapshotId(_BackupOptions.snapshotId);

  const DbBackupDeleteOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDbBackupDeleteCommand extends CloudCliCommand<DbBackupDeleteOption> {
  @override
  final name = 'delete';

  @override
  final description = 'Delete a database backup snapshot.';

  @override
  String get category => CommandCategories.dangerZone;

  CloudDbBackupDeleteCommand({required super.logger})
    : super(options: DbBackupDeleteOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbBackupDeleteOption> commandConfig,
  ) async {
    await DbBackupCommands.deleteSnapshot(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: commandConfig.value(DbBackupDeleteOption.projectId),
      snapshotId: commandConfig.value(DbBackupDeleteOption.snapshotId),
      skipConfirmation: globalConfiguration.skipConfirmation,
    );
  }
}

enum DbBackupRestoreOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  snapshotId(_BackupOptions.snapshotId);

  const DbBackupRestoreOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDbBackupRestoreCommand
    extends CloudCliCommand<DbBackupRestoreOption> {
  @override
  final name = 'restore';

  @override
  final description = 'Restore the live database to a backup snapshot.';

  @override
  String get category => CommandCategories.dangerZone;

  CloudDbBackupRestoreCommand({required super.logger})
    : super(options: DbBackupRestoreOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbBackupRestoreOption> commandConfig,
  ) async {
    await DbBackupCommands.restoreSnapshot(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: commandConfig.value(DbBackupRestoreOption.projectId),
      snapshotId: commandConfig.value(DbBackupRestoreOption.snapshotId),
      skipConfirmation: globalConfiguration.skipConfirmation,
    );
  }
}

enum DbScheduleSetOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  frequency(
    EnumOption<BackupFrequency>(
      argName: 'frequency',
      argAbbrev: 'f',
      helpText: 'How often a snapshot is taken.',
      mandatory: true,
      enumParser: EnumParser(BackupFrequency.values),
    ),
  ),
  day(
    IntOption(
      argName: 'day',
      helpText:
          'The day for a weekly (1-7) or monthly (1-31) schedule. '
          'Defaults to 1. Not applicable to a daily schedule.',
      min: 1,
      max: 31,
    ),
  ),
  hour(
    IntOption(
      argName: 'hour',
      helpText:
          'The hour of the day (0-23) to take the snapshot. Defaults to 0.',
      min: 0,
      max: 23,
    ),
  ),
  retention(
    DurationOption(
      argName: 'retention',
      helpText:
          'How long scheduled snapshots are kept before being automatically '
          'deleted (e.g. "30d"). Uses the platform default if omitted.',
    ),
  );

  const DbScheduleSetOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDbScheduleSetCommand extends CloudCliCommand<DbScheduleSetOption> {
  @override
  final name = 'set';

  @override
  final description = 'Set (create or update) the automated backup schedule.';

  CloudDbScheduleSetCommand({required super.logger})
    : super(options: DbScheduleSetOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbScheduleSetOption> commandConfig,
  ) async {
    final frequency = commandConfig.value(DbScheduleSetOption.frequency);
    final day = commandConfig.optionalValue(DbScheduleSetOption.day);

    if (frequency == BackupFrequency.weekly &&
        day != null &&
        (day < 1 || day > 7)) {
      throw CloudCliUsageException(
        'The --day value must be between 1 and 7 for a weekly schedule.',
      );
    }

    await DbBackupCommands.setSchedule(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: commandConfig.value(DbScheduleSetOption.projectId),
      frequency: frequency,
      day: day,
      hour: commandConfig.optionalValue(DbScheduleSetOption.hour),
      retention: commandConfig.optionalValue(DbScheduleSetOption.retention),
    );
  }
}

enum DbScheduleShowOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption());

  const DbScheduleShowOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDbScheduleShowCommand extends CloudCliCommand<DbScheduleShowOption> {
  @override
  final name = 'show';

  @override
  final description = 'Show the automated backup schedule.';

  CloudDbScheduleShowCommand({required super.logger})
    : super(options: DbScheduleShowOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbScheduleShowOption> commandConfig,
  ) async {
    await DbBackupCommands.showSchedule(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: commandConfig.value(DbScheduleShowOption.projectId),
    );
  }
}

enum DbScheduleUnsetOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption());

  const DbScheduleUnsetOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDbScheduleUnsetCommand
    extends CloudCliCommand<DbScheduleUnsetOption> {
  @override
  final name = 'unset';

  @override
  final description = 'Unset (disable) the automated backup schedule.';

  CloudDbScheduleUnsetCommand({required super.logger})
    : super(options: DbScheduleUnsetOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DbScheduleUnsetOption> commandConfig,
  ) async {
    await DbBackupCommands.disableSchedule(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: commandConfig.value(DbScheduleUnsetOption.projectId),
    );
  }
}

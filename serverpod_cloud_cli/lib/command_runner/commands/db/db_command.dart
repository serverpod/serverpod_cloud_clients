import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/db/db_backup_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/db/db_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/db/db_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart'
    show CommandOutput, ConfirmationWidget;

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
  Future<void> runWithOutput(
    final Configuration<DbConnectionDetailsOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(DbConnectionDetailsOption.projectId);

    await renderCommand(
      output,
      operation: () => DbOperations.getConnectionDetails(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: const DbConnectionTextUi(),
    );
  }
}

enum DbUserCreateOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  username(
    StringOption(
      argName: 'username',
      argPos: 0,
      helpText: 'The username of the DB user to create.',
      mandatory: true,
    ),
  );

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
  Future<void> runWithOutput(
    final Configuration<DbUserCreateOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(DbUserCreateOption.projectId);
    final username = commandConfig.value(DbUserCreateOption.username);

    await renderCommand(
      output,
      operation: () => DbOperations.createSuperUser(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        username: username,
      ),
      textOutputUi: const DbUserCreateTextUi(),
    );
  }
}

enum DbUserResetPasswordOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  username(
    StringOption(
      argName: 'username',
      argPos: 0,
      helpText: 'The username of the DB user whose password is reset.',
      mandatory: true,
    ),
  );

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
  Future<void> runWithOutput(
    final Configuration<DbUserResetPasswordOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(DbUserResetPasswordOption.projectId);
    final username = commandConfig.value(DbUserResetPasswordOption.username);

    await renderCommand(
      output,
      operation: () => DbOperations.resetPassword(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        username: username,
      ),
      textOutputUi: const DbUserResetPasswordTextUi(),
    );
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
  Future<void> runWithOutput(
    final Configuration<DbWipeOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(DbWipeOption.projectId);

    if (!globalConfiguration.skipConfirmation) {
      final confirmed = await output.renderInteractive(
        ui: ConfirmationWidget('''
WARNING: Deletes all tables and data in the database for project "$projectId".
This is a NON-REVERSIBLE action.
The server will error until a redeploy is performed.

Do you want to proceed?''', defaultValue: false),
      );
      if (!confirmed) {
        await renderCommand(
          output,
          operation: () async => const <String, Object?>{},
          textOutputUi: const DbWipeCancelledTextUi(),
        );
        return;
      }
    }

    await logger.progress(
      'Wiping database for project "$projectId"...',
      newParagraph: true,
      () async {
        await DbOperations.wipeDatabase(
          runner.serviceProvider.cloudApiClient,
          projectId: projectId,
        );
        return true;
      },
    );

    await renderCommand(
      output,
      operation: () async => {'projectId': projectId},
      textOutputUi: DbWipeTextUi(baseCommand: baseCommand),
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
  Future<void> runWithOutput(
    final Configuration<DbBackupCreateOption> commandConfig,
    final CommandOutput output,
  ) async {
    final utc = commandConfig.value(DbBackupCreateOption.utc);

    late DatabaseSnapshot snapshot;
    await logger.progress(
      'Creating database snapshot for project "${commandConfig.value(DbBackupCreateOption.projectId)}"',
      () async {
        snapshot = await DbBackupOperations.createSnapshot(
          runner.serviceProvider.cloudApiClient,
          projectId: commandConfig.value(DbBackupCreateOption.projectId),
          name: commandConfig.optionalValue(DbBackupCreateOption.name),
          expireIn: commandConfig.optionalValue(DbBackupCreateOption.expireIn),
        );
        return true;
      },
      successMessage: 'Snapshot created.',
      newParagraph: true,
    );

    await renderCommand(
      output,
      operation: () async => [snapshot],
      textOutputUi: BackupSnapshotListTextUi(utc: utc),
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
  Future<void> runWithOutput(
    final Configuration<DbBackupListOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(DbBackupListOption.projectId);
    final utc = commandConfig.value(DbBackupListOption.utc);

    await renderCommand(
      output,
      operation: () => DbBackupOperations.listSnapshots(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: BackupSnapshotListTextUi(
        utc: utc,
        emptyProjectId: projectId,
        baseCommand: baseCommand,
      ),
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
  Future<void> runWithOutput(
    final Configuration<DbBackupDeleteOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(DbBackupDeleteOption.projectId);
    final snapshotId = commandConfig.value(DbBackupDeleteOption.snapshotId);

    await confirmToContinue(
      output,
      message:
          'Permanently delete snapshot "$snapshotId" for project "$projectId"? '
          'This action cannot be undone.',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => DbBackupOperations.deleteSnapshot(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        snapshotId: snapshotId,
      ),
      textOutputUi: const BackupSnapshotDeleteTextUi(),
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
  Future<void> runWithOutput(
    final Configuration<DbBackupRestoreOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(DbBackupRestoreOption.projectId);
    final snapshotId = commandConfig.value(DbBackupRestoreOption.snapshotId);

    await confirmToContinue(
      output,
      message: '''
WARNING: Restores the database for project "$projectId" to snapshot "$snapshotId".
The live database is replaced with the data from the snapshot.
This action cannot be undone.

Do you want to proceed?''',
      defaultValue: false,
    );

    await logger.progress(
      'Restoring database for project "$projectId"',
      () async {
        await DbBackupOperations.restoreSnapshot(
          runner.serviceProvider.cloudApiClient,
          projectId: projectId,
          snapshotId: snapshotId,
        );
        return true;
      },
      successMessage: 'Database restored.',
      newParagraph: true,
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
  Future<void> runWithOutput(
    final Configuration<DbScheduleSetOption> commandConfig,
    final CommandOutput output,
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

    await renderCommand(
      output,
      operation: () => DbBackupOperations.setSchedule(
        runner.serviceProvider.cloudApiClient,
        projectId: commandConfig.value(DbScheduleSetOption.projectId),
        frequency: frequency,
        day: day,
        hour: commandConfig.optionalValue(DbScheduleSetOption.hour),
        retention: commandConfig.optionalValue(DbScheduleSetOption.retention),
      ),
      textOutputUi: const BackupScheduleSetTextUi(),
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
  Future<void> runWithOutput(
    final Configuration<DbScheduleShowOption> commandConfig,
    final CommandOutput output,
  ) async {
    await renderCommand(
      output,
      operation: () => DbBackupOperations.getSchedule(
        runner.serviceProvider.cloudApiClient,
        projectId: commandConfig.value(DbScheduleShowOption.projectId),
      ),
      textOutputUi: BackupScheduleShowTextUi(baseCommand: baseCommand),
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
  Future<void> runWithOutput(
    final Configuration<DbScheduleUnsetOption> commandConfig,
    final CommandOutput output,
  ) async {
    await renderCommand(
      output,
      operation: () => DbBackupOperations.disableSchedule(
        runner.serviceProvider.cloudApiClient,
        projectId: commandConfig.value(DbScheduleUnsetOption.projectId),
      ),
      textOutputUi: const BackupScheduleUnsetTextUi(),
    );
  }
}

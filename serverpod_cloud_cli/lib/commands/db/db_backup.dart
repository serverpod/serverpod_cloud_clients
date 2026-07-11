import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

/// Commands for managing database backup snapshots and the automated backup
/// schedule of a project's database.
abstract class DbBackupCommands {
  /// Creates a manual snapshot of the project's database.
  ///
  /// When [expireIn] is provided the snapshot is scheduled for automatic
  /// deletion after that duration, otherwise it is retained indefinitely.
  static Future<void> createSnapshot(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    final String? name,
    final Duration? expireIn,
    final bool utc = false,
  }) async {
    final expiresAt = expireIn == null
        ? null
        : DateTime.now().toUtc().add(expireIn);

    DatabaseSnapshot? snapshot;
    try {
      await logger.progress(
        'Creating database snapshot for project "$projectId"',
        () async {
          snapshot = await cloudApiClient.database.createSnapshot(
            cloudCapsuleId: projectId,
            name: name,
            expiresAt: expiresAt,
          );
          return true;
        },
        successMessage: 'Snapshot created.',
        newParagraph: true,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to create snapshot');
    }

    final created = snapshot;
    if (created != null) {
      _snapshotsTable([created], utc: utc).writeLines(logger.line);
    }
  }

  /// Lists all snapshots of the project's database.
  static Future<void> listSnapshots(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    final bool utc = false,
  }) async {
    final List<DatabaseSnapshot> snapshots;
    try {
      snapshots = await cloudApiClient.database.listSnapshots(
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to list snapshots');
    }

    if (snapshots.isEmpty) {
      logger.info('No snapshots found for project "$projectId".');
      logger.terminalCommand(
        message: 'Create a snapshot with:',
        'scloud db backup create --project $projectId',
      );
      return;
    }

    _snapshotsTable(snapshots, utc: utc).writeLines(logger.line);
  }

  /// Deletes a single snapshot of the project's database.
  static Future<void> deleteSnapshot(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final String snapshotId,
    final bool skipConfirmation = false,
  }) async {
    if (!skipConfirmation) {
      final confirmed = await logger.confirm(
        'Permanently delete snapshot "$snapshotId" for project "$projectId"? '
        'This action cannot be undone.',
        defaultValue: false,
      );
      if (!confirmed) {
        throw UserAbortException();
      }
    }

    try {
      await cloudApiClient.database.deleteSnapshot(
        cloudCapsuleId: projectId,
        snapshotId: snapshotId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to delete snapshot');
    }

    logger.success('Snapshot "$snapshotId" deleted.', newParagraph: true);
  }

  /// Restores the project's live database to a snapshot.
  static Future<void> restoreSnapshot(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final String snapshotId,
    final bool skipConfirmation = false,
  }) async {
    if (!skipConfirmation) {
      final confirmed = await logger.confirm('''
WARNING: Restores the database for project "$projectId" to snapshot "$snapshotId".
The live database is replaced with the data from the snapshot.
The current state is retained by the provider as a separate backup.

Do you want to proceed?''', defaultValue: false);
      if (!confirmed) {
        throw UserAbortException();
      }
    }

    try {
      await logger.progress(
        'Restoring database for project "$projectId"',
        () async {
          await cloudApiClient.database.restoreFromSnapshot(
            cloudCapsuleId: projectId,
            snapshotId: snapshotId,
          );
          return true;
        },
        successMessage: 'Database restored.',
        newParagraph: true,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to restore snapshot');
    }
  }

  /// Sets (creates or updates) the automated backup schedule for the project's
  /// database.
  ///
  /// [hour] defaults to 0 (midnight UTC). For weekly and monthly schedules
  /// [day] defaults to 1 when omitted; it is not applicable to daily schedules
  /// and is ignored in that case.
  static Future<void> setSchedule(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final BackupFrequency frequency,
    final int? day,
    final int? hour,
    final Duration? retention,
  }) async {
    final effectiveHour = hour ?? 0;
    final effectiveDay = switch (frequency) {
      BackupFrequency.daily => null,
      BackupFrequency.weekly || BackupFrequency.monthly => day ?? 1,
    };

    if (frequency == BackupFrequency.daily && day != null) {
      logger.warning(
        'A day is not applicable to a daily schedule and is ignored.',
      );
    }

    try {
      await cloudApiClient.database.setBackupSchedule(
        cloudCapsuleId: projectId,
        frequency: frequency,
        day: effectiveDay,
        hour: effectiveHour,
        retention: retention,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to set backup schedule');
    }

    logger.success(
      'Backup schedule set for project "$projectId".',
      newParagraph: true,
    );
    _scheduleTable(
      BackupSchedule(
        frequency: frequency,
        day: effectiveDay,
        hour: effectiveHour,
        retention: retention,
      ),
    ).writeLines(logger.line);
  }

  /// Shows the automated backup schedule for the project's database.
  static Future<void> showSchedule(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
  }) async {
    final BackupSchedule? schedule;
    try {
      schedule = await cloudApiClient.database.getBackupSchedule(
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get backup schedule');
    }

    if (schedule == null) {
      logger.info('No backup schedule is configured for project "$projectId".');
      logger.terminalCommand(
        message: 'Set a schedule with:',
        'scloud db schedule set --project $projectId --frequency daily',
      );
      return;
    }

    _scheduleTable(schedule).writeLines(logger.line);
  }

  /// Disables the automated backup schedule for the project's database.
  static Future<void> disableSchedule(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
  }) async {
    try {
      await cloudApiClient.database.setBackupSchedule(
        cloudCapsuleId: projectId,
        frequency: null,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to disable backup schedule');
    }

    logger.success(
      'Backup schedule disabled for project "$projectId".',
      newParagraph: true,
    );
  }

  static TablePrinter _snapshotsTable(
    final List<DatabaseSnapshot> snapshots, {
    required final bool utc,
  }) {
    return TablePrinter(
      headers: ['ID', 'Name', 'Type', 'Created', 'Expires', 'Size'],
      rows: snapshots.map(
        (final snapshot) => [
          snapshot.id,
          snapshot.name,
          snapshot.manual ? 'manual' : 'scheduled',
          _formatTimestamp(snapshot.createdAt, utc: utc),
          snapshot.expiresAt == null
              ? 'never'
              : _formatTimestamp(snapshot.expiresAt, utc: utc),
          _formatBytes(snapshot.fullSizeBytes),
        ],
      ),
    );
  }

  static TablePrinter _scheduleTable(final BackupSchedule schedule) {
    final table = TablePrinter(headers: ['Setting', 'Value']);
    table.addRow(['Frequency', schedule.frequency.name]);
    table.addRow(['Hour (UTC)', schedule.hour?.toString() ?? '-']);
    if (schedule.frequency != BackupFrequency.daily) {
      table.addRow(['Day', schedule.day?.toString() ?? '-']);
    }
    table.addRow([
      'Retention',
      schedule.retention == null
          ? 'kept indefinitely'
          : _formatDuration(schedule.retention),
    ]);
    return table;
  }

  static String _formatTimestamp(
    final DateTime? timestamp, {
    required final bool utc,
  }) {
    if (timestamp == null) return '-';
    final local = utc ? timestamp.toUtc() : timestamp.toLocal();
    return local.toString().substring(0, 19);
  }

  static String _formatBytes(final int? bytes) {
    if (bytes == null) return '-';
    if (bytes < 1024) return '$bytes B';
    const units = ['KB', 'MB', 'GB', 'TB'];
    var size = bytes / 1024;
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  static String _formatDuration(final Duration? duration) {
    if (duration == null) return '-';
    if (duration.inHours % 24 == 0 && duration.inHours != 0) {
      final days = duration.inDays;
      return '$days ${days == 1 ? 'day' : 'days'}';
    }
    final hours = duration.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'}';
  }
}

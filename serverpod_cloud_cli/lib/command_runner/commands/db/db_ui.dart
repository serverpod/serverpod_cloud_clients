import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class DbConnectionTextUi extends OutputWidget {
  const DbConnectionTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final connection = context.get<DatabaseConnection>();
    final portString = connection.port == 5432 ? '' : ':${connection.port}';
    final connectionString =
        'postgresql://${connection.host}$portString/${connection.name}'
        '?sslmode=${connection.requiresSsl ? 'require' : 'disable'}';

    return SuccessTextWidget(
      '''
Connection details:
  Host: ${connection.host}
  Port: ${connection.port}
  Database: ${connection.name}''',
      followUp:
          '''
This psql command can be used to connect to the database (it will prompt for the password):
  psql "$connectionString" --user <username>''',
    );
  }
}

class DbUserCreateTextUi extends OutputWidget {
  const DbUserCreateTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final password = context.get<String>();
    return SuccessTextWidget('''
DB superuser created. The password is only shown this once:
$password''');
  }
}

class DbUserResetPasswordTextUi extends OutputWidget {
  const DbUserResetPasswordTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final password = context.get<String>();
    return SuccessTextWidget('''
DB password is reset. The new password is only shown this once:
$password''');
  }
}

class DbWipeTextUi extends OutputWidget {
  final String baseCommand;

  const DbWipeTextUi({required this.baseCommand});

  @override
  OutputWidget build(final OutputContext context) {
    return OutputWidgetList([
      const SuccessTextWidget('Database wiped successfully.'),
      InfoTextWidget('Redeploy is needed, run: $baseCommand deploy'),
    ]);
  }
}

class DbWipeCancelledTextUi extends OutputWidget {
  const DbWipeCancelledTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return const InfoTextWidget('Database wipe cancelled.');
  }
}

class BackupSnapshotListTextUi extends OutputWidget {
  final bool utc;
  final String? emptyProjectId;
  final String? baseCommand;

  const BackupSnapshotListTextUi({
    required this.utc,
    this.emptyProjectId,
    this.baseCommand,
  });

  @override
  OutputWidget build(final OutputContext context) {
    final snapshots = context.get<List<DatabaseSnapshot>>();
    if (snapshots.isEmpty) {
      final projectId = emptyProjectId;
      final command = baseCommand;
      if (projectId != null && command != null) {
        return OutputWidgetList([
          InfoTextWidget('No snapshots found for project "$projectId".'),
          CommandHintTextWidget(
            'Create a snapshot with:',
            command: '$command db backup create --project $projectId',
          ),
        ]);
      }
      return const InfoTextWidget('No snapshots found.');
    }

    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<DatabaseSnapshot>(
        columns: [
          TableColumnFormatter.forElement(
            'ID',
            getter: (final snapshot) => snapshot.id,
          ),
          TableColumnFormatter.forElement(
            'Name',
            getter: (final snapshot) => snapshot.name,
          ),
          TableColumnFormatter.forElement(
            'Type',
            getter: (final snapshot) => snapshot.manual ? 'manual' : 'scheduled',
          ),
          TableColumnFormatter.forElement(
            'Created',
            getter: (final snapshot) => snapshot.createdAt,
          ),
          TableColumnFormatter.forElement(
            'Expires',
            getter: (final snapshot) => snapshot.expiresAt ?? 'never',
          ),
          TableColumnFormatter.forElement(
            'Size',
            getter: (final snapshot) => _formatBytes(snapshot.fullSizeBytes),
          ),
        ],
        utc: utc,
      ),
    );
  }
}

class BackupSnapshotDeleteTextUi extends OutputWidget {
  const BackupSnapshotDeleteTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'Snapshot "${result['snapshotId']}" deleted.',
      newParagraph: true,
    );
  }
}

class BackupScheduleSetTextUi extends OutputWidget {
  const BackupScheduleSetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final warning = result['warning'];
    return OutputWidgetList([
      if (warning is String) WarningTextWidget(warning),
      SuccessTextWidget(
        'Backup schedule set for project "${result['projectId']}".',
        newParagraph: true,
      ),
      _BackupScheduleTable(
        frequency: result['frequency'],
        day: result['day'],
        hour: result['hour'],
        retention: result['retention'],
      ),
    ]);
  }
}

class BackupScheduleShowTextUi extends OutputWidget {
  final String baseCommand;

  const BackupScheduleShowTextUi({required this.baseCommand});

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final projectId = result['projectId'];
    final schedule = result['schedule'];
    if (schedule is! BackupSchedule) {
      return OutputWidgetList([
        InfoTextWidget(
          'No backup schedule is configured for project "$projectId".',
        ),
        CommandHintTextWidget(
          'Set a schedule with:',
          command:
              '$baseCommand db schedule set --project $projectId '
              '--frequency daily',
        ),
      ]);
    }

    return _BackupScheduleTable(
      frequency: schedule.frequency,
      day: schedule.day,
      hour: schedule.hour,
      retention: schedule.retention,
    );
  }
}

class BackupScheduleUnsetTextUi extends OutputWidget {
  const BackupScheduleUnsetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'Backup schedule disabled for project "${result['projectId']}".',
      newParagraph: true,
    );
  }
}

class _BackupScheduleTable extends OutputWidget {
  final Object? frequency;
  final Object? day;
  final Object? hour;
  final Object? retention;

  const _BackupScheduleTable({
    required this.frequency,
    required this.day,
    required this.hour,
    required this.retention,
  });

  @override
  OutputWidget build(final OutputContext context) {
    final frequencyValue = frequency;
    final frequencyName = frequencyValue is BackupFrequency
        ? frequencyValue.name
        : '$frequencyValue';
    final retentionValue = retention;
    final retentionDuration = retentionValue is Duration
        ? retentionValue
        : null;
    final rows = <Map<String, Object?>>[
      {'setting': 'Frequency', 'value': frequencyName},
      {'setting': 'Hour (UTC)', 'value': hour?.toString() ?? '-'},
      if (frequency != BackupFrequency.daily)
        {'setting': 'Day', 'value': day?.toString() ?? '-'},
      {
        'setting': 'Retention',
        'value': retentionDuration != null
            ? _formatDuration(retentionDuration)
            : 'kept indefinitely',
      },
    ];

    return TextTableWidget(
      TextTableOutputFormatter<Map<String, Object?>>(
        columns: [
          TableColumnFormatter.forKey('Setting', key: 'setting'),
          TableColumnFormatter.forKey('Value', key: 'value'),
        ],
        utc: false,
      ).format(rows),
    );
  }
}

String _formatBytes(final int? bytes) {
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

String _formatDuration(final Duration duration) {
  if (duration.inHours % 24 == 0 && duration.inHours != 0) {
    final days = duration.inDays;
    return '$days ${days == 1 ? 'day' : 'days'}';
  }
  final hours = duration.inHours;
  return '$hours ${hours == 1 ? 'hour' : 'hours'}';
}

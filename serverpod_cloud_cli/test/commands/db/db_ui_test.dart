import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/db/db_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a DbConnectionTextUi', () {
    group('when rendered with default port and no ssl', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const DbConnectionTextUi(),
          data: DatabaseConnection(
            host: 'db.example.com',
            port: 5432,
            name: 'app',
            user: 'wernher',
            requiresSsl: false,
          ),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the connection details', () {
        expect(stdout, contains('Host: db.example.com'));
        expect(stdout, contains('Port: 5432'));
        expect(stdout, contains('Database: app'));
      });

      test('then stdout contains a psql command without a port suffix', () {
        expect(
          stdout,
          contains(
            'psql "postgresql://db.example.com/app?sslmode=disable" --user <username>',
          ),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered with a non-default port and ssl', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const DbConnectionTextUi(),
          data: DatabaseConnection(
            host: 'db.example.com',
            port: 5433,
            name: 'app',
            user: 'wernher',
            requiresSsl: true,
          ),
        );
        stdout = io.stdout;
      });

      test('then stdout includes the port and require sslmode', () {
        expect(
          stdout,
          contains(
            'psql "postgresql://db.example.com:5433/app?sslmode=require"',
          ),
        );
      });
    });
  });

  group('Given a DbUserCreateTextUi', () {
    group('when rendered with a generated password', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const DbUserCreateTextUi(),
          data: 'one-time-password',
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the password', () {
        expect(stdout, contains('DB superuser created.'));
        expect(stdout, contains('one-time-password'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a DbUserResetPasswordTextUi', () {
    group('when rendered with a new password', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const DbUserResetPasswordTextUi(),
          data: 'reset-password',
        );
        stdout = io.stdout;
      });

      test('then stdout contains the new password', () {
        expect(stdout, contains('DB password is reset.'));
        expect(stdout, contains('reset-password'));
      });
    });
  });

  group('Given a DbWipeTextUi', () {
    group('when rendered after a successful wipe', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const DbWipeTextUi(baseCommand: 'scloud', projectId: 'my-project'),
          data: Stream.value(const {'projectId': 'my-project'}),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the progress heading', () {
        expect(stdout, contains('Wiping database for project "my-project"'));
      });

      test('then stdout contains the wipe success message', () {
        expect(stdout, contains('Database wiped successfully.'));
      });

      test('then stdout hints to redeploy', () {
        expect(stdout, contains('scloud deploy'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a DbWipeCancelledTextUi', () {
    group('when rendered', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const DbWipeCancelledTextUi(),
          data: const <String, Object?>{},
        );
        stdout = io.stdout;
      });

      test('then stdout reports that the wipe was cancelled', () {
        expect(stdout, contains('Database wipe cancelled.'));
      });
    });
  });

  group('Given a BackupSnapshotCreateTextUi', () {
    group('when rendered after creating a snapshot', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupSnapshotCreateTextUi(utc: true),
          data: DatabaseSnapshot(
            id: 'snap-1',
            name: 'nightly',
            createdAt: DateTime.utc(2026, 1, 15, 10, 30),
            manual: true,
            fullSizeBytes: 5 * 1024 * 1024,
          ),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the create success message', () {
        expect(stdout, contains('Snapshot "snap-1" created.'));
      });

      test('then stdout contains the snapshot row', () {
        expect(stdout, contains('snap-1'));
        expect(stdout, contains('nightly'));
        expect(stdout, contains('manual'));
        expect(stdout, contains('5.0 MB'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a BackupSnapshotListTextUi', () {
    group('when rendered with no snapshots and a project hint', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupSnapshotListTextUi(
            utc: true,
            emptyProjectId: 'my-project',
            baseCommand: 'scloud',
          ),
          data: const (
            snapshots: <DatabaseSnapshot>[],
            planType: PlanType.growth,
          ),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports that no snapshots were found', () {
        expect(
          stdout,
          contains('No snapshots found for project "my-project".'),
        );
      });

      test('then stdout hints to create a snapshot', () {
        expect(
          stdout,
          contains('scloud db backup create --project my-project'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered with no snapshots on the starter plan', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupSnapshotListTextUi(
            utc: true,
            emptyProjectId: 'my-project',
            baseCommand: 'scloud',
          ),
          data: const (
            snapshots: <DatabaseSnapshot>[],
            planType: PlanType.starter,
          ),
        );
        stdout = io.stdout;
      });

      test('then stdout says backups need the Growth plan', () {
        expect(
          stdout,
          contains('Database backups are available on the Growth plan.'),
        );
      });

      test('then stdout links to the project plan page', () {
        expect(stdout, contains('/project/my-project/plan-and-settings'));
      });

      test('then stdout does not hint to create a snapshot', () {
        expect(stdout, isNot(contains('scloud db backup create')));
      });

      test('then stdout does not report that no snapshots were found', () {
        expect(stdout, isNot(contains('No snapshots found')));
      });
    });

    group('when rendered with no snapshots on an unknown plan', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupSnapshotListTextUi(
            utc: true,
            emptyProjectId: 'my-project',
            baseCommand: 'scloud',
          ),
          data: const (
            snapshots: <DatabaseSnapshot>[],
            planType: PlanType.unknown,
          ),
        );
        stdout = io.stdout;
      });

      test('then stdout hints to create a snapshot', () {
        expect(
          stdout,
          contains('scloud db backup create --project my-project'),
        );
      });
    });

    group('when rendered with a snapshot', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupSnapshotListTextUi(utc: true),
          data: (
            snapshots: [
              DatabaseSnapshot(
                id: 'snap-1',
                name: 'nightly',
                createdAt: DateTime.utc(2026, 1, 15, 10, 30),
                manual: true,
                fullSizeBytes: 5 * 1024 * 1024,
              ),
            ],
            planType: null,
          ),
        );
        stdout = io.stdout;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('ID'));
        expect(stdout, contains('Name'));
        expect(stdout, contains('Type'));
      });

      test('then stdout contains the snapshot row', () {
        expect(stdout, contains('snap-1'));
        expect(stdout, contains('nightly'));
        expect(stdout, contains('manual'));
        expect(stdout, contains('5.0 MB'));
      });
    });
  });

  group('Given a BackupSnapshotRestoreTextUi', () {
    group('when rendered after restoring a snapshot', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupSnapshotRestoreTextUi(projectId: 'my-project'),
          data: Stream.value(const {
            'projectId': 'my-project',
            'snapshotId': 'snap-1',
          }),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the progress heading', () {
        expect(stdout, contains('Restoring database for project "my-project"'));
      });

      test('then stdout contains the restore success message', () {
        expect(stdout, contains('Database restored.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a BackupSnapshotDeleteTextUi', () {
    group('when rendered after deleting a snapshot', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupSnapshotDeleteTextUi(),
          data: const {'snapshotId': 'snap-1'},
        );
        stdout = io.stdout;
      });

      test('then stdout contains the delete success message', () {
        expect(stdout, contains('Snapshot "snap-1" deleted.'));
      });
    });
  });

  group('Given a BackupScheduleSetTextUi', () {
    group('when rendered after setting a weekly schedule', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupScheduleSetTextUi(),
          data: {
            'projectId': 'my-project',
            'frequency': BackupFrequency.weekly,
            'day': 2,
            'hour': 4,
            'retention': const Duration(days: 30),
          },
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the set success message', () {
        expect(
          stdout,
          contains('Backup schedule set for project "my-project".'),
        );
      });

      test('then stdout contains the schedule table', () {
        expect(stdout, contains('weekly'));
        expect(stdout, contains('30 days'));
        expect(stdout, contains('Day'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered without a retention', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupScheduleSetTextUi(),
          data: {
            'projectId': 'my-project',
            'frequency': BackupFrequency.daily,
            'hour': 0,
          },
        );
        stdout = io.stdout;
      });

      test('then stdout shows the platform default retention', () {
        expect(stdout, contains('platform default'));
        expect(stdout, isNot(contains('kept indefinitely')));
      });
    });

    group('when rendered with a warning', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupScheduleSetTextUi(),
          data: {
            'projectId': 'my-project',
            'frequency': BackupFrequency.daily,
            'day': 2,
            'hour': 3,
            'retention': const Duration(days: 7),
            'warning':
                'A day is not applicable to a daily schedule and is ignored.',
          },
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stderr contains the warning', () {
        expect(
          stderr,
          contains(
            'A day is not applicable to a daily schedule and is ignored.',
          ),
        );
      });

      test('then stdout still contains the success message', () {
        expect(
          stdout,
          contains('Backup schedule set for project "my-project".'),
        );
      });

      test('then stdout does not contain a Day row', () {
        expect(stdout, isNot(contains('Day')));
      });
    });
  });

  group('Given a BackupScheduleShowTextUi', () {
    group('when rendered with no schedule', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupScheduleShowTextUi(baseCommand: 'scloud'),
          data: const (
            projectId: 'my-project',
            schedule: null,
            planType: PlanType.growth,
          ),
        );
        stdout = io.stdout;
      });

      test('then stdout reports that no schedule is configured', () {
        expect(
          stdout,
          contains(
            'No backup schedule is configured for project "my-project".',
          ),
        );
      });

      test('then stdout hints to set a schedule', () {
        expect(stdout, contains('scloud db schedule set --project my-project'));
      });
    });

    group('when rendered with no schedule on the starter plan', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupScheduleShowTextUi(baseCommand: 'scloud'),
          data: const (
            projectId: 'my-project',
            schedule: null,
            planType: PlanType.starter,
          ),
        );
        stdout = io.stdout;
      });

      test('then stdout says backups need the Growth plan', () {
        expect(
          stdout,
          contains('Database backups are available on the Growth plan.'),
        );
      });

      test('then stdout links to the project plan page', () {
        expect(stdout, contains('/project/my-project/plan-and-settings'));
      });

      test('then stdout does not hint to set a schedule', () {
        expect(stdout, isNot(contains('scloud db schedule set')));
      });

      test('then stdout does not report that no schedule is configured', () {
        expect(stdout, isNot(contains('No backup schedule')));
      });
    });

    group('when rendered with a daily schedule', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupScheduleShowTextUi(baseCommand: 'scloud'),
          data: (
            projectId: 'my-project',
            schedule: BackupSchedule(
              frequency: BackupFrequency.daily,
              hour: 4,
              retention: const Duration(days: 14),
            ),
            planType: null,
          ),
        );
        stdout = io.stdout;
      });

      test('then stdout contains the daily schedule', () {
        expect(stdout, contains('daily'));
        expect(stdout, contains('14 days'));
        expect(stdout, contains('Hour (UTC)'));
      });
    });
  });

  group('Given a BackupScheduleUnsetTextUi', () {
    group('when rendered after disabling a schedule', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const BackupScheduleUnsetTextUi(),
          data: const {'projectId': 'my-project'},
        );
        stdout = io.stdout;
      });

      test('then stdout contains the disable success message', () {
        expect(
          stdout,
          contains('Backup schedule disabled for project "my-project".'),
        );
      });
    });
  });

  group('Given a DbUserListTextUi', () {
    group('when rendered with users', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const DbUserListTextUi(
            utc: true,
            projectId: 'my-project',
            baseCommand: 'scloud',
          ),
          data: [
            DatabaseUserBuilder().withUsername('wernher').build(),
            DatabaseUserBuilder()
                .withUsername('valentina')
                .withCreatedAt(DateTime.utc(2026, 1, 15))
                .withPasswordReset()
                .build(),
          ],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('User'));
        expect(stdout, contains('Created'));
        expect(stdout, contains('Last reset'));
      });

      test('then stdout contains the usernames', () {
        expect(stdout, contains('wernher'));
        expect(stdout, contains('valentina'));
      });

      test('then a user without a password reset shows never', () {
        expect(
          stdout.split('\n'),
          contains(allOf(contains('wernher'), contains('never'))),
        );
      });

      test('then a user with a password reset shows the reset time', () {
        expect(
          stdout.split('\n'),
          contains(allOf(contains('valentina'), contains('2026-01-16'))),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered without users', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const DbUserListTextUi(
            utc: false,
            projectId: 'my-project',
            baseCommand: 'scloud',
          ),
          data: <DatabaseUser>[],
        );
        stdout = io.stdout;
      });

      test('then stdout informs that no users exist', () {
        expect(
          stdout,
          contains('No database users found for project "my-project".'),
        );
      });

      test('then stdout hints how to create a user', () {
        expect(
          stdout,
          contains('scloud db user create <username> --project my-project'),
        );
      });
    });
  });

  group('Given a DbUserDeleteTextUi', () {
    group('when rendered after deleting a user', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const DbUserDeleteTextUi(),
          data: const {'username': 'wernher'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the success message', () {
        expect(stdout, contains('Database user "wernher" deleted.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}

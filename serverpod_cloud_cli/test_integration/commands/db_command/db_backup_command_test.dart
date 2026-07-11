import 'package:cli_tools/cli_tools.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/db_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:test/test.dart';

import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  tearDown(() async {
    logger.clear();
  });
  const projectId = 'projectId';

  DatabaseSnapshot snapshot({
    final String id = 'snap-1',
    final String name = 'nightly',
    final bool manual = true,
    final DateTime? expiresAt,
  }) => DatabaseSnapshot(
    id: id,
    name: name,
    createdAt: DateTime.utc(2026, 1, 15, 10, 30),
    expiresAt: expiresAt,
    manual: manual,
    fullSizeBytes: 5 * 1024 * 1024,
  );

  group('Given command instantiation', () {
    test('then db backup create requires login', () {
      expect(CloudDbBackupCreateCommand(logger: logger).requireLogin, isTrue);
    });

    test('then db backup restore requires login', () {
      expect(CloudDbBackupRestoreCommand(logger: logger).requireLogin, isTrue);
    });

    test('then db schedule create requires login', () {
      expect(CloudDbScheduleSetCommand(logger: logger).requireLogin, isTrue);
    });
  });

  group('Given authenticated', () {
    setUp(() async {
      client.authKeyProvider = InMemoryKeyManager.authenticated();
    });

    group('when creating a snapshot', () {
      setUpAll(() {
        when(
          () => client.database.createSnapshot(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            name: any(named: 'name'),
            expiresAt: any(named: 'expiresAt'),
          ),
        ).thenAnswer((final _) async => snapshot());
      });

      tearDownAll(() {
        reset(client.database);
      });
      tearDown(() {
        clearInteractions(client.database);
      });

      test('then succeeds and outputs the snapshot', () async {
        await cli.run(['db', 'backup', 'create', '--project', projectId]);

        expect(
          logger.lineCalls.any((final c) => c.line.contains('snap-1')),
          isTrue,
        );
      });

      test('then calls createSnapshot without expiry by default', () async {
        await cli.run(['db', 'backup', 'create', '--project', projectId]);

        verify(
          () => client.database.createSnapshot(
            cloudCapsuleId: projectId,
            name: null,
            expiresAt: null,
          ),
        ).called(1);
      });

      test(
        'then passes the name and computes expiry from --expire-in',
        () async {
          await cli.run([
            'db',
            'backup',
            'create',
            '--project',
            projectId,
            '--name',
            'pre-release',
            '--expire-in',
            '7d',
          ]);

          final captured =
              verify(
                    () => client.database.createSnapshot(
                      cloudCapsuleId: projectId,
                      name: 'pre-release',
                      expiresAt: captureAny(named: 'expiresAt'),
                    ),
                  ).captured.single
                  as DateTime?;
          expect(captured, isNotNull);
        },
      );
    });

    group('when listing snapshots', () {
      group('and snapshots exist', () {
        setUpAll(() {
          when(
            () => client.database.listSnapshots(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer(
            (final _) async => [
              snapshot(id: 'snap-1', name: 'nightly', manual: false),
              snapshot(id: 'snap-2', name: 'manual-1'),
            ],
          );
        });

        tearDownAll(() {
          reset(client.database);
        });

        test('then outputs a table with the snapshots', () async {
          await cli.run(['db', 'backup', 'list', '--project', projectId]);

          expect(
            logger.lineCalls.any((final c) => c.line.contains('Name')),
            isTrue,
          );
          expect(
            logger.lineCalls.any((final c) => c.line.contains('snap-1')),
            isTrue,
          );
          expect(
            logger.lineCalls.any((final c) => c.line.contains('snap-2')),
            isTrue,
          );
        });
      });

      group('and no snapshots exist', () {
        setUpAll(() {
          when(
            () => client.database.listSnapshots(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((final _) async => []);
        });

        tearDownAll(() {
          reset(client.database);
        });

        test('then informs the user and suggests creating one', () async {
          await cli.run(['db', 'backup', 'list', '--project', projectId]);

          expect(
            logger.infoCalls.any(
              (final c) => c.message.contains('No snapshots found'),
            ),
            isTrue,
          );
          expect(
            logger.terminalCommandCalls.any(
              (final c) => c.command.contains('scloud db backup create'),
            ),
            isTrue,
          );
        });
      });
    });

    group('when deleting a snapshot', () {
      setUpAll(() {
        when(
          () => client.database.deleteSnapshot(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            snapshotId: any(named: 'snapshotId'),
          ),
        ).thenAnswer((final _) async {});
      });

      tearDownAll(() {
        reset(client.database);
      });
      tearDown(() {
        clearInteractions(client.database);
      });

      test('then deletes with --yes without prompting', () async {
        await cli.run([
          'db',
          'backup',
          'delete',
          'snap-1',
          '--project',
          projectId,
          '--yes',
        ]);

        verify(
          () => client.database.deleteSnapshot(
            cloudCapsuleId: projectId,
            snapshotId: 'snap-1',
          ),
        ).called(1);
        expect(logger.successCalls, isNotEmpty);
      });

      test('then does not delete when the user declines', () async {
        logger.answerNextConfirmWith(false);
        final result = cli.run([
          'db',
          'backup',
          'delete',
          'snap-1',
          '--project',
          projectId,
        ]);

        await expectLater(result, throwsA(isA<ExitException>()));
        verifyNever(
          () => client.database.deleteSnapshot(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            snapshotId: any(named: 'snapshotId'),
          ),
        );
      });
    });

    group('when restoring a snapshot', () {
      setUpAll(() {
        when(
          () => client.database.restoreFromSnapshot(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            snapshotId: any(named: 'snapshotId'),
          ),
        ).thenAnswer((final _) async {});
      });

      tearDownAll(() {
        reset(client.database);
      });
      tearDown(() {
        clearInteractions(client.database);
      });

      test('then restores with --yes and reports success', () async {
        await cli.run([
          'db',
          'backup',
          'restore',
          'snap-1',
          '--project',
          projectId,
          '--yes',
        ]);

        verify(
          () => client.database.restoreFromSnapshot(
            cloudCapsuleId: projectId,
            snapshotId: 'snap-1',
          ),
        ).called(1);
      });

      test('then does not restore when the user declines', () async {
        logger.answerNextConfirmWith(false);
        final result = cli.run([
          'db',
          'backup',
          'restore',
          'snap-1',
          '--project',
          projectId,
        ]);

        await expectLater(result, throwsA(isA<ExitException>()));
        verifyNever(
          () => client.database.restoreFromSnapshot(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            snapshotId: any(named: 'snapshotId'),
          ),
        );
      });
    });

    group('when setting a schedule', () {
      setUpAll(() {
        when(
          () => client.database.setBackupSchedule(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            frequency: any(named: 'frequency'),
            day: any(named: 'day'),
            hour: any(named: 'hour'),
            retention: any(named: 'retention'),
          ),
        ).thenAnswer((final _) async {});
      });

      tearDownAll(() {
        reset(client.database);
      });
      tearDown(() {
        clearInteractions(client.database);
      });

      test('then a daily schedule defaults hour to 0 and omits day', () async {
        await cli.run([
          'db',
          'schedule',
          'set',
          '--project',
          projectId,
          '--frequency',
          'daily',
        ]);

        verify(
          () => client.database.setBackupSchedule(
            cloudCapsuleId: projectId,
            frequency: BackupFrequency.daily,
            day: null,
            hour: 0,
            retention: null,
          ),
        ).called(1);
      });

      test('then a weekly schedule defaults day to 1', () async {
        await cli.run([
          'db',
          'schedule',
          'set',
          '--project',
          projectId,
          '--frequency',
          'weekly',
          '--hour',
          '3',
        ]);

        verify(
          () => client.database.setBackupSchedule(
            cloudCapsuleId: projectId,
            frequency: BackupFrequency.weekly,
            day: 1,
            hour: 3,
            retention: null,
          ),
        ).called(1);
      });

      test('then a weekly schedule rejects a day outside 1-7', () async {
        final result = cli.run([
          'db',
          'schedule',
          'set',
          '--project',
          projectId,
          '--frequency',
          'weekly',
          '--day',
          '8',
        ]);

        await expectLater(result, throwsA(isA<ExitException>()));
        expect(
          logger.errorCalls.any(
            (final c) => c.message.contains(
              'The --day value must be between 1 and 7 for a weekly schedule.',
            ),
          ),
          isTrue,
        );
        verifyNever(
          () => client.database.setBackupSchedule(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            frequency: any(named: 'frequency'),
            day: any(named: 'day'),
            hour: any(named: 'hour'),
            retention: any(named: 'retention'),
          ),
        );
      });
    });

    group('when showing a schedule', () {
      group('and a schedule exists', () {
        setUpAll(() {
          when(
            () => client.database.getBackupSchedule(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer(
            (final _) async => BackupSchedule(
              frequency: BackupFrequency.weekly,
              day: 2,
              hour: 4,
              retention: const Duration(days: 30),
            ),
          );
        });

        tearDownAll(() {
          reset(client.database);
        });

        test('then outputs the schedule details', () async {
          await cli.run(['db', 'schedule', 'show', '--project', projectId]);

          expect(
            logger.lineCalls.any((final c) => c.line.contains('weekly')),
            isTrue,
          );
          expect(
            logger.lineCalls.any((final c) => c.line.contains('30 days')),
            isTrue,
          );
        });
      });

      group('and no schedule exists', () {
        setUpAll(() {
          when(
            () => client.database.getBackupSchedule(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((final _) async => null);
        });

        tearDownAll(() {
          reset(client.database);
        });

        test('then informs the user no schedule is configured', () async {
          await cli.run(['db', 'schedule', 'show', '--project', projectId]);

          expect(
            logger.infoCalls.any(
              (final c) => c.message.contains('No backup schedule'),
            ),
            isTrue,
          );
        });
      });
    });

    group('when unsetting a schedule', () {
      setUpAll(() {
        when(
          () => client.database.setBackupSchedule(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            frequency: any(named: 'frequency'),
            day: any(named: 'day'),
            hour: any(named: 'hour'),
            retention: any(named: 'retention'),
          ),
        ).thenAnswer((final _) async {});
      });

      tearDownAll(() {
        reset(client.database);
      });
      tearDown(() {
        clearInteractions(client.database);
      });

      test('then disables the schedule with a null frequency', () async {
        await cli.run(['db', 'schedule', 'unset', '--project', projectId]);

        verify(
          () => client.database.setBackupSchedule(
            cloudCapsuleId: projectId,
            frequency: null,
            day: null,
            hour: null,
            retention: null,
          ),
        ).called(1);
        expect(logger.successCalls, isNotEmpty);
      });
    });

    group('when the plan does not include backups', () {
      setUpAll(() {
        when(
          () => client.database.createSnapshot(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            name: any(named: 'name'),
            expiresAt: any(named: 'expiresAt'),
          ),
        ).thenThrow(
          ProcurementDeniedException(
            message:
                "Database backup is not available for this project's plan.",
            reason: ProcurementDeniedReason.productNotAvailable,
          ),
        );
      });

      tearDownAll(() {
        reset(client.database);
      });

      test('then nudges the user to upgrade to the Growth plan', () async {
        final result = cli.run([
          'db',
          'backup',
          'create',
          '--project',
          projectId,
        ]);

        await expectLater(result, throwsA(isA<ExitException>()));
        expect(logger.errorCalls, isNotEmpty);
        expect(logger.errorCalls.last.hint, contains('Growth plan'));
      });
    });
  });
}

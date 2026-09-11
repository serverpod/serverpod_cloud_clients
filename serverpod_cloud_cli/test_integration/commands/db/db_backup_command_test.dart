import 'dart:convert';

import 'package:cli_tools/cli_tools.dart';
import 'package:config/config.dart' show UsageException;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/db/db_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (globalCfg) => client,
    ),
  );

  tearDown(() async {
    logger.clear();
  });
  const projectId = 'projectId';

  void stubPlanType(final PlanType planType) {
    when(
      () => client.plans.getSubscriptionInfoOfProject(
        cloudProjectId: any(named: 'cloudProjectId'),
      ),
    ).thenAnswer(
      (_) async => SubscriptionInfoBuilder().withPlanType(planType).build(),
    );
  }

  DatabaseSnapshot snapshot({
    String id = 'snap-1',
    String name = 'nightly',
    bool manual = true,
    DateTime? expiresAt,
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
        ).thenAnswer((_) async => snapshot());
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
          logger.successCalls.single,
          equalsSuccessCall(
            message: 'Snapshot "snap-1" created.',
            newParagraph: true,
          ),
        );
        expect(logger.lineCalls.any((c) => c.line.contains('snap-1')), isTrue);
      });

      test('then emits a JSON object with the snapshot', () async {
        await cli.run([
          'db',
          'backup',
          'create',
          '--project',
          projectId,
          '--format',
          'json',
        ]);

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, hasLength(1));
        final payload = jsonDecode(logger.rawCalls.single.content) as Map;
        expect(payload['id'], 'snap-1');
        expect(payload['name'], 'nightly');
        expect(payload['manual'], isTrue);
      });

      test('then emits a YAML object with the snapshot', () async {
        await cli.run([
          'db',
          'backup',
          'create',
          '--project',
          projectId,
          '--format',
          'yaml',
        ]);

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, hasLength(1));
        final payload = yamlDecode(logger.rawCalls.single.content) as Map;
        expect(payload['id'], 'snap-1');
        expect(payload['name'], 'nightly');
        expect(payload['manual'], isTrue);
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
            (_) async => [
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

          expect(logger.lineCalls.any((c) => c.line.contains('Name')), isTrue);
          expect(
            logger.lineCalls.any((c) => c.line.contains('snap-1')),
            isTrue,
          );
          expect(
            logger.lineCalls.any((c) => c.line.contains('snap-2')),
            isTrue,
          );
        });

        test('then --format json emits an array of the snapshots', () async {
          await cli.run([
            'db',
            'backup',
            'list',
            '--project',
            projectId,
            '--format',
            'json',
          ]);

          final decoded = jsonDecode(logger.rawCalls.single.content) as List;
          expect(decoded, hasLength(2));
          expect((decoded.first as Map)['id'], 'snap-1');
          expect(logger.lineCalls, isEmpty);
        });

        test('then --format yaml emits an array of the snapshots', () async {
          await cli.run([
            'db',
            'backup',
            'list',
            '--project',
            projectId,
            '--format',
            'yaml',
          ]);

          final decoded = yamlDecode(logger.rawCalls.single.content) as List;
          expect(decoded, hasLength(2));
          expect((decoded.first as Map)['id'], 'snap-1');
          expect(logger.lineCalls, isEmpty);
        });
      });

      group('and no snapshots exist on the growth plan', () {
        setUpAll(() {
          when(
            () => client.database.listSnapshots(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((_) async => []);
          stubPlanType(PlanType.growth);
        });

        tearDownAll(() {
          reset(client.database);
          reset(client.plans);
        });

        test('then informs the user and suggests creating one', () async {
          await cli.run(['db', 'backup', 'list', '--project', projectId]);

          expect(
            logger.infoCalls.any(
              (c) => c.message.contains('No snapshots found'),
            ),
            isTrue,
          );
          expect(
            logger.terminalCommandCalls.any(
              (c) => c.command.contains('scloud db backup create'),
            ),
            isTrue,
          );
        });

        test('then --format json emits an empty array', () async {
          await cli.run([
            'db',
            'backup',
            'list',
            '--project',
            projectId,
            '--format',
            'json',
          ]);

          expect(jsonDecode(logger.rawCalls.single.content), isEmpty);
          expect(logger.infoCalls, isEmpty);
        });
      });

      group('and no snapshots exist on the starter plan', () {
        setUpAll(() {
          when(
            () => client.database.listSnapshots(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((_) async => []);
          stubPlanType(PlanType.starter);
        });

        tearDownAll(() {
          reset(client.database);
          reset(client.plans);
        });

        test('then points the user at the plan page instead', () async {
          await cli.run(['db', 'backup', 'list', '--project', projectId]);

          expect(
            logger.infoCalls.any(
              (c) => c.message.contains(
                'Database backups are available on the Growth plan.',
              ),
            ),
            isTrue,
          );
          expect(
            logger.infoCalls.any(
              (c) =>
                  c.message.contains('/project/$projectId/plan-and-settings'),
            ),
            isTrue,
          );
          expect(logger.terminalCommandCalls, isEmpty);
        });

        test('then does not report that no snapshots were found', () async {
          await cli.run(['db', 'backup', 'list', '--project', projectId]);

          expect(
            logger.infoCalls.any(
              (c) => c.message.contains('No snapshots found'),
            ),
            isFalse,
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
        ).thenAnswer((_) async {});
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
        ).thenAnswer((_) async {});
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
        expect(
          logger.successCalls.single,
          equalsSuccessCall(message: 'Database restored.', newParagraph: true),
        );
      });

      test('then emits a JSON object with the restore result', () async {
        await cli.run([
          'db',
          'backup',
          'restore',
          'snap-1',
          '--project',
          projectId,
          '--yes',
          '--format',
          'json',
        ]);

        expect(logger.lineCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'projectId': projectId,
          'snapshotId': 'snap-1',
        });
      });

      test('then emits a YAML object with the restore result', () async {
        await cli.run([
          'db',
          'backup',
          'restore',
          'snap-1',
          '--project',
          projectId,
          '--yes',
          '--format',
          'yaml',
        ]);

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as Map;
        expect(payload['projectId'], projectId);
        expect(payload['snapshotId'], 'snap-1');
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
        ).thenAnswer((_) async {});
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

        await expectLater(
          result,
          throwsA(
            isA<UsageException>().having(
              (e) => e.message,
              'message',
              'The --day value must be between 1 and 7 for a weekly schedule.',
            ),
          ),
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
            (_) async => BackupSchedule(
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
            logger.lineCalls.any((c) => c.line.contains('weekly')),
            isTrue,
          );
          expect(
            logger.lineCalls.any((c) => c.line.contains('30 days')),
            isTrue,
          );
        });

        test('then --format json emits the project id and schedule', () async {
          await cli.run([
            'db',
            'schedule',
            'show',
            '--project',
            projectId,
            '--format',
            'json',
          ]);

          final decoded =
              jsonDecode(logger.rawCalls.single.content)
                  as Map<String, Object?>;
          expect(decoded.keys, unorderedEquals(['projectId', 'schedule']));
          expect(decoded['projectId'], projectId);
          expect((decoded['schedule'] as Map)['frequency'], 'weekly');
          expect(logger.lineCalls, isEmpty);
        });

        test('then --format yaml emits the project id and schedule', () async {
          await cli.run([
            'db',
            'schedule',
            'show',
            '--project',
            projectId,
            '--format',
            'yaml',
          ]);

          final decoded = yamlDecode(logger.rawCalls.single.content) as Map;
          expect(decoded.keys, unorderedEquals(['projectId', 'schedule']));
          expect(decoded['projectId'], projectId);
          expect(logger.lineCalls, isEmpty);
        });
      });

      group('and no schedule exists on the growth plan', () {
        setUpAll(() {
          when(
            () => client.database.getBackupSchedule(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((_) async => null);
          stubPlanType(PlanType.growth);
        });

        tearDownAll(() {
          reset(client.database);
          reset(client.plans);
        });

        test('then informs the user no schedule is configured', () async {
          await cli.run(['db', 'schedule', 'show', '--project', projectId]);

          expect(
            logger.infoCalls.any(
              (c) => c.message.contains('No backup schedule'),
            ),
            isTrue,
          );
          expect(
            logger.terminalCommandCalls.any(
              (c) => c.command.contains('scloud db schedule set'),
            ),
            isTrue,
          );
        });

        test('then --format json emits a null schedule', () async {
          await cli.run([
            'db',
            'schedule',
            'show',
            '--project',
            projectId,
            '--format',
            'json',
          ]);

          final decoded =
              jsonDecode(logger.rawCalls.single.content)
                  as Map<String, Object?>;
          expect(decoded.keys, unorderedEquals(['projectId', 'schedule']));
          expect(decoded['schedule'], isNull);
          expect(logger.infoCalls, isEmpty);
        });
      });

      group('and no schedule exists on the starter plan', () {
        setUpAll(() {
          when(
            () => client.database.getBackupSchedule(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            ),
          ).thenAnswer((_) async => null);
          stubPlanType(PlanType.starter);
        });

        tearDownAll(() {
          reset(client.database);
          reset(client.plans);
        });

        test('then points the user at the plan page instead', () async {
          await cli.run(['db', 'schedule', 'show', '--project', projectId]);

          expect(
            logger.infoCalls.any(
              (c) => c.message.contains(
                'Database backups are available on the Growth plan.',
              ),
            ),
            isTrue,
          );
          expect(
            logger.infoCalls.any(
              (c) =>
                  c.message.contains('/project/$projectId/plan-and-settings'),
            ),
            isTrue,
          );
          expect(logger.terminalCommandCalls, isEmpty);
        });

        test('then does not report that no schedule is configured', () async {
          await cli.run(['db', 'schedule', 'show', '--project', projectId]);

          expect(
            logger.infoCalls.any(
              (c) => c.message.contains('No backup schedule'),
            ),
            isFalse,
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
        ).thenAnswer((_) async {});
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

      test('then links to the project plan page', () async {
        final result = cli.run([
          'db',
          'backup',
          'create',
          '--project',
          projectId,
        ]);

        await expectLater(result, throwsA(isA<ExitException>()));
        expect(
          logger.errorCalls.last.hint,
          contains('/project/$projectId/plan-and-settings'),
        );
      });
    });
  });
}

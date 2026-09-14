import 'dart:async';

import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/database_scaling/admin_database_scaling_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

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
    adminUserMode: true,
  );

  tearDown(() async {
    logger.clear();
    reset(client.adminDatabaseScaling);
  });

  test('Given admin reconcile-database-scaling command when instantiated '
      'then requires login', () {
    expect(
      AdminReconcileDatabaseScalingCommand(logger: logger).requireLogin,
      isTrue,
    );
  });

  group('Given authenticated', () {
    group('when executing admin reconcile-database-scaling', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminDatabaseScaling.reconcileComputeScaling(
            dryRun: any(named: 'dryRun'),
            cloudCapsuleIds: any(named: 'cloudCapsuleIds'),
          ),
        ).thenAnswer((final _) async {});

        commandResult = cli.run(['admin', 'reconcile-database-scaling']);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test(
        'then the pass is requested as a dry run over all databases',
        () async {
          await commandResult.catchError((final _) {});

          verify(
            () => client.adminDatabaseScaling.reconcileComputeScaling(
              dryRun: true,
              cloudCapsuleIds: null,
            ),
          ).called(1);
        },
      );

      test('then logs that nothing will be changed', () async {
        await commandResult.catchError((final _) {});

        expect(
          logger.successCalls.single.message,
          contains('dry run over all databases'),
        );
      });
    });

    group('when executing admin reconcile-database-scaling with --apply', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminDatabaseScaling.reconcileComputeScaling(
            dryRun: any(named: 'dryRun'),
            cloudCapsuleIds: any(named: 'cloudCapsuleIds'),
          ),
        ).thenAnswer((final _) async {});

        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'admin',
          'reconcile-database-scaling',
          '--apply',
        ]);
      });

      test('then the pass is requested as an applying run', () async {
        await commandResult.catchError((final _) {});

        verify(
          () => client.adminDatabaseScaling.reconcileComputeScaling(
            dryRun: false,
            cloudCapsuleIds: null,
          ),
        ).called(1);
      });

      test('then logs that compute endpoints are restarted', () async {
        await commandResult.catchError((final _) {});

        expect(logger.successCalls.single.followUp, contains('restarted'));
      });
    });

    group(
      'when executing admin reconcile-database-scaling for two projects',
      () {
        late Future commandResult;

        setUp(() async {
          when(
            () => client.adminDatabaseScaling.reconcileComputeScaling(
              dryRun: any(named: 'dryRun'),
              cloudCapsuleIds: any(named: 'cloudCapsuleIds'),
            ),
          ).thenAnswer((final _) async {});

          commandResult = cli.run([
            'admin',
            'reconcile-database-scaling',
            '--project-id',
            'project-a,project-b',
          ]);
        });

        test('then the pass is restricted to those projects', () async {
          await commandResult.catchError((final _) {});

          verify(
            () => client.adminDatabaseScaling.reconcileComputeScaling(
              dryRun: true,
              cloudCapsuleIds: ['project-a', 'project-b'],
            ),
          ).called(1);
        });

        test('then logs the restricted scope', () async {
          await commandResult.catchError((final _) {});

          expect(logger.successCalls.single.message, contains('2 project(s)'));
        });
      },
    );

    group('when executing admin reconcile-database-scaling with --apply and '
        'declining the prompt', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminDatabaseScaling.reconcileComputeScaling(
            dryRun: any(named: 'dryRun'),
            cloudCapsuleIds: any(named: 'cloudCapsuleIds'),
          ),
        ).thenAnswer((final _) async {});

        logger.answerNextConfirmWith(false);

        commandResult = cli.run([
          'admin',
          'reconcile-database-scaling',
          '--apply',
        ]);
      });

      test('then throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the pass is never started', () async {
        await commandResult.catchError((final _) {});

        verifyNever(
          () => client.adminDatabaseScaling.reconcileComputeScaling(
            dryRun: any(named: 'dryRun'),
            cloudCapsuleIds: any(named: 'cloudCapsuleIds'),
          ),
        );
      });
    });

    group('when the reconciliation request fails', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminDatabaseScaling.reconcileComputeScaling(
            dryRun: any(named: 'dryRun'),
            cloudCapsuleIds: any(named: 'cloudCapsuleIds'),
          ),
        ).thenThrow(Exception('API Error'));

        commandResult = cli.run(['admin', 'reconcile-database-scaling']);
      });

      test('then throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error message', () async {
        await commandResult.catchError((final _) {});

        expect(
          logger.errorCalls.first.message,
          equals('Failed to start the database scaling reconciliation'),
        );
      });
    });
  });
}

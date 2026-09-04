import 'dart:async';
import 'dart:convert';

import 'package:config/config.dart' show UsageException;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';

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
    adminUserMode: true,
  );

  tearDown(() async {
    logger.clear();
    reset(client.bucket);
  });

  const projectId = 'projectId';

  void stubDeleteBucket() {
    when(
      () => client.bucket.deleteBucket(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        storageId: any(named: 'storageId'),
      ),
    ).thenAnswer((_) async {});
  }

  void stubDeleteBucketThrows(final Object exception) {
    when(
      () => client.bucket.deleteBucket(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        storageId: any(named: 'storageId'),
      ),
    ).thenThrow(exception);
  }

  test(
    'Given storage delete command when instantiated then requires login',
    () {
      expect(CloudStorageDeleteCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given a storage to delete', () {
    setUp(() {
      stubDeleteBucket();
    });

    group('when declining the confirmation prompt', () {
      late Future commandResult;

      setUp(() async {
        logger.answerNextConfirmWith(false);
        commandResult = cli.run([
          'storage',
          'delete',
          'user-uploads',
          '-p',
          projectId,
        ]);
      });

      test('then throws UserAbortException', () async {
        await expectLater(commandResult, throwsA(isA<UserAbortException>()));
      });

      test('then the storage is not deleted', () async {
        try {
          await commandResult;
        } catch (_) {}

        verifyNever(
          () => client.bucket.deleteBucket(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            storageId: any(named: 'storageId'),
          ),
        );
      });
    });

    group('when accepting the confirmation prompt', () {
      late Future commandResult;

      setUp(() async {
        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'storage',
          'delete',
          'user-uploads',
          '-p',
          projectId,
        ]);
      });

      test('then warns that every file is deleted', () async {
        await commandResult;

        expect(
          logger.confirmCalls.single.message,
          contains('every file in it'),
        );
      });

      test('then deletes the storage', () async {
        await commandResult;

        verify(
          () => client.bucket.deleteBucket(
            cloudCapsuleId: projectId,
            storageId: 'user-uploads',
          ),
        ).called(1);
      });

      test('then logs the success message', () async {
        await commandResult;

        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message: 'Successfully deleted storage "user-uploads".',
          ),
        );
      });
    });

    group('when passing --yes', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'delete',
          'user-uploads',
          '-p',
          projectId,
          '--yes',
        ]);
      });

      test('then does not prompt for confirmation', () async {
        await commandResult;

        expect(logger.confirmCalls, isEmpty);
      });

      test('then logs the success message', () async {
        await commandResult;

        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message: 'Successfully deleted storage "user-uploads".',
          ),
        );
      });
    });

    group('when using --format json without --yes', () {
      test('then throws a UsageException', () async {
        await expectLater(
          cli.run([
            'storage',
            'delete',
            'user-uploads',
            '-p',
            projectId,
            '--format',
            'json',
          ]),
          throwsA(
            isA<UsageException>().having(
              (final e) => e.message,
              'message',
              contains('Interactive UI is not supported'),
            ),
          ),
        );
      });
    });

    group('when using --format json with --yes', () {
      test('then emits the deleted storage id as JSON', () async {
        await cli.run([
          'storage',
          'delete',
          'user-uploads',
          '-p',
          projectId,
          '--yes',
          '--format',
          'json',
        ]);

        expect(logger.lineCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'storageId': 'user-uploads',
        });
      });
    });
  });

  group('Given a storage that does not exist', () {
    late Future commandResult;

    setUp(() async {
      stubDeleteBucketThrows(NotFoundException(message: 'no such storage'));

      commandResult = cli.run([
        'storage',
        'delete',
        'user-uploads',
        '-p',
        projectId,
        '--yes',
      ]);
    });

    test('then throws exception', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then logs the storage not found error with a hint', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(
        logger.errorCalls.single,
        equalsErrorCall(
          message:
              'Storage "user-uploads" was not found in project "projectId".',
          hint: 'Run "scloud storage list" to see the storages of the project.',
        ),
      );
    });
  });
}

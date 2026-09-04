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
    reset(client.bucketObjects);
  });

  const projectId = 'projectId';
  const storageId = 'public';
  const path = 'docs/report.pdf';

  void stubDeleteFile() {
    when(
      () => client.bucketObjects.deleteFile(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        storageId: any(named: 'storageId'),
        path: any(named: 'path'),
      ),
    ).thenAnswer((_) async {});
  }

  test(
    'Given storage file delete command when instantiated then requires login',
    () {
      expect(
        CloudStorageFileDeleteCommand(logger: logger).requireLogin,
        isTrue,
      );
    },
  );

  group('Given a file to delete', () {
    setUp(() {
      stubDeleteFile();
    });

    group('when declining the confirmation prompt', () {
      late Future commandResult;

      setUp(() async {
        logger.answerNextConfirmWith(false);
        commandResult = cli.run([
          'storage',
          'file',
          'delete',
          storageId,
          path,
          '-p',
          projectId,
        ]);
      });

      test('then throws UserAbortException', () async {
        await expectLater(commandResult, throwsA(isA<UserAbortException>()));
      });

      test('then the file is not deleted', () async {
        try {
          await commandResult;
        } catch (_) {}

        verifyNever(
          () => client.bucketObjects.deleteFile(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            storageId: any(named: 'storageId'),
            path: any(named: 'path'),
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
          'file',
          'delete',
          storageId,
          path,
          '-p',
          projectId,
        ]);
      });

      test('then the confirmation names the file and the storage', () async {
        await commandResult;

        expect(
          logger.confirmCalls.single.message,
          'Delete file "docs/report.pdf" from storage "public"?',
        );
      });

      test('then the file is deleted', () async {
        await commandResult;

        verify(
          () => client.bucketObjects.deleteFile(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: path,
          ),
        ).called(1);
      });

      test('then logs the success message', () async {
        await commandResult;

        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message:
                'Successfully deleted file "docs/report.pdf" '
                'from storage "public".',
          ),
        );
      });
    });

    group('when passing --yes', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'file',
          'delete',
          storageId,
          path,
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

        expect(logger.successCalls, hasLength(1));
      });
    });

    group('when using --format json without --yes', () {
      test('then throws a UsageException', () async {
        await expectLater(
          cli.run([
            'storage',
            'file',
            'delete',
            storageId,
            path,
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
      test('then emits the deleted file as JSON', () async {
        await cli.run([
          'storage',
          'file',
          'delete',
          storageId,
          path,
          '-p',
          projectId,
          '--yes',
          '--format',
          'json',
        ]);

        expect(logger.lineCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'storageId': storageId,
          'path': path,
        });
      });
    });
  });

  group('Given a storage that does not exist', () {
    late Future commandResult;

    setUp(() async {
      when(
        () => client.bucketObjects.deleteFile(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          storageId: any(named: 'storageId'),
          path: any(named: 'path'),
        ),
      ).thenThrow(NotFoundException(message: 'no such storage'));

      commandResult = cli.run([
        'storage',
        'file',
        'delete',
        storageId,
        path,
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
          message: 'Storage "public" was not found in project "projectId".',
          hint: 'Run "scloud storage list" to see the storages of the project.',
        ),
      );
    });
  });
}

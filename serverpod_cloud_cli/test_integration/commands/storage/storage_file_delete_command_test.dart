import 'dart:async';
import 'dart:convert';

import 'package:config/config.dart' show UsageException;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
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
    adminUserMode: true,
  );

  tearDown(() async {
    logger.clear();
    reset(client.bucketObjects);
  });

  const projectId = 'projectId';
  const storageId = 'public';
  const path = 'docs/report.pdf';

  void stubListFiles(final List<BucketFile> files) {
    when(
      () => client.bucketObjects.listFiles(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        storageId: any(named: 'storageId'),
        prefix: any(named: 'prefix'),
        pageToken: any(named: 'pageToken'),
      ),
    ).thenAnswer((_) async => BucketFileListing(files: files));
  }

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

  group('Given a storage holding the file', () {
    setUp(() {
      stubListFiles([
        BucketFileBuilder().withName(path).withSizeBytes(1500).build(),
        BucketFileBuilder().withName('$path.bak').build(),
      ]);
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

      test('then the listing is fetched for the path', () async {
        await commandResult;

        verify(
          () => client.bucketObjects.listFiles(
            cloudCapsuleId: projectId,
            storageId: storageId,
            prefix: path,
            pageToken: null,
          ),
        ).called(1);
      });

      test('then the confirmation names the file and the storage', () async {
        await commandResult;

        expect(
          logger.confirmCalls.single.message,
          'Delete file "docs/report.pdf" from storage "public"?',
        );
      });

      test('then only the file is deleted', () async {
        await commandResult;

        verify(
          () => client.bucketObjects.deleteFile(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: path,
          ),
        ).called(1);
        verifyNever(
          () => client.bucketObjects.deleteFile(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            storageId: any(named: 'storageId'),
            path: '$path.bak',
          ),
        );
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
          'fileCount': 1,
          'sizeBytes': 1500,
          'files': [
            {'path': path, 'sizeBytes': 1500},
          ],
        });
      });
    });
  });

  group('Given a storage holding a folder', () {
    setUp(() {
      stubListFiles([
        BucketFileBuilder().withName('avatars/u1.png').withSizeBytes(4).build(),
        BucketFileBuilder()
            .withName('avatars/sub/u2.png')
            .withSizeBytes(6)
            .build(),
        BucketFileBuilder().withName('avatars.png').build(),
      ]);
      stubDeleteFile();
    });

    group('when deleting the folder and accepting the confirmation', () {
      late Future commandResult;

      setUp(() async {
        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'storage',
          'file',
          'delete',
          storageId,
          'avatars',
          '-p',
          projectId,
        ]);
      });

      test('then the confirmation lists every file under it', () async {
        await commandResult;

        final message = logger.confirmCalls.single.message;
        expect(
          message,
          contains(
            'The folder "avatars/" in storage "public" contains 2 files '
            '(10 B):',
          ),
        );
        expect(message, contains('avatars/sub/u2.png'));
        expect(message, contains('avatars/u1.png'));
        expect(message, isNot(contains('avatars.png')));
        expect(message, contains('Delete them? This cannot be undone.'));
      });

      test('then every file under the folder is deleted', () async {
        await commandResult;

        verify(
          () => client.bucketObjects.deleteFile(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: 'avatars/u1.png',
          ),
        ).called(1);
        verify(
          () => client.bucketObjects.deleteFile(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: 'avatars/sub/u2.png',
          ),
        ).called(1);
      });

      test('then the file outside the folder is kept', () async {
        await commandResult;

        verifyNever(
          () => client.bucketObjects.deleteFile(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            storageId: any(named: 'storageId'),
            path: 'avatars.png',
          ),
        );
      });

      test('then logs how many files were deleted', () async {
        await commandResult;

        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message:
                'Successfully deleted 2 files (10 B) from folder "avatars/" '
                'in storage "public".',
          ),
        );
      });
    });

    group('when deleting the folder with a trailing slash and --yes', () {
      test('then every file under the folder is deleted', () async {
        await cli.run([
          'storage',
          'file',
          'delete',
          storageId,
          'avatars/',
          '-p',
          projectId,
          '--yes',
        ]);

        verify(
          () => client.bucketObjects.deleteFile(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: any(named: 'path'),
          ),
        ).called(2);
      });
    });

    group('when declining the confirmation', () {
      late Future commandResult;

      setUp(() async {
        logger.answerNextConfirmWith(false);
        commandResult = cli.run([
          'storage',
          'file',
          'delete',
          storageId,
          'avatars',
          '-p',
          projectId,
        ]);
      });

      test('then throws UserAbortException', () async {
        await expectLater(commandResult, throwsA(isA<UserAbortException>()));
      });

      test('then nothing is deleted', () async {
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

    group('when using --format json with --yes', () {
      test('then emits the deleted files as JSON', () async {
        await cli.run([
          'storage',
          'file',
          'delete',
          storageId,
          'avatars',
          '-p',
          projectId,
          '--yes',
          '--format',
          'json',
        ]);

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as Map;
        expect(payload['storageId'], storageId);
        expect(payload['path'], 'avatars/');
        expect(payload['fileCount'], 2);
        expect(payload['sizeBytes'], 10);
        expect(payload['files'], [
          {'path': 'avatars/sub/u2.png', 'sizeBytes': 6},
          {'path': 'avatars/u1.png', 'sizeBytes': 4},
        ]);
      });
    });

    group('when using --format yaml with --yes', () {
      test('then emits the deleted files as YAML', () async {
        await cli.run([
          'storage',
          'file',
          'delete',
          storageId,
          'avatars',
          '-p',
          projectId,
          '--yes',
          '--format',
          'yaml',
        ]);

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as Map;
        expect(payload['storageId'], storageId);
        expect(payload['path'], 'avatars/');
        expect(payload['fileCount'], 2);
        expect(payload['files'], [
          {'path': 'avatars/sub/u2.png', 'sizeBytes': 6},
          {'path': 'avatars/u1.png', 'sizeBytes': 4},
        ]);
      });
    });

    group('when a later delete fails', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.bucketObjects.deleteFile(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            storageId: any(named: 'storageId'),
            path: 'avatars/u1.png',
          ),
        ).thenThrow(ServerpodClientException('boom', 500));

        commandResult = cli.run([
          'storage',
          'file',
          'delete',
          storageId,
          'avatars',
          '-p',
          projectId,
          '--yes',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the error reports how many files were deleted', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single.message,
          allOf(
            contains('Failed to delete "avatars/u1.png".'),
            contains('1 of 2 files were deleted before the failure.'),
          ),
        );
      });
    });
  });

  group('Given a storage holding a folder with more than 20 files', () {
    setUp(() {
      stubListFiles([
        for (var i = 1; i <= 21; i++)
          BucketFileBuilder()
              .withName('logs/${i.toString().padLeft(2, '0')}.txt')
              .build(),
      ]);
      stubDeleteFile();
    });

    test('when deleting the folder then the confirmation truncates '
        'the listing', () async {
      logger.answerNextConfirmWith(true);

      await cli.run([
        'storage',
        'file',
        'delete',
        storageId,
        'logs',
        '-p',
        projectId,
      ]);

      final message = logger.confirmCalls.single.message;
      expect(message, contains('contains 21 files'));
      expect(message, contains('logs/20.txt'));
      expect(message, isNot(contains('logs/21.txt')));
      expect(message, contains('... and 1 more'));
    });
  });

  group('Given a path that matches nothing in the storage', () {
    late Future commandResult;

    setUp(() async {
      stubListFiles([]);
      stubDeleteFile();

      commandResult = cli.run([
        'storage',
        'file',
        'delete',
        storageId,
        'missing',
        '-p',
        projectId,
        '--yes',
      ]);
    });

    test('then throws exception', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then logs the nothing to delete error with a hint', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(
        logger.errorCalls.single,
        equalsErrorCall(
          message:
              'Nothing to delete: "missing" was not found in storage '
              '"public".',
          hint: 'Run "scloud storage file list public" to see the files.',
        ),
      );
    });

    test('then nothing is deleted', () async {
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

  group('Given a blank path', () {
    late Future commandResult;

    setUp(() async {
      stubListFiles([BucketFileBuilder().build()]);
      stubDeleteFile();

      commandResult = cli.run([
        'storage',
        'file',
        'delete',
        storageId,
        '/',
        '-p',
        projectId,
        '--yes',
      ]);
    });

    test('then throws exception', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then logs the blank path error with a hint', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(
        logger.errorCalls.single,
        equalsErrorCall(
          message: 'The path must name a file or a folder in the storage.',
          hint:
              'Run "scloud storage delete public" to delete '
              'the whole storage.',
        ),
      );
    });

    test('then nothing is listed or deleted', () async {
      try {
        await commandResult;
      } catch (_) {}

      verifyNever(
        () => client.bucketObjects.listFiles(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          storageId: any(named: 'storageId'),
          prefix: any(named: 'prefix'),
          pageToken: any(named: 'pageToken'),
        ),
      );
      verifyNever(
        () => client.bucketObjects.deleteFile(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          storageId: any(named: 'storageId'),
          path: any(named: 'path'),
        ),
      );
    });
  });

  group('Given a storage that does not exist', () {
    late Future commandResult;

    setUp(() async {
      when(
        () => client.bucketObjects.listFiles(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          storageId: any(named: 'storageId'),
          prefix: any(named: 'prefix'),
          pageToken: any(named: 'pageToken'),
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

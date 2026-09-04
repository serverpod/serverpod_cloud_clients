@Tags(['concurrency_one']) // due to current directory manipulation
library;

import 'dart:async';
import 'dart:convert';

import 'package:config/config.dart' show UsageException;
import 'package:dio/dio.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/push_current_dir.dart';
import '../../../test_utils/recording_file_uploader.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final uploader = RecordingFileUploader();
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (globalCfg) => client,
      fileUploaderFactory: uploader.factory,
    ),
    adminUserMode: true,
  );

  setUp(() {
    pushCurrentDirectory(d.sandbox);
  });

  tearDown(() async {
    logger.clear();
    uploader.clear();
    reset(client.bucketObjects);
  });

  const projectId = 'projectId';
  const storageId = 'public';

  void stubUploadDescription() {
    when(
      () => client.bucketObjects.createUploadDescription(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        storageId: any(named: 'storageId'),
        path: any(named: 'path'),
      ),
    ).thenAnswer((_) async => UploadDescriptionBuilder().build());
  }

  test(
    'Given storage file upload command when instantiated then requires login',
    () {
      expect(
        CloudStorageFileUploadCommand(logger: logger).requireLogin,
        isTrue,
      );
    },
  );

  group('Given a local file', () {
    setUp(() async {
      await d.file('avatar.png', 'image-bytes').create();
      stubUploadDescription();
    });

    group('when uploading without a destination path', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatar.png'),
          '-p',
          projectId,
        ]);
      });

      test('then the upload is prepared for the file name', () async {
        await commandResult;

        verify(
          () => client.bucketObjects.createUploadDescription(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: 'avatar.png',
          ),
        ).called(1);
      });

      test('then the file contents are uploaded', () async {
        await commandResult;

        expect(uploader.uploads, hasLength(1));
        expect(utf8.decode(uploader.uploads.single.data), 'image-bytes');
      });

      test('then logs the success message', () async {
        await commandResult;

        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message: 'Successfully uploaded "avatar.png" to storage "public".',
          ),
        );
      });

      test('then does not ask for confirmation', () async {
        await commandResult;

        expect(logger.confirmCalls, isEmpty);
      });
    });

    group('when uploading into a folder path', () {
      test('then the file name is appended to the folder', () async {
        await cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatar.png'),
          'avatars/',
          '-p',
          projectId,
        ]);

        verify(
          () => client.bucketObjects.createUploadDescription(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: 'avatars/avatar.png',
          ),
        ).called(1);
      });
    });

    group('when uploading under an explicit name', () {
      test('then the given path is used as is', () async {
        await cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatar.png'),
          'avatars/u1.png',
          '-p',
          projectId,
        ]);

        verify(
          () => client.bucketObjects.createUploadDescription(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: 'avatars/u1.png',
          ),
        ).called(1);
      });
    });

    group('when uploading with --format json', () {
      test('then emits the uploaded file as JSON', () async {
        await cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatar.png'),
          '-p',
          projectId,
          '--format',
          'json',
        ]);

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as Map;
        expect(payload['storageId'], storageId);
        expect(payload['fileCount'], 1);
        expect(payload['sizeBytes'], 11);
        expect(payload['files'], [
          {'path': 'avatar.png', 'sizeBytes': 11},
        ]);
      });
    });

    group('when the uploader reports a failure', () {
      late Future commandResult;

      setUp(() async {
        uploader.uploadResponse = false;

        commandResult = cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatar.png'),
          '-p',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs the upload failure', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single,
          equalsErrorCall(
            message: 'Failed to upload "avatar.png".',
            hint: 'Please try again.',
          ),
        );
      });
    });

    group('when the storage already holds a file at the path', () {
      late Future commandResult;

      setUp(() async {
        uploader.throwOnUpload = DioException(
          requestOptions: RequestOptions(),
          response: Response(requestOptions: RequestOptions(), statusCode: 412),
          type: DioExceptionType.badResponse,
        );

        commandResult = cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatar.png'),
          '-p',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs the file exists error with a delete hint', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single,
          equalsErrorCall(
            message:
                'A file already exists at "avatar.png" in storage "public".',
            hint:
                'Delete it first with "scloud storage file delete public '
                'avatar.png", then upload again.',
          ),
        );
      });
    });

    group('when the storage does not exist', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.bucketObjects.createUploadDescription(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            storageId: any(named: 'storageId'),
            path: any(named: 'path'),
          ),
        ).thenThrow(NotFoundException(message: 'no such storage'));

        commandResult = cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatar.png'),
          '-p',
          projectId,
        ]);
      });

      test('then logs the storage not found error with a hint', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single,
          equalsErrorCall(
            message: 'Storage "public" was not found in project "projectId".',
            hint:
                'Run "scloud storage list" to see the storages of the project.',
          ),
        );
      });
    });
  });

  group('Given a local directory', () {
    setUp(() async {
      await d.dir('avatars', [
        d.file('u1.png', 'one'),
        d.dir('sub', [d.file('u2.png', 'two')]),
      ]).create();
      stubUploadDescription();
    });

    group('when uploading and accepting the confirmation', () {
      late Future commandResult;

      setUp(() async {
        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatars'),
          '-p',
          projectId,
        ]);
      });

      test('then the confirmation lists every file', () async {
        await commandResult;

        final message = logger.confirmCalls.single.message;
        expect(message, contains('contains 2 files'));
        expect(message, contains('avatars/sub/u2.png'));
        expect(message, contains('avatars/u1.png'));
      });

      test('then the directory name is kept in the storage paths', () async {
        await commandResult;

        verify(
          () => client.bucketObjects.createUploadDescription(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: 'avatars/u1.png',
          ),
        ).called(1);
        verify(
          () => client.bucketObjects.createUploadDescription(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: 'avatars/sub/u2.png',
          ),
        ).called(1);
      });

      test('then every file is uploaded', () async {
        await commandResult;

        expect(
          uploader.uploads.map((final u) => utf8.decode(u.data)),
          containsAll(['one', 'two']),
        );
      });

      test('then logs how many files were uploaded', () async {
        await commandResult;

        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message: 'Successfully uploaded 2 files (6 B) to storage "public".',
          ),
        );
      });
    });

    group('when declining the confirmation', () {
      late Future commandResult;

      setUp(() async {
        logger.answerNextConfirmWith(false);
        commandResult = cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatars'),
          '-p',
          projectId,
        ]);
      });

      test('then throws UserAbortException', () async {
        await expectLater(commandResult, throwsA(isA<UserAbortException>()));
      });

      test('then nothing is uploaded', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(uploader.uploads, isEmpty);
        verifyNever(
          () => client.bucketObjects.createUploadDescription(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            storageId: any(named: 'storageId'),
            path: any(named: 'path'),
          ),
        );
      });
    });

    group('when uploading into a folder path with --yes', () {
      test('then the directory name is nested under the path', () async {
        await cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatars'),
          'docs/',
          '-p',
          projectId,
          '--yes',
        ]);

        expect(logger.confirmCalls, isEmpty);
        verify(
          () => client.bucketObjects.createUploadDescription(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: 'docs/avatars/u1.png',
          ),
        ).called(1);
      });
    });

    group('when uploading under an explicit name with --yes', () {
      test('then the given path replaces the directory name', () async {
        await cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatars'),
          'images',
          '-p',
          projectId,
          '--yes',
        ]);

        verify(
          () => client.bucketObjects.createUploadDescription(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: 'images/u1.png',
          ),
        ).called(1);
      });
    });

    group('when using --format json without --yes', () {
      test('then throws a UsageException', () async {
        await expectLater(
          cli.run([
            'storage',
            'file',
            'upload',
            storageId,
            p.join(d.sandbox, 'avatars'),
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

    group('when a later upload fails', () {
      late Future commandResult;

      setUp(() async {
        uploader.failFromIndex = 1;

        commandResult = cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatars'),
          '-p',
          projectId,
          '--yes',
        ]);
      });

      test('then the error reports how many files were uploaded', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single.message,
          allOf(
            contains('Failed to upload "avatars/u1.png".'),
            contains('1 of 2 files were uploaded before the failure.'),
          ),
        );
      });
    });

    group('when an upload fails part way through', () {
      late Future commandResult;

      setUp(() async {
        uploader.uploadResponse = false;

        commandResult = cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'avatars'),
          '-p',
          projectId,
          '--yes',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the error names the file that failed', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single.message,
          contains('Failed to upload "avatars/sub/u2.png".'),
        );
      });
    });
  });

  group('Given a local directory with a single file', () {
    setUp(() async {
      await d.dir('avatars', [d.file('u1.png', 'one')]).create();
      stubUploadDescription();
    });

    test('then the confirmation uses the singular "file"', () async {
      logger.answerNextConfirmWith(true);

      await cli.run([
        'storage',
        'file',
        'upload',
        storageId,
        p.join(d.sandbox, 'avatars'),
        '-p',
        projectId,
      ]);

      final message = logger.confirmCalls.single.message;
      expect(message, contains('contains 1 file '));
      expect(message, isNot(contains('1 files')));
    });
  });

  group('Given an empty local directory', () {
    setUp(() async {
      await d.dir('empty', []).create();
    });

    test('when uploading then reports that it holds no files', () async {
      final commandResult = cli.run([
        'storage',
        'file',
        'upload',
        storageId,
        p.join(d.sandbox, 'empty'),
        '-p',
        projectId,
        '--yes',
      ]);

      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      expect(logger.errorCalls.single.message, contains('contains no files.'));
    });
  });

  group('Given a source path that does not exist', () {
    test('when uploading then throws a UsageException', () async {
      await expectLater(
        cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'missing.png'),
          '-p',
          projectId,
        ]),
        throwsA(
          isA<UsageException>().having(
            (final e) => e.message,
            'message',
            contains('does not exist'),
          ),
        ),
      );
    });
  });
}

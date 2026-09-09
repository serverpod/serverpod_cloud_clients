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
import '../../../test_utils/project_factory.dart';
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

  group(
    'Given a local directory containing a symlink to a file outside it',
    () {
      setUp(() async {
        await d.file('secret.txt', 'secret').create();
        await d.dir('avatars', [d.file('u1.png', 'one')]).create();
        SymLinkFactory(
          withName: 'leak.txt',
          withTarget: '../secret.txt',
        ).construct(p.join(d.sandbox, 'avatars'));
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

        test('then the linked file is not uploaded', () async {
          await commandResult;

          expect(uploader.uploads.map((final u) => utf8.decode(u.data)), [
            'one',
          ]);
        });

        test('then the confirmation reports the skipped link', () async {
          await commandResult;

          final message = logger.confirmCalls.single.message;
          expect(
            message,
            contains(
              'Skipping 1 symbolic link, listed relative to the directory:',
            ),
          );
          expect(message, contains('leak.txt'));
        });

        test('then the link is left out of the file count', () async {
          await commandResult;

          expect(
            logger.confirmCalls.single.message,
            contains(
              'contains 1 '
              'file',
            ),
          );
        });
      });

      group('when uploading with --yes', () {
        setUp(() async {
          await cli.run([
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

        test('then the success message reports the skipped link', () async {
          expect(
            logger.successCalls.single,
            equalsSuccessCall(
              message:
                  'Successfully uploaded "avatars/u1.png" to storage '
                  '"public". 1 symbolic link was skipped.',
            ),
          );
        });
      });

      group('when uploading with --format json and --yes', () {
        test('then the payload lists the skipped link', () async {
          await cli.run([
            'storage',
            'file',
            'upload',
            storageId,
            p.join(d.sandbox, 'avatars'),
            '-p',
            projectId,
            '--yes',
            '--format',
            'json',
          ]);

          expect(logger.lineCalls, isEmpty);
          final payload = jsonDecode(logger.rawCalls.single.content) as Map;
          expect(payload['skippedLinks'], ['leak.txt']);
        });
      });

      group('when uploading with --follow-symlinks and --yes', () {
        setUp(() async {
          await cli.run([
            'storage',
            'file',
            'upload',
            storageId,
            p.join(d.sandbox, 'avatars'),
            '-p',
            projectId,
            '--yes',
            '--follow-symlinks',
          ]);
        });

        test('then the linked file is uploaded', () async {
          expect(
            uploader.uploads.map((final u) => utf8.decode(u.data)),
            containsAll(['one', 'secret']),
          );
        });

        test('then the link name is its storage path', () async {
          verify(
            () => client.bucketObjects.createUploadDescription(
              cloudCapsuleId: projectId,
              storageId: storageId,
              path: 'avatars/leak.txt',
            ),
          ).called(1);
        });
      });
    },
    onPlatform: {'windows': Skip('Symlinks are not supported on Windows')},
  );

  group('Given a local directory containing a symlink to a directory', () {
    setUp(() async {
      await d.dir('secrets', [d.file('id_rsa', 'private-key')]).create();
      await d.dir('avatars', [d.file('u1.png', 'one')]).create();
      SymLinkFactory(
        withName: 'linked',
        withTarget: '../secrets',
      ).construct(p.join(d.sandbox, 'avatars'));
      stubUploadDescription();
    });

    group('when uploading and accepting the confirmation', () {
      setUp(() async {
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
      });

      test('then only the real file is uploaded', () async {
        expect(uploader.uploads.map((final u) => utf8.decode(u.data)), ['one']);
      });

      test('then the confirmation does not list the linked contents', () async {
        expect(logger.confirmCalls.single.message, isNot(contains('id_rsa')));
      });
    });
  }, onPlatform: {'windows': Skip('Symlinks are not supported on Windows')});

  group('Given a symlink to a local directory', () {
    setUp(() async {
      await d.dir('avatars', [d.file('u1.png', 'one')]).create();
      SymLinkFactory(
        withName: 'linked-avatars',
        withTarget: 'avatars',
      ).construct(d.sandbox);
      stubUploadDescription();
    });

    test('when uploading then the link is refused', () async {
      final commandResult = cli.run([
        'storage',
        'file',
        'upload',
        storageId,
        p.join(d.sandbox, 'linked-avatars'),
        '-p',
        projectId,
      ]);

      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      expect(uploader.uploads, isEmpty);
    });

    test('when uploading with --follow-symlinks then it is walked', () async {
      logger.answerNextConfirmWith(true);

      await cli.run([
        'storage',
        'file',
        'upload',
        storageId,
        p.join(d.sandbox, 'linked-avatars'),
        '-p',
        projectId,
        '--follow-symlinks',
      ]);

      verify(
        () => client.bucketObjects.createUploadDescription(
          cloudCapsuleId: projectId,
          storageId: storageId,
          path: 'linked-avatars/u1.png',
        ),
      ).called(1);
    });
  }, onPlatform: {'windows': Skip('Symlinks are not supported on Windows')});

  group('Given a symlink to a local file', () {
    setUp(() async {
      await d.file('avatar.png', 'image-bytes').create();
      SymLinkFactory(
        withName: 'link.png',
        withTarget: 'avatar.png',
      ).construct(d.sandbox);
      stubUploadDescription();
    });

    group('when uploading', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'link.png'),
          '-p',
          projectId,
        ]);
      });

      test('then the link is refused', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        expect(uploader.uploads, isEmpty);
      });

      test('then the error points at --follow-symlinks', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single,
          equalsErrorCall(
            message: '"${p.join(d.sandbox, 'link.png')}" is a symbolic link.',
            hint:
                'Symbolic links are not uploaded. Pass "--follow-symlinks" '
                'to upload what it points to.',
          ),
        );
      });
    });

    group('when uploading with --follow-symlinks', () {
      setUp(() async {
        await cli.run([
          'storage',
          'file',
          'upload',
          storageId,
          p.join(d.sandbox, 'link.png'),
          '-p',
          projectId,
          '--follow-symlinks',
        ]);
      });

      test('then the content of the link target is uploaded', () async {
        expect(utf8.decode(uploader.uploads.single.data), 'image-bytes');
      });

      test('then the link name is the storage path', () async {
        verify(
          () => client.bucketObjects.createUploadDescription(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: 'link.png',
          ),
        ).called(1);
      });
    });
  }, onPlatform: {'windows': Skip('Symlinks are not supported on Windows')});

  group('Given a local directory containing a .DS_Store file', () {
    setUp(() async {
      await d.dir('avatars', [
        d.file('.DS_Store', 'junk'),
        d.file('u1.png', 'one'),
      ]).create();
      stubUploadDescription();
    });

    test('when uploading then the .DS_Store file is not uploaded', () async {
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

      expect(uploader.uploads.map((final u) => utf8.decode(u.data)), ['one']);
      expect(logger.confirmCalls.single.message, isNot(contains('.DS_Store')));
    });
  });

  group('Given a local directory containing only symlinks', () {
    setUp(() async {
      await d.file('secret.txt', 'secret').create();
      await d.dir('avatars', []).create();
      SymLinkFactory(
        withName: 'leak.txt',
        withTarget: '../secret.txt',
      ).construct(p.join(d.sandbox, 'avatars'));
    });

    test('when uploading then the error names the skipped links', () async {
      final commandResult = cli.run([
        'storage',
        'file',
        'upload',
        storageId,
        p.join(d.sandbox, 'avatars'),
        '-p',
        projectId,
        '--yes',
      ]);

      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      expect(
        logger.errorCalls.single,
        equalsErrorCall(
          message:
              'The directory "${p.join(d.sandbox, 'avatars')}" contains no '
              'files to upload, only 1 symbolic link.',
          hint:
              'Symbolic links are not uploaded. Pass "--follow-symlinks" to '
              'upload what they point to.',
        ),
      );
    });
  }, onPlatform: {'windows': Skip('Symlinks are not supported on Windows')});

  group('Given a local directory containing only a .DS_Store file', () {
    setUp(() async {
      await d.dir('avatars', [d.file('.DS_Store', 'junk')]).create();
    });

    test('when uploading then reports that it holds no files', () async {
      final commandResult = cli.run([
        'storage',
        'file',
        'upload',
        storageId,
        p.join(d.sandbox, 'avatars'),
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

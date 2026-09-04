@Tags(['concurrency_one']) // due to current directory manipulation
library;

import 'dart:async';
import 'dart:convert';

import 'package:config/config.dart' show UsageException;
import 'package:dio/dio.dart';
import 'package:ground_control_client/ground_control_client.dart';
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
import '../../../test_utils/mock_file_downloader.dart';
import '../../../test_utils/push_current_dir.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final downloader = MockFileDownloader();
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (globalCfg) => client,
      fileDownloaderFactory: downloader.factory,
    ),
    adminUserMode: true,
  );

  setUp(() {
    pushCurrentDirectory(d.sandbox);
  });

  tearDown(() async {
    logger.clear();
    downloader.clear();
    reset(client.bucketObjects);
  });

  const projectId = 'projectId';
  const storageId = 'public';
  const remotePath = 'docs/report.pdf';
  const signedUrl = 'https://signed.example/report.pdf';

  void stubDownloadUrl() {
    when(
      () => client.bucketObjects.getDownloadUrl(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        storageId: any(named: 'storageId'),
        path: any(named: 'path'),
      ),
    ).thenAnswer((_) async => signedUrl);
  }

  test('Given storage file download command when instantiated '
      'then requires login', () {
    expect(
      CloudStorageFileDownloadCommand(logger: logger).requireLogin,
      isTrue,
    );
  });

  group('Given a file in a storage', () {
    setUp(() {
      stubDownloadUrl();
      downloader.init(bytes: utf8.encode('pdf-bytes'));
    });

    group('when downloading without an output path', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'file',
          'download',
          storageId,
          remotePath,
          '-p',
          projectId,
        ]);
      });

      test('then the signed url is requested for the file', () async {
        await commandResult;

        verify(
          () => client.bucketObjects.getDownloadUrl(
            cloudCapsuleId: projectId,
            storageId: storageId,
            path: remotePath,
          ),
        ).called(1);
      });

      test('then the signed url is downloaded', () async {
        await commandResult;

        expect(downloader.downloads.single.url, Uri.parse(signedUrl));
      });

      test('then the file lands in the current directory', () async {
        await commandResult;

        await expectLater(
          d.file('report.pdf', 'pdf-bytes').validate(),
          completes,
        );
      });

      test('then logs the success message', () async {
        await commandResult;

        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message: 'Successfully downloaded "docs/report.pdf" to report.pdf.',
          ),
        );
      });

      test('then does not ask for confirmation', () async {
        await commandResult;

        expect(logger.confirmCalls, isEmpty);
      });
    });

    group('when downloading with --output naming a file', () {
      setUp(() async {
        await d.dir('out').create();
      });

      test('then the file is saved at that path', () async {
        await cli.run([
          'storage',
          'file',
          'download',
          storageId,
          remotePath,
          '-p',
          projectId,
          '--output',
          p.join('out', 'q3.pdf'),
        ]);

        await expectLater(
          d.dir('out', [d.file('q3.pdf', 'pdf-bytes')]).validate(),
          completes,
        );
      });
    });

    group('when downloading with --output naming an existing directory', () {
      setUp(() async {
        await d.dir('downloads').create();
      });

      test('then the file is saved inside it under its own name', () async {
        await cli.run([
          'storage',
          'file',
          'download',
          storageId,
          remotePath,
          '-p',
          projectId,
          '--output',
          'downloads',
        ]);

        await expectLater(
          d.dir('downloads', [d.file('report.pdf', 'pdf-bytes')]).validate(),
          completes,
        );
      });
    });

    group('when the destination directory does not exist', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'file',
          'download',
          storageId,
          remotePath,
          '-p',
          projectId,
          '--output',
          p.join('missing', 'report.pdf'),
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs the missing directory error with a hint', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single,
          equalsErrorCall(
            message: 'The directory "missing" does not exist.',
            hint:
                'Create it, or pass --output with a path inside an existing '
                'directory.',
          ),
        );
      });

      test('then nothing is downloaded', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(downloader.downloads, isEmpty);
      });
    });

    group('when the destination file already exists', () {
      setUp(() async {
        await d.file('report.pdf', 'old').create();
      });

      group('and the confirmation is declined', () {
        late Future commandResult;

        setUp(() async {
          logger.answerNextConfirmWith(false);
          commandResult = cli.run([
            'storage',
            'file',
            'download',
            storageId,
            remotePath,
            '-p',
            projectId,
          ]);
        });

        test('then throws UserAbortException', () async {
          await expectLater(commandResult, throwsA(isA<UserAbortException>()));
        });

        test('then the existing file is untouched', () async {
          try {
            await commandResult;
          } catch (_) {}

          expect(downloader.downloads, isEmpty);
          await expectLater(d.file('report.pdf', 'old').validate(), completes);
        });
      });

      group('and --yes is passed', () {
        test('then the file is overwritten without a prompt', () async {
          await cli.run([
            'storage',
            'file',
            'download',
            storageId,
            remotePath,
            '-p',
            projectId,
            '--yes',
          ]);

          expect(logger.confirmCalls, isEmpty);
          await expectLater(
            d.file('report.pdf', 'pdf-bytes').validate(),
            completes,
          );
        });
      });

      group('and --format json is used without --yes', () {
        test('then throws a UsageException', () async {
          await expectLater(
            cli.run([
              'storage',
              'file',
              'download',
              storageId,
              remotePath,
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
    });

    group('when downloading with --format json', () {
      test('then emits the downloaded file as JSON', () async {
        await cli.run([
          'storage',
          'file',
          'download',
          storageId,
          remotePath,
          '-p',
          projectId,
          '--format',
          'json',
        ]);

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as Map;
        expect(payload['storageId'], storageId);
        expect(payload['path'], remotePath);
        expect(payload['file'], 'report.pdf');
        expect(payload['sizeBytes'], 9);
      });
    });
  });

  group('Given a file that does not exist in the storage', () {
    late Future commandResult;

    setUp(() async {
      stubDownloadUrl();
      downloader.throwOnDownload = DioException(
        requestOptions: RequestOptions(),
        response: Response(requestOptions: RequestOptions(), statusCode: 404),
        type: DioExceptionType.badResponse,
      );

      commandResult = cli.run([
        'storage',
        'file',
        'download',
        storageId,
        remotePath,
        '-p',
        projectId,
      ]);
    });

    test('then throws exception', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then logs the file not found error with a hint', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(
        logger.errorCalls.single,
        equalsErrorCall(
          message: 'File "docs/report.pdf" was not found in storage "public".',
          hint: 'Run "scloud storage file list public" to see the files.',
        ),
      );
    });
  });

  group('Given a storage that does not exist', () {
    late Future commandResult;

    setUp(() async {
      when(
        () => client.bucketObjects.getDownloadUrl(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          storageId: any(named: 'storageId'),
          path: any(named: 'path'),
        ),
      ).thenThrow(NotFoundException(message: 'no such storage'));

      commandResult = cli.run([
        'storage',
        'file',
        'download',
        storageId,
        remotePath,
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
          hint: 'Run "scloud storage list" to see the storages of the project.',
        ),
      );
    });
  });
}

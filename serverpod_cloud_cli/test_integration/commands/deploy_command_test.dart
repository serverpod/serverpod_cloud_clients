import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:googleapis/storage/v1.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_mock.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';

import '../../test_utils/bucket_upload_description.dart';
import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/project_factory.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(authenticationKeyManager: AuthedKeyManagerMock());
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  final testCacheFolderPath = p.join(
    'test_integration',
    const Uuid().v4(),
  );

  final testProjectDir = p.join(
    testCacheFolderPath,
    'project',
  );

  tearDown(() {
    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    logger.clear();
  });

  test('Given deploy command when instantiated then requires login', () {
    expect(CloudDeployCommand(logger: logger).requireLogin, isTrue);
  });

  group(
      'Given unauthenticated and current directory is serverpod server directory',
      () {
    setUp(() async {
      DirectoryFactory.serverpodServerDir().construct(testProjectDir);

      when(() => client.deploy.createUploadDescription(any()))
          .thenThrow(ServerpodClientUnauthorized());
    });

    tearDown(() async {});

    group('when executing deploy', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'deploy',
          '--project',
          '123',
          '--scloud-dir',
          testCacheFolderPath,
          '--project-dir',
          testProjectDir,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message:
                  'The credentials for this session seem to no longer be valid.',
            ));
      });
    });
  });

  group('Given authenticated', () {
    group('and invalid concurrency option value when running deploy command',
        () {
      late Future cliCommandFuture;
      setUp(() async {
        cliCommandFuture = cli.run([
          'deploy',
          '--concurrency',
          'invalid',
          '--project',
          '123',
        ]);
      });

      test('then UsageException is thrown.', () async {
        await expectLater(
          cliCommandFuture,
          throwsA(isA<UsageException>().having(
            (final e) => e.message,
            'message',
            contains('Invalid value for option `concurrency` <integer>'),
          )),
        );
      });
    });

    group(
        'and current directory is not Serverpod server directory when running deploy command',
        () {
      late Future cliCommandFuture;
      setUp(() async {
        DirectoryFactory(withFiles: [
          FileFactory(
            withName: 'pubspec.yaml',
            withContents: '''
name: my_project
environment:
  sdk: '>=3.1.0 <4.0.0'
''',
          ),
        ]).construct(testProjectDir);

        cliCommandFuture = cli.run([
          'deploy',
          '--project',
          '123',
          '--scloud-dir',
          testCacheFolderPath,
          '--project-dir',
          testProjectDir,
        ]);
      });

      test('then ExitErrorException is thrown.', () async {
        await expectLater(
          cliCommandFuture,
          throwsA(isA<ErrorExitException>()),
        );
      });

      test('then error message is logged', () async {
        await cliCommandFuture.catchError((final _) {});
        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message: '`$testProjectDir` is not a Serverpod server directory.',
            hint: "Provide the project's server directory and try again.",
          ),
        );
      });
    });

    group(
        'and current directory is a Serverpod server directory '
        'with outdated sdk dependency '
        'when running deploy command', () {
      late Future cliCommandFuture;

      setUp(() async {
        DirectoryFactory(withFiles: [
          FileFactory(
            withName: 'pubspec.yaml',
            withContents: '''
name: my_project
environment:
  sdk: '>=3.1.0 <3.6.0'
dependencies:
  serverpod: ^2.3.0
''',
          ),
        ]).construct(testProjectDir);

        cliCommandFuture = cli.run([
          'deploy',
          '--project',
          '123',
          '--scloud-dir',
          testCacheFolderPath,
          '--project-dir',
          testProjectDir,
        ]);
      });

      test('then ExitErrorException is thrown.', () async {
        await expectLater(
          cliCommandFuture,
          throwsA(isA<ErrorExitException>()),
        );
      });

      test('then error message is logged', () async {
        await cliCommandFuture.catchError((final _) {});
        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first.message,
          contains('Unsupported sdk version constraint'),
        );
      });
    });

    group('and current directory is a Serverpod server directory', () {
      setUp(() async {
        DirectoryFactory.serverpodServerDir().construct(testProjectDir);
      });

      group('and 403 response for creating file upload request', () {
        setUp(() async {
          when(() => client.deploy.createUploadDescription(any()))
              .thenThrow(ServerpodClientForbidden());
        });

        group('when deploying through CLI', () {
          late Future cliCommandFuture;
          setUp(() async {
            cliCommandFuture = cli.run([
              'deploy',
              '--concurrency',
              '1',
              '--project',
              '123',
              '--project-dir',
              testProjectDir,
            ]);
          });

          test('then ExitErrorException is thrown.', () async {
            await expectLater(
              cliCommandFuture,
              throwsA(isA<ErrorExitException>()),
            );
          });

          test(
              'then failed to fetch upload description error message is logged.',
              () async {
            await cliCommandFuture.catchError((final _) {});
            expect(logger.errorCalls, isNotEmpty);
            expect(
              logger.errorCalls.first.message,
              startsWith('Failed to fetch upload description'),
            );
          });
        });
      });

      group(
          'and valid upload description response and the project directory contains directory symlink',
          () {
        setUp(() async {
          when(() => client.deploy.createUploadDescription(any())).thenAnswer(
              (final _) async => BucketUploadDescription.uploadDescription);

          const symlinkedDirectoryName = 'symlinked_directory';
          DirectoryFactory.serverpodServerDir(withSubDirectories: [
            DirectoryFactory(
              withDirectoryName: symlinkedDirectoryName,
              withFiles: [
                FileFactory(withName: 'file1.txt', withContents: 'file1'),
              ],
              withSymLinks: [
                SymLinkFactory(
                  withName: 'symlinked_directory_link',
                  withTarget: symlinkedDirectoryName,
                ),
              ],
            ),
          ]).construct(testProjectDir);
        });

        group('when deploying through CLI', () {
          late Future cliCommandFuture;
          setUp(() async {
            cliCommandFuture = cli.run([
              'deploy',
              '--concurrency',
              '1',
              '--project',
              BucketUploadDescription.projectId,
              '--project-dir',
              testProjectDir,
            ]);
          });

          test('then the upload succeeds.', () async {
            await expectLater(cliCommandFuture, completes);
          });
        });
      });

      group(
          'Given valid upload description response but project contains unresolved symlink',
          () {
        setUp(() async {
          when(() => client.deploy.createUploadDescription(any())).thenAnswer(
              (final _) async => BucketUploadDescription.uploadDescription);

          DirectoryFactory(
            withSymLinks: [
              SymLinkFactory(
                withName: 'non-resolving-symlink',
                withTarget: 'non-existing-file',
              ),
            ],
          ).construct(testProjectDir);
        });

        group('when deploying through CLI', () {
          late Future cliCommandFuture;
          setUp(() async {
            cliCommandFuture = cli.run([
              'deploy',
              '--concurrency',
              '1',
              '--project',
              BucketUploadDescription.projectId,
              '--project-dir',
              testProjectDir,
            ]);
          });

          test('then the upload succeeds.', () async {
            await expectLater(cliCommandFuture, completes);
          });
        });
      });

      group('and upload description response but with invalid url', () {
        const projectId = 'my-project-id';
        const projectUuid = '586a138e-66f3-4dcb-b2e6-bb2d38ab4a4a';
        const bucketName = 'bucket';

        /// This url is missing the `bucketName` subdomain.
        final Map<String, dynamic> descriptionContent = {
          'url':
              "http://localhost:8000/$projectId%2F$projectUuid.zip?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=test-service-bucket%40hosting-example-414217.iam.gserviceaccount.com%2F20240909%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20240909T094501Z&X-Goog-Expires=600&X-Goog-SignedHeaders=accept%3Bcontent-type%3Bhost%3Bx-goog-meta-tenant-project-id&x-goog-signature=2a3432d7e650cd7f32e4b6ddb01051390ae40084fb45f7af25cfaa891f33425d7bf64939b78b9e339b28bcf5238dfb58c67fd8e1eb8957c2df22b1b91d1f01a3ecd1ad4217a570a7e7a80e2999164ca7d920058bfdf52851341fe3c85340da14917026c8efae8f733d5d6548a149ae0558f88307bfcf23f97c2a141317d2be5cf4035488bd7b01137333250be11a174e73096674d8eaffcc7c7d2849044a3eb7669c35f7e421f99ab9557610478c96b68b29962fa1ea002cf76a09a0f302c66157844bd1a2b4b8a36378fd18f8a8dab750d955ff1866c9b20105c56b1f3ebf88c4dcf75043518c74d3d25c54673557b397ba1e31336766004c06ddf7bbbe1940\\",
          'type': 'binary',
          'httpMethod': 'PUT',
          'headers': {
            'content-type': 'application/octet-stream',
            'accept': '*/*',
            'x-goog-meta-tenant-project-id': projectId,
            'x-goog-meta-upload-id': 'upload-$projectUuid',
            'host': '$bucketName.localhost:8000',
          },
        };

        setUp(() async {
          DirectoryFactory.serverpodServerDir().construct(testProjectDir);

          when(() => client.deploy.createUploadDescription(any()))
              .thenAnswer((final _) async => jsonEncode(descriptionContent));
        });

        group('when deploying through CLI', () {
          late Future cliCommandFuture;
          setUp(() async {
            cliCommandFuture = cli.run([
              'deploy',
              '--concurrency',
              '1',
              '--project',
              projectId,
              '--project-dir',
              testProjectDir,
            ]);
          });

          test('then ExitErrorException is thrown.', () async {
            await expectLater(
              cliCommandFuture,
              throwsA(isA<ErrorExitException>()),
            );
          });

          test('then failed to upload project error message is logged.',
              () async {
            await cliCommandFuture.catchError((final _) {});
            expect(logger.errorCalls, isNotEmpty);
            expect(
              logger.errorCalls.first.message,
              startsWith('Failed to upload project'),
            );
          });
        });
      });

      group('and valid upload description response', () {
        setUp(() async {
          DirectoryFactory.serverpodServerDir().construct(testProjectDir);

          when(() => client.deploy.createUploadDescription(any())).thenAnswer(
            (final _) async => BucketUploadDescription.uploadDescription,
          );
        });

        group('when deploying through CLI', () {
          late Future cliCommandFuture;
          setUp(() async {
            cliCommandFuture = cli.run([
              'deploy',
              '--project',
              BucketUploadDescription.projectId,
              '--project-dir',
              testProjectDir,
            ]);
          });

          test(
              'then command executes successfully and logs Project uploaded successfully message.',
              () async {
            await expectLater(cliCommandFuture, completes);

            expect(logger.successCalls, isNotEmpty);
            expect(
                logger.successCalls.last,
                equalsSuccessCall(
                  message: 'Project uploaded successfully!',
                  trailingRocket: true,
                  followUp: '''

When the server has started, you can access it at:
Web:      https://${BucketUploadDescription.projectId}.serverpod.space/
API:      https://${BucketUploadDescription.projectId}.api.serverpod.space/
Insights: https://${BucketUploadDescription.projectId}.insights.serverpod.space/

See the `scloud domain` command to set up a custom domain.''',
                ));
          });

          test('then zipped project is accessible in bucket.', () async {
            await cliCommandFuture;
            final client = http.Client();
            final storage = StorageApi(
              client,
              rootUrl: 'http://localhost:8000/',
            );

            await expectLater(
              storage.objects.get(
                BucketUploadDescription.bucketName,
                BucketUploadDescription.uploadedFilePath,
              ),
              completion(
                isNotNull,
              ),
            );
          });
        });
      });
    });

    group('and valid upload description response', () {
      setUp(() async {
        DirectoryFactory.serverpodServerDir().construct(testProjectDir);

        when(() => client.deploy.createUploadDescription(any())).thenAnswer(
            (final _) async => BucketUploadDescription.uploadDescription);
      });

      group('when deploying through CLI with --dry-run', () {
        late Future cliCommandFuture;
        setUp(() async {
          cliCommandFuture = cli.run([
            'deploy',
            '--dry-run',
            '--project',
            BucketUploadDescription.projectId,
            '--project-dir',
            testProjectDir,
          ]);
        });

        test('then command completes successfully.', () async {
          await expectLater(cliCommandFuture, completes);
        });

        test('then dry run message is logged.', () async {
          await cliCommandFuture;
          expect(logger.infoCalls, isNotEmpty);
          expect(logger.infoCalls.last.message, 'Dry run, skipping upload.');
        });
      });
    });
  });
}

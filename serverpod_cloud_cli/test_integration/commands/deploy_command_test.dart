@Tags(['concurrency_one']) // due to current directory manipulation
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:yaml_codec/yaml_codec.dart';

import '../../test_utils/bucket_upload_description.dart';
import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/project_factory.dart';
import '../../test_utils/push_current_dir.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(authenticationKeyManager: AuthedKeyManagerMock());
  final mockFileUploader = MockFileUploader();
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
      fileUploaderFactory: (final _) => mockFileUploader,
    ),
  );

  setUp(() {
    mockFileUploader.init();
    logger.clear();
  });

  test('Given deploy command when instantiated then requires login', () {
    expect(CloudDeployCommand(logger: logger).requireLogin, isTrue);
  });

  group(
      'Given unauthenticated and current directory is serverpod server directory',
      () {
    setUp(() async {
      await ProjectFactory.serverpodServerDir().create();

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
          '--project-dir',
          p.join(d.sandbox, ProjectFactory.defaultDirectoryName),
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
      late String testProjectDir;
      late Future cliCommandFuture;

      setUp(() async {
        await d.dir('project', [
          d.file('pubspec.yaml', '''
name: my_project
environment:
  sdk: '>=3.1.0 <4.0.0'
'''),
        ]).create();
        testProjectDir = p.join(d.sandbox, 'project');

        cliCommandFuture = cli.run([
          'deploy',
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
      late String testProjectDir;
      late Future cliCommandFuture;

      setUp(() async {
        await d.dir('project', [
          d.file('pubspec.yaml', '''
name: my_project
environment:
  sdk: '>=3.1.0 <3.6.0'
dependencies:
  serverpod: ^2.3.0
''')
        ]).create();
        testProjectDir = p.join(d.sandbox, 'project');

        cliCommandFuture = cli.run([
          'deploy',
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
      late String testProjectDir;

      setUp(() async {
        await ProjectFactory.serverpodServerDir().create();
        testProjectDir = p.join(d.sandbox, ProjectFactory.defaultDirectoryName);
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
          DirectoryFactory(
            withSubDirectories: [
              DirectoryFactory(
                withDirectoryName: symlinkedDirectoryName,
                withFiles: [
                  FileFactory(withName: 'file1.txt', withContents: 'file1'),
                ],
              ),
            ],
            withSymLinks: [
              SymLinkFactory(
                withName: 'symlinked_directory_link',
                withTarget: symlinkedDirectoryName,
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

          test('then ExitErrorException is thrown.', () async {
            await expectLater(
              cliCommandFuture,
              throwsA(isA<ErrorExitException>()),
            );
          });

          test('then directory symlinks are unsupported message is logged.',
              () async {
            await cliCommandFuture.catchError((final _) {});
            expect(logger.errorCalls, isNotEmpty);
            expect(
              logger.errorCalls.first.message,
              startsWith(
                  'Serverpod Cloud does not support directory symlinks:'),
            );
          });
        });
      }, onPlatform: {
        'windows': Skip('Symlinks are not supported on Windows')
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

          test('then ExitErrorException is thrown.', () async {
            await expectLater(
              cliCommandFuture,
              throwsA(isA<ErrorExitException>()),
            );
          });

          test('then non-resolving symlinks message is logged.', () async {
            await cliCommandFuture.catchError((final _) {});
            expect(logger.errorCalls, isNotEmpty);
            expect(
              logger.errorCalls.first.message,
              startsWith(
                  'Serverpod Cloud does not support non-resolving symlinks:'),
            );
          });
        });
      }, onPlatform: {
        'windows': Skip('Symlinks are not supported on Windows')
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
          when(() => client.deploy.createUploadDescription(any()))
              .thenAnswer((final _) async => jsonEncode(descriptionContent));

          mockFileUploader.init(uploadResponse: false);
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
                  newParagraph: true,
                  followUp: '''
When the server has started, you can access it at:
Web:      https://${BucketUploadDescription.projectId}.serverpod.space/
API:      https://${BucketUploadDescription.projectId}.api.serverpod.space/
Insights: https://${BucketUploadDescription.projectId}.insights.serverpod.space/''',
                ));
          });

          test(
              'then command executes successfully and logs deploy command hint.',
              () async {
            await expectLater(cliCommandFuture, completes);

            expect(logger.terminalCommandCalls, isNotEmpty);
            expect(
              logger.terminalCommandCalls.last,
              equalsTerminalCommandCall(
                message: 'Set up your custom domain by running:',
                command: 'scloud domain',
                newParagraph: true,
              ),
            );
          });

          test('then zipped project is accessible in bucket.', () async {
            await cliCommandFuture;

            expect(mockFileUploader.uploadedData, isNotEmpty);
          });
        });
      });
    });

    group('and valid upload description response', () {
      late String testProjectDir;

      setUp(() async {
        await ProjectFactory.serverpodServerDir().create();
        testProjectDir = p.join(d.sandbox, ProjectFactory.defaultDirectoryName);

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

  group(
      'and a non-workspace directory structure and a valid upload description response',
      () {
    setUp(() async {
      await ProjectFactory.serverpodServerDir(
        contents: [
          d.file('scloud.yaml', '''
project:
  projectId: "my-project-id"
'''),
          d.dir('subdir', [
            d.file('subdir_file.txt', 'file_content'),
            d.dir('subsubdir', [
              d.file('subsubdir_file.txt', 'file_content'),
            ]),
          ]),
        ],
      ).create();

      when(() => client.deploy.createUploadDescription(any())).thenAnswer(
          (final _) async => BucketUploadDescription.uploadDescription);
    });

    group(
        'when deploying through CLI without explicit project dir and with --dry-run',
        () {
      late Future cliCommandFuture;
      setUp(() async {
        pushCurrentDirectory(d.sandbox);

        cliCommandFuture = cli.run([
          'deploy',
          '--dry-run',
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

  group('and a non-workspace serverpod project with a flutter dependency', () {
    setUp(() async {
      await d.dir(
        'project',
        [
          d.file('pubspec.yaml', '''
name: "project"
environment:
  sdk: ${ProjectFactory.validSdkVersion}
  flutter: ^3.29.0
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
          d.file('scloud.yaml', '''
project:
  projectId: "my-project-id"
'''),
        ],
      ).create();

      when(() => client.deploy.createUploadDescription(any())).thenAnswer(
          (final _) async => BucketUploadDescription.uploadDescription);
    });

    group('when deploying through CLI and with --dry-run', () {
      late Future cliCommandFuture;
      setUp(() async {
        pushCurrentDirectory(d.sandbox);

        cliCommandFuture = cli.run([
          'deploy',
          '--dry-run',
        ]);
      });

      test('then command throws ErrorExitException.', () async {
        await expectLater(
          cliCommandFuture,
          throwsA(isA<ErrorExitException>()),
        );
      });

      test('then an unsupported flutter dependency error message is logged.',
          () async {
        await cliCommandFuture.catchError((final _) {});

        expect(logger.errorCalls, hasLength(1));
        expect(
          logger.errorCalls.single.message,
          equals(
              'A Flutter dependency is not allowed in a server package: project'),
        );
      });
    });
  });

  group('and a valid workspace directory structure', () {
    setUp(() async {
      await d.dir('monorepo', [
        d.file('pubspec.yaml', '''
name: monorepo
environment:
  sdk: ${ProjectFactory.validSdkVersion}
  flutter: 3.29.0
workspace:
  - packages/dart_utilities
  - project/project_server
'''),
        d.dir('packages', [
          d.dir('dart_utilities', [
            d.file('pubspec.yaml', '''
name: dart_utilities
version: 1.0.0
environment:
  sdk: ${ProjectFactory.validSdkVersion}
resolution: workspace
'''),
          ]),
        ]),
        d.dir('project', [
          d.dir('project_server', [
            d.file('pubspec.yaml', '''
name: project_server
environment:
  sdk: ${ProjectFactory.validSdkVersion}
resolution: workspace
dependencies:
  serverpod: ^2.3.0
  dart_utilities: ^1.0.0
'''),
          ]),
        ]),
      ]).create();

      when(() => client.deploy.createUploadDescription(any())).thenAnswer(
          (final _) async => BucketUploadDescription.uploadDescription);
    });

    group(
        'when deploying through CLI without explicit project dir and with --dry-run',
        () {
      late Future cliCommandFuture;
      setUp(() async {
        pushCurrentDirectory(p.join(d.sandbox, 'monorepo', 'project'));

        cliCommandFuture = cli.run([
          'deploy',
          '--project',
          BucketUploadDescription.projectId,
          '--dry-run',
        ]);
      });

      test('then command completes successfully.', () async {
        await expectLater(cliCommandFuture, completes);
      });

      test('then the included packages are logged.', () async {
        await cliCommandFuture;

        expect(logger.listCalls, hasLength(1));
        expect(
          logger.listCalls.single,
          equalsListCall(
            title: 'Including workspace packages',
            items: [
              'project/project_server',
              'packages/dart_utilities',
            ],
          ),
        );
      });

      test('then .scloud/scloud_server_dir file is created.', () async {
        await cliCommandFuture;

        final descriptor = d.dir('.scloud', [
          d.file('scloud_server_dir', 'project/project_server'),
        ]);

        await expectLater(
          descriptor.validate(p.join(d.sandbox, 'monorepo')),
          completes,
        );
      });

      test('then .scloud/scloud_ws_pubspec.yaml file is created.', () async {
        await cliCommandFuture;

        final fileDescriptor = d.file('scloud_ws_pubspec.yaml', isNotEmpty);
        final descriptor = d.dir('.scloud', [
          fileDescriptor,
        ]);

        await expectLater(
          descriptor.validate(p.join(d.sandbox, 'monorepo')),
          completes,
        );

        final content = File(
          p.join(d.sandbox, 'monorepo', '.scloud', 'scloud_ws_pubspec.yaml'),
        ).readAsStringSync();
        final doc = yamlDecode(content);
        expect(doc, containsPair('name', 'monorepo'));
        expect(doc, containsPair('environment', isNot(contains('flutter'))));
        expect(
          doc,
          containsPair('environment', containsPair('sdk', isNotEmpty)),
        );
        expect(
          doc,
          containsPair(
            'workspace',
            containsAll([
              'project/project_server',
              'packages/dart_utilities',
            ]),
          ),
        );
      });
    });
  });

  group(
      'and an invalid workspace directory structure with an indirect flutter dependency',
      () {
    setUp(() async {
      await d.dir('monorepo', [
        d.file('pubspec.yaml', '''
name: monorepo
environment:
  sdk: ${ProjectFactory.validSdkVersion}
  flutter: 3.29.0
workspace:
  - packages/flutter_utilities
  - project/project_server
'''),
        d.dir('packages', [
          d.dir('flutter_utilities', [
            d.file('pubspec.yaml', '''
name: flutter_utilities
version: 1.0.0
environment:
  sdk: ${ProjectFactory.validSdkVersion}
  flutter: 3.29.0
resolution: workspace
'''),
          ]),
        ]),
        d.dir('project', [
          d.dir('project_server', [
            d.file('pubspec.yaml', '''
name: project_server
environment:
  sdk: ${ProjectFactory.validSdkVersion}
resolution: workspace
dependencies:
  serverpod: ^2.3.0
  flutter_utilities: ^1.0.0
'''),
          ]),
        ]),
      ]).create();

      when(() => client.deploy.createUploadDescription(any())).thenAnswer(
          (final _) async => BucketUploadDescription.uploadDescription);
    });

    group('when deploying through CLI and with --dry-run', () {
      late Future cliCommandFuture;
      setUp(() async {
        pushCurrentDirectory(p.join(d.sandbox, 'monorepo', 'project'));

        cliCommandFuture = cli.run([
          'deploy',
          '--project',
          BucketUploadDescription.projectId,
          '--dry-run',
        ]);
      });

      test('then command throws ErrorExitException.', () async {
        await expectLater(
          cliCommandFuture,
          throwsA(isA<ErrorExitException>()),
        );
      });

      test('then an unsupported flutter dependency error message is logged.',
          () async {
        await cliCommandFuture.catchError((final _) {});

        expect(logger.errorCalls, hasLength(1));
        expect(
          logger.errorCalls.single.message,
          equals(
              'A Flutter dependency is not allowed in a server package: flutter_utilities'),
        );
      });
    });
  });
}

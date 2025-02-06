import 'dart:async';
import 'dart:io';

import 'package:googleapis/storage/v1.dart';
import 'package:http/http.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';

import '../test_utils/command_logger_matchers.dart';
import '../test_utils/http_server_builder.dart';
import '../test_utils/project_factory.dart';
import '../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final version = Version.parse('0.0.1');
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: version,
  );

  final testCacheDirFactory = DirectoryFactory()..withPath('test_integration');

  setUp(() {
    testCacheDirFactory.construct();
  });

  tearDown(() {
    testCacheDirFactory.destruct();

    logger.clear();
  });

  test('Given deploy command when instantiated then requires login', () {
    expect(CloudDeployCommand(logger: logger).requireLogin, isTrue);
  });

  group(
      'Given unauthenticated and current directory is serverpod server directory',
      () {
    final projectDirFactory = DirectoryFactory.serverpodServerDir()
      ..withParent(testCacheDirFactory)
      ..withName('project');

    late Uri localServerAddress;
    late Completer requestCompleter;
    late HttpServer server;

    setUp(() async {
      projectDirFactory.construct();

      requestCompleter = Completer();
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheDirFactory.directory.path,
      );

      final serverBuilder = HttpServerBuilder();
      serverBuilder.withOnRequest((final request) {
        requestCompleter.complete();
        request.response.statusCode = 401;
        request.response.close();
      });

      final (startedServer, serverAddress) = await serverBuilder.build();
      localServerAddress = serverAddress;
      server = startedServer;
    });

    tearDown(() async {
      projectDirFactory.destruct();

      await server.close(force: true);
    });

    group('when executing deploy', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'deploy',
          '--project-id',
          '123',
          '--api-url',
          localServerAddress.toString(),
          '--scloud-dir',
          testCacheDirFactory.directory.path,
          '--project-dir',
          projectDirFactory.directory.path,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(requestCompleter.future, completes);
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
    setUp(() async {
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheDirFactory.directory.path,
      );
    });

    group('and invalid concurrency option value when running deploy command',
        () {
      late Future cliCommandFuture;
      setUp(() async {
        cliCommandFuture = cli.run([
          'deploy',
          '--concurrency',
          'invalid',
          '--project-id',
          '123',
          '--scloud-dir',
          testCacheDirFactory.directory.path,
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
            message:
                'Failed to parse --concurrency option, value must be an integer.',
          ),
        );
      });
    });

    group(
        'and current directory is not Serverpod server directory when running deploy command',
        () {
      final projectDirFactory = DirectoryFactory()
        ..withParent(testCacheDirFactory)
        ..withName('project')
        ..addFile(
          FileFactory(
            withName: 'pubspec.yaml',
            withContents: 'name: my_project',
          ),
        );

      late Future cliCommandFuture;

      setUp(() async {
        projectDirFactory.construct();

        cliCommandFuture = cli.run([
          'deploy',
          '--project-id',
          '123',
          '--scloud-dir',
          testCacheDirFactory.directory.path,
          '--project-dir',
          projectDirFactory.directory.path,
        ]);
      });

      tearDown(() {
        projectDirFactory.destruct();
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
            message: 'The provided project directory '
                '(either through the --project-dir flag or the current directory) '
                'is not a Serverpod server directory.',
            hint: "Provide the project's server directory and try again.",
          ),
        );
      });
    });

    group(
        'and current directory is a Serverpod server directory '
        'with outdated sdk dependency '
        'when running deploy command', () {
      final projectDirFactory = DirectoryFactory()
        ..withParent(testCacheDirFactory)
        ..withName('project')
        ..addFile(
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
        );

      late Future cliCommandFuture;

      setUp(() async {
        projectDirFactory.construct();

        cliCommandFuture = cli.run([
          'deploy',
          '--project-id',
          '123',
          '--scloud-dir',
          testCacheDirFactory.directory.path,
          '--project-dir',
          projectDirFactory.directory.path,
        ]);
      });

      tearDown(() {
        projectDirFactory.destruct();
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

    group(
        'and current directory is a Serverpod server directory '
        'with too advanced sdk dependency '
        'when running deploy command', () {
      final projectDirFactory = DirectoryFactory()
        ..withParent(testCacheDirFactory)
        ..withName('project')
        ..addFile(
          FileFactory(
            withName: 'pubspec.yaml',
            withContents: '''
name: my_project
environment:
  sdk: '>=3.8.0 <4.0.0'
dependencies:
  serverpod: ^2.3.0
''',
          ),
        );

      late Future cliCommandFuture;

      setUp(() async {
        projectDirFactory.construct();

        cliCommandFuture = cli.run([
          'deploy',
          '--project-id',
          '123',
          '--scloud-dir',
          testCacheDirFactory.directory.path,
          '--project-dir',
          projectDirFactory.directory.path,
        ]);
      });

      tearDown(() {
        projectDirFactory.destruct();
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

    group(
        'and current directory is a Serverpod server directory '
        'with outdated serverpod dependency '
        'when running deploy command', () {
      final projectDirFactory = DirectoryFactory()
        ..withParent(testCacheDirFactory)
        ..withName('project')
        ..addFile(
          FileFactory(
            withName: 'pubspec.yaml',
            withContents: '''
name: my_project
environment:
  sdk: '>=3.6.0'
dependencies:
  serverpod: ^2.2.0
''',
          ),
        );

      late Future cliCommandFuture;

      setUp(() async {
        projectDirFactory.construct();

        cliCommandFuture = cli.run([
          'deploy',
          '--project-id',
          '123',
          '--scloud-dir',
          testCacheDirFactory.directory.path,
          '--project-dir',
          projectDirFactory.directory.path,
        ]);
      });

      tearDown(() {
        projectDirFactory.destruct();
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
          contains('Unsupported serverpod version constraint'),
        );
      });
    });

    group(
        'and current directory is a Serverpod server directory '
        'with broad and compatible sdk dependency '
        'when running deploy command', () {
      final projectDirFactory = DirectoryFactory()
        ..withParent(testCacheDirFactory)
        ..withName('project')
        ..addFile(
          FileFactory(
            withName: 'pubspec.yaml',
            withContents: '''
name: my_project
environment:
  sdk: '>=3.5.0 <4.0.0'
dependencies:
  serverpod: ^2.3.0
''',
          ),
        );

      late Future cliCommandFuture;

      setUp(() async {
        projectDirFactory.construct();

        cliCommandFuture = cli.run([
          'deploy',
          '--project-id',
          '123',
          '--scloud-dir',
          testCacheDirFactory.directory.path,
          '--project-dir',
          projectDirFactory.directory.path,
        ]);
      });

      tearDown(() {
        projectDirFactory.destruct();
      });

      test('then no dependency error message is logged', () async {
        await cliCommandFuture.catchError((final _) {});
        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first.message,
          isNot(anyOf([
            contains('Unsupported sdk version constraint'),
            contains('Unsupported serverpod version constraint'),
          ])),
        );
      });
    });

    group('and current directory is a Serverpod server directory', () {
      final projectDirFactory = DirectoryFactory.serverpodServerDir()
        ..withParent(testCacheDirFactory)
        ..withName('project');

      setUp(() async {
        projectDirFactory.construct();
      });

      tearDown(() {
        projectDirFactory.destruct();
      });

      group('and 403 response for creating file upload request', () {
        late Uri localServerAddress;
        late HttpServer server;

        setUp(() async {
          final serverBuilder = HttpServerBuilder();
          serverBuilder.withOnRequest((final request) {
            request.response.statusCode = 403;
            request.response.close();
          });

          final (startedServer, serverAddress) = await serverBuilder.build();
          localServerAddress = serverAddress;
          server = startedServer;
        });

        tearDown(() {
          server.close(force: true);
        });

        group('when deploying through CLI', () {
          late Future cliCommandFuture;
          setUp(() async {
            cliCommandFuture = cli.run([
              'deploy',
              '--concurrency',
              '1',
              '--project-id',
              '123',
              '--api-url',
              localServerAddress.toString(),
              '--scloud-dir',
              testCacheDirFactory.directory.path,
              '--project-dir',
              projectDirFactory.directory.path,
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
          'Given valid upload description response but project directory contains directory symlink',
          () {
        late Uri localServerAddress;
        late HttpServer server;

        const symlinkedDirectoryName = 'symlinked_directory';
        final targetDirectoryFactory = DirectoryFactory(
          withName: symlinkedDirectoryName,
          withFiles: [
            FileFactory(withName: 'file1.txt', withContents: 'file1'),
          ],
        );
        final symlinkFactory = SymLinkFactory(
          withName: 'symlinked_directory_link',
          withTarget: symlinkedDirectoryName,
        );

        setUp(() async {
          final serverBuilder = HttpServerBuilder();
          serverBuilder.withOnRequest((final request) async {
            final response = request.response;
            response.statusCode = 200;
            response.write('"this-is-an-upload-description"');
            await response.close();
          });

          final (startedServer, serverAddress) = await serverBuilder.build();
          localServerAddress = serverAddress;
          server = startedServer;

          targetDirectoryFactory.construct(
              path: projectDirFactory.directory.path);
          symlinkFactory.construct(projectDirFactory.directory.path);
        });

        tearDown(() {
          server.close(force: true);

          targetDirectoryFactory.destruct();
        });

        group('when deploying through CLI', () {
          late Future cliCommandFuture;
          setUp(() async {
            cliCommandFuture = cli.run([
              'deploy',
              '--concurrency',
              '1',
              '--project-id',
              '123',
              '--project-dir',
              projectDirFactory.directory.path,
              '--api-url',
              localServerAddress.toString(),
              '--scloud-dir',
              testCacheDirFactory.directory.path,
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
      });

      group(
          'Given valid upload description response but project contains unresolved symlink',
          () {
        late Uri localServerAddress;
        late HttpServer server;
        final symlinkFactory = SymLinkFactory(
          withName: 'non-resolving-symlink',
          withTarget: 'non-existing-file',
        );

        setUp(() async {
          final serverBuilder = HttpServerBuilder();
          serverBuilder.withOnRequest((final request) async {
            final response = request.response;
            response.statusCode = 200;
            response.write('"this-is-an-upload-description"');
            await response.close();
          });

          final (startedServer, serverAddress) = await serverBuilder.build();
          localServerAddress = serverAddress;
          server = startedServer;

          symlinkFactory.construct(projectDirFactory.directory.path);
        });

        tearDown(() {
          server.close(force: true);
        });

        group('when deploying through CLI', () {
          late Future cliCommandFuture;
          setUp(() async {
            cliCommandFuture = cli.run([
              'deploy',
              '--concurrency',
              '1',
              '--project-id',
              '123',
              '--project-dir',
              projectDirFactory.directory.path,
              '--api-url',
              localServerAddress.toString(),
              '--scloud-dir',
              testCacheDirFactory.directory.path,
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
      });

      group('and upload description response but with invalid url', () {
        late Uri localServerAddress;
        late HttpServer server;
        const projectId = 'my-project-id';
        const projectUuid = '586a138e-66f3-4dcb-b2e6-bb2d38ab4a4a';
        const bucketName = 'bucket';

        /// This url is missing the `bucketName` subdomain.
        const uploadDescription =
            '"{\\"url\\":\\"http://localhost:8000/$projectId%2F$projectUuid.zip?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=test-service-bucket%40hosting-example-414217.iam.gserviceaccount.com%2F20240909%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20240909T094501Z&X-Goog-Expires=600&X-Goog-SignedHeaders=accept%3Bcontent-type%3Bhost%3Bx-goog-meta-tenant-project-id&x-goog-signature=2a3432d7e650cd7f32e4b6ddb01051390ae40084fb45f7af25cfaa891f33425d7bf64939b78b9e339b28bcf5238dfb58c67fd8e1eb8957c2df22b1b91d1f01a3ecd1ad4217a570a7e7a80e2999164ca7d920058bfdf52851341fe3c85340da14917026c8efae8f733d5d6548a149ae0558f88307bfcf23f97c2a141317d2be5cf4035488bd7b01137333250be11a174e73096674d8eaffcc7c7d2849044a3eb7669c35f7e421f99ab9557610478c96b68b29962fa1ea002cf76a09a0f302c66157844bd1a2b4b8a36378fd18f8a8dab750d955ff1866c9b20105c56b1f3ebf88c4dcf75043518c74d3d25c54673557b397ba1e31336766004c06ddf7bbbe1940\\",\\"type\\":\\"binary\\",\\"httpMethod\\":\\"PUT\\",\\"headers\\":{\\"content-type\\":\\"application/octet-stream\\",\\"accept\\":\\"*/*\\",\\"x-goog-meta-tenant-project-id\\":\\"$projectId\\",\\"x-goog-meta-upload-id\\":\\"upload-$projectUuid\\",\\"host\\":\\"$bucketName.localhost:8000\\"}}"';

        final projectDirFactory = DirectoryFactory.serverpodServerDir()
          ..withParent(testCacheDirFactory)
          ..withName('project2');

        setUp(() async {
          projectDirFactory.construct();

          final serverBuilder = HttpServerBuilder();
          serverBuilder.withOnRequest((final request) async {
            final response = request.response;
            response.statusCode = 200;
            response.write(uploadDescription);
            await response.close();
          });

          final (startedServer, serverAddress) = await serverBuilder.build();
          localServerAddress = serverAddress;
          server = startedServer;
        });

        tearDown(() {
          projectDirFactory.destruct();

          server.close(force: true);
        });

        group('when deploying through CLI', () {
          late Future cliCommandFuture;
          setUp(() async {
            cliCommandFuture = cli.run([
              'deploy',
              '--concurrency',
              '1',
              '--project-id',
              projectId,
              '--api-url',
              localServerAddress.toString(),
              '--scloud-dir',
              testCacheDirFactory.directory.path,
              '--project-dir',
              projectDirFactory.directory.path,
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
              startsWith('Failed to upload project:'),
            );
          });
        });
      });

      group('and valid upload description response', () {
        late Uri localServerAddress;
        late HttpServer server;
        const projectId = 'my-project-id';
        const projectUuid = '586a138e-66f3-4dcb-b2e6-bb2d38ab4a4a';
        const bucketName = 'bucket';

        const uploadDescription = '"{'
            '\\"url\\": \\"http://$bucketName.localhost:8000/$projectId%2F$projectUuid.zip?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=test-service-bucket%40hosting-example-414217.iam.gserviceaccount.com%2F20240909%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20240909T094501Z&X-Goog-Expires=600&X-Goog-SignedHeaders=accept%3Bcontent-type%3Bhost%3Bx-goog-meta-tenant-project-id&x-goog-signature=2a3432d7e650cd7f32e4b6ddb01051390ae40084fb45f7af25cfaa891f33425d7bf64939b78b9e339b28bcf5238dfb58c67fd8e1eb8957c2df22b1b91d1f01a3ecd1ad4217a570a7e7a80e2999164ca7d920058bfdf52851341fe3c85340da14917026c8efae8f733d5d6548a149ae0558f88307bfcf23f97c2a141317d2be5cf4035488bd7b01137333250be11a174e73096674d8eaffcc7c7d2849044a3eb7669c35f7e421f99ab9557610478c96b68b29962fa1ea002cf76a09a0f302c66157844bd1a2b4b8a36378fd18f8a8dab750d955ff1866c9b20105c56b1f3ebf88c4dcf75043518c74d3d25c54673557b397ba1e31336766004c06ddf7bbbe1940\\",'
            '\\"type\\": \\"binary\\",'
            '\\"httpMethod\\": \\"PUT\\",'
            '\\"headers\\": {'
            '\\"content-type\\": \\"application/octet-stream\\",'
            '\\"accept\\": \\"*/*\\",'
            '\\"x-goog-meta-tenant-project-id\\": \\"$projectId\\",'
            '\\"x-goog-meta-upload-id\\": \\"upload-$projectUuid\\",'
            '\\"host\\": \\"$bucketName.localhost:8000\\"'
            '}'
            '}"';

        final projectDirFactory = DirectoryFactory.serverpodServerDir()
          ..withParent(testCacheDirFactory)
          ..withName('project2');

        setUp(() async {
          projectDirFactory.construct();

          final serverBuilder = HttpServerBuilder();
          serverBuilder.withOnRequest((final request) async {
            final response = request.response;
            response.statusCode = 200;
            response.write(uploadDescription);
            await response.close();
          });

          final (startedServer, serverAddress) = await serverBuilder.build();
          localServerAddress = serverAddress;
          server = startedServer;
        });

        tearDown(() {
          projectDirFactory.destruct();

          server.close(force: true);
        });

        group('when deploying through CLI', () {
          late Future cliCommandFuture;
          setUp(() async {
            cliCommandFuture = cli.run([
              'deploy',
              '--concurrency',
              '1',
              '--project-id',
              projectId,
              '--api-url',
              localServerAddress.toString(),
              '--scloud-dir',
              testCacheDirFactory.directory.path,
              '--project-dir',
              projectDirFactory.directory.path,
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
                ));
          });

          test('then zipped project is accessible in bucket.', () async {
            await cliCommandFuture;
            final client = Client();
            final storage = StorageApi(
              client,
              rootUrl: 'http://localhost:8000/',
            );

            await expectLater(
              storage.objects.get(bucketName, '$projectId/$projectUuid.zip'),
              completion(
                isNotNull,
              ),
            );
          });
        });
      });
    });
  });
}

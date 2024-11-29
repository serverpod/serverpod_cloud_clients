import 'dart:async';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:googleapis/storage/v1.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../test_utils/http_server_builder.dart';
import '../test_utils/project_factory.dart';
import '../test_utils/test_logger.dart';

void main() {
  final logger = TestLogger();
  final version = Version.parse('0.0.1');
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: version,
  );

  final testCacheFolderPath = p.join(
    'test_integration',
    const Uuid().v4(),
  );

  final testAuthDir = p.join(
    testCacheFolderPath,
    'auth',
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

  group('Given invalid concurrency option value when running deploy command',
      () {
    late Future cliCommandFuture;
    setUp(() async {
      cliCommandFuture = cli.run([
        'deploy',
        '--concurrency',
        'invalid',
        '--project-id',
        '123',
        '--auth-dir',
        testAuthDir,
      ]);
    });

    test('then exit exception is thrown.', () async {
      await expectLater(
        cliCommandFuture,
        throwsA(isA<ExitException>()),
      );
    });

    test('then error message is logged', () async {
      await cliCommandFuture.catchError((final _) {});
      expect(logger.errors, isNotEmpty);
      expect(
        logger.errors.first,
        'Failed to parse --concurrency option, value must be an integer.',
      );
    });
  });

  group('Given 403 response for creating file upload request', () {
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
          '--auth-dir',
          testAuthDir,
          '--api-url',
          localServerAddress.toString(),
        ]);
      });

      test('then exit exception is thrown.', () async {
        await expectLater(
          cliCommandFuture,
          throwsA(isA<ExitException>()),
        );
      });

      test('then failed to fetch upload description error message is logged.',
          () async {
        await cliCommandFuture.catchError((final _) {});
        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          startsWith('Failed to fetch upload description'),
        );
      });
    });
  });

  group('Given valid upload description response but no project directory', () {
    late Uri localServerAddress;
    late HttpServer server;

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

      assert(Directory(testProjectDir).existsSync() == false);
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
          '--auth-dir',
          testAuthDir,
          '--project-dir',
          testProjectDir,
          '--api-url',
          localServerAddress.toString(),
        ]);
      });

      test('then exit exception is thrown.', () async {
        await expectLater(
          cliCommandFuture,
          throwsA(isA<ExitException>()),
        );
      });

      test('then project directory does not exist error message is logged.',
          () async {
        await cliCommandFuture.catchError((final _) {});
        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          startsWith('Project directory does not exist:'),
        );
      });
    });
  });

  group('Given valid upload description response but empty project directory',
      () {
    late Uri localServerAddress;
    late HttpServer server;

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

      DirectoryFactory().construct(testProjectDir);
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
          '--auth-dir',
          testAuthDir,
          '--project-dir',
          testProjectDir,
          '--api-url',
          localServerAddress.toString(),
        ]);
      });

      test('then exit exception is thrown.', () async {
        await expectLater(
          cliCommandFuture,
          throwsA(isA<ExitException>()),
        );
      });

      test('then no files to upload error message is logged.', () async {
        await cliCommandFuture.catchError((final _) {});
        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          startsWith('No files to upload'),
        );
      });
    });
  });

  group(
      'Given valid upload description response but project directory contains directory symlink',
      () {
    late Uri localServerAddress;
    late HttpServer server;

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
          '--auth-dir',
          testAuthDir,
          '--project-dir',
          testProjectDir,
          '--api-url',
          localServerAddress.toString(),
        ]);
      });

      test('then exit exception is thrown.', () async {
        await expectLater(
          cliCommandFuture,
          throwsA(isA<ExitException>()),
        );
      });

      test('then directory symlinks are unsupported message is logged.',
          () async {
        await cliCommandFuture.catchError((final _) {});
        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          startsWith('Serverpod Cloud does not support directory symlinks:'),
        );
      });
    });
  });

  group(
      'Given valid upload description response but project contains unresolved symlink',
      () {
    late Uri localServerAddress;
    late HttpServer server;

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

      DirectoryFactory(
        withSymLinks: [
          SymLinkFactory(
            withName: 'non-resolving-symlink',
            withTarget: 'non-existing-file',
          ),
        ],
      ).construct(testProjectDir);
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
          '--auth-dir',
          testAuthDir,
          '--project-dir',
          testProjectDir,
          '--api-url',
          localServerAddress.toString(),
        ]);
      });

      test('then exit exception is thrown.', () async {
        await expectLater(
          cliCommandFuture,
          throwsA(isA<ExitException>()),
        );
      });

      test('then non-resolving symlinks message is logged.', () async {
        await cliCommandFuture.catchError((final _) {});
        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          startsWith(
              'Serverpod Cloud does not support non-resolving symlinks:'),
        );
      });
    });
  });

  group('Given upload description response but with invalid url', () {
    late Uri localServerAddress;
    late HttpServer server;
    const projectId = 'my-project-id';
    const projectUuid = '586a138e-66f3-4dcb-b2e6-bb2d38ab4a4a';
    const bucketName = 'bucket';

    /// This url is missing the `bucketName` subdomain.
    const uploadDescription =
        '"{\\"url\\":\\"http://localhost:8000/$projectId%2F$projectUuid.zip?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=test-service-bucket%40hosting-example-414217.iam.gserviceaccount.com%2F20240909%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20240909T094501Z&X-Goog-Expires=600&X-Goog-SignedHeaders=accept%3Bcontent-type%3Bhost%3Bx-goog-meta-tenant-project-id&x-goog-signature=2a3432d7e650cd7f32e4b6ddb01051390ae40084fb45f7af25cfaa891f33425d7bf64939b78b9e339b28bcf5238dfb58c67fd8e1eb8957c2df22b1b91d1f01a3ecd1ad4217a570a7e7a80e2999164ca7d920058bfdf52851341fe3c85340da14917026c8efae8f733d5d6548a149ae0558f88307bfcf23f97c2a141317d2be5cf4035488bd7b01137333250be11a174e73096674d8eaffcc7c7d2849044a3eb7669c35f7e421f99ab9557610478c96b68b29962fa1ea002cf76a09a0f302c66157844bd1a2b4b8a36378fd18f8a8dab750d955ff1866c9b20105c56b1f3ebf88c4dcf75043518c74d3d25c54673557b397ba1e31336766004c06ddf7bbbe1940\\",\\"type\\":\\"binary\\",\\"httpMethod\\":\\"PUT\\",\\"headers\\":{\\"content-type\\":\\"application/octet-stream\\",\\"accept\\":\\"*/*\\",\\"x-goog-meta-tenant-project-id\\":\\"$projectId\\",\\"x-goog-meta-upload-id\\":\\"upload-$projectUuid\\",\\"host\\":\\"$bucketName.localhost:8000\\"}}"';

    setUp(() async {
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
          '--auth-dir',
          testAuthDir,
          '--api-url',
          localServerAddress.toString(),
        ]);
      });

      test('then exit exception is thrown.', () async {
        await expectLater(
          cliCommandFuture,
          throwsA(isA<ExitException>()),
        );
      });

      test('then failed to upload project error message is logged.', () async {
        await cliCommandFuture.catchError((final _) {});
        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          startsWith('Failed to upload project, please try again.'),
        );
      });
    });
  });

  group('Given valid upload description response', () {
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

    setUp(() async {
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
          '--auth-dir',
          testAuthDir,
          '--api-url',
          localServerAddress.toString(),
        ]);
      });

      test(
          'then command executes successfully and logs Project uploaded successfully message.',
          () async {
        await expectLater(cliCommandFuture, completes);

        expect(logger.messages, isNotEmpty);
        expect(logger.messages.last, 'Project uploaded successfully! 🚀');
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
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/secrets_command.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';
import 'package:test/test.dart';

import '../../test_utils/http_server_builder.dart';
import '../../test_utils/test_logger.dart';

void main() {
  final logger = TestLogger();
  final commandLogger = CommandLogger(logger);
  final version = Version.parse('0.0.1');
  final cli = CloudCliCommandRunner.create(
    logger: commandLogger,
    version: version,
  );

  final testCacheFolderPath = p.join(
    'test_integration',
    const Uuid().v4(),
  );

  tearDown(() {
    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    logger.clear();
  });

  const projectId = 'projectId';

  test('Given secrets command when instantiated then requires login', () {
    expect(CloudSecretsCommand(logger: commandLogger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    late Uri localServerAddress;
    late Completer requestCompleter;
    late HttpServer server;

    setUp(() async {
      requestCompleter = Completer();
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheFolderPath,
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
      await server.close(force: true);
    });

    group('when executing secrets create', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'secrets',
          'create',
          'key',
          'value',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(requestCompleter.future, completes);
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errors, isNotEmpty);
        expect(
            logger.errors.first,
            'The credentials for this session seem to no longer be valid.\n'
            'Please run `scloud logout` followed by `scloud login` and try this command again.');
      });
    });

    group('when executing secrets delete', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'secrets',
          'delete',
          'key',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(requestCompleter.future, completes);
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errors, isNotEmpty);
        expect(
            logger.errors.first,
            'The credentials for this session seem to no longer be valid.\n'
            'Please run `scloud logout` followed by `scloud login` and try this command again.');
      });
    });

    group('when executing secrets list', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'secrets',
          'list',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(requestCompleter.future, completes);
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          'The credentials for this session seem to no longer be valid.\n'
          'Please run `scloud logout` followed by `scloud login` and try this command again.',
        );
      });
    });
  });

  group('Given authenticated', () {
    late Uri localServerAddress;
    late HttpServer server;

    setUp(() async {
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheFolderPath,
      );

      final serverBuilder = HttpServerBuilder();

      serverBuilder.withSuccessfulResponse();

      final (startedServer, serverAddress) = await serverBuilder.build();
      localServerAddress = serverAddress;
      server = startedServer;
    });

    tearDown(() async {
      await server.close(force: true);
    });

    group('when executing secrets create', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'secrets',
          'create',
          'key',
          'value',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.messages, isNotEmpty);
        expect(
          logger.messages.first,
          'Successfully created secret.',
        );
      });
    });

    group('when executing secrets delete', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'secrets',
          'delete',
          'key',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.messages, isNotEmpty);
        expect(
          logger.messages.first,
          'Successfully deleted secret: key.',
        );
      });
    });
  });

  group('Given authenticated when executing secrets list', () {
    late Uri localServerAddress;
    late HttpServer server;

    late Future commandResult;

    setUp(() async {
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheFolderPath,
      );

      final serverBuilder = HttpServerBuilder();
      serverBuilder.withSuccessfulResponse(jsonEncode([
        'SECRET_1',
        'SECRET_2',
        'SECRET_3',
      ]));

      final (startedServer, serverAddress) = await serverBuilder.build();
      localServerAddress = serverAddress;
      server = startedServer;

      commandResult = cli.run([
        'secrets',
        'list',
        '--project-id',
        projectId,
        '--api-url',
        localServerAddress.toString(),
        '--auth-dir',
        testCacheFolderPath,
      ]);
    });

    tearDown(() async {
      await server.close(force: true);
    });

    setUp(() async {});

    test('then completes successfully', () async {
      await expectLater(commandResult, completes);
    });

    test('then logs table', () async {
      await commandResult;

      expect(logger.messages, isNotEmpty);
      expect(
        logger.messages.first,
        'Secret name\n'
        '-----------\n'
        'SECRET_1   \n'
        'SECRET_2   \n'
        'SECRET_3   \n',
      );
    });
  });
}

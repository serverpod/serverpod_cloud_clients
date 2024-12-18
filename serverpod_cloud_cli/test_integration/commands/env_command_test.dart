import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/env_command.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';
import 'package:test/test.dart';

import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/http_server_builder.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final version = Version.parse('0.0.1');
  final cli = CloudCliCommandRunner.create(
    logger: logger,
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

  test('Given env command when instantiated then requires login', () {
    expect(CloudEnvCommand(logger: logger).requireLogin, isTrue);
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

    group('when executing env create', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'env',
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

        expect(logger.errorCalls, isNotEmpty);
        expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message:
                  'The credentials for this session seem to no longer be valid.',
            ));
      });
    });

    group('when executing env update', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'env',
          'update',
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

        expect(logger.errorCalls, isNotEmpty);
        expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message:
                  'The credentials for this session seem to no longer be valid.',
            ));
      });
    });

    group('when executing env delete', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'env',
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

        expect(logger.errorCalls, isNotEmpty);
        expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message:
                  'The credentials for this session seem to no longer be valid.',
            ));
      });
    });

    group('when executing env list', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'env',
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
    late Uri localServerAddress;
    late HttpServer server;

    setUp(() async {
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheFolderPath,
      );

      final serverBuilder = HttpServerBuilder();

      serverBuilder.withSuccessfulResponse(EnvironmentVariable(
        environmentId: 1,
        name: 'name',
        value: 'value',
      ));

      final (startedServer, serverAddress) = await serverBuilder.build();
      localServerAddress = serverAddress;
      server = startedServer;
    });

    tearDown(() async {
      await server.close(force: true);
    });

    group('when executing env create', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'env',
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

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'Successfully created environment variable.',
          ),
        );
      });
    });

    group('when executing env update', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'env',
          'update',
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

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'Successfully updated environment variable: key.',
          ),
        );
      });
    });

    group('when executing env delete', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'env',
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

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'Successfully deleted environment variable: key.',
          ),
        );
      });
    });
  });

  group('Given authenticated when executing env list', () {
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
        EnvironmentVariable(
          environmentId: 1,
          name: 'name',
          value: 'value',
        )
      ]));

      final (startedServer, serverAddress) = await serverBuilder.build();
      localServerAddress = serverAddress;
      server = startedServer;

      commandResult = cli.run([
        'env',
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

    test('then completes successfully', () async {
      await expectLater(commandResult, completes);
    });

    test('then logs success message', () async {
      await commandResult;

      expect(logger.infoCalls, isNotEmpty);
      expect(
        logger.infoCalls.first,
        equalsInfoCall(
          message: 'Name | Value\n'
              '-----+------\n'
              'name | value\n',
        ),
      );
    });
  });
}

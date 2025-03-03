import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/secret_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:ground_control_client/ground_control_client.dart';

import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/http_server_builder.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final cli = CloudCliCommandRunner.create(
    logger: logger,
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
    expect(CloudSecretCommand(logger: logger).requireLogin, isTrue);
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
          'secret',
          'create',
          'key',
          'value',
          '--project',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--scloud-dir',
          testCacheFolderPath,
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

    group('when executing secrets delete and confirming prompt', () {
      late Future commandResult;
      setUp(() async {
        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'secret',
          'delete',
          'key',
          '--project',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--scloud-dir',
          testCacheFolderPath,
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

    group('when executing secrets list', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'secret',
          'list',
          '--project',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--scloud-dir',
          testCacheFolderPath,
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
          'secret',
          'create',
          'key',
          'value',
          '--project',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--scloud-dir',
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
          equalsSuccessCall(message: 'Successfully created secret.'),
        );
      });
    });

    group('when executing secrets delete and confirming prompt', () {
      late Future commandResult;
      setUp(() async {
        logger.answerNextConfirmWith(true);
        commandResult = cli.run([
          'secret',
          'delete',
          'key',
          '--project',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--scloud-dir',
          testCacheFolderPath,
        ]);
      });

      test('then logs confirm message', () async {
        await commandResult;

        expect(logger.confirmCalls, isNotEmpty);
        expect(
          logger.confirmCalls.first,
          equalsConfirmCall(
            message: 'Are you sure you want to delete the secret "key"?',
            defaultValue: false,
          ),
        );
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(message: 'Successfully deleted secret: key.'),
        );
      });
    });

    group('when executing secrets delete and rejecting prompt', () {
      late Future commandResult;
      setUp(() async {
        logger.answerNextConfirmWith(false);
        commandResult = cli.run([
          'secret',
          'delete',
          'key',
          '--project',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--scloud-dir',
          testCacheFolderPath,
        ]);
      });

      test('then logs confirm message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.confirmCalls, isNotEmpty);
        expect(
          logger.confirmCalls.first,
          equalsConfirmCall(
            message: 'Are you sure you want to delete the secret "key"?',
            defaultValue: false,
          ),
        );
      });

      test('then throws exit exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs no success message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.successCalls, isEmpty);
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
        'secret',
        'list',
        '--project',
        projectId,
        '--api-url',
        localServerAddress.toString(),
        '--scloud-dir',
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

      expect(logger.lineCalls, isNotEmpty);
      expect(
        logger.lineCalls,
        containsAllInOrder([
          equalsLineCall(line: 'Secret name'),
          equalsLineCall(line: '-----------'),
          equalsLineCall(line: 'SECRET_1   '),
          equalsLineCall(line: 'SECRET_2   '),
          equalsLineCall(line: 'SECRET_3   '),
        ]),
      );
    });
  });
}

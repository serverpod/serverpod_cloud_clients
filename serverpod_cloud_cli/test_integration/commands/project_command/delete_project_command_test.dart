import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:test/test.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/http_server_builder.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final cli = CloudCliCommandRunner.create(
    logger: logger,
  );

  final testCacheFolderPath = p.join(
    'test_integration',
    const Uuid().v4(),
  );
  late Directory originalDirectory;

  setUp(() {
    Directory(testCacheFolderPath).createSync(recursive: true);
    originalDirectory = Directory.current;
    Directory.current = testCacheFolderPath;
  });

  tearDown(() {
    Directory.current = originalDirectory;

    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    logger.clear();
  });

  const projectId = 'my-proj';

  group('Given authenticated', () {
    setUp(() async {
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheFolderPath,
      );
    });

    group(
        'and existing project when deleting the project and accepting the prompt',
        () {
      late Uri localServerAddress;
      late HttpServer server;
      late Future commandResult;

      setUp(() async {
        final serverBuilder = HttpServerBuilder();

        serverBuilder.withMethodResponse(
          'projects',
          'deleteProject',
          (final _) => (200, Project(cloudProjectId: projectId)),
        );

        final (startedServer, serverAddress) = await serverBuilder.build();
        localServerAddress = serverAddress;
        server = startedServer;

        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'project',
          'delete',
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

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs confirm message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.confirmCalls, isNotEmpty);
        expect(
          logger.confirmCalls.first,
          equalsConfirmCall(
            message: 'Are you sure you want to delete the project "my-proj"?',
            defaultValue: false,
          ),
        );
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'Successfully deleted the project "my-proj".',
          ),
        );
      });
    });

    group(
        'and existing project when deleting the project and rejecting the prompt',
        () {
      late Uri localServerAddress;
      late HttpServer server;
      late Future commandResult;

      setUp(() async {
        final serverBuilder = HttpServerBuilder();

        serverBuilder.withMethodResponse(
          'projects',
          'deleteProject',
          (final _) => (200, Project(cloudProjectId: projectId)),
        );

        final (startedServer, serverAddress) = await serverBuilder.build();
        localServerAddress = serverAddress;
        server = startedServer;

        logger.answerNextConfirmWith(false);

        commandResult = cli.run([
          'project',
          'delete',
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

      test('then command throws exit exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs confirm message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.confirmCalls, isNotEmpty);
        expect(
          logger.confirmCalls.first,
          equalsConfirmCall(
            message: 'Are you sure you want to delete the project "my-proj"?',
            defaultValue: false,
          ),
        );
      });

      test('then logs no success message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.successCalls, isEmpty);
      });
    });

    group(
        'and project does not exist when deleting the project and accepting the prompt',
        () {
      late Uri localServerAddress;
      late HttpServer server;
      late Future commandResult;

      setUp(() async {
        final serverBuilder = HttpServerBuilder();

        serverBuilder.withMethodResponse(
          'projects',
          'deleteProject',
          (final _) =>
              (400, NotFoundException(message: 'No such project: $projectId')),
        );

        final (startedServer, serverAddress) = await serverBuilder.build();
        localServerAddress = serverAddress;
        server = startedServer;

        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'project',
          'delete',
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

      test('then command throws exit exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message: 'The requested resource did not exist.',
            hint: 'No such project: my-proj',
          ),
        );
      });
    });
  });
}

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/link_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/json_to_yaml.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/http_server_builder.dart';
import '../../test_utils/project_factory.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final cli = CloudCliCommandRunner.create(
    logger: logger,
  );

  const projectId = 'projectId';

  final testCacheDirFactory = DirectoryFactory()..withPath('test_integration');

  setUp(() {
    testCacheDirFactory.construct();
  });

  tearDown(() {
    testCacheDirFactory.destruct();

    logger.clear();
  });

  test('Given link command when instantiated then requires login', () {
    expect(CloudLinkCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated and servrpod directory', () {
    late Uri localServerAddress;
    late Completer requestCompleter;
    late HttpServer server;
    final testProjectDirFactory = DirectoryFactory.serverpodServerDir()
      ..withParent(testCacheDirFactory)
      ..withName('project');

    setUp(() async {
      testProjectDirFactory.construct();

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
      await server.close(force: true);
      testProjectDirFactory.destruct();
    });

    group('when executing link', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'link',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--scloud-dir',
          testCacheDirFactory.directory.path,
          '--project-dir',
          testProjectDirFactory.directory.path,
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

    group('and serverpod directory', () {
      late Uri localServerAddress;
      late HttpServer server;
      final testProjectDirFactory = DirectoryFactory.serverpodServerDir()
        ..withParent(testCacheDirFactory)
        ..withName('project');

      setUp(() async {
        testProjectDirFactory.construct();

        final serverBuilder = HttpServerBuilder();

        serverBuilder.withSuccessfulResponse(
          ProjectConfig(projectId: projectId),
        );

        final (startedServer, serverAddress) = await serverBuilder.build();
        localServerAddress = serverAddress;
        server = startedServer;
      });

      tearDown(() async {
        await server.close(force: true);
        testProjectDirFactory.destruct();
      });

      group('and scloud.yaml does not already exist when executing link', () {
        late Future commandResult;
        setUp(() async {
          commandResult = cli.run([
            'link',
            '--project-id',
            projectId,
            '--api-url',
            localServerAddress.toString(),
            '--scloud-dir',
            testCacheDirFactory.directory.path,
            '--project-dir',
            testProjectDirFactory.directory.path,
          ]);
        });

        tearDown(() async {
          final file = File('scloud.yaml');
          if (file.existsSync()) {
            file.deleteSync();
          }
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then logs success message', () async {
          await commandResult;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(message: 'Successfully linked project!'),
          );
        });

        test('then writes scloud.yaml file', () async {
          await commandResult;

          final file = File(p.join(
            testProjectDirFactory.directory.path,
            'scloud.yaml',
          ));
          expect(file.existsSync(), isTrue);

          final content = file.readAsStringSync();
          final yaml = loadYaml(content) as YamlMap;
          final project = yaml['project'] as YamlMap;

          expect(project['projectId'], projectId);
        });
      });

      group('and scloud.yaml exists when executing link', () {
        late Future commandResult;
        setUp(() {
          final file = File(p.join(
            testProjectDirFactory.directory.path,
            'scloud.yaml',
          ));
          file.writeAsStringSync(jsonToYaml({
            'project': {'projectId': 'otherProjectId'},
          }));

          commandResult = cli.run([
            'link',
            '--project-id',
            projectId,
            '--api-url',
            localServerAddress.toString(),
            '--scloud-dir',
            testCacheDirFactory.directory.path,
            '--project-dir',
            testProjectDirFactory.directory.path,
          ]);
        });

        tearDown(() {
          final file = File('scloud.yaml');
          if (file.existsSync()) {
            file.deleteSync();
          }
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then logs success message', () async {
          await commandResult;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(message: 'Successfully linked project!'),
          );
        });

        test('then writes updated project id to scloud.yaml file', () async {
          await commandResult;

          final file = File(p.join(
            testProjectDirFactory.directory.path,
            'scloud.yaml',
          ));
          expect(file.existsSync(), isTrue);

          final content = file.readAsStringSync();
          final yaml = loadYaml(content) as YamlMap;
          final project = yaml['project'] as YamlMap;
          expect(project['projectId'], projectId);
        });
      });

      group('and incorrectly formatted scloud.yaml exists when executing link',
          () {
        late Future commandResult;
        setUp(() {
          final file = File(p.join(
            testProjectDirFactory.directory.path,
            'scloud.yaml',
          ));
          file.writeAsStringSync(jsonToYaml({
            'project': ['projectId'],
          }));

          commandResult = cli.run([
            'link',
            '--project-id',
            projectId,
            '--api-url',
            localServerAddress.toString(),
            '--scloud-dir',
            testCacheDirFactory.directory.path,
            '--project-dir',
            testProjectDirFactory.directory.path,
          ]);
        });

        tearDown(() {
          final file = File('scloud.yaml');
          if (file.existsSync()) {
            file.deleteSync();
          }
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
              message: 'Failed to write to scloud.yaml file: '
                  'SchemaValidationException: At path "project": Expected YamlMap, got YamlList',
            ),
          );
        });
      });
    });

    group('and not a serverpod directory when executing link', () {
      late Future commandResult;
      final testProjectDirFactory = DirectoryFactory()
        ..withParent(testCacheDirFactory)
        ..withName('project');

      setUp(() {
        testProjectDirFactory.construct();

        commandResult = cli.run([
          'link',
          '--project-id',
          projectId,
          '--project-dir',
          testProjectDirFactory.directory.path,
          '--scloud-dir',
          testCacheDirFactory.directory.path,
        ]);
      });

      tearDown(() {
        testProjectDirFactory.destruct();
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
            message: 'The provided project directory '
                '(either through the --project-dir flag or the current directory) '
                'is not a Serverpod server directory.',
            hint: "Provide the project's server directory and try again.",
          ),
        );
      });
    });
  });
}

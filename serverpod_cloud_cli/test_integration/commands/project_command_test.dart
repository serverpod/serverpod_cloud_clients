import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/json_to_yaml.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

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

  const projectId = 'projectId';

  group('Given authenticated', () {
    late Uri localServerAddress;
    late HttpServer server;

    setUp(() async {
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheFolderPath,
      );

      final serverBuilder = HttpServerBuilder();

      serverBuilder.withMethodResponse('projects', 'createProject',
          (final _) => (200, Project(cloudProjectId: projectId)));

      serverBuilder.withMethodResponse('projects', 'fetchProjectConfig',
          (final _) => (200, ProjectConfig(projectId: projectId)));

      final (startedServer, serverAddress) = await serverBuilder.build();
      localServerAddress = serverAddress;
      server = startedServer;
    });

    tearDown(() async {
      await server.close(force: true);
    });

    group(
        'and inside a serverpod directory without scloud.yaml file when calling create',
        () {
      late Future commandResult;
      setUp(() async {
        File('pubspec.yaml').writeAsStringSync(jsonToYaml({
          'name': 'my_project_server',
          'dependencies': {
            'serverpod': '2.1',
          },
        }));

        commandResult = cli.run([
          'project',
          'create',
          projectId,
          '--no-enable-db',
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
            message: "Successfully created new project '$projectId'.",
          ),
        );
      });

      test('then writes scloud.yaml file', () async {
        await commandResult;

        final file = File('scloud.yaml');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();
        final yaml = loadYaml(content) as YamlMap;
        final project = yaml['project'] as YamlMap;
        expect(project['projectId'], projectId);
      });
    });

    group(
        'and inside a serverpod directory with existing scloud.yaml file when calling create',
        () {
      late Future commandResult;
      setUp(() async {
        File('pubspec.yaml').writeAsStringSync(jsonToYaml({
          'name': 'my_project_server',
          'dependencies': {
            'serverpod': '2.1',
          },
        }));

        File('scloud.yaml').writeAsStringSync(jsonToYaml({
          'project': {'projectId': 'otherProjectId'},
        }));

        commandResult = cli.run([
          'project',
          'create',
          projectId,
          '--no-enable-db',
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
            message: "Successfully created new project '$projectId'.",
          ),
        );
      });

      test('then does not update existing scloud.yaml file', () async {
        await commandResult;

        final file = File('scloud.yaml');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();
        final yaml = loadYaml(content) as YamlMap;
        final project = yaml['project'] as YamlMap;
        expect(project['projectId'], 'otherProjectId');
      });
    });

    group('and inside a dart directory when calling create', () {
      late Future commandResult;
      setUp(() async {
        File('pubspec.yaml').writeAsStringSync(jsonToYaml({
          'name': 'my_own_server',
          'dependencies': {
            'test': '1.0',
          },
        }));

        commandResult = cli.run([
          'project',
          'create',
          projectId,
          '--no-enable-db',
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
            message: "Successfully created new project '$projectId'.",
          ),
        );
      });

      test('then does not write scloud.yaml file', () async {
        await commandResult;

        final file = File('scloud.yaml');
        expect(file.existsSync(), isFalse);
      });
    });

    group('and outside a serverpod directory when calling create', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'project',
          'create',
          projectId,
          '--no-enable-db',
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
            message: "Successfully created new project '$projectId'.",
          ),
        );
      });

      test('then does not write scloud.yaml file', () async {
        await commandResult;

        final file = File('scloud.yaml');
        expect(file.existsSync(), isFalse);
      });

      test(
          'then informs the user that they have to run the link '
          'command in the project server folder', () async {
        await commandResult;

        expect(logger.terminalCommandCalls, isNotEmpty);
        expect(
          logger.terminalCommandCalls.last,
          equalsTerminalCommandCall(
            message:
                'Since the current directory is not a Serverpod server directory '
                'an scloud.yaml configuration file has not been created. '
                'Use the link command to create it in the server directory of this project:',
            newParagraph: true,
            command: 'scloud link $projectId',
          ),
        );
      });
    });
  });
}

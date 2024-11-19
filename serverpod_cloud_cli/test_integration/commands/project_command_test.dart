import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/json_to_yaml.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../../test_utils/http_server_builder.dart';
import '../../test_utils/test_logger.dart';

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
      final serverBuilder = HttpServerBuilder();

      serverBuilder.withOnServerpodMethodCall('createTenantProject', () {
        return TenantProject(canonicalName: projectId).toString();
      });

      serverBuilder.withOnServerpodMethodCall('fetchProjectConfig', () {
        return ProjectConfig(projectId: projectId).toString();
      });

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
          '--api-url',
          localServerAddress.toString(),
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
          "Successfully created new project '$projectId'.",
        );
      });

      test('then writes scloud.yaml file', () async {
        await commandResult;

        final file = File('scloud.yaml');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();
        final yaml = loadYaml(content);

        expect(yaml['project']['projectId'], projectId);
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
          '--api-url',
          localServerAddress.toString(),
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
          "Successfully created new project '$projectId'.",
        );
      });

      test('then does not update existing scloud.yaml file', () async {
        await commandResult;

        final file = File('scloud.yaml');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();
        final yaml = loadYaml(content);

        expect(yaml['project']['projectId'], 'otherProjectId');
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
          '--api-url',
          localServerAddress.toString(),
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
          "Successfully created new project '$projectId'.",
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
          '--api-url',
          localServerAddress.toString(),
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
          "Successfully created new project '$projectId'.",
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

        expect(
          logger.messages.last,
          'Since the current directory is not a Serverpod server directory '
          'an scloud.yaml configuration file has not been created. \n'
          'Use the scloud link command to create it in the server '
          'directory of this project.',
        );
      });
    });
  });
}

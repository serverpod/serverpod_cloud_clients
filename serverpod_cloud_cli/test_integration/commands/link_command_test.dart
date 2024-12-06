import 'dart:async';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
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

  const projectId = 'projectId';

  tearDown(() {
    logger.clear();
  });

  group('Given unauthenticated', () {
    late Uri localServerAddress;
    late HttpServer server;

    setUp(() async {
      final serverBuilder = HttpServerBuilder();
      serverBuilder.withOnRequest((final request) {
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

    group('when executing link', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'link',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          'Failed to fetch project config: ServerpodClientException: Unauthorized, statusCode = 401',
        );
      });
    });
  });

  group('Given authenticated', () {
    late Uri localServerAddress;
    late HttpServer server;

    setUp(() async {
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

        expect(logger.messages, isNotEmpty);
        expect(
          logger.messages.first,
          'Successfully linked project!',
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

    group('and scloud.yaml exists when executing link', () {
      late Future commandResult;
      setUp(() {
        final file = File('scloud.yaml');
        file.writeAsStringSync(jsonToYaml({
          'project': {'projectId': 'otherProjectId'},
        }));

        commandResult = cli.run([
          'link',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
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

        expect(logger.messages, isNotEmpty);
        expect(
          logger.messages.first,
          'Successfully linked project!',
        );
      });

      test('then writes updated project id to scloud.yaml file', () async {
        await commandResult;

        final file = File('scloud.yaml');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();
        final yaml = loadYaml(content);
        expect(yaml['project']['projectId'], projectId);
      });
    });

    group('and incorrectly formatted scloud.yaml exists when executing link',
        () {
      late Future commandResult;
      setUp(() {
        final file = File('scloud.yaml');
        file.writeAsStringSync(jsonToYaml({
          'project': ['projectId'],
        }));

        commandResult = cli.run([
          'link',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
        ]);
      });

      tearDown(() {
        final file = File('scloud.yaml');
        if (file.existsSync()) {
          file.deleteSync();
        }
      });

      test('then command throws exit exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          'Failed to write to scloud.yaml file: '
          'SchemaValidationException: At path "project": Expected YamlMap, got YamlList',
        );
      });
    });
  });
}
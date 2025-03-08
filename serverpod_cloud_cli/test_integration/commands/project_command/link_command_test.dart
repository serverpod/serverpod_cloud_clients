import 'dart:async';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:path/path.dart' as p;

import 'package:ground_control_client/ground_control_client_mock.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/json_to_yaml.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/project_factory.dart';
import '../../../test_utils/push_current_dir.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final keyManager = InMemoryKeyManager();
  final client = ClientMock(authenticationKeyManager: keyManager);
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  const projectId = 'projectId';

  tearDown(() async {
    await keyManager.remove();

    logger.clear();
  });

  test('Given project link command when instantiated then requires login', () {
    expect(CloudProjectLinkCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated and serverpod directory', () {
    late String testProjectDir;

    setUp(() async {
      testProjectDir =
          DirectoryFactory.serverpodServerDir().construct(d.sandbox).path;
    });

    group('when executing link', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'project',
          'link',
          '--project',
          projectId,
          '--project-dir',
          testProjectDir,
        ]);
      });

      test('then throws exception', () async {
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
              message: 'This command requires you to be logged in.',
            ));
      });
    });
  });

  group('Given authenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    group('and serverpod directory', () {
      late String testProjectDir;

      setUp(() async {
        final projectDir =
            DirectoryFactory.serverpodServerDir().construct(d.sandbox);
        testProjectDir = projectDir.path;

        final projectConfig = ProjectConfig(projectId: projectId);
        when(() => client.projects.fetchProjectConfig(
              cloudProjectId: any(named: 'cloudProjectId'),
            )).thenAnswer((final _) async => Future.value(projectConfig));
      });

      group('and scloud.yaml does not already exist when executing link', () {
        late Future commandResult;
        setUp(() async {
          commandResult = cli.run([
            'project',
            'link',
            '--project',
            projectId,
            '--project-dir',
            testProjectDir,
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
            equalsSuccessCall(message: 'Successfully linked project!'),
          );
        });

        test('then writes scloud.yaml file', () async {
          await commandResult;

          final file = File(p.join(testProjectDir, 'scloud.yaml'));
          expect(file.existsSync(), isTrue);

          final content = file.readAsStringSync();
          final yaml = loadYaml(content) as YamlMap;
          final project = yaml['project'] as YamlMap;

          expect(project['projectId'], projectId);
        });

        test('then includes standard header in scloud.yaml file', () async {
          await commandResult;

          final file = File(p.join(testProjectDir, 'scloud.yaml'));
          expect(file.existsSync(), isTrue);

          final content = file.readAsStringSync();
          expect(
              content,
              startsWith(
                  '# This file configures your Serverpod Cloud project.'));
        });
      });

      group('and scloud.yaml exists when executing link', () {
        late Future commandResult;
        setUp(() {
          final file = File(p.join(testProjectDir, 'scloud.yaml'));
          file.writeAsStringSync(jsonToYaml({
            'project': {'projectId': 'otherProjectId'},
          }));

          commandResult = cli.run([
            'project',
            'link',
            '--project',
            projectId,
            '--project-dir',
            testProjectDir,
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

          final file = File(p.join(testProjectDir, 'scloud.yaml'));
          expect(file.existsSync(), isTrue);

          final content = file.readAsStringSync();
          final yaml = loadYaml(content) as YamlMap;
          final project = yaml['project'] as YamlMap;
          expect(project['projectId'], projectId);
        });

        test('then includes standard header in scloud.yaml file', () async {
          await commandResult;

          final file = File(p.join(testProjectDir, 'scloud.yaml'));
          expect(file.existsSync(), isTrue);

          final content = file.readAsStringSync();
          expect(
              content,
              startsWith(
                  '# This file configures your Serverpod Cloud project.'));
        });
      });

      group(
          'and inside a serverpod directory without .scloudignore file when calling create',
          () {
        late Future commandResult;
        setUp(() async {
          commandResult = cli.run([
            'project',
            'link',
            '--project',
            projectId,
            '--project-dir',
            testProjectDir,
          ]);
        });

        test('then writes .scloudignore file', () async {
          await commandResult;
          final file = File(p.join(testProjectDir, '.scloudignore'));
          expect(file.existsSync(), isTrue);
        });
      });

      group(
          'and inside a serverpod directory with a custom .scloudignore file when calling create',
          () {
        late Future commandResult;
        setUp(() async {
          File(p.join(testProjectDir, '.scloudignore')).writeAsStringSync(
            '# Custom .scloudignore file',
          );

          commandResult = cli.run([
            'project',
            'link',
            '--project',
            projectId,
            '--project-dir',
            testProjectDir,
          ]);
        });

        test('then the content of the .scloudignore file is not changed',
            () async {
          await commandResult;

          final content = File(
            p.join(testProjectDir, '.scloudignore'),
          ).readAsStringSync();
          expect(content, '# Custom .scloudignore file');
        });
      });

      group('and incorrectly formatted scloud.yaml exists when executing link',
          () {
        late Future commandResult;
        setUp(() {
          final file = File(p.join(testProjectDir, 'scloud.yaml'));
          file.writeAsStringSync(jsonToYaml({
            'project': ['projectId'],
          }));

          commandResult = cli.run([
            'project',
            'link',
            '--project',
            projectId,
            '--project-dir',
            testProjectDir,
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
      late String testProjectDir;
      late Future commandResult;

      setUp(() async {
        final projectDir =
            DirectoryFactory(withDirectoryName: 'not_a_serverpod_dir')
                .construct(d.sandbox);
        testProjectDir = projectDir.path;

        final projectConfig = ProjectConfig(projectId: projectId);
        when(() => client.projects.fetchProjectConfig(
              cloudProjectId: any(named: 'cloudProjectId'),
            )).thenAnswer((final _) async => Future.value(projectConfig));

        commandResult = cli.run([
          'project',
          'link',
          '--project',
          projectId,
          '--project-dir',
          testProjectDir,
        ]);
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

    group('and a serverpod directory inside a deep directory hierarchy', () {
      setUp(() async {
        final descriptor = d.dir('topdir', [
          d.dir('project_dir', [
            d.dir('project_server', [
              d.file('pubspec.yaml', '''
name: my_project_server
environment:
  sdk: '>=3.6.0 <3.7.0'
dependencies:
  serverpod: ^2.3.0
'''),
            ]),
            d.dir('project_client', [
              d.file('pubspec.yaml', '''
name: my_project_client
environment:
  sdk: '>=3.6.0 <3.7.0'
'''),
            ]),
            d.dir('project_flutter', [
              d.file('pubspec.yaml', '''
name: my_project_flutter
environment:
  sdk: '>=3.6.0 <3.7.0'
'''),
            ]),
          ]),
        ]);
        await descriptor.create();

        final projectConfig = ProjectConfig(projectId: projectId);
        when(() => client.projects.fetchProjectConfig(
              cloudProjectId: any(named: 'cloudProjectId'),
            )).thenAnswer((final _) async => Future.value(projectConfig));
      });

      group('and cur dir is three levels above the project dir', () {
        late Future commandResult;

        setUp(() async {
          pushCurrentDirectory(p.join(d.sandbox));

          commandResult = cli.run(['project', 'link', '--project', projectId]);
        });

        test('then project link command throws exit exception', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then project link command logs error message', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
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

      group('and cur dir is two levels above the project dir', () {
        late Future commandResult;

        setUp(() async {
          pushCurrentDirectory(p.join(d.sandbox, 'topdir'));

          commandResult = cli.run(['project', 'link', '--project', projectId]);
        });

        test('then project link command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then project link command logs info message', () async {
          final expectedProjectDirPath =
              p.join(p.current, 'project_dir', 'project_server');

          await commandResult;
          expect(logger.infoCalls, isNotEmpty);
          expect(
            logger.infoCalls.first,
            equalsInfoCall(
              message: 'Using project directory `$expectedProjectDirPath`',
            ),
          );
        });
      });

      group('and cur dir is one level above the project dir', () {
        late Future commandResult;

        setUp(() async {
          pushCurrentDirectory(p.join(d.sandbox, 'topdir', 'project_dir'));

          commandResult = cli.run(['project', 'link', '--project', projectId]);
        });

        test('then project link command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then project link command logs info message', () async {
          final expectedProjectDirPath = p.join(p.current, 'project_server');

          await commandResult;
          expect(logger.infoCalls, isNotEmpty);
          expect(
            logger.infoCalls.first,
            equalsInfoCall(
              message: 'Using project directory `$expectedProjectDirPath`',
            ),
          );
        });
      });

      group('and cur dir is in the flutter dir', () {
        late Future commandResult;

        setUp(() async {
          pushCurrentDirectory(
              p.join(d.sandbox, 'topdir', 'project_dir', 'project_flutter'));

          commandResult = cli.run(['project', 'link', '--project', projectId]);
        });

        test('then project link command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then project link command logs info message', () async {
          final expectedProjectDirPath =
              p.join(p.current, '..', 'project_server');

          await commandResult;
          expect(logger.infoCalls, isNotEmpty);
          expect(
            logger.infoCalls.first,
            equalsInfoCall(
              message: 'Using project directory `$expectedProjectDirPath`',
            ),
          );
        });
      });
    });
  });
}

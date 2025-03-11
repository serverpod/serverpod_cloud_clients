import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:path/path.dart' as p;

import 'package:ground_control_client/ground_control_client_mock.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:test/test.dart';

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

      when(() => client.projects.fetchProjectConfig(
            cloudProjectId: any(named: 'cloudProjectId'),
          )).thenAnswer(
        (final invocation) async => Future.value(
          ProjectConfig(projectId: invocation.namedArguments[#cloudProjectId]),
        ),
      );
    });

    group('and serverpod directory', () {
      late String testProjectDir;

      setUp(() async {
        await ProjectFactory.serverpodServerDir(
          withDirectoryName: 'server_dir',
        ).create();
        testProjectDir = p.join(d.sandbox, 'server_dir');
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

          final expected = d.dir(testProjectDir, [
            d.file(
              'scloud.yaml',
              contains('''
project:
  projectId: "$projectId"
'''),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });

        test('then includes standard header in scloud.yaml file', () async {
          await commandResult;

          final expected = d.dir(testProjectDir, [
            d.file(
              'scloud.yaml',
              startsWith(
                  '# This file configures your Serverpod Cloud project.'),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('and scloud.yaml exists when executing link', () {
        late Future commandResult;

        setUp(() async {
          await d.dir(testProjectDir, [
            d.file('scloud.yaml', '''
project:
  projectId: "otherProjectId"
'''),
          ]).create();

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

        test('then writes updated project id to scloud.yaml file', () async {
          await commandResult;

          final expected = d.dir(testProjectDir, [
            d.file(
              'scloud.yaml',
              contains('''
project:
  projectId: "$projectId"
'''),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });

        test('then includes standard header in scloud.yaml file', () async {
          await commandResult;

          final expected = d.dir(testProjectDir, [
            d.file(
              'scloud.yaml',
              startsWith(
                  '# This file configures your Serverpod Cloud project.'),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group(
          'and inside a serverpod directory without .scloudignore file when executing link',
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

          final expected = d.dir(testProjectDir, [
            d.file(
              '.scloudignore',
              contains('# .scloudignore'),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group(
          'and inside a serverpod directory with a custom .scloudignore file when executing link',
          () {
        late Future commandResult;
        setUp(() async {
          await d.dir(testProjectDir, [
            d.file(
              '.scloudignore',
              '# Custom .scloudignore file',
            ),
          ]).create();

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

          final expected = d.dir(testProjectDir, [
            d.file(
              '.scloudignore',
              contains('# Custom .scloudignore file'),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('and incorrectly formatted scloud.yaml exists when executing link',
          () {
        late Future commandResult;
        setUp(() async {
          await d.dir(testProjectDir, [
            d.file('scloud.yaml', '''
project:
  - "projectId"
'''),
          ]).create();

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
              message:
                  'Failed to write to ${p.join(testProjectDir, 'scloud.yaml')} file: '
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
        await d.dir('not_a_serverpod_dir').create();
        testProjectDir = p.join(d.sandbox, 'not_a_serverpod_dir');

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

    group('and a deep directory hierarchy with a serverpod directory', () {
      setUp(() async {
        final descriptor = d.dir('topdir', [
          d.dir('project_dir', [
            d.dir('project_server', [
              ProjectFactory.serverpodServerPubspec(),
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
      });

      group(
          'and cur dir is three levels above the project dir when executing link',
          () {
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

        test('then scloud.yaml is not created', () async {
          try {
            await commandResult;
          } catch (_) {}

          final expected = d.dir('topdir', [
            d.dir('project_dir', [
              d.dir('project_server', [
                d.nothing('scloud.yaml'),
              ]),
              d.dir('project_client', [
                d.nothing('scloud.yaml'),
              ]),
              d.dir('project_flutter', [
                d.nothing('scloud.yaml'),
              ]),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group(
          'and cur dir is two levels above the project dir when executing link',
          () {
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
              message:
                  "Wrote the '${p.join(expectedProjectDirPath, 'scloud.yaml')}' configuration file for '$projectId'.",
            ),
          );
        });

        test('then scloud.yaml is created in the project dir', () async {
          await commandResult;
          final expected = d.dir('topdir', [
            d.dir('project_dir', [
              d.dir('project_server', [
                d.file('scloud.yaml', contains('''
project:
  projectId: "projectId"
''')),
              ]),
              d.dir('project_client', [
                d.nothing('scloud.yaml'),
              ]),
              d.dir('project_flutter', [
                d.nothing('scloud.yaml'),
              ]),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group(
          'and cur dir is one level above the project dir when executing link',
          () {
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
              message:
                  "Wrote the '${p.join(expectedProjectDirPath, 'scloud.yaml')}' configuration file for '$projectId'.",
            ),
          );
        });

        test('then scloud.yaml is created in the project dir', () async {
          await commandResult;
          final expected = d.dir('topdir', [
            d.dir('project_dir', [
              d.dir('project_server', [
                d.file('scloud.yaml', contains('''
project:
  projectId: "projectId"
''')),
              ]),
              d.dir('project_client', [
                d.nothing('scloud.yaml'),
              ]),
              d.dir('project_flutter', [
                d.nothing('scloud.yaml'),
              ]),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('and cur dir is in the flutter dir when executing link', () {
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
          final expectedProjectDirPath = p.normalize(
            p.join(p.current, '..', 'project_server'),
          );

          await commandResult;
          expect(logger.infoCalls, isNotEmpty);
          expect(
            logger.infoCalls.first,
            equalsInfoCall(
              message: //'Using project directory `$expectedProjectDirPath`',
                  "Wrote the '${p.join(expectedProjectDirPath, 'scloud.yaml')}' configuration file for '$projectId'.",
            ),
          );
        });

        test('then scloud.yaml is created in the project dir', () async {
          await commandResult;
          final expected = d.dir('topdir', [
            d.dir('project_dir', [
              d.dir('project_server', [
                d.file('scloud.yaml', contains('''
project:
  projectId: "projectId"
''')),
              ]),
              d.dir('project_client', [
                d.nothing('scloud.yaml'),
              ]),
              d.dir('project_flutter', [
                d.nothing('scloud.yaml'),
              ]),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group(
          'and cur dir is in the flutter dir '
          'and there is preexisting scloud.yaml file in server dir '
          'when executing link', () {
        late Future commandResult;

        setUp(() async {
          final preexistingScloudYamlFile = d.file(
            'scloud.yaml',
            '''
project:
  projectId: "otherProjectId"
''',
          );
          await preexistingScloudYamlFile.create(
              p.join(d.sandbox, 'topdir', 'project_dir', 'project_server'));

          pushCurrentDirectory(
              p.join(d.sandbox, 'topdir', 'project_dir', 'project_flutter'));

          commandResult =
              cli.run(['project', 'link', '--project', 'specialId']);
        });

        test('then project link command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then project link command logs info message', () async {
          final expectedProjectDirPath = p.normalize(
            p.join(p.current, '..', 'project_server'),
          );

          await commandResult;
          expect(logger.infoCalls, isNotEmpty);
          expect(
            logger.infoCalls.first,
            equalsInfoCall(
              message:
                  "Wrote the '${p.join(expectedProjectDirPath, 'scloud.yaml')}' configuration file for 'specialId'.",
            ),
          );
        });

        test('then scloud.yaml is updated in the project dir', () async {
          await commandResult;
          final expected = d.dir('topdir', [
            d.dir('project_dir', [
              d.dir('project_server', [
                d.file('scloud.yaml', contains('''
project:
  projectId: "specialId"
''')),
              ]),
              d.dir('project_client', [
                d.nothing('scloud.yaml'),
              ]),
              d.dir('project_flutter', [
                d.nothing('scloud.yaml'),
              ]),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group(
          'and cur dir is in the flutter dir '
          'and there is preexisting scloud.yaml file in parent project dir '
          'when executing link', () {
        late Future commandResult;

        setUp(() async {
          final preexistingScloudYamlFile = d.file(
            'scloud.yaml',
            '''
project:
  projectId: "otherProjectId"
''',
          );
          await preexistingScloudYamlFile
              .create(p.join(d.sandbox, 'topdir', 'project_dir'));

          pushCurrentDirectory(
              p.join(d.sandbox, 'topdir', 'project_dir', 'project_flutter'));

          commandResult = cli.run([
            'project',
            'link',
            '--project-dir',
            p.join(d.sandbox, 'topdir', 'project_dir', 'project_server'),
            '--project',
            'specialId',
          ]);
        });

        test('then project link command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then project link command logs info message', () async {
          final expectedConfigDirPath =
              p.join(d.sandbox, 'topdir', 'project_dir');

          await commandResult;
          expect(logger.infoCalls, isNotEmpty);
          expect(
            logger.infoCalls.first,
            equalsInfoCall(
              message:
                  "Wrote the '${p.join(expectedConfigDirPath, 'scloud.yaml')}' configuration file for 'specialId'.",
            ),
          );
        });

        test('then scloud.yaml is updated in the project dir', () async {
          await commandResult;
          final expected = d.dir('topdir', [
            d.dir('project_dir', [
              d.dir('project_server', [
                d.nothing('scloud.yaml'),
              ]),
              d.dir('project_client', [
                d.nothing('scloud.yaml'),
              ]),
              d.dir('project_flutter', [
                d.nothing('scloud.yaml'),
              ]),
              d.file('scloud.yaml', contains('''
project:
  projectId: "specialId"
''')),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group(
          'and cur dir is in the flutter dir '
          'and there is preexisting scloud.yaml file in parent project dir '
          'when executing link with different config file option', () {
        late Future commandResult;

        setUp(() async {
          final preexistingScloudYamlFile = d.file(
            'scloud.yaml',
            '''
project:
  projectId: "otherProjectId"
''',
          );
          await preexistingScloudYamlFile
              .create(p.join(d.sandbox, 'topdir', 'project_dir'));

          pushCurrentDirectory(
              p.join(d.sandbox, 'topdir', 'project_dir', 'project_flutter'));

          commandResult = cli.run([
            'project',
            'link',
            '--project-dir',
            p.join(d.sandbox, 'topdir', 'project_dir', 'project_server'),
            '--project-config-file',
            p.join(d.sandbox, 'topdir', 'project_dir', 'custom_scloud.yaml'),
            '--project',
            'customProjectId',
          ]);
        });

        test('then project link command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then project link command logs info message', () async {
          final expectedConfigDirPath =
              p.join(d.sandbox, 'topdir', 'project_dir');

          await commandResult;
          expect(logger.infoCalls, isNotEmpty);
          expect(
            logger.infoCalls.first,
            equalsInfoCall(
              message:
                  "Wrote the '${p.join(expectedConfigDirPath, 'custom_scloud.yaml')}' configuration file for 'customProjectId'.",
            ),
          );
        });

        test('then scloud.yaml is updated in the project dir', () async {
          await commandResult;
          final expected = d.dir('topdir', [
            d.dir('project_dir', [
              d.dir('project_server', [
                d.nothing('scloud.yaml'),
              ]),
              d.dir('project_client', [
                d.nothing('scloud.yaml'),
              ]),
              d.dir('project_flutter', [
                d.nothing('scloud.yaml'),
              ]),
              d.file('scloud.yaml', contains('''
project:
  projectId: "otherProjectId"
''')),
              d.file('custom_scloud.yaml', contains('''
project:
  projectId: "customProjectId"
''')),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });
    });
  });
}

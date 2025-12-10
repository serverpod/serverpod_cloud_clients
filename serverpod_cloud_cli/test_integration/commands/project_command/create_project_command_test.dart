@Tags(['concurrency_one']) // due to current directory manipulation
library;

import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/project_factory.dart';
import '../../../test_utils/push_current_dir.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  const projectId = 'projectId';

  tearDown(() {
    logger.clear();
  });

  group('Given authenticated', () {
    setUp(() async {
      when(() => client.projects.createProject(
            cloudProjectId: any(named: 'cloudProjectId'),
          )).thenAnswer(
        (final invocation) async => Future.value(
          ProjectBuilder()
              .withCloudProjectId(invocation.namedArguments[#cloudProjectId])
              .build(),
        ),
      );

      when(() => client.projects.fetchProjectConfig(
            cloudProjectId: any(named: 'cloudProjectId'),
          )).thenAnswer(
        (final invocation) async => Future.value(
          ProjectConfig(projectId: invocation.namedArguments[#cloudProjectId]),
        ),
      );

      when(() => client.plans.listProcuredPlanNames()).thenAnswer(
        (final invocation) async => Future.value([]),
      );

      when(() => client.plans
              .procurePlan(planProductName: any(named: 'planProductName')))
          .thenAnswer((final invocation) async => Future.value());
    });

    group('and inside a serverpod directory', () {
      late String serverDir;

      setUp(() async {
        await ProjectFactory.serverpodServerDir(
          withDirectoryName: 'server_dir',
        ).create();
        serverDir = p.join(d.sandbox, 'server_dir');
        pushCurrentDirectory(serverDir);
      });

      group('when calling create and declining new project cost acceptance',
          () {
        late Future commandResult;
        setUp(() async {
          logger.answerNextConfirmWith(
            false, // decline new project cost acceptance
          );

          commandResult = cli.run([
            'project',
            'create',
            projectId,
            '--no-enable-db',
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs confirmation question', () async {
          await commandResult.catchError((final _) {});

          expect(logger.confirmCalls, hasLength(1));
          expect(
            logger.confirmCalls.single,
            equalsConfirmCall(
              message:
                  'Depending on your subscription, a new project may incur additional costs. Continue?',
              defaultValue: true,
            ),
          );
        });
      });

      group('without scloud.yaml file when calling create', () {
        late Future commandResult;
        setUp(() async {
          logger.answerNextConfirmWith(
            true, // accept new project cost acceptance
          );

          commandResult = cli.run([
            'project',
            'create',
            projectId,
            '--no-enable-db',
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then logs confirmation question', () async {
          await commandResult.catchError((final _) {});

          expect(logger.confirmCalls, hasLength(1));
          expect(
            logger.confirmCalls.single,
            equalsConfirmCall(
              message:
                  'Depending on your subscription, a new project may incur additional costs. Continue?',
              defaultValue: true,
            ),
          );
        });

        test('then logs success message', () async {
          await commandResult;

          expect(logger.successCalls, hasLength(1));
          expect(
            logger.successCalls.single,
            equalsSuccessCall(
              message: "Serverpod Cloud project created.",
              newParagraph: true,
            ),
          );
        });

        test('then writes scloud.yaml file', () async {
          await commandResult;

          final expected = d.dir(serverDir, [
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

        test('then writes .scloudignore file', () async {
          await commandResult;

          final expected = d.dir(serverDir, [
            d.file(
              '.scloudignore',
              contains('# .scloudignore'),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('with existing scloud.yaml file when calling create', () {
        late Future commandResult;
        setUp(() async {
          await d.dir(serverDir, [
            ProjectFactory.serverpodServerPubspec(),
            d.file('scloud.yaml', '''
project:
  projectId: "otherProjectId"
'''),
          ]).create();

          logger.answerNextConfirmWith(
            true, // accept new project cost acceptance
          );
          commandResult = cli.run([
            'project',
            'create',
            projectId,
            '--no-enable-db',
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then logs success message', () async {
          await commandResult;

          expect(logger.successCalls, hasLength(1));
          expect(
            logger.successCalls.single,
            equalsSuccessCall(
              message: "Serverpod Cloud project created.",
              newParagraph: true,
            ),
          );
        });

        test('then does not update existing scloud.yaml file', () async {
          await commandResult;

          final expected = d.dir(serverDir, [
            d.file(
              'scloud.yaml',
              contains('''
project:
  projectId: "otherProjectId"
'''),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('without .scloudignore file when calling create', () {
        late Future commandResult;
        setUp(() async {
          await ProjectFactory.serverpodServerDir(
            withDirectoryName: serverDir,
          ).create();

          logger.answerNextConfirmWith(
            true, // accept new project cost acceptance
          );
          commandResult = cli.run([
            'project',
            'create',
            projectId,
            '--no-enable-db',
          ]);
        });

        test('then writes .scloudignore file', () async {
          await commandResult;

          final expected = d.dir(serverDir, [
            d.file(
              '.scloudignore',
              contains('# .scloudignore'),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('with a custom .scloudignore file when calling create', () {
        late Future commandResult;
        setUp(() async {
          await d.dir(serverDir, [
            ProjectFactory.serverpodServerPubspec(),
            d.file('.scloudignore', '# Custom .scloudignore file'),
          ]).create();

          logger.answerNextConfirmWith(
            true, // accept new project cost acceptance
          );
          commandResult = cli.run([
            'project',
            'create',
            projectId,
            '--no-enable-db',
          ]);
        });

        test('then the content of the .scloudignore file is not changed',
            () async {
          await commandResult;

          final expected = d.dir(serverDir, [
            d.file(
              '.scloudignore',
              contains('# Custom .scloudignore file'),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });
    });

    group('and inside a dart (but not Serverpod) directory when calling create',
        () {
      late Future commandResult;

      setUp(() async {
        await d.dir('dart_dir', [
          d.file('pubspec.yaml', '''
name: my_own_server
dependencies:
  test: 1.0
'''),
        ]).create();
        final dartDir = p.absolute(d.sandbox, 'dart_dir');
        pushCurrentDirectory(dartDir);

        logger.answerNextConfirmWith(
          true, // accept new project cost acceptance
        );
        commandResult = cli.run([
          'project',
          'create',
          projectId,
          '--no-enable-db',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.successCalls, hasLength(1));
        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message: "Serverpod Cloud project created.",
            newParagraph: true,
          ),
        );
      });

      test('then does not write scloud.yaml file', () async {
        await commandResult;

        final expected = d.dir('dart_dir', [
          d.nothing('scloud.yaml'),
        ]);
        await expectLater(expected.validate(), completes);
      });
    });

    group('and in a non-dart directory when calling create', () {
      late Future commandResult;

      setUp(() async {
        await d.dir('other_dir').create();
        final otherDir = p.absolute(d.sandbox, 'other_dir');
        pushCurrentDirectory(otherDir);

        logger.answerNextConfirmWith(
          true, // accept new project cost acceptance
        );
        commandResult = cli.run([
          'project',
          'create',
          projectId,
          '--no-enable-db',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.successCalls, hasLength(1));
        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message: "Serverpod Cloud project created.",
            newParagraph: true,
          ),
        );
      });

      test('then does not write scloud.yaml file', () async {
        await commandResult;

        final expected = d.dir('other_dir', [
          d.nothing('scloud.yaml'),
        ]);
        await expectLater(expected.validate(), completes);
      });

      test(
          'then informs the user that they have to run the link '
          'command in the project server folder', () async {
        await commandResult;

        expect(logger.terminalCommandCalls, isNotEmpty);
        expect(
          logger.terminalCommandCalls.last,
          equalsTerminalCommandCall(
            message: 'Since no Serverpod server directory was identified, '
                'an scloud.yaml configuration file has not been created. '
                'Use the link command to create it in the server directory of this project:',
            newParagraph: true,
            command: 'scloud project link --project $projectId',
          ),
        );
      });
    });

    group('and in a directory 3 levels up from a serverpod directory', () {
      late Future commandResult;

      setUp(() async {
        await d.dir('grandparent_dir', [
          d.dir('parent_dir', [
            d.dir('server_dir', [
              ProjectFactory.serverpodServerPubspec(),
            ])
          ])
        ]).create();
        pushCurrentDirectory(d.sandbox);
      });

      group('when calling create without --project-dir option', () {
        setUp(() async {
          logger.answerNextConfirmWith(
            true, // accept new project cost acceptance
          );
          commandResult = cli.run([
            'project',
            'create',
            projectId,
            '--no-enable-db',
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then logs success message', () async {
          await commandResult;

          expect(logger.successCalls, hasLength(1));
          expect(
            logger.successCalls.single,
            equalsSuccessCall(
              message: "Serverpod Cloud project created.",
              newParagraph: true,
            ),
          );
        });

        test('then does not write scloud.yaml file', () async {
          await commandResult;

          final expected = d.dir('grandparent_dir', [
            d.dir('parent_dir', [
              d.nothing('scloud.yaml'),
              d.dir('server_dir', [
                d.nothing('scloud.yaml'),
              ]),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });

        test(
            'then informs the user that they have to run the link '
            'command in the project server folder', () async {
          await commandResult;

          expect(logger.terminalCommandCalls, isNotEmpty);
          expect(
            logger.terminalCommandCalls.last,
            equalsTerminalCommandCall(
              message: 'Since no Serverpod server directory was identified, '
                  'an scloud.yaml configuration file has not been created. '
                  'Use the link command to create it in the server directory of this project:',
              newParagraph: true,
              command: 'scloud project link --project $projectId',
            ),
          );
        });
      });

      group('when calling create with --project-dir option', () {
        setUp(() async {
          logger.answerNextConfirmWith(
            true, // accept new project cost acceptance
          );
          commandResult = cli.run([
            'project',
            'create',
            projectId,
            '--project-dir',
            'grandparent_dir/parent_dir/server_dir',
            '--no-enable-db',
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then logs success message', () async {
          await commandResult;

          expect(logger.successCalls, hasLength(1));
          expect(
            logger.successCalls.single,
            equalsSuccessCall(
              message: "Serverpod Cloud project created.",
              newParagraph: true,
            ),
          );
        });

        test('then writes scloud.yaml file', () async {
          await commandResult;

          final expected = d.dir('grandparent_dir', [
            d.dir('parent_dir', [
              d.dir('server_dir', [
                d.file(
                  'scloud.yaml',
                  contains('''
project:
  projectId: "$projectId"
'''),
                ),
              ]),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });

        test('then writes .scloudignore file', () async {
          await commandResult;

          final expected = d.dir('grandparent_dir', [
            d.dir('parent_dir', [
              d.dir('server_dir', [
                d.file(
                  '.scloudignore',
                  contains('# .scloudignore'),
                ),
              ]),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group(
          'when calling create with --project-dir option with non-existing directory',
          () {
        test('then command throws UsageException', () async {
          await expectLater(
            cli.run([
              'project',
              'create',
              projectId,
              '--project-dir',
              'grandparent_dir/parent_dir/non_existing_dir',
              '--no-enable-db',
            ]),
            throwsA(isA<UsageException>().having(
              (final e) => e.message,
              'message',
              equals(
                'Invalid value for option `project-dir`: Directory '
                '"grandparent_dir/parent_dir/non_existing_dir" does not exist.',
              ),
            )),
          );
        });
      });
    });
  });
}

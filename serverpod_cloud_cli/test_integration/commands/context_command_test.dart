import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/context_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/scloud_settings_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';

import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/test_command_logger.dart';

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

  late String testConfigDirPath;

  setUp(() async {
    await d.dir('config_dir').create();
    testConfigDirPath = p.join(d.sandbox, 'config_dir');
  });

  tearDown(() async {
    logger.clear();
  });

  test(
    'Given context set command when instantiated then does not require login',
    () {
      expect(CloudContextSetCommand(logger: logger).requireLogin, isFalse);
    },
  );

  test(
    'Given context show command when instantiated then does not require login',
    () {
      expect(CloudContextShowCommand(logger: logger).requireLogin, isFalse);
    },
  );

  test(
    'Given context unset command when instantiated then does not require login',
    () {
      expect(CloudContextUnsetCommand(logger: logger).requireLogin, isFalse);
    },
  );

  test('Given context list command when instantiated then requires login', () {
    expect(CloudContextListCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given no global project context is set', () {
    group('when executing context show', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'context',
          'show',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs that no context is set', () async {
        await commandResult;

        expect(logger.infoCalls, isNotEmpty);
        expect(
          logger.infoCalls.first,
          equalsInfoCall(message: 'No global project context is set.'),
        );
      });
    });

    group('when executing context set', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'context',
          'set',
          'my-project',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs a success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'Set the global project context to "my-project".',
          ),
        );
      });

      test('then the context is persisted in the settings', () async {
        await commandResult;

        final settings = await ResourceManager.tryLoadSettings(
          localStoragePath: testConfigDirPath,
        );
        expect(settings?.projectContext, equals('my-project'));
      });
    });

    group('when executing context set without project id', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'context',
          'set',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test(
        'then throws UsageException that the project option is mandatory',
        () async {
          await expectLater(
            commandResult,
            throwsA(
              isA<UsageException>().having(
                (final e) => e.message,
                'message',
                equals('Option `project` is mandatory.'),
              ),
            ),
          );
        },
      );
    });

    group('when executing context unset', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'context',
          'unset',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs a success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(message: 'Unset the global project context.'),
        );
      });
    });
  });

  group('Given a global project context is set', () {
    setUp(() async {
      await ResourceManager.storeSettings(
        settings: ServerpodCloudSettingsData()..projectContext = 'my-project',
        localStoragePath: testConfigDirPath,
      );
    });

    group('when executing context show', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'context',
          'show',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the current context', () async {
        await commandResult;

        expect(logger.infoCalls, isNotEmpty);
        expect(logger.infoCalls.first, equalsInfoCall(message: 'my-project'));
      });
    });

    group('when executing context set with another project id', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'context',
          'set',
          'other-project',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then the context is updated in the settings', () async {
        await commandResult;

        final settings = await ResourceManager.tryLoadSettings(
          localStoragePath: testConfigDirPath,
        );
        expect(settings?.projectContext, equals('other-project'));
      });
    });

    group('when executing context unset', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'context',
          'unset',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then the context is unset in the settings', () async {
        await commandResult;

        final settings = await ResourceManager.tryLoadSettings(
          localStoragePath: testConfigDirPath,
        );
        expect(settings?.projectContext, isNull);
      });
    });
  });

  group('Given authenticated and projects exist', () {
    setUp(() async {
      final projects = [
        ProjectInfoBuilder()
            .withProject(
              ProjectBuilder()
                  .withCloudProjectId('projectId')
                  .withCreatedAt(DateTime.parse("2024-12-31 10:20:30")),
            )
            .withLatestDeployAttemptTime(DateTime.parse("2024-12-31 10:20:30"))
            .build(),
        ProjectInfoBuilder()
            .withProject(
              ProjectBuilder()
                  .withCloudProjectId('projectId2')
                  .withCreatedAt(DateTime.parse("2024-12-31 12:20:30"))
                  .withArchivedAt(DateTime.parse("2025-01-01 14:20:30")),
            )
            .withLatestDeployAttemptTime(DateTime.parse("2024-12-31 12:20:30"))
            .build(),
      ];

      when(
        () => client.projects.listProjectsInfo(
          includeLatestDeployAttemptTime: any(
            named: 'includeLatestDeployAttemptTime',
            that: isTrue,
          ),
        ),
      ).thenAnswer((final _) async => projects);
    });

    tearDown(() {
      reset(client.projects);
    });

    group('when executing context list', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'context',
          'list',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the list of projects', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(
              line: 'Project Id | Created At          | Last Deploy Attempt',
            ),
            equalsLineCall(
              line: '-----------+---------------------+--------------------',
            ),
            equalsLineCall(
              line: 'projectId  | 2024-12-31 10:20:30 | 2024-12-31 10:20:30',
            ),
          ]),
        );
      });

      test('then excludes archived projects', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((final call) => call.line),
          isNot(contains(startsWith('projectId2'))),
        );
      });
    });
  });
}

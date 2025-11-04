import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

import '../../../test_utils/command_logger_matchers.dart';
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

  tearDown(() async {
    await keyManager.remove();

    logger.clear();
  });

  test('Given project list command when instantiated then requires login', () {
    expect(CloudProjectListCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    setUpAll(() async {
      when(() => client.projects.listProjectsInfo(
            includeLatestDeployAttemptTime:
                any(named: 'includeLatestDeployAttemptTime'),
          )).thenThrow(ServerpodClientUnauthorized());
    });

    tearDownAll(() {
      reset(client.projects);
    });

    group('when executing project list', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'project',
          'list',
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
              message:
                  'The credentials for this session seem to no longer be valid.',
            ));
      });
    });
  });

  group('Given authenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    setUpAll(() async {
      final projects = [
        ProjectInfoBuilder()
            .withProject(ProjectBuilder()
                .withCloudProjectId('projectId')
                .withCreatedAt(DateTime.parse("2024-12-31 10:20:30")))
            .withLatestDeployAttemptTime(DateTime.parse("2024-12-31 10:20:30"))
            .build(),
        ProjectInfoBuilder()
            .withProject(ProjectBuilder()
                .withCloudProjectId('projectId2')
                .withCreatedAt(DateTime.parse("2024-12-31 12:20:30"))
                .withArchivedAt(DateTime.parse("2025-01-01 14:20:30")))
            .withLatestDeployAttemptTime(DateTime.parse("2024-12-31 12:20:30"))
            .build(),
        ProjectInfoBuilder()
            .withProject(ProjectBuilder()
                .withCloudProjectId('projectId3')
                .withCreatedAt(DateTime.parse("2024-12-30 10:20:30")))
            .withLatestDeployAttemptTime(null)
            .build(),
      ];

      when(() => client.projects.listProjectsInfo(
            includeLatestDeployAttemptTime:
                any(named: 'includeLatestDeployAttemptTime', that: isTrue),
          )).thenAnswer((final _) async => projects);
    });

    tearDownAll(() {
      reset(client.projects);
    });

    group('when executing project list without options', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'project',
          'list',
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the ordered list of projects', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(
                line: 'Project Id | Created At          | Last Deploy Attempt'),
            equalsLineCall(
                line: '-----------+---------------------+--------------------'),
            equalsLineCall(
                line: 'projectId3 | 2024-12-30 10:20:30 |                    '),
            equalsLineCall(
                line: 'projectId  | 2024-12-31 10:20:30 | 2024-12-31 10:20:30'),
          ]),
        );
      });

      test('then outputs list of projects exluding those archived', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls.map((final call) => call.line),
          isNot(contains('projectId2')),
        );
      });
    });

    group('when executing project list with --all', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'project',
          'list',
          '--all',
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the ordered list of projects', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(
                line:
                    'Project Id | Created At          | Last Deploy Attempt | Deleted At         '),
            equalsLineCall(
                line:
                    '-----------+---------------------+---------------------+--------------------'),
            equalsLineCall(
                line:
                    'projectId3 | 2024-12-30 10:20:30 |                     |                    '),
            equalsLineCall(
                line:
                    'projectId  | 2024-12-31 10:20:30 | 2024-12-31 10:20:30 |                    '),
            equalsLineCall(
                line:
                    'projectId2 | 2024-12-31 12:20:30 | 2024-12-31 12:20:30 | 2025-01-01 14:20:30'),
          ]),
        );
      });
    });
  });
}

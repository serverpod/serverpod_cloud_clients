import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

import '../../../test_utils/command_logger_matchers.dart';
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

  tearDown(() async {
    logger.clear();
  });

  test('Given project list command when instantiated then requires login', () {
    expect(CloudProjectListCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given authenticated', () {
    setUpAll(() async {
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
        ProjectInfoBuilder()
            .withProject(
              ProjectBuilder()
                  .withCloudProjectId('projectId3')
                  .withCreatedAt(DateTime.parse("2024-12-30 10:20:30")),
            )
            .withLatestDeployAttemptTime(null)
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

    tearDownAll(() {
      reset(client.projects);
    });

    group('when executing project list without options', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run(['project', 'list']);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the ordered list of projects', () async {
        await commandResult;

        expect(logger.outputTableCalls, isNotEmpty);
        expect(
          logger.outputTableCalls.first,
          equalsOutputTableCall(
            headers: ['Project Id', 'Created At', 'Last Deploy Attempt'],
            rows: [
              ['projectId3', '2024-12-30 10:20:30', null],
              ['projectId', '2024-12-31 10:20:30', '2024-12-31 10:20:30'],
            ],
          ),
        );
      });

      test('then outputs list of projects exluding those archived', () async {
        await commandResult;

        expect(logger.outputTableCalls, isNotEmpty);
        final rows = logger.outputTableCalls.first.rows;
        expect(
          rows.expand((final row) => row).whereType<String>(),
          isNot(contains('projectId2')),
        );
      });
    });

    group('when executing project list with --all', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run(['project', 'list', '--all']);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the ordered list of projects', () async {
        await commandResult;

        expect(logger.outputTableCalls, isNotEmpty);
        expect(
          logger.outputTableCalls.first,
          equalsOutputTableCall(
            headers: [
              'Project Id',
              'Created At',
              'Last Deploy Attempt',
              'Deleted At',
            ],
            rows: [
              ['projectId3', '2024-12-30 10:20:30', null, null],
              ['projectId', '2024-12-31 10:20:30', '2024-12-31 10:20:30', null],
              [
                'projectId2',
                '2024-12-31 12:20:30',
                '2024-12-31 12:20:30',
                '2025-01-01 14:20:30',
              ],
            ],
          ),
        );
      });
    });
  });
}

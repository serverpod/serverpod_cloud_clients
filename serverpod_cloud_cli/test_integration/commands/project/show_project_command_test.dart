import 'dart:async';
import 'dart:convert';

import 'package:cli_tools/cli_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project/project_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';

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
      apiClientFactory: (globalCfg) => client,
    ),
  );

  const projectId = 'projectId';

  tearDown(() async {
    logger.clear();
  });

  void stubProjectInfo() {
    when(
      () => client.projects.fetchProjectInfo(
        cloudProjectId: projectId,
        includeLatestDeployAttemptTime: any(
          named: 'includeLatestDeployAttemptTime',
          that: isTrue,
        ),
      ),
    ).thenAnswer(
      (_) async => ProjectInfoBuilder()
          .withProject(
            ProjectBuilder()
                .withCloudProjectId(projectId)
                .withCreatedAt(DateTime.parse('2024-12-31 10:20:30'))
                .withCapsules([
                  CapsuleBuilder()
                      .withCloudCapsuleId(projectId)
                      .withRegion(ServerpodRegion.usEast)
                      .build(),
                ]),
          )
          .withLatestDeployAttemptTime(DateTime.parse('2025-01-02 08:00:00'))
          .build(),
    );
  }

  List<String> tableLines() {
    return logger.lineCalls.map((call) => call.line.trimRight()).toList();
  }

  test('Given project show command when instantiated then requires login', () {
    expect(CloudProjectShowCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated when executing project show', () {
    setUpAll(() {
      when(
        () => client.projects.fetchProjectInfo(
          cloudProjectId: any(named: 'cloudProjectId'),
          includeLatestDeployAttemptTime: any(
            named: 'includeLatestDeployAttemptTime',
          ),
        ),
      ).thenThrow(ServerpodClientUnauthorized());
    });

    tearDownAll(() {
      reset(client.projects);
    });

    late Future commandResult;
    setUp(() {
      commandResult = cli.run(['project', 'show', projectId]);
    });

    test('then throws exception', () async {
      await expectLater(commandResult, throwsA(isA<ExitException>()));
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
        ),
      );
    });
  });

  group('Given a project with a plan, compute and database', () {
    setUpAll(() {
      stubProjectInfo();
      when(
        () => client.plans.getSubscriptionInfoOfProject(
          cloudProjectId: projectId,
        ),
      ).thenAnswer(
        (_) async => SubscriptionInfoBuilder()
            .withPlanType(PlanType.growth)
            .withPlanDisplayName('Growth')
            .withStartDate(DateTime.parse('2024-12-31 10:20:30'))
            .withTrialEndDate(DateTime.parse('2025-01-14 10:20:30'))
            .build(),
      );
      when(
        () => client.compute.readCompute(cloudCapsuleId: projectId),
      ).thenAnswer(
        (_) async => ComputeInfoBuilder()
            .withSize(ComputeSizeOption.medium)
            .withMemoryMb(1024)
            .withMinInstances(1)
            .withMaxInstances(3)
            .build(),
      );
      when(
        () => client.database.readDatabase(cloudCapsuleId: projectId),
      ).thenAnswer(
        (_) async => DatabaseInfoBuilder()
            .withSize(DatabaseSizeOption.small)
            .withMemoryMb(2048)
            .withMinCu(0.5)
            .withMaxCu(2)
            .withStorageLimitGB(10)
            .withComputeHoursLimit(300)
            .build(),
      );
    });

    tearDownAll(() {
      reset(client.projects);
      reset(client.plans);
      reset(client.compute);
      reset(client.database);
    });

    group('when executing project show', () {
      setUp(() async {
        await cli.run(['project', 'show', projectId]);
      });

      test('then renders the project profile table', () {
        expect(tableLines(), [
          '',
          '  Project   projectId',
          '  Created   2024-12-31 10:20:30 (local)',
          '  Region    US East',
          '  Deployed  2025-01-02 08:00:00 (local)',
          '',
          '  Plan      Growth',
          '  Trial     ends 2025-01-14 10:20:30 (local)',
          '',
          '  Compute   medium — 1024 MB, 1-3 podlets',
          '  Database  small — 2048 MB, 0.5-2 CU, 10 GB storage, 300 h compute',
        ]);
      });
    });

    group('when executing project show with --utc', () {
      setUp(() async {
        await cli.run(['project', 'show', projectId, '--utc']);
      });

      test('then renders the timestamps in UTC', () {
        expect(
          tableLines(),
          contains(
            '  Created   '
            '${DateTime.parse('2024-12-31 10:20:30').toUtc().toString().substring(0, 19)}'
            ' (UTC)',
          ),
        );
      });
    });

    group('when executing project show with --format json', () {
      setUp(() async {
        await cli.run(['project', 'show', projectId, '--format', 'json']);
      });

      test('then emits the project profile as a JSON object', () {
        expect(logger.lineCalls, isEmpty);

        final payload = jsonDecode(logger.rawCalls.single.content) as Map;
        expect(payload['projectId'], projectId);
        expect(
          payload['createdAt'],
          DateTime.parse('2024-12-31 10:20:30').toUtc().toIso8601String(),
        );
        expect(payload['region'], 'usEast');
        expect(
          payload['latestDeployAttemptAt'],
          DateTime.parse('2025-01-02 08:00:00').toUtc().toIso8601String(),
        );
        expect(payload['plan'], containsPair('type', 'growth'));
        expect(payload['plan'], containsPair('displayName', 'Growth'));
        expect(payload['compute'], containsPair('size', 'medium'));
        expect(payload['compute'], containsPair('memoryMb', 1024));
        expect(payload['compute'], containsPair('minInstances', 1));
        expect(payload['compute'], containsPair('maxInstances', 3));
        expect(payload['database'], containsPair('size', 'small'));
        expect(payload['database'], containsPair('minCu', 0.5));
        expect(payload['database'], containsPair('maxCu', 2.0));
        expect(payload['database'], containsPair('storageLimitGb', 10));
        expect(payload['database'], containsPair('computeHoursLimit', 300));
      });
    });

    group('when executing project show with --format yaml', () {
      setUp(() async {
        await cli.run(['project', 'show', projectId, '--format', 'yaml']);
      });

      test('then emits the project profile as a YAML document', () {
        expect(logger.lineCalls, isEmpty);

        final payload = yamlDecode(logger.rawCalls.single.content) as Map;
        expect(payload['projectId'], projectId);
        expect(payload['region'], 'usEast');
        expect(payload['plan'], containsPair('displayName', 'Growth'));
        expect(payload['compute'], containsPair('size', 'medium'));
        expect(payload['database'], containsPair('size', 'small'));
      });
    });
  });

  group('Given a project without a plan, compute or database', () {
    setUpAll(() {
      stubProjectInfo();
      when(
        () => client.plans.getSubscriptionInfoOfProject(
          cloudProjectId: projectId,
        ),
      ).thenThrow(NotFoundException(message: 'Subscription not found'));
      when(
        () => client.compute.readCompute(cloudCapsuleId: projectId),
      ).thenThrow(NotFoundException(message: 'Resource config not found'));
      when(
        () => client.database.readDatabase(cloudCapsuleId: projectId),
      ).thenThrow(NotFoundException(message: 'Database not found'));
    });

    tearDownAll(() {
      reset(client.projects);
      reset(client.plans);
      reset(client.compute);
      reset(client.database);
    });

    group('when executing project show', () {
      setUp(() async {
        await cli.run(['project', 'show', projectId]);
      });

      test('then reports the absent resources', () {
        expect(
          tableLines(),
          containsAllInOrder([
            '  Plan      none',
            '  Compute   not configured',
            '  Database  not enabled',
          ]),
        );
      });
    });

    group('when executing project show with --format json', () {
      setUp(() async {
        await cli.run(['project', 'show', projectId, '--format', 'json']);
      });

      test('then emits null for the absent resources', () {
        final payload = jsonDecode(logger.rawCalls.single.content) as Map;
        expect(payload['plan'], isNull);
        expect(payload['compute'], isNull);
        expect(payload['database'], isNull);
      });
    });
  });

  group('Given a project that does not exist', () {
    setUpAll(() {
      when(
        () => client.projects.fetchProjectInfo(
          cloudProjectId: any(named: 'cloudProjectId'),
          includeLatestDeployAttemptTime: any(
            named: 'includeLatestDeployAttemptTime',
          ),
        ),
      ).thenThrow(NotFoundException(message: 'Project not found'));
    });

    tearDownAll(() {
      reset(client.projects);
    });

    late Future commandResult;
    setUp(() {
      commandResult = cli.run(['project', 'show', projectId]);
    });

    test('then throws exception', () async {
      await expectLater(commandResult, throwsA(isA<ExitException>()));
    });

    test('then logs that the project was not found', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(logger.errorCalls, isNotEmpty);
      expect(
        logger.errorCalls.first,
        equalsErrorCall(message: 'Project "$projectId" was not found.'),
      );
    });
  });
}

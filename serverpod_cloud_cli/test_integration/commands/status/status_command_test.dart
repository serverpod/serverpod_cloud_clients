import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';

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

  tearDown(() async {
    logger.clear();
    reset(client.status);
  });

  const projectId = 'my-project';

  DeployAttemptSummary servingSummary() {
    return DeployAttemptSummary(
      attemptId: Uuid().v4obj(),
      commitHash: '8f3c2a1',
      commitMessage: 'Fix session timeout',
      branch: 'main',
      deployedBy: UserBuilder().withName('Alice').build(),
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      endedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  DeployAttemptSummary incomingSummary() {
    return DeployAttemptSummary(
      attemptId: Uuid().v4obj(),
      commitHash: '9d4e7b2',
      commitMessage: 'Add push notifications',
      branch: 'main',
      deployedBy: UserBuilder().withName('Alice').build(),
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );
  }

  DeployAttemptSummary buildingSummary() {
    return DeployAttemptSummary(
      attemptId: Uuid().v4obj(),
      status: DeployProgressStatus.running,
      commitHash: '9d4e7b2',
      commitMessage: 'Add push notifications',
      branch: 'main',
      deployedBy: UserBuilder().withName('Alice').build(),
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );
  }

  DeployAttemptSummary failedSummary() {
    return DeployAttemptSummary(
      attemptId: Uuid().v4obj(),
      status: DeployProgressStatus.failure,
      commitHash: '9d4e7b2',
      commitMessage: 'Add push notifications',
      branch: 'main',
      deployedBy: UserBuilder().withName('Alice').build(),
      startedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      endedAt: DateTime.now().subtract(const Duration(minutes: 20)),
    );
  }

  CapsuleStatus runningStatus() {
    return CapsuleStatus(
      cloudCapsuleId: projectId,
      status: CapsuleState.ready,
      deployment: CapsuleDeploymentStatus(
        name: 'app',
        state: CapsuleState.ready,
        desiredReplicas: 2,
        readyReplicas: 2,
      ),
    );
  }

  void stubRuntimeStatus(CapsuleRuntimeStatus runtime) {
    when(
      () => client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId),
    ).thenAnswer((_) async => runtime);
  }

  List<String> panelLines() {
    return logger.lineCalls.map((call) => call.line).toList();
  }

  test('Given status command when instantiated then requires login', () {
    expect(CloudStatusCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given a running capsule when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: CapsuleStatus(
            cloudCapsuleId: projectId,
            status: CapsuleState.ready,
            deployment: CapsuleDeploymentStatus(
              name: 'app',
              state: CapsuleState.ready,
              desiredReplicas: 2,
              readyReplicas: 2,
            ),
          ),
          serving: servingSummary(),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the running panel with the url footer', () {
      expect(panelLines(), [
        '',
        '  Status    ● Running',
        '  Podlets   2/2 ready',
        '  Serving   Deployed 2 hours ago by Alice',
        '            8f3c2a1  Fix session timeout',
        '',
        '  api       https://my-project.api.serverpod.space/',
        '  insights  https://my-project.insights.serverpod.space/',
        '  web       https://my-project.serverpod.space/',
      ]);
    });
  });

  group(
    'Given a deploy older than 7 days when executing status with --utc',
    () {
      setUp(() async {
        stubRuntimeStatus(
          CapsuleRuntimeStatus(
            status: CapsuleStatus(
              cloudCapsuleId: projectId,
              status: CapsuleState.ready,
              deployment: CapsuleDeploymentStatus(
                name: 'app',
                state: CapsuleState.ready,
                desiredReplicas: 2,
                readyReplicas: 2,
              ),
            ),
            serving: DeployAttemptSummary(
              attemptId: Uuid().v4obj(),
              commitHash: '8f3c2a1',
              commitMessage: 'Fix session timeout',
              branch: 'main',
              deployedBy: UserBuilder().withName('Alice').build(),
              startedAt: DateTime.utc(2026, 6, 1, 10, 30, 0),
              endedAt: DateTime.utc(2026, 6, 1, 10, 30, 0),
            ),
          ),
        );

        await cli.run(['status', '--project', projectId, '--utc']);
      });

      test('then renders an absolute utc timestamp', () {
        expect(
          panelLines(),
          contains('  Serving   Deployed 2026-06-01 10:30:00z by Alice'),
        );
      });
    },
  );

  group('Given a running capsule with an unmatched serving revision '
      'when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: CapsuleStatus(
            cloudCapsuleId: projectId,
            status: CapsuleState.ready,
            deployment: CapsuleDeploymentStatus(
              name: 'app',
              state: CapsuleState.ready,
              desiredReplicas: 2,
              readyReplicas: 2,
            ),
          ),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the panel without deployment rows', () {
      expect(panelLines(), [
        '',
        '  Status    ● Running',
        '  Podlets   2/2 ready',
        '',
        '  api       https://my-project.api.serverpod.space/',
        '  insights  https://my-project.insights.serverpod.space/',
        '  web       https://my-project.serverpod.space/',
      ]);
    });
  });

  group(
    'Given a serving deploy without commit metadata when executing status',
    () {
      setUp(() async {
        stubRuntimeStatus(
          CapsuleRuntimeStatus(
            status: CapsuleStatus(
              cloudCapsuleId: projectId,
              status: CapsuleState.ready,
              deployment: CapsuleDeploymentStatus(
                name: 'app',
                state: CapsuleState.ready,
                desiredReplicas: 2,
                readyReplicas: 2,
              ),
            ),
            serving: DeployAttemptSummary(
              attemptId: Uuid().v4obj(),
              deployedBy: UserBuilder()
                  .withName(null)
                  .withEmail('alice@example.com')
                  .build(),
              startedAt: DateTime.now().subtract(const Duration(hours: 2)),
              endedAt: DateTime.now().subtract(const Duration(hours: 2)),
            ),
          ),
        );

        await cli.run(['status', '--project', projectId]);
      });

      test('then renders the serving row without a commit line '
          'and with the deployer email', () {
        expect(panelLines(), [
          '',
          '  Status    ● Running',
          '  Podlets   2/2 ready',
          '  Serving   Deployed 2 hours ago by alice@example.com',
          '',
          '  api       https://my-project.api.serverpod.space/',
          '  insights  https://my-project.insights.serverpod.space/',
          '  web       https://my-project.serverpod.space/',
        ]);
      });
    },
  );

  group('Given a rollout in flight when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: CapsuleStatus(
            cloudCapsuleId: projectId,
            status: CapsuleState.progressing,
            deployment: CapsuleDeploymentStatus(
              name: 'app',
              state: CapsuleState.progressing,
              desiredReplicas: 2,
              readyReplicas: 1,
            ),
          ),
          serving: servingSummary(),
          incoming: incomingSummary(),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the deploying panel with the incoming block', () {
      expect(panelLines(), [
        '',
        '  Status    ◐ Deploying',
        '  Podlets   1/2 ready',
        '  Serving   Deployed 2 hours ago by Alice',
        '            8f3c2a1  Fix session timeout',
        '',
        '  Incoming  Started 5 minutes ago by Alice',
        '            9d4e7b2  Add push notifications',
        '',
        '  Follow the rollout: scloud deployment show',
      ]);
    });
  });

  group('Given a running capsule with a build in flight '
      'when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: runningStatus(),
          serving: servingSummary(),
          latestAttempt: buildingSummary(),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the building block with the build hint '
        'and no url footer', () {
      expect(panelLines(), [
        '',
        '  Status    ● Running',
        '  Podlets   2/2 ready',
        '  Serving   Deployed 2 hours ago by Alice',
        '            8f3c2a1  Fix session timeout',
        '',
        '  Building  Started 5 minutes ago by Alice',
        '            9d4e7b2  Add push notifications',
        '',
        '  Follow the build: scloud deployment show',
      ]);
    });
  });

  group('Given a first deploy that is building when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: CapsuleStatus(
            cloudCapsuleId: projectId,
            status: CapsuleState.notProvisioned,
          ),
          latestAttempt: buildingSummary(),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the derived building state', () {
      expect(panelLines(), [
        '',
        '  Status    ◌ Building — first deploy in progress',
        '  Building  Started 5 minutes ago by Alice',
        '            9d4e7b2  Add push notifications',
        '',
        '  Follow the build: scloud deployment show',
      ]);
    });
  });

  group('Given a running capsule whose latest deploy failed '
      'when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: runningStatus(),
          serving: servingSummary(),
          latestAttempt: failedSummary(),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the failed block with the diagnosis hint', () {
      expect(panelLines(), [
        '',
        '  Status    ● Running',
        '  Podlets   2/2 ready',
        '  Serving   Deployed 2 hours ago by Alice',
        '            8f3c2a1  Fix session timeout',
        '',
        '  Failed    Deployment 20 minutes ago by Alice',
        '            9d4e7b2  Add push notifications',
        '',
        '  See what went wrong: scloud deployment show',
      ]);
    });
  });

  group('Given a first deploy that failed when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: CapsuleStatus(
            cloudCapsuleId: projectId,
            status: CapsuleState.notProvisioned,
          ),
          latestAttempt: failedSummary(),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the not deployed state with the failed block', () {
      expect(panelLines(), [
        '',
        '  Status    ○ Not deployed',
        '  Failed    Deployment 20 minutes ago by Alice',
        '            9d4e7b2  Add push notifications',
        '',
        '  See what went wrong: scloud deployment show',
      ]);
    });
  });

  group('Given a cancelled latest deploy when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: runningStatus(),
          serving: servingSummary(),
          latestAttempt: DeployAttemptSummary(
            attemptId: Uuid().v4obj(),
            status: DeployProgressStatus.cancelled,
            deployedBy: UserBuilder().withName('Alice').build(),
            startedAt: DateTime.now().subtract(const Duration(minutes: 25)),
            endedAt: DateTime.now().subtract(const Duration(minutes: 20)),
          ),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the cancelled block', () {
      expect(panelLines(), contains('  Cancelled 20 minutes ago by Alice'));
    });
  });

  group(
    'Given a successful unmatched latest attempt when executing status',
    () {
      setUp(() async {
        stubRuntimeStatus(
          CapsuleRuntimeStatus(
            status: runningStatus(),
            serving: servingSummary(),
            latestAttempt: DeployAttemptSummary(
              attemptId: Uuid().v4obj(),
              status: DeployProgressStatus.success,
              deployedBy: UserBuilder().withName('Alice').build(),
              startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
            ),
          ),
        );

        await cli.run(['status', '--project', projectId]);
      });

      test('then renders the quiet running panel with the url footer', () {
        expect(panelLines(), [
          '',
          '  Status    ● Running',
          '  Podlets   2/2 ready',
          '  Serving   Deployed 2 hours ago by Alice',
          '            8f3c2a1  Fix session timeout',
          '',
          '  api       https://my-project.api.serverpod.space/',
          '  insights  https://my-project.insights.serverpod.space/',
          '  web       https://my-project.serverpod.space/',
        ]);
      });
    },
  );

  group('Given a degraded capsule whose latest deploy failed '
      'when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: CapsuleStatus(
            cloudCapsuleId: projectId,
            status: CapsuleState.degraded,
            deployment: CapsuleDeploymentStatus(
              name: 'app',
              state: CapsuleState.degraded,
              desiredReplicas: 2,
              readyReplicas: 1,
            ),
          ),
          serving: servingSummary(),
          latestAttempt: failedSummary(),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then the runtime hint outranks the failed deploy hint', () {
      expect(panelLines(), [
        '',
        '  Status    ◑ Degraded — 1 of 2 podlets is not ready',
        '  Podlets   1/2 ready',
        '  Serving   Deployed 2 hours ago by Alice',
        '            8f3c2a1  Fix session timeout',
        '',
        '  Failed    Deployment 20 minutes ago by Alice',
        '            9d4e7b2  Add push notifications',
        '',
        '  Check for errors: scloud log --tail',
      ]);
    });
  });

  group('Given a degraded capsule when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: CapsuleStatus(
            cloudCapsuleId: projectId,
            status: CapsuleState.degraded,
            deployment: CapsuleDeploymentStatus(
              name: 'app',
              state: CapsuleState.degraded,
              desiredReplicas: 2,
              readyReplicas: 1,
            ),
          ),
          serving: servingSummary(),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the degraded panel with the diagnosis', () {
      expect(panelLines(), [
        '',
        '  Status    ◑ Degraded — 1 of 2 podlets is not ready',
        '  Podlets   1/2 ready',
        '  Serving   Deployed 2 hours ago by Alice',
        '            8f3c2a1  Fix session timeout',
        '',
        '  Check for errors: scloud log --tail',
      ]);
    });
  });

  group('Given an unavailable capsule when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: CapsuleStatus(
            cloudCapsuleId: projectId,
            status: CapsuleState.unavailable,
            deployment: CapsuleDeploymentStatus(
              name: 'app',
              state: CapsuleState.unavailable,
              desiredReplicas: 2,
              readyReplicas: 0,
            ),
          ),
          serving: servingSummary(),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the down panel with the deployed label', () {
      expect(panelLines(), [
        '',
        '  Status    ✖ Down — no podlets are ready',
        '  Podlets   0/2 ready',
        '  Deployed  Deployed 2 hours ago by Alice',
        '            8f3c2a1  Fix session timeout',
        '',
        '  Check for crash output: scloud log',
      ]);
    });
  });

  group('Given a suspended capsule when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: CapsuleStatus(
            cloudCapsuleId: projectId,
            status: CapsuleState.suspended,
            deployment: CapsuleDeploymentStatus(
              name: 'app',
              state: CapsuleState.suspended,
              desiredReplicas: 0,
              readyReplicas: 0,
            ),
          ),
          serving: servingSummary(),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the suspended panel without a podlets row', () {
      expect(panelLines(), [
        '',
        '  Status    ⏸ Suspended',
        '  Deployed  Deployed 2 hours ago by Alice',
        '            8f3c2a1  Fix session timeout',
        '',
        '  Resume the project from the Serverpod Cloud console.',
      ]);
    });
  });

  group('Given a capsule without a deployment when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: CapsuleStatus(
            cloudCapsuleId: projectId,
            status: CapsuleState.notProvisioned,
          ),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the not deployed panel with the deploy hint', () {
      expect(panelLines(), [
        '',
        '  Status    ○ Not deployed',
        '',
        '  Launch your project: scloud launch',
      ]);
    });
  });

  group('Given an unrecognized capsule state when executing status', () {
    setUp(() async {
      stubRuntimeStatus(
        CapsuleRuntimeStatus(
          status: CapsuleStatus(
            cloudCapsuleId: projectId,
            status: CapsuleState.unknown,
            deployment: CapsuleDeploymentStatus(
              name: 'app',
              state: CapsuleState.unknown,
              desiredReplicas: 2,
              readyReplicas: 2,
            ),
          ),
          serving: servingSummary(),
        ),
      );

      await cli.run(['status', '--project', projectId]);
    });

    test('then renders the unknown panel with the support hint', () {
      expect(panelLines(), [
        '',
        '  Status    ? Unknown — the status service reported an unrecognized state',
        '  Podlets   2/2 ready',
        '  Deployed  Deployed 2 hours ago by Alice',
        '            8f3c2a1  Fix session timeout',
        '',
        '  If this persists, contact Serverpod support.',
      ]);
    });
  });

  group('Given the status service is unavailable when executing status', () {
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId),
      ).thenThrow(
        CapsuleStatusUnavailableException(
          message: 'The status of capsule my-project could not be determined',
        ),
      );

      commandResult = cli.run(['status', '--project', projectId]);
    });

    test('then throws error exit exception', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then logs a retryable error', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));

      expect(logger.errorCalls, isNotEmpty);
      expect(
        logger.errorCalls.first,
        equalsErrorCall(
          message:
              'Could not retrieve the podlet status for project "my-project".',
          hint:
              'The status service is temporarily unavailable — '
              'try again shortly.',
        ),
      );
    });
  });

  group('Given the project does not exist when executing status', () {
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId),
      ).thenThrow(NotFoundException(message: 'Capsule $projectId not found'));

      commandResult = cli.run(['status', '--project', projectId]);
    });

    test('then throws error exit exception', () async {
      await expectLater(
        commandResult,
        throwsA(
          isA<ErrorExitException>().having((e) => e.exitCode, 'exitCode', 1),
        ),
      );
    });

    test('then logs a not-found error that names the project', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));

      expect(logger.errorCalls, hasLength(1));
      expect(
        logger.errorCalls.first,
        equalsErrorCall(message: 'Project "$projectId" was not found.'),
      );
    });
  });

  group('Given the project is not in the cluster when executing status', () {
    late Future<void> commandResult;

    setUp(() {
      when(
        () => client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId),
      ).thenThrow(
        NotFoundException(
          message: 'Capsule $projectId not found in the cluster',
        ),
      );

      commandResult = cli.run(['status', '--project', projectId]);
    });

    test('then throws error exit exception', () async {
      await expectLater(
        commandResult,
        throwsA(
          isA<ErrorExitException>().having((e) => e.exitCode, 'exitCode', 1),
        ),
      );
    });

    test('then logs a not-found error that names the project', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));

      expect(logger.errorCalls, hasLength(1));
      expect(
        logger.errorCalls.first,
        equalsErrorCall(message: 'Project "$projectId" was not found.'),
      );
    });
  });
}

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a RuntimeStatusTextUi', () {
    group('when rendered for a running project', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const RuntimeStatusTextUi(baseCommand: 'scloud', utc: true),
          data: CapsuleRuntimeStatus(
            status: CapsuleStatus(
              cloudCapsuleId: 'my-project',
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
              startedAt: DateTime.utc(2024, 12, 31, 10, 20, 30),
              endedAt: DateTime.utc(2024, 12, 31, 10, 20, 30),
            ),
          ),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the running status', () {
        expect(stdout, contains('Status'));
        expect(stdout, contains('Running'));
      });

      test('then stdout contains the podlet counts', () {
        expect(stdout, contains('Podlets'));
        expect(stdout, contains('2/2 ready'));
      });

      test('then stdout contains the serving deploy details', () {
        expect(stdout, contains('Serving'));
        expect(stdout, contains('8f3c2a1'));
        expect(stdout, contains('Fix session timeout'));
        expect(stdout, contains('Alice'));
      });

      test('then stdout contains the project urls', () {
        expect(stdout, contains('https://my-project.api.serverpod.space/'));
        expect(
          stdout,
          contains('https://my-project.insights.serverpod.space/'),
        );
        expect(stdout, contains('https://my-project.serverpod.space/'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered for a project that is not deployed', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const RuntimeStatusTextUi(baseCommand: 'scloud', utc: true),
          data: CapsuleRuntimeStatus(
            status: CapsuleStatus(
              cloudCapsuleId: 'my-project',
              status: CapsuleState.notProvisioned,
            ),
          ),
        );
        stdout = io.stdout;
      });

      test('then stdout contains the not-deployed status', () {
        expect(stdout, contains('Not deployed'));
      });

      test('then stdout hints to launch', () {
        expect(stdout, contains('Launch your project:'));
        expect(stdout, contains('scloud launch'));
      });
    });

    group('when rendered for a degraded project', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const RuntimeStatusTextUi(baseCommand: 'scloud', utc: true),
          data: CapsuleRuntimeStatus(
            status: CapsuleStatus(
              cloudCapsuleId: 'my-project',
              status: CapsuleState.degraded,
              deployment: CapsuleDeploymentStatus(
                name: 'app',
                state: CapsuleState.degraded,
                desiredReplicas: 2,
                readyReplicas: 1,
              ),
            ),
          ),
        );
        stdout = io.stdout;
      });

      test('then stdout contains the degraded diagnosis', () {
        expect(stdout, contains('Degraded'));
        expect(stdout, contains('1 of 2 podlets is not ready'));
      });

      test('then stdout hints to check logs', () {
        expect(stdout, contains('Check for errors:'));
        expect(stdout, contains('scloud log --tail'));
      });
    });
  });
}

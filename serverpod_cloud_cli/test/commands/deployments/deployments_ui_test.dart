import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deployments/deployments_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a DeploymentListTextUi', () {
    group('when rendered with no deployments', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          DeploymentListTextUi(utc: true, baseCommand: 'scloud'),
          data: const <Map<String, Object?>>[],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout hints to deploy', () {
        expect(stdout, contains('No deployment status found.'));
        expect(stdout, contains('scloud deploy'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered with a deployment', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          DeploymentListTextUi(utc: true, baseCommand: 'scloud'),
          data: [
            {
              'index': 0,
              'projectId': 'my-project',
              'deployId': 'attempt-1',
              'status': 'SUCCESS',
              'startedAt': DateTime.utc(2024, 12, 31, 10, 20, 30),
              'finishedAt': DateTime.utc(2024, 12, 31, 10, 25, 0),
              'info': 'ok',
            },
          ],
        );
        stdout = io.stdout;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('Project'));
        expect(stdout, contains('Deploy Id'));
        expect(stdout, contains('Status'));
      });

      test('then stdout contains the deployment row', () {
        expect(stdout, contains('my-project'));
        expect(stdout, contains('attempt-1'));
        expect(stdout, contains('SUCCESS'));
      });
    });
  });

  group('Given a DeploymentShowTextUi', () {
    final attemptId = UuidValue.fromString(
      '550e8400-e29b-41d4-a716-446655440000',
    );
    final startedAt = DateTime.utc(2021, 12, 31, 10, 20, 30);
    final snapshot = {
      'projectId': 'my-project',
      'attemptId': attemptId,
      'startedAt': startedAt,
      'stages': [
        DeployAttemptStageBuilder()
            .withUploadStageSuccess()
            .withStartedAt(startedAt)
            .build(),
        DeployAttemptStageBuilder().withBuildStageSuccess().build(),
        DeployAttemptStageBuilder()
            .withStageType(DeployStageType.service)
            .withStageStatus(DeployProgressStatus.success)
            .build(),
      ],
    };

    group('when rendered with a full status', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const DeploymentShowTextUi(utc: true, overallStatus: false),
          data: snapshot,
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the status header', () {
        expect(
          stdout,
          contains(
            'Status of my-project deployment $attemptId, started at 2021-12-31 10:20:30z:',
          ),
        );
      });

      test('then stdout contains the stage lines', () {
        expect(stdout, contains('Upload successful.'));
        expect(stdout, contains('Cloud build successful.'));
        expect(stdout, contains('Rollout successful.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered with overall status only', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const DeploymentShowTextUi(utc: true, overallStatus: true),
          data: snapshot,
        );
        stdout = io.stdout;
      });

      test('then stdout contains only the overall status word', () {
        expect(stdout.trim(), equals('success'));
      });
    });
  });

  group('Given a BuildSecretSetTextUi', () {
    group('when rendered after setting a secret', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const BuildSecretSetTextUi(),
          data: const {'name': 'SSH_KEY'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the set success message', () {
        expect(stdout, contains('Successfully set build secret: SSH_KEY.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a BuildSecretUnsetTextUi', () {
    group('when rendered after removing a secret', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const BuildSecretUnsetTextUi(),
          data: const {'name': 'SSH_KEY'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the removal success message', () {
        expect(stdout, contains('Successfully removed build secret: SSH_KEY.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}

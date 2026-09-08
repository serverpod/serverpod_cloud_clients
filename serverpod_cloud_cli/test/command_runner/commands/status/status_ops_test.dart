import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart';
import 'package:test/test.dart';

void main() {
  group('Given a finished stage', () {
    final stage = DeployAttemptStageBuilder()
        .withStageStatus(DeployProgressStatus.success)
        .withStartedAt(DateTime.utc(2021, 12, 31, 10, 20, 30))
        .withEndedAt(DateTime.utc(2021, 12, 31, 10, 22, 5))
        .build();

    test('when computing the elapsed time then it spans start to end', () {
      expect(
        StatusCommands.stageElapsed(stage),
        const Duration(minutes: 1, seconds: 35),
      );
    });
  });

  group('Given a running stage', () {
    final stage = DeployAttemptStageBuilder()
        .withStageStatus(DeployProgressStatus.running)
        .withStartedAt(DateTime.utc(2021, 12, 31, 10, 20, 30))
        .withEndedAt(null)
        .build();

    test('when computing the elapsed time then it counts from the start', () {
      expect(
        StatusCommands.stageElapsed(
          stage,
          now: DateTime.utc(2021, 12, 31, 10, 25, 30),
        ),
        const Duration(minutes: 5),
      );
    });

    test('when the start is ahead of now then the elapsed time is zero', () {
      expect(
        StatusCommands.stageElapsed(
          stage,
          now: DateTime.utc(2021, 12, 31, 10, 20, 0),
        ),
        Duration.zero,
      );
    });
  });

  group('Given a stage without a start time', () {
    final stage = DeployAttemptStageBuilder()
        .withStageStatus(DeployProgressStatus.awaiting)
        .withStartedAt(null)
        .withEndedAt(null)
        .build();

    test('when computing the elapsed time then it is null', () {
      expect(StatusCommands.stageElapsed(stage), isNull);
    });
  });

  test('Given no stage when computing the elapsed time then it is null', () {
    expect(StatusCommands.stageElapsed(null), isNull);
  });
}

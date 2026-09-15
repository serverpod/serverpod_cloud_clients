import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
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

  group('Given a watched project', () {
    const projectId = 'my-project';
    late ClientMock client;
    late StreamController<void> stop;

    setUp(() {
      client = ClientMock(authKeyProvider: InMemoryKeyManager.authenticated());
      stop = StreamController<void>.broadcast();
    });

    tearDown(() async {
      await stop.close();
    });

    test(
      'when the status changes between polls then each distinct status is emitted once',
      () async {
        final answers = [
          CapsuleRuntimeStatusBuilder().build(),
          CapsuleRuntimeStatusBuilder().build(),
          CapsuleRuntimeStatusBuilder().withDegradedPodlets().build(),
        ];
        when(
          () =>
              client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId),
        ).thenAnswer((_) async => answers.removeAt(0));

        final statuses = await StatusCommands.watchRuntimeStatus(
          client,
          projectId: projectId,
          interval: const Duration(milliseconds: 1),
          stop: stop.stream,
        ).take(2).toList();

        expect(statuses.map((runtime) => runtime.status.status), [
          CapsuleState.ready,
          CapsuleState.degraded,
        ]);
      },
    );

    test(
      'when the first poll finds the status unavailable then the stream fails with a FailureException',
      () async {
        when(
          () =>
              client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId),
        ).thenThrow(CapsuleStatusUnavailableException(message: 'unavailable'));

        final statuses = StatusCommands.watchRuntimeStatus(
          client,
          projectId: projectId,
          interval: const Duration(milliseconds: 1),
          stop: stop.stream,
        );

        await expectLater(
          statuses,
          emitsInOrder([emitsError(isA<FailureException>()), emitsDone]),
        );
      },
    );

    test(
      'when the status becomes unavailable after the first status then polling continues',
      () async {
        final answers = <Future<CapsuleRuntimeStatus> Function()>[
          () async => CapsuleRuntimeStatusBuilder().build(),
          () async =>
              throw CapsuleStatusUnavailableException(message: 'unavailable'),
          () async =>
              CapsuleRuntimeStatusBuilder().withDegradedPodlets().build(),
        ];
        when(
          () =>
              client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId),
        ).thenAnswer((_) => answers.removeAt(0)());

        final statuses = await StatusCommands.watchRuntimeStatus(
          client,
          projectId: projectId,
          interval: const Duration(milliseconds: 1),
          stop: stop.stream,
        ).take(2).toList();

        expect(statuses.map((runtime) => runtime.status.status), [
          CapsuleState.ready,
          CapsuleState.degraded,
        ]);
      },
    );

    test(
      'when the project is not found after the first status then the stream fails with a FailureException',
      () async {
        final answers = <Future<CapsuleRuntimeStatus> Function()>[
          () async => CapsuleRuntimeStatusBuilder().build(),
          () async => throw NotFoundException(message: 'not found'),
        ];
        when(
          () =>
              client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId),
        ).thenAnswer((_) => answers.removeAt(0)());

        final statuses = StatusCommands.watchRuntimeStatus(
          client,
          projectId: projectId,
          interval: const Duration(milliseconds: 1),
          stop: stop.stream,
        );

        await expectLater(
          statuses,
          emitsInOrder([
            isA<CapsuleRuntimeStatus>(),
            emitsError(isA<FailureException>()),
            emitsDone,
          ]),
        );
      },
    );

    test(
      'when stop emits then the stream closes without polling again',
      () async {
        when(
          () =>
              client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId),
        ).thenAnswer((_) async {
          Timer.run(() => stop.add(null));
          return CapsuleRuntimeStatusBuilder().build();
        });

        final statuses = StatusCommands.watchRuntimeStatus(
          client,
          projectId: projectId,
          interval: const Duration(milliseconds: 50),
          stop: stop.stream,
        );

        await expectLater(
          statuses,
          emitsInOrder([isA<CapsuleRuntimeStatus>(), emitsDone]),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        verify(
          () =>
              client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId),
        ).called(1);
      },
    );

    test(
      'when stop emits while a poll is in flight then the stream closes without emitting that status',
      () async {
        final pending = Completer<CapsuleRuntimeStatus>();
        when(
          () =>
              client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId),
        ).thenAnswer((_) => pending.future);

        final statuses = StatusCommands.watchRuntimeStatus(
          client,
          projectId: projectId,
          interval: const Duration(milliseconds: 1),
          stop: stop.stream,
        );
        final done = expectLater(statuses, emitsDone);
        await Future<void>.delayed(Duration.zero);
        stop.add(null);
        await done;

        pending.complete(CapsuleRuntimeStatusBuilder().build());
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
    );

    test(
      'when stop emits while a failing poll is in flight then the stream closes without an error',
      () async {
        final pending = Completer<CapsuleRuntimeStatus>();
        when(
          () =>
              client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId),
        ).thenAnswer((_) => pending.future);

        final statuses = StatusCommands.watchRuntimeStatus(
          client,
          projectId: projectId,
          interval: const Duration(milliseconds: 1),
          stop: stop.stream,
        );
        final done = expectLater(statuses, emitsDone);
        await Future<void>.delayed(Duration.zero);
        stop.add(null);
        await done;

        pending.completeError(NotFoundException(message: 'not found'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
    );
  });
}

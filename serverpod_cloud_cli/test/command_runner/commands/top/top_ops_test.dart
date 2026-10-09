import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/top_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/top_snapshot.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';

void main() {
  const projectId = 'my-project';
  late ClientMock client;

  setUp(() {
    client = ClientMock(authKeyProvider: InMemoryKeyManager.authenticated());
  });

  group('Given a project with status, deployments, metrics and logs', () {
    setUp(() {
      when(() {
        return client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId);
      }).thenAnswer((final Invocation _) async {
        return CapsuleRuntimeStatusBuilder().withDegradedPodlets().build();
      });
      when(() {
        return client.status.getDeployAttempts(
          cloudCapsuleId: projectId,
          limit: 3,
        );
      }).thenAnswer((final Invocation _) async {
        return [
          DeployAttemptBuilder().withCommitMessage('feat: latest').build(),
        ];
      });
      when(() {
        return client.metrics.fetchPodResourceMetrics(
          cloudCapsuleId: projectId,
          range: MetricsRange.oneHour,
          until: any(named: 'until'),
        );
      }).thenAnswer((final Invocation _) async {
        return [PodResourceSeriesBuilder().withPodName('app-0').build()];
      });
      when(() {
        return client.metrics.fetchNetworkMetrics(
          cloudCapsuleId: projectId,
          range: MetricsRange.oneHour,
          until: any(named: 'until'),
        );
      }).thenAnswer((final Invocation _) async {
        return CapsuleNetworkSeriesBuilder().build();
      });
      when(() {
        return client.metrics.fetchDatabaseMetrics(
          cloudCapsuleId: projectId,
          range: MetricsRange.oneHour,
          until: any(named: 'until'),
        );
      }).thenAnswer((final Invocation _) async {
        return DatabaseMetricsBuilder().withIdleDatabase().build();
      });
      when(() {
        return client.logs.fetchRecentRecords(
          cloudCapsuleId: projectId,
          limit: 50,
        );
      }).thenAnswer((final Invocation _) {
        return Stream.fromIterable([
          LogRecordBuilder().withContent('server started').build(),
        ]);
      });
    });

    Future<TopSnapshot> fetchSnapshot() {
      return TopOperations.fetchSnapshot(
        client,
        projectId: projectId,
        deploymentLimit: 3,
        logLimit: 50,
      );
    }

    test('when fetching a snapshot then it holds the status', () async {
      final TopSnapshot snapshot = await fetchSnapshot();

      expect(snapshot.runtime.status.status, CapsuleState.degraded);
    });

    test('when fetching a snapshot then it holds the deployments', () async {
      final TopSnapshot snapshot = await fetchSnapshot();

      expect(snapshot.deployments?.single.commitMessage, 'feat: latest');
    });

    test('when fetching a snapshot then it holds the metrics', () async {
      final TopSnapshot snapshot = await fetchSnapshot();

      expect(snapshot.podResources?.single.podName, 'app-0');
      expect(snapshot.network, isNotNull);
      expect(snapshot.database?.status, DatabaseMetricsStatus.idle);
    });

    test('when fetching a snapshot then it holds the recent logs', () async {
      final TopSnapshot snapshot = await fetchSnapshot();

      expect(snapshot.logs?.single.content, 'server started');
    });

    test('when fetching a snapshot '
        'then the metrics window ends when the status was fetched', () async {
      final TopSnapshot snapshot = await fetchSnapshot();

      expect(snapshot.metricsUntil, snapshot.updatedAt);
    });

    group('and the network metrics cannot be fetched', () {
      setUp(() {
        when(() {
          return client.metrics.fetchNetworkMetrics(
            cloudCapsuleId: projectId,
            range: MetricsRange.oneHour,
            until: any(named: 'until'),
          );
        }).thenThrow(Exception('metrics store down'));
      });

      test('when fetching a snapshot '
          'then only the network metrics are missing', () async {
        final TopSnapshot snapshot = await fetchSnapshot();

        expect(snapshot.network, isNull);
        expect(snapshot.podResources, isNotNull);
        expect(snapshot.database, isNotNull);
      });
    });

    group('and the deployments cannot be fetched', () {
      setUp(() {
        when(() {
          return client.status.getDeployAttempts(
            cloudCapsuleId: projectId,
            limit: 3,
          );
        }).thenThrow(Exception('boom'));
      });

      test(
        'when fetching a snapshot then the deployments are missing',
        () async {
          final TopSnapshot snapshot = await fetchSnapshot();

          expect(snapshot.deployments, isNull);
        },
      );
    });

    group('and the logs cannot be fetched', () {
      setUp(() {
        when(() {
          return client.logs.fetchRecentRecords(
            cloudCapsuleId: projectId,
            limit: 50,
          );
        }).thenAnswer((final Invocation _) {
          return Stream.error(Exception('boom'));
        });
      });

      test('when fetching a snapshot then the logs are missing', () async {
        final TopSnapshot snapshot = await fetchSnapshot();

        expect(snapshot.logs, isNull);
      });
    });

    group('and the project is not found', () {
      setUp(() {
        when(() {
          return client.status.getCapsuleRuntimeStatus(
            cloudCapsuleId: projectId,
          );
        }).thenThrow(NotFoundException(message: 'not found'));
      });

      test('when fetching a snapshot '
          'then it fails with a FailureException', () async {
        await expectLater(fetchSnapshot(), throwsA(isA<FailureException>()));
      });
    });
  });

  group('Given a watched snapshot', () {
    late StreamController<LogRecord> tail;
    late TopSnapshot initial;

    setUp(() {
      tail = StreamController<LogRecord>();
      initial = TopSnapshot(
        runtime: CapsuleRuntimeStatusBuilder().build(),
        updatedAt: DateTime.utc(2026, 1, 1, 12),
        deployments: const [],
        podResources: null,
        network: null,
        database: null,
        metricsUntil: DateTime.utc(2026, 1, 1, 12),
        logs: [LogRecordBuilder().withRecordId('known').build()],
      );
      when(() {
        return client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId);
      }).thenAnswer((final Invocation _) async {
        return CapsuleRuntimeStatusBuilder().build();
      });
      when(() {
        return client.status.getDeployAttempts(
          cloudCapsuleId: projectId,
          limit: 3,
        );
      }).thenAnswer((final Invocation _) async {
        return [];
      });
      when(() {
        return client.logs.tailRecords(cloudCapsuleId: projectId);
      }).thenAnswer((final Invocation _) {
        return tail.stream;
      });
    });

    tearDown(() {
      unawaited(tail.close());
    });

    Stream<TopSnapshot> watchSnapshots({
      final Duration interval = const Duration(hours: 1),
      final Duration metricsInterval = const Duration(hours: 1),
      final int logLimit = 50,
    }) {
      return TopOperations.watchSnapshots(
        client,
        initial: initial,
        projectId: projectId,
        interval: interval,
        metricsInterval: metricsInterval,
        deploymentLimit: 3,
        logLimit: logLimit,
      );
    }

    test('when the status changes at a refresh '
        'then a snapshot with the new status is emitted', () async {
      when(() {
        return client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId);
      }).thenAnswer((final Invocation _) async {
        return CapsuleRuntimeStatusBuilder().withDegradedPodlets().build();
      });

      final TopSnapshot snapshot = await watchSnapshots(
        interval: const Duration(milliseconds: 1),
      ).first;

      expect(snapshot.runtime.status.status, CapsuleState.degraded);
      expect(snapshot.updatedAt, isNot(initial.updatedAt));
    });

    test('when new deployments arrive at a refresh '
        'then a snapshot with the deployments is emitted', () async {
      when(() {
        return client.status.getDeployAttempts(
          cloudCapsuleId: projectId,
          limit: 3,
        );
      }).thenAnswer((final Invocation _) async {
        return [DeployAttemptBuilder().withCommitMessage('feat: new').build()];
      });

      final TopSnapshot snapshot = await watchSnapshots(
        interval: const Duration(milliseconds: 1),
      ).first;

      expect(snapshot.deployments?.single.commitMessage, 'feat: new');
    });

    test('when a status refresh fails '
        'then a snapshot with a stale status is emitted', () async {
      when(() {
        return client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId);
      }).thenThrow(Exception('boom'));

      final TopSnapshot snapshot = await watchSnapshots(
        interval: const Duration(milliseconds: 1),
      ).first;

      expect(snapshot.isStatusStale, isTrue);
      expect(snapshot.updatedAt, initial.updatedAt);
    });

    test('when a status refresh succeeds after a failed one '
        'then the status is no longer stale', () async {
      final List<Future<CapsuleRuntimeStatus> Function()> answers = [
        () async {
          throw Exception('boom');
        },
        () async {
          return CapsuleRuntimeStatusBuilder().withDegradedPodlets().build();
        },
      ];
      when(() {
        return client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId);
      }).thenAnswer((final Invocation _) {
        return answers.removeAt(0)();
      });
      when(() {
        return client.status.getDeployAttempts(
          cloudCapsuleId: projectId,
          limit: 3,
        );
      }).thenThrow(Exception('boom'));

      final List<TopSnapshot> snapshots = await watchSnapshots(
        interval: const Duration(milliseconds: 1),
      ).take(2).toList();

      expect(snapshots.first.isStatusStale, isTrue);
      expect(snapshots.last.isStatusStale, isFalse);
      expect(snapshots.last.runtime.status.status, CapsuleState.degraded);
    });

    test('when a status refresh is refused as unauthorized '
        'then the stream ends with a FailureException', () async {
      when(() {
        return client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId);
      }).thenThrow(ServerpodClientUnauthorized());

      await expectLater(
        watchSnapshots(interval: const Duration(milliseconds: 1)),
        emitsInOrder([
          emitsError(
            isA<FailureException>().having(
              (final FailureException e) {
                return e.nestedException;
              },
              'nestedException',
              isA<ServerpodClientUnauthorized>(),
            ),
          ),
          emitsDone,
        ]),
      );
    });

    test('when a status refresh is refused as forbidden '
        'then the stream ends with a FailureException', () async {
      when(() {
        return client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId);
      }).thenThrow(ServerpodClientForbidden());

      await expectLater(
        watchSnapshots(interval: const Duration(milliseconds: 1)),
        emitsInOrder([emitsError(isA<FailureException>()), emitsDone]),
      );
    });

    test('when a status refresh is refused as unauthorized '
        'then the log tail is cancelled', () async {
      when(() {
        return client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId);
      }).thenThrow(ServerpodClientUnauthorized());

      await watchSnapshots(
        interval: const Duration(milliseconds: 1),
      ).drain<void>().catchError((final Object _) {});

      expect(tail.hasListener, isFalse);
    });

    test('when the metrics refresh '
        'then a snapshot with the new metrics is emitted', () async {
      when(() {
        return client.metrics.fetchPodResourceMetrics(
          cloudCapsuleId: projectId,
          range: MetricsRange.oneHour,
          until: any(named: 'until'),
        );
      }).thenAnswer((final Invocation _) async {
        return [PodResourceSeriesBuilder().withPodName('app-0').build()];
      });
      when(() {
        return client.metrics.fetchNetworkMetrics(
          cloudCapsuleId: projectId,
          range: MetricsRange.oneHour,
          until: any(named: 'until'),
        );
      }).thenThrow(Exception('boom'));
      when(() {
        return client.metrics.fetchDatabaseMetrics(
          cloudCapsuleId: projectId,
          range: MetricsRange.oneHour,
          until: any(named: 'until'),
        );
      }).thenAnswer((final Invocation _) async {
        return DatabaseMetricsBuilder().build();
      });

      final TopSnapshot snapshot = await watchSnapshots(
        metricsInterval: const Duration(milliseconds: 1),
      ).first;

      expect(snapshot.podResources?.single.podName, 'app-0');
      expect(snapshot.network, isNull);
      expect(snapshot.database, isNotNull);
      expect(snapshot.metricsUntil, isNot(initial.metricsUntil));
    });

    test('when the network metrics fail at a refresh '
        'then the earlier network metrics are cleared', () async {
      initial = initial.copyWith(
        network: CapsuleNetworkSeriesBuilder().build(),
      );
      when(() {
        return client.metrics.fetchPodResourceMetrics(
          cloudCapsuleId: projectId,
          range: MetricsRange.oneHour,
          until: any(named: 'until'),
        );
      }).thenAnswer((final Invocation _) async {
        return [PodResourceSeriesBuilder().build()];
      });
      when(() {
        return client.metrics.fetchNetworkMetrics(
          cloudCapsuleId: projectId,
          range: MetricsRange.oneHour,
          until: any(named: 'until'),
        );
      }).thenThrow(Exception('boom'));
      when(() {
        return client.metrics.fetchDatabaseMetrics(
          cloudCapsuleId: projectId,
          range: MetricsRange.oneHour,
          until: any(named: 'until'),
        );
      }).thenAnswer((final Invocation _) async {
        return DatabaseMetricsBuilder().build();
      });

      final TopSnapshot snapshot = await watchSnapshots(
        metricsInterval: const Duration(milliseconds: 1),
      ).first;

      expect(snapshot.network, isNull);
    });

    test('when a log record is written '
        'then a snapshot with the record appended is emitted', () async {
      final Stream<TopSnapshot> snapshots = watchSnapshots();
      tail.add(LogRecordBuilder().withRecordId('new').build());

      final TopSnapshot snapshot = await snapshots.first;

      expect(
        snapshot.logs?.map((final LogRecord record) {
          return record.recordId;
        }),
        ['known', 'new'],
      );
    });

    test('when a log record is written and the logs were missing '
        'then a snapshot with only the record is emitted', () async {
      initial = TopSnapshot(
        runtime: initial.runtime,
        updatedAt: initial.updatedAt,
        deployments: initial.deployments,
        podResources: null,
        network: null,
        database: null,
        metricsUntil: initial.metricsUntil,
        logs: null,
      );
      final Stream<TopSnapshot> snapshots = watchSnapshots();
      tail.add(LogRecordBuilder().withRecordId('new').build());

      final TopSnapshot snapshot = await snapshots.first;

      expect(snapshot.logs?.single.recordId, 'new');
    });

    test('when an already known log record arrives '
        'then it is not added again', () async {
      final Stream<TopSnapshot> snapshots = watchSnapshots();
      tail.add(LogRecordBuilder().withRecordId('known').build());
      tail.add(LogRecordBuilder().withRecordId('new').build());

      final TopSnapshot snapshot = await snapshots.first;

      expect(
        snapshot.logs?.map((final LogRecord record) {
          return record.recordId;
        }),
        ['known', 'new'],
      );
    });

    test('when the log records exceed the limit '
        'then the oldest record is dropped', () async {
      final Stream<TopSnapshot> snapshots = watchSnapshots(logLimit: 1);
      tail.add(LogRecordBuilder().withRecordId('new').build());

      final TopSnapshot snapshot = await snapshots.first;

      expect(snapshot.logs?.single.recordId, 'new');
    });

    test('when the log tail ends '
        'then the tail reconnects and later records arrive', () async {
      final List<Stream<LogRecord>> tails = [
        Stream.fromIterable([LogRecordBuilder().withRecordId('first').build()]),
        Stream.fromIterable([
          LogRecordBuilder().withRecordId('second').build(),
        ]).asBroadcastStream(),
      ];
      when(() {
        return client.logs.tailRecords(cloudCapsuleId: projectId);
      }).thenAnswer((final Invocation _) {
        return tails.length > 1 ? tails.removeAt(0) : tails.first;
      });
      when(() {
        return client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId);
      }).thenThrow(Exception('boom'));
      when(() {
        return client.status.getDeployAttempts(
          cloudCapsuleId: projectId,
          limit: 3,
        );
      }).thenThrow(Exception('boom'));

      final TopSnapshot snapshot =
          await watchSnapshots(
            interval: const Duration(milliseconds: 1),
          ).firstWhere((final TopSnapshot snapshot) {
            return snapshot.logs?.length == 3;
          });

      expect(
        snapshot.logs?.map((final LogRecord record) {
          return record.recordId;
        }),
        ['known', 'first', 'second'],
      );
    });

    test('when the log tail fails '
        'then the tail reconnects and later records arrive', () async {
      final List<Stream<LogRecord>> tails = [
        Stream.error(Exception('boom')),
        Stream.fromIterable([
          LogRecordBuilder().withRecordId('after').build(),
        ]).asBroadcastStream(),
      ];
      when(() {
        return client.logs.tailRecords(cloudCapsuleId: projectId);
      }).thenAnswer((final Invocation _) {
        return tails.length > 1 ? tails.removeAt(0) : tails.first;
      });
      when(() {
        return client.status.getCapsuleRuntimeStatus(cloudCapsuleId: projectId);
      }).thenThrow(Exception('boom'));
      when(() {
        return client.status.getDeployAttempts(
          cloudCapsuleId: projectId,
          limit: 3,
        );
      }).thenThrow(Exception('boom'));

      final TopSnapshot snapshot =
          await watchSnapshots(
            interval: const Duration(milliseconds: 1),
          ).firstWhere((final TopSnapshot snapshot) {
            return snapshot.logs?.length == 2;
          });

      expect(snapshot.logs?.last.recordId, 'after');
    });

    test('when the listener cancels then the log tail is cancelled', () async {
      final StreamSubscription<TopSnapshot> subscription = watchSnapshots()
          .listen((final TopSnapshot _) {});
      await pumpEventQueue();

      await subscription.cancel();

      expect(tail.hasListener, isFalse);
    });
  });
}

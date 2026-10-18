import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:nocterm/nocterm.dart' hide isEmpty, isNotEmpty;
import 'package:serverpod_cloud_cli/command_runner/commands/top/top_snapshot.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/tui/main_screen.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/tui/state.dart';
import 'package:test/test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 1, 1, 12);
  final DateTime aMinuteAgo = now.subtract(const Duration(minutes: 1));
  final TopSnapshot empty = TopSnapshot(
    runtime: CapsuleRuntimeStatusBuilder().build(),
    updatedAt: now,
    deployments: null,
    podResources: null,
    network: null,
    database: null,
    metricsUntil: now,
    logs: const [],
  );

  Future<String> render(
    final TopSnapshot snapshot, {
    final Size size = const Size(140, 30),
  }) async {
    late String text;
    await testNocterm('top screen', (final NoctermTester tester) async {
      await tester.pumpComponent(
        MainScreen(
          state: TopState(
            baseCommand: 'xcloud',
            projectId: 'my-app',
            snapshot: snapshot,
            utc: true,
            interval: const Duration(seconds: 5),
          ),
          logScrollController: ScrollController(),
          onQuit: () {},
        ),
      );
      text = tester.terminalState.getText();
    }, size: size);
    return text;
  }

  group('Given a running project', () {
    test('when the screen is rendered '
        'then the title names the base command and the project', () async {
      expect(await render(empty), contains('xcloud top · my-app'));
    });

    test('when the screen is rendered '
        'then the state and the ready podlets are shown', () async {
      final String text = await render(empty);

      expect(text, contains('● Running'));
      expect(text, contains('2/2 podlets ready'));
    });

    test('when the screen is rendered '
        'then the time of the last update is shown in UTC', () async {
      expect(await render(empty), contains('Updated 12:00:00 (UTC)'));
    });
  });

  group('Given a status that could not be refreshed', () {
    test('when the screen is rendered '
        'then the last update is marked as stale', () async {
      expect(
        await render(empty.copyWith(isStatusStale: true)),
        contains('Stale · Updated 12:00:00 (UTC)'),
      );
    });
  });

  group('Given a project with degraded podlets', () {
    test('when the screen is rendered then the state is Degraded', () async {
      final String text = await render(
        empty.copyWith(
          runtime: CapsuleRuntimeStatusBuilder().withDegradedPodlets().build(),
        ),
      );

      expect(text, contains('◑ Degraded'));
      expect(text, contains('1/2 podlets ready'));
    });
  });

  group('Given a project whose latest deployment failed', () {
    test('when the screen is rendered '
        'then the failed deployment is shown under the status', () async {
      final String text = await render(
        empty.copyWith(
          runtime: CapsuleRuntimeStatusBuilder()
              .withLatestAttempt(
                DeployAttemptBuilder()
                    .withFailedDeployment()
                    .withCommitMessage('fix: broken thing')
                    .build(),
              )
              .build(),
        ),
      );

      expect(text, matches(RegExp(r'Failed\s+279d40t\s+fix: broken thing')));
    });
  });

  group('Given metrics that could not be fetched', () {
    test('when the screen is rendered '
        'then each metrics panel says it is not available', () async {
      final String text = await render(empty);

      expect('Not available.'.allMatches(text), hasLength(4));
    });
  });

  group('Given podlet CPU and memory samples', () {
    test('when the screen is rendered '
        'then the latest total of both podlets is shown', () async {
      final String text = await render(
        empty.copyWith(
          podResources: [
            for (final String name in ['app-0', 'app-1'])
              PodResourceSeriesBuilder()
                  .withPodName(name)
                  .withCpuCores([
                    MetricSampleBuilder()
                        .withTimestamp(aMinuteAgo)
                        .withValue(0.25)
                        .build(),
                  ])
                  .withMemoryBytes([
                    MetricSampleBuilder()
                        .withTimestamp(aMinuteAgo)
                        .withValue(100000000)
                        .build(),
                  ])
                  .build(),
          ],
        ),
      );

      expect(text, contains('0.50 cores'));
      expect(text, contains('200 MB'));
    });
  });

  group('Given podlet series without samples', () {
    test('when the screen is rendered then the rows say no data', () async {
      final String text = await render(
        empty.copyWith(
          podResources: [
            PodResourceSeriesBuilder()
                .withCpuCores([])
                .withMemoryBytes([])
                .build(),
          ],
        ),
      );

      expect('no data'.allMatches(text), hasLength(2));
    });
  });

  group('Given requests of which a tenth are server errors', () {
    test('when the screen is rendered '
        'then the request rate and the error share are shown', () async {
      final String text = await render(
        empty.copyWith(
          network: CapsuleNetworkSeriesBuilder()
              .withRequestsPerSecond([
                MetricSampleBuilder()
                    .withTimestamp(aMinuteAgo)
                    .withValue(20)
                    .build(),
              ])
              .withResponses(HttpResponseClass.serverError, [
                MetricSampleBuilder()
                    .withTimestamp(aMinuteAgo)
                    .withValue(2)
                    .build(),
              ])
              .build(),
        ),
      );

      expect(text, contains('20.0 req/s'));
      expect(text, matches(RegExp(r'5xx errors.*10%')));
    });
  });

  group('Given requests without server errors', () {
    test('when the screen is rendered then the error share is zero', () async {
      final String text = await render(
        empty.copyWith(
          network: CapsuleNetworkSeriesBuilder().withRequestsPerSecond([
            MetricSampleBuilder().withTimestamp(aMinuteAgo).build(),
          ]).build(),
        ),
      );

      expect(text, matches(RegExp(r'5xx errors\s+0%')));
    });
  });

  group('Given a reporting database', () {
    test('when the screen is rendered '
        'then its CPU and open connections are shown', () async {
      final String text = await render(
        empty.copyWith(
          database: DatabaseMetricsBuilder()
              .withCpuCores([
                MetricSampleBuilder()
                    .withTimestamp(aMinuteAgo)
                    .withValue(0.1)
                    .build(),
              ])
              .withConnections([
                MetricSampleBuilder()
                    .withTimestamp(aMinuteAgo)
                    .withValue(7)
                    .build(),
              ])
              .build(),
        ),
      );

      expect(text, contains('0.10 cores'));
      expect(text, contains('7 open'));
    });
  });

  group('Given an idle database', () {
    test(
      'when the screen is rendered then the panel says it is idle',
      () async {
        final String text = await render(
          empty.copyWith(
            database: DatabaseMetricsBuilder().withIdleDatabase().build(),
          ),
        );

        expect(text, contains('Idle, with no activity in the last hour.'));
      },
    );
  });

  group('Given a database without metrics export', () {
    test('when the screen is rendered '
        'then the panel says metrics are not enabled', () async {
      final String text = await render(
        empty.copyWith(
          database: DatabaseMetricsBuilder().withExportNotEnabled().build(),
        ),
      );

      expect(text, contains('Metrics are not enabled for this database.'));
    });
  });

  group('Given a project without deployments', () {
    test('when the screen is rendered '
        'then the deployments panel says there are none', () async {
      final String text = await render(empty.copyWith(deployments: []));

      expect(text, contains('No deployments yet.'));
    });
  });

  group('Given a served deployment and a failed one', () {
    final DeployAttempt served = DeployAttemptBuilder()
        .withSuccessfulDeployment()
        .withCommitMessage('feat: served change')
        .build();
    final DeployAttempt failed = DeployAttemptBuilder()
        .withFailedDeployment()
        .withCommitMessage('feat: failed change')
        .build();
    late String text;

    setUp(() async {
      text = await render(
        empty.copyWith(
          runtime: CapsuleRuntimeStatusBuilder().withServing(served).build(),
          deployments: [failed, served],
        ),
      );
    });

    test('when the screen is rendered '
        'then only the served deployment is marked as serving', () {
      expect(
        text,
        matches(RegExp(r'● Success\s+279d40t\s+feat: served change\s+serving')),
      );
      expect('serving'.allMatches(text), hasLength(1));
    });

    test('when the screen is rendered '
        'then the failed deployment is listed with its status', () {
      expect(
        text,
        matches(RegExp(r'✖ Failure\s+279d40t\s+feat: failed change')),
      );
    });
  });

  group('Given a project without log records', () {
    test('when the screen is rendered '
        'then the logs panel says there are none', () async {
      expect(await render(empty), contains('No log records yet.'));
    });
  });

  group('Given logs that could not be fetched', () {
    test('when the screen is rendered '
        'then the logs panel says not available', () async {
      final String text = await render(
        TopSnapshot(
          runtime: CapsuleRuntimeStatusBuilder().build(),
          updatedAt: now,
          deployments: const [],
          podResources: null,
          network: null,
          database: null,
          metricsUntil: now,
          logs: null,
        ),
      );

      expect(text, isNot(contains('No log records yet.')));
      expect('Not available.'.allMatches(text), hasLength(4));
    });
  });

  group('Given an error log record', () {
    test('when the screen is rendered '
        'then the record is shown with its UTC time and level', () async {
      final String text = await render(
        empty.copyWith(
          logs: [
            LogRecordBuilder()
                .withTimestamp(DateTime.utc(2026, 1, 1, 11, 58, 3))
                .withSeverity('ERROR')
                .withContent('payment failed')
                .build(),
          ],
        ),
      );

      expect(text, contains('11:58:03 error payment failed'));
    });
  });

  group('Given a narrow terminal', () {
    test('when the screen is rendered '
        'then the metrics panels are stacked', () async {
      final String text = await render(empty, size: const Size(80, 40));
      final List<String> lines = text.split('\n');

      expect(
        lines.indexWhere((final String line) {
          return line.contains('Traffic');
        }),
        greaterThan(
          lines.indexWhere((final String line) {
            return line.contains('Podlets ·');
          }),
        ),
      );
    });
  });

  group('Given the screen', () {
    test('when Q is pressed then the quit callback is called', () async {
      int quitCount = 0;

      await testNocterm('top screen', (final NoctermTester tester) async {
        await tester.pumpComponent(
          MainScreen(
            state: TopState(
              baseCommand: 'xcloud',
              projectId: 'my-app',
              snapshot: empty,
              utc: true,
              interval: const Duration(seconds: 5),
            ),
            logScrollController: ScrollController(),
            onQuit: () {
              quitCount++;
            },
          ),
        );
        await tester.sendKey(LogicalKey.keyQ);
      });

      expect(quitCount, 1);
    });
  });
}

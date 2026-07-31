import 'dart:convert';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';

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

  final testCacheFolderPath = p.join('test_integration', const Uuid().v4());

  Future<void> runCli(final List<String> args) =>
      cli.run([...args, '--config-dir', testCacheFolderPath]);

  setUpAll(() {
    registerFallbackValue(MetricsRange.oneHour);
  });

  setUp(() async {
    await ResourceManager.storeLatestCliVersion(
      cliVersionData: PackageVersionData(
        Version(0, 0, 1),
        DateTime.now().add(const Duration(days: 1)),
      ),
      logger: logger,
      localStoragePath: testCacheFolderPath,
    );
  });

  tearDown(() {
    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    logger.clear();
    reset(client.metrics);
  });

  const projectId = 'projectId';
  final sampleTime = DateTime.utc(2026, 1, 15, 10, 30);

  final podSeries = [
    PodResourceSeries(
      podName: 'pod-a',
      cpuCores: [MetricSample(timestamp: sampleTime, value: 0.125)],
      memoryBytes: [MetricSample(timestamp: sampleTime, value: 134217728)],
    ),
  ];
  final networkSeries = CapsuleNetworkSeries(
    requestsPerSecond: [MetricSample(timestamp: sampleTime, value: 2.5)],
    responses: [
      ResponseClassSeries(
        responseClass: HttpResponseClass.successful,
        responsesPerSecond: [MetricSample(timestamp: sampleTime, value: 2.0)],
      ),
    ],
  );
  final idleDatabase = DatabaseMetrics(
    status: DatabaseMetricsStatus.idle,
    cpuCores: [],
    memoryBytes: [],
    connections: [],
    storageBytes: [],
  );

  void whenComputeReturns(final List<PodResourceSeries> result) {
    when(
      () => client.metrics.fetchPodResourceMetrics(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        range: any(named: 'range'),
        until: any(named: 'until'),
      ),
    ).thenAnswer((final _) async => result);
  }

  void whenNetworkReturns(final CapsuleNetworkSeries result) {
    when(
      () => client.metrics.fetchNetworkMetrics(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        range: any(named: 'range'),
        until: any(named: 'until'),
      ),
    ).thenAnswer((final _) async => result);
  }

  void whenDatabaseReturns(final DatabaseMetrics result) {
    when(
      () => client.metrics.fetchDatabaseMetrics(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        range: any(named: 'range'),
        until: any(named: 'until'),
      ),
    ).thenAnswer((final _) async => result);
  }

  Map<String, dynamic> outputDocument() =>
      jsonDecode(logger.lineCalls.single.line) as Map<String, dynamic>;

  group('Given all endpoints report data', () {
    setUp(() {
      whenComputeReturns(podSeries);
      whenNetworkReturns(networkSeries);
      whenDatabaseReturns(idleDatabase);
    });

    group('when running metrics without a target', () {
      setUp(() async {
        await runCli(['metrics', '--project', projectId]);
      });

      test(
        'then all three endpoints are queried with the default range',
        () async {
          verify(
            () => client.metrics.fetchPodResourceMetrics(
              cloudCapsuleId: projectId,
              range: MetricsRange.oneHour,
              until: null,
            ),
          ).called(1);
          verify(
            () => client.metrics.fetchNetworkMetrics(
              cloudCapsuleId: projectId,
              range: MetricsRange.oneHour,
              until: null,
            ),
          ).called(1);
          verify(
            () => client.metrics.fetchDatabaseMetrics(
              cloudCapsuleId: projectId,
              range: MetricsRange.oneHour,
              until: null,
            ),
          ).called(1);
        },
      );

      test('then a combined JSON document is emitted', () async {
        final doc = outputDocument();

        expect(doc['projectId'], projectId);
        expect(doc['range'], 'oneHour');
        expect(doc['until'], isNull);
        expect(doc['compute'], {
          'pods': [
            {
              'pod': 'pod-a',
              'cpuCores': [
                {'timestamp': '2026-01-15T10:30:00.000Z', 'value': 0.125},
              ],
              'memoryBytes': [
                {'timestamp': '2026-01-15T10:30:00.000Z', 'value': 134217728.0},
              ],
            },
          ],
        });
        expect(doc['network'], {
          'requestsPerSecond': [
            {'timestamp': '2026-01-15T10:30:00.000Z', 'value': 2.5},
          ],
          'responses': [
            {
              'responseClass': 'successful',
              'responsesPerSecond': [
                {'timestamp': '2026-01-15T10:30:00.000Z', 'value': 2.0},
              ],
            },
          ],
        });
        expect(doc['db'], {
          'status': 'idle',
          'cpuCores': isEmpty,
          'memoryBytes': isEmpty,
          'connections': isEmpty,
          'storageBytes': isEmpty,
        });
      });
    });

    group('when running metrics with --target db', () {
      setUp(() async {
        await runCli(['metrics', '--project', projectId, '--target', 'db']);
      });

      test('then only the database endpoint is queried', () async {
        verify(
          () => client.metrics.fetchDatabaseMetrics(
            cloudCapsuleId: projectId,
            range: MetricsRange.oneHour,
            until: null,
          ),
        ).called(1);
        verifyNever(
          () => client.metrics.fetchPodResourceMetrics(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            range: any(named: 'range'),
            until: any(named: 'until'),
          ),
        );
        verifyNever(
          () => client.metrics.fetchNetworkMetrics(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            range: any(named: 'range'),
            until: any(named: 'until'),
          ),
        );
      });

      test('then the document contains only the db signal set', () async {
        final doc = outputDocument();

        expect(
          doc.keys,
          unorderedEquals(['projectId', 'range', 'until', 'db']),
        );
        expect(doc['db'], containsPair('status', 'idle'));
      });
    });

    group('when running metrics with a range and a duration until anchor', () {
      test(
        'then the endpoint receives the range and a bounded until',
        () async {
          const threeHours = Duration(hours: 3);
          final earliestAnchor = DateTime.now().subtract(threeHours);
          await runCli([
            'metrics',
            '--project',
            projectId,
            '--target',
            'compute',
            '--range',
            'oneDay',
            '--until',
            '3h',
          ]);
          final latestAnchor = DateTime.now().subtract(threeHours);

          final captured = verify(
            () => client.metrics.fetchPodResourceMetrics(
              cloudCapsuleId: projectId,
              range: MetricsRange.oneDay,
              until: captureAny(named: 'until'),
            ),
          ).captured.single;

          expect(captured, isA<DateTime>());
          final until = captured as DateTime;
          expect(
            until.isBefore(earliestAnchor),
            isFalse,
            reason: 'until $until is before $earliestAnchor',
          );
          expect(
            until.isAfter(latestAnchor),
            isFalse,
            reason: 'until $until is after $latestAnchor',
          );
        },
      );
    });
  });

  group('Given one endpoint fails while the others report data', () {
    setUp(() {
      whenComputeReturns(podSeries);
      whenDatabaseReturns(idleDatabase);
      when(
        () => client.metrics.fetchNetworkMetrics(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          range: any(named: 'range'),
          until: any(named: 'until'),
        ),
      ).thenAnswer((final _) async => throw Exception('connection refused'));
    });

    test('then the command exits with a wrapped failure', () async {
      await expectLater(
        runCli(['metrics', '--project', projectId]),
        throwsA(isA<ErrorExitException>()),
      );

      expect(
        logger.errorCalls.single.message,
        contains('Failed to fetch metrics'),
      );
    });
  });
}

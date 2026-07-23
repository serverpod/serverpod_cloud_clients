import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/metrics_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/commands/metrics/metrics.dart';
import 'package:test/test.dart';

import '../../test_utils/test_command_logger.dart';

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

  setUpAll(() {
    registerFallbackValue(MetricsRange.oneHour);
  });

  const projectId = 'projectId';
  final firstSampleTime = DateTime.utc(2026, 1, 15, 10, 30);
  final secondSampleTime = DateTime.utc(2026, 1, 15, 10, 31);
  final thirdSampleTime = DateTime.utc(2026, 1, 15, 10, 32);

  PodResourceSeries series({
    required final String podName,
    required final List<DateTime> cpuTimes,
    required final List<DateTime> memoryTimes,
  }) => PodResourceSeries(
    podName: podName,
    cpuCores: cpuTimes
        .map((final t) => PodMetricSample(timestamp: t, value: 0.125))
        .toList(),
    memoryBytes: memoryTimes
        .map((final t) => PodMetricSample(timestamp: t, value: 134217728))
        .toList(),
  );

  void whenFetchReturns(final List<PodResourceSeries> result) {
    when(
      () => client.metrics.fetchPodResourceMetrics(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        range: any(named: 'range'),
        until: any(named: 'until'),
      ),
    ).thenAnswer((final _) async => result);
  }

  String outputLines() => logger.lineCalls.map((final c) => c.line).join('\n');

  group('Given command instantiation', () {
    test('then metrics requires login', () {
      expect(CloudMetricsCommand(logger: logger).requireLogin, isTrue);
    });
  });

  group('Given authenticated', () {
    setUp(() async {
      client.authKeyProvider = InMemoryKeyManager.authenticated();
    });

    tearDown(() {
      reset(client.metrics);
    });

    group('when fetching metrics without a range', () {
      setUp(() {
        whenFetchReturns([
          series(
            podName: 'pod-a',
            cpuTimes: [firstSampleTime],
            memoryTimes: [firstSampleTime],
          ),
        ]);
      });

      test('then defaults to the one hour range ending now', () async {
        await cli.run(['metrics', '--project', projectId]);

        verify(
          () => client.metrics.fetchPodResourceMetrics(
            cloudCapsuleId: projectId,
            range: MetricsRange.oneHour,
            until: null,
          ),
        ).called(1);
      });
    });

    group('when fetching metrics with a range and an until timestamp', () {
      setUp(() {
        whenFetchReturns([
          series(
            podName: 'pod-a',
            cpuTimes: [firstSampleTime],
            memoryTimes: [firstSampleTime],
          ),
        ]);
      });

      test('then passes both to the endpoint', () async {
        await cli.run([
          'metrics',
          '--project',
          projectId,
          '--range',
          'oneWeek',
          '--until',
          '2026-01-15T10:30:00Z',
        ]);

        verify(
          () => client.metrics.fetchPodResourceMetrics(
            cloudCapsuleId: projectId,
            range: MetricsRange.oneWeek,
            until: firstSampleTime,
          ),
        ).called(1);
      });

      test('then accepts a duration as the until anchor', () async {
        await cli.run(['metrics', '--project', projectId, '--until', '3h']);

        final captured =
            verify(
                  () => client.metrics.fetchPodResourceMetrics(
                    cloudCapsuleId: projectId,
                    range: MetricsRange.oneHour,
                    until: captureAny(named: 'until'),
                  ),
                ).captured.single
                as DateTime?;
        expect(captured, isNotNull);
        expect(captured!.isBefore(DateTime.now()), isTrue);
      });
    });

    group('when an invalid range is given', () {
      late Future<void> result;
      setUp(() {
        result = cli.run([
          'metrics',
          '--project',
          projectId,
          '--range',
          'oneYear',
        ]);
      });

      test('then throws UsageException listing the allowed values', () async {
        await expectLater(
          result,
          throwsA(
            isA<UsageException>().having(
              (final e) => e.message,
              'message',
              allOf(contains('oneHour'), contains('oneMonth')),
            ),
          ),
        );
      });
    });

    group('when both --raw and --table are given', () {
      late Future<void> result;
      setUp(() {
        result = cli.run([
          'metrics',
          '--project',
          projectId,
          '--raw',
          '--table',
        ]);
      });

      test('then throws UsageException', () async {
        await expectLater(result, throwsA(isA<UsageException>()));

        verifyNever(
          () => client.metrics.fetchPodResourceMetrics(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            range: any(named: 'range'),
            until: any(named: 'until'),
          ),
        );
      });
    });

    group('when a pod is missing a sample inside its own lifetime', () {
      setUp(() {
        whenFetchReturns([
          series(
            podName: 'pod-a',
            cpuTimes: [firstSampleTime, thirdSampleTime],
            memoryTimes: [firstSampleTime, thirdSampleTime],
          ),
          series(
            podName: 'pod-b',
            cpuTimes: [firstSampleTime, secondSampleTime, thirdSampleTime],
            memoryTimes: [firstSampleTime, secondSampleTime, thirdSampleTime],
          ),
        ]);
      });

      test('then renders a table per pod', () async {
        await cli.run(['metrics', '--project', projectId, '--utc']);

        final output = outputLines();
        expect(output, contains('Pod: pod-a'));
        expect(output, contains('Pod: pod-b'));
        expect(output, contains('CPU (cores)'));
      });

      test('then renders the gap as no data instead of zero', () async {
        await cli.run(['metrics', '--project', projectId, '--utc']);

        final output = outputLines();
        expect(output, contains(noDataPlaceholder));
        expect(output, contains('2026-01-15 10:31:00'));
        expect(output, isNot(contains('0.000')));
      });

      test('then --table renders the same table as the default', () async {
        await cli.run(['metrics', '--project', projectId, '--utc', '--table']);

        expect(outputLines(), contains('Pod: pod-a'));
      });
    });

    group('when pods are sequential rather than concurrent', () {
      setUp(() {
        whenFetchReturns([
          series(
            podName: 'pod-a',
            cpuTimes: [firstSampleTime],
            memoryTimes: [firstSampleTime],
          ),
          series(
            podName: 'pod-b',
            cpuTimes: [thirdSampleTime],
            memoryTimes: [thirdSampleTime],
          ),
        ]);
      });

      test("then each table is clipped to that pod's lifetime", () async {
        await cli.run(['metrics', '--project', projectId, '--utc']);

        final output = outputLines();
        expect(output, isNot(contains(noDataPlaceholder)));
        expect(output, contains('2026-01-15 10:30:00'));
        expect(output, contains('2026-01-15 10:32:00'));
      });
    });

    group('when raw output is requested', () {
      setUp(() {
        whenFetchReturns([
          series(
            podName: 'pod-a',
            cpuTimes: [firstSampleTime],
            memoryTimes: [],
          ),
        ]);
      });

      test('then emits the series as JSON', () async {
        await cli.run([
          'metrics',
          '--project',
          projectId,
          '--range',
          'oneDay',
          '--raw',
        ]);

        final json = jsonDecode(outputLines()) as Map<String, dynamic>;
        expect(json['projectId'], projectId);
        expect(json['range'], 'oneDay');
        expect(json['until'], isNull);

        final pods = json['pods'] as List<dynamic>;
        final pod = pods.single as Map<String, dynamic>;
        expect(pod['pod'], 'pod-a');
        expect((pod['cpuCores'] as List<dynamic>).single, {
          'timestamp': '2026-01-15T10:30:00.000Z',
          'value': 0.125,
        });
      });

      test('then a gap is an absent sample, not a zero', () async {
        await cli.run(['metrics', '--project', projectId, '--raw']);

        final json = jsonDecode(outputLines()) as Map<String, dynamic>;
        final pod =
            (json['pods'] as List<dynamic>).single as Map<String, dynamic>;
        expect(pod['memoryBytes'], isEmpty);
      });
    });

    group('when the capsule has no metrics', () {
      setUp(() {
        whenFetchReturns([]);
      });

      test('then reports that no metrics were found', () async {
        await cli.run(['metrics', '--project', projectId]);

        expect(
          logger.infoCalls.any(
            (final c) => c.message.contains('No pod metrics found'),
          ),
          isTrue,
        );
      });
    });
  });
}

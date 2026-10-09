import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/tui/top_series.dart';
import 'package:test/test.dart';

void main() {
  final DateTime from = DateTime.utc(2026, 1, 1, 12);
  final DateTime to = DateTime.utc(2026, 1, 1, 13);

  group('Given samples spread over an hour', () {
    final List<MetricSample> samples = [
      MetricSampleBuilder()
          .withTimestamp(DateTime.utc(2026, 1, 1, 12, 5))
          .withValue(2)
          .build(),
      MetricSampleBuilder()
          .withTimestamp(DateTime.utc(2026, 1, 1, 12, 10))
          .withValue(4)
          .build(),
      MetricSampleBuilder()
          .withTimestamp(DateTime.utc(2026, 1, 1, 12, 50))
          .withValue(8)
          .build(),
    ];

    test('when bucketing into four slots '
        'then each slot is the average of its samples', () {
      expect(bucketSamples(samples, from: from, to: to, buckets: 4), [
        3,
        null,
        null,
        8,
      ]);
    });

    test('when bucketing into no slots then the result is empty', () {
      expect(bucketSamples(samples, from: from, to: to, buckets: 0), isEmpty);
    });
  });

  group('Given a sample outside the window', () {
    final List<MetricSample> samples = [
      MetricSampleBuilder()
          .withTimestamp(DateTime.utc(2026, 1, 1, 11, 59))
          .build(),
    ];

    test('when bucketing then the sample is left out', () {
      expect(bucketSamples(samples, from: from, to: to, buckets: 2), [
        null,
        null,
      ]);
    });
  });

  group('Given a sample at the end of the window', () {
    final List<MetricSample> samples = [
      MetricSampleBuilder().withTimestamp(to).build(),
    ];

    test('when bucketing then the sample lands in the last slot', () {
      expect(bucketSamples(samples, from: from, to: to, buckets: 2), [null, 1]);
    });
  });

  group('Given two series', () {
    test('when summing then values in the same slot are added', () {
      expect(
        sumBuckets([
          [1, null, 3],
          [2, null, null],
        ]),
        [3, null, 3],
      );
    });
  });

  test('Given no series when summing then the result is empty', () {
    expect(sumBuckets([]), isEmpty);
  });

  group('Given values with a gap at the end', () {
    test('when taking the latest value then the gap is skipped', () {
      expect(latestValue([1, 2, null]), 2);
    });
  });

  test('Given only gaps when taking the latest value then it is null', () {
    expect(latestValue([null, null]), isNull);
  });

  group('Given values from zero to the highest', () {
    test('when drawing a sparkline '
        'then each value is a block scaled to the highest', () {
      expect(sparkline([0, 5, 10]), '▁▅█');
    });
  });

  test('Given a gap when drawing a sparkline then the gap is a space', () {
    expect(sparkline([10, null, 10]), '█ █');
  });

  test('Given only zeros when drawing a sparkline '
      'then every value is the lowest block', () {
    expect(sparkline([0, 0]), '▁▁');
  });

  test('Given a CPU usage when formatting then it has two decimals', () {
    expect(formatCores(0.384), '0.38 cores');
  });

  test('Given a low request rate when formatting then it has one decimal', () {
    expect(formatRate(12.44), '12.4 req/s');
  });

  test('Given a high request rate when formatting then it has no decimals', () {
    expect(formatRate(124.4), '124 req/s');
  });

  test('Given a small share when formatting then it has one decimal', () {
    expect(formatShare(1, 250), '0.4%');
  });

  test('Given a large share when formatting then it has no decimals', () {
    expect(formatShare(1, 4), '25%');
  });

  test('Given a total of zero when formatting a share then it is zero', () {
    expect(formatShare(1, 0), '0%');
  });
}

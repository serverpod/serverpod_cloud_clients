import 'dart:math' as math;

import 'package:ground_control_client/ground_control_client.dart';

/// The most columns a sparkline is drawn with: one per sample of the metrics
/// window, which the server samples once a minute over an hour.
const int maxSparklineBuckets = 60;

const List<String> _sparklineBlocks = ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'];

/// Averages [samples] into [buckets] equal time slots between [from] and
/// [to]. A slot without a sample is null, so a gap stays a gap.
List<double?> bucketSamples(
  final List<MetricSample> samples, {
  required final DateTime from,
  required final DateTime to,
  required final int buckets,
}) {
  final int span = to.difference(from).inMicroseconds;
  if (buckets <= 0 || span <= 0) {
    return const [];
  }

  final List<double> sums = List<double>.filled(buckets, 0);
  final List<int> counts = List<int>.filled(buckets, 0);
  for (final MetricSample sample in samples) {
    final int offset = sample.timestamp.difference(from).inMicroseconds;
    if (offset < 0 || offset > span) {
      continue;
    }
    final int index = math.min(buckets - 1, offset * buckets ~/ span);
    sums[index] += sample.value;
    counts[index]++;
  }

  return [
    for (int i = 0; i < buckets; i++)
      counts[i] == 0 ? null : sums[i] / counts[i],
  ];
}

/// Adds up [series] slot by slot. A slot is null when no series has a value
/// in it.
List<double?> sumBuckets(final List<List<double?>> series) {
  if (series.isEmpty) {
    return const [];
  }

  return [
    for (int i = 0; i < series.first.length; i++)
      series
          .map((final List<double?> values) {
            return values[i];
          })
          .nonNulls
          .fold<double?>(null, (final double? sum, final double value) {
            return (sum ?? 0) + value;
          }),
  ];
}

/// The total of [series] over time, as [buckets] slots between [from] and
/// [to].
List<double?> totalSeries(
  final List<List<MetricSample>> series, {
  required final DateTime from,
  required final DateTime to,
  final int buckets = maxSparklineBuckets,
}) {
  return sumBuckets([
    for (final List<MetricSample> samples in series)
      bucketSamples(samples, from: from, to: to, buckets: buckets),
  ]);
}

/// The most recent value of [values], or null if there is none.
double? latestValue(final List<double?> values) {
  return values.nonNulls.lastOrNull;
}

/// Draws [values] as one block character per value, scaled from zero to the
/// highest value. A null value is drawn as a space.
String sparkline(final List<double?> values) {
  final double highest = values.nonNulls.fold<double>(0, math.max);

  return [
    for (final double? value in values)
      if (value == null)
        ' '
      else if (highest <= 0)
        _sparklineBlocks.first
      else
        _sparklineBlocks[math.min(
          _sparklineBlocks.length - 1,
          (value / highest * (_sparklineBlocks.length - 1)).round(),
        )],
  ].join();
}

/// Formats a CPU usage in cores, for example `0.38 cores`.
String formatCores(final double cores) {
  return '${cores.toStringAsFixed(2)} cores';
}

/// Formats a request rate, for example `12.4 req/s`.
String formatRate(final double perSecond) {
  final int digits = perSecond >= 100 ? 0 : 1;
  return '${perSecond.toStringAsFixed(digits)} req/s';
}

/// Formats [part] as a percentage of [total], for example `0.4%`.
String formatShare(final double part, final double total) {
  if (total <= 0 || part <= 0) {
    return '0%';
  }
  final double percent = part / total * 100;
  return '${percent.toStringAsFixed(percent >= 10 ? 0 : 1)}%';
}

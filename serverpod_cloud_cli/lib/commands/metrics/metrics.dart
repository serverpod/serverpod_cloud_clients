import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

/// The rendering of a period for which a pod has no observed sample.
const noDataPlaceholder = 'no data';

/// The output format of the metrics command.
enum MetricsOutputFormat { table, json }

/// Commands for reading resource metrics of a project's pods.
abstract class MetricsCommands {
  /// Fetches and renders per-pod CPU and memory for the project's capsule
  /// over a window of length [range] ending at [until] (defaults to now).
  ///
  /// Timestamps that a pod has no sample for are rendered as
  /// [noDataPlaceholder] in table output and are absent from JSON output —
  /// a gap is never filled with a zero or an interpolated value.
  static Future<void> fetchPodMetrics(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final MetricsRange range,
    final DateTime? until,
    final MetricsOutputFormat format = MetricsOutputFormat.table,
    final bool utc = false,
  }) async {
    final List<PodResourceSeries> series;
    try {
      series = await cloudApiClient.metrics.fetchPodResourceMetrics(
        cloudCapsuleId: projectId,
        range: range,
        until: until,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to fetch pod metrics');
    }

    switch (format) {
      case MetricsOutputFormat.json:
        logger.line(
          _asJson(series, projectId: projectId, range: range, until: until),
        );
      case MetricsOutputFormat.table:
        _writeTables(series, logger: logger, projectId: projectId, utc: utc);
    }
  }

  static void _writeTables(
    final List<PodResourceSeries> series, {
    required final CommandLogger logger,
    required final String projectId,
    required final bool utc,
  }) {
    if (series.isEmpty) {
      logger.info(
        'No pod metrics found for project "$projectId" '
        'in the selected time window.',
      );
      return;
    }

    final timestamps = _sampledTimestamps(series);
    for (final pod in series) {
      final podTimestamps = _lifetimeOf(pod, within: timestamps);
      if (podTimestamps.isEmpty) continue;

      logger.line('');
      logger.line('Pod: ${pod.podName}');
      logger.line('');
      _podTable(
        pod,
        timestamps: podTimestamps,
        utc: utc,
      ).writeLines(logger.line);
    }
  }

  /// The grid timestamps spanning [pod]'s own first to last observed sample.
  ///
  /// Pods in a window are usually sequential rather than concurrent — a deploy
  /// replaces one with another — so showing every pod against the full grid
  /// buries its handful of samples under the rest of the window. Clipping to
  /// the pod's lifetime keeps gaps *within* that lifetime visible while
  /// dropping the stretches where the pod did not exist at all.
  static List<DateTime> _lifetimeOf(
    final PodResourceSeries pod, {
    required final List<DateTime> within,
  }) {
    final observed = [
      ...pod.cpuCores.map((final s) => s.timestamp),
      ...pod.memoryBytes.map((final s) => s.timestamp),
    ];
    if (observed.isEmpty) return const [];

    final first = observed.reduce((final a, final b) => a.isBefore(b) ? a : b);
    final last = observed.reduce((final a, final b) => a.isAfter(b) ? a : b);

    return within
        .where((final t) => !t.isBefore(first) && !t.isAfter(last))
        .toList();
  }

  /// The union of all timestamps observed across every pod and both metrics,
  /// ascending.
  ///
  /// All pods are sampled on the same server-side grid, so a timestamp another
  /// pod reported at is a period this pod genuinely has no data for, rather
  /// than a grid position the CLI invented.
  static List<DateTime> _sampledTimestamps(
    final List<PodResourceSeries> series,
  ) {
    final timestamps = <DateTime>{
      for (final pod in series) ...[
        ...pod.cpuCores.map((final s) => s.timestamp),
        ...pod.memoryBytes.map((final s) => s.timestamp),
      ],
    }.toList();
    timestamps.sort();
    return timestamps;
  }

  static TablePrinter _podTable(
    final PodResourceSeries pod, {
    required final List<DateTime> timestamps,
    required final bool utc,
  }) {
    final cpuByTimestamp = _byTimestamp(pod.cpuCores);
    final memoryByTimestamp = _byTimestamp(pod.memoryBytes);

    return TablePrinter(
      headers: ['Time', 'CPU (cores)', 'Memory'],
      rows: timestamps.map(
        (final timestamp) => [
          _formatTimestamp(timestamp, utc: utc),
          _formatCpu(cpuByTimestamp[timestamp]),
          _formatBytes(memoryByTimestamp[timestamp]),
        ],
      ),
    );
  }

  static Map<DateTime, double> _byTimestamp(
    final List<PodMetricSample> samples,
  ) => {for (final sample in samples) sample.timestamp: sample.value};

  static String _asJson(
    final List<PodResourceSeries> series, {
    required final String projectId,
    required final MetricsRange range,
    required final DateTime? until,
  }) {
    final json = {
      'projectId': projectId,
      'range': range.name,
      'until': until?.toUtc().toIso8601String(),
      'pods': series
          .map(
            (final pod) => {
              'pod': pod.podName,
              'cpuCores': pod.cpuCores.map(_sampleAsJson).toList(),
              'memoryBytes': pod.memoryBytes.map(_sampleAsJson).toList(),
            },
          )
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(json);
  }

  static Map<String, Object> _sampleAsJson(final PodMetricSample sample) => {
    'timestamp': sample.timestamp.toUtc().toIso8601String(),
    'value': sample.value,
  };

  static String _formatTimestamp(
    final DateTime timestamp, {
    required final bool utc,
  }) {
    final local = utc ? timestamp.toUtc() : timestamp.toLocal();
    return local.toString().substring(0, 19);
  }

  static String _formatCpu(final double? cores) {
    if (cores == null) return noDataPlaceholder;
    return cores.toStringAsFixed(3);
  }

  static String _formatBytes(final double? bytes) {
    if (bytes == null) return noDataPlaceholder;
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    const units = ['KB', 'MB', 'GB', 'TB'];
    var size = bytes / 1024;
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}

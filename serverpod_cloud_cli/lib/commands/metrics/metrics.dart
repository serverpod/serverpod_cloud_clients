import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

/// The signal set a metrics query is scoped to.
enum MetricsTarget { compute, network, db }

/// The format the metrics command renders its output in.
enum DataOutputFormat { json }

/// Commands for reading resource metrics of a project's capsule.
abstract class MetricsCommands {
  /// Fetches capsule metrics for [target] (all targets when null) over a
  /// window of length [range] ending at [until] (defaults to now), and emits
  /// them as a single JSON document.
  ///
  /// Series are sparse: a period with no observed sample is absent from the
  /// output — a gap is never filled with a zero or an interpolated value.
  static Future<void> fetchMetrics(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final MetricsRange range,
    final MetricsTarget? target,
    final DateTime? until,
  }) async {
    final targets = target == null ? MetricsTarget.values : [target];

    final computeFuture = targets.contains(MetricsTarget.compute)
        ? cloudApiClient.metrics.fetchPodResourceMetrics(
            cloudCapsuleId: projectId,
            range: range,
            until: until,
          )
        : null;
    final networkFuture = targets.contains(MetricsTarget.network)
        ? cloudApiClient.metrics.fetchNetworkMetrics(
            cloudCapsuleId: projectId,
            range: range,
            until: until,
          )
        : null;
    final dbFuture = targets.contains(MetricsTarget.db)
        ? cloudApiClient.metrics.fetchDatabaseMetrics(
            cloudCapsuleId: projectId,
            range: range,
            until: until,
          )
        : null;

    try {
      await Future.wait<void>([
        if (computeFuture != null) computeFuture,
        if (networkFuture != null) networkFuture,
        if (dbFuture != null) dbFuture,
      ]);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to fetch metrics');
    }

    final compute = await computeFuture;
    final network = await networkFuture;
    final db = await dbFuture;

    final document = {
      'projectId': projectId,
      'range': range.name,
      'until': until?.toUtc().toIso8601String(),
      if (compute != null) 'compute': _computeAsJson(compute),
      if (network != null) 'network': _networkAsJson(network),
      if (db != null) 'db': _databaseAsJson(db),
    };

    logger.line(const JsonEncoder.withIndent('  ').convert(document));
  }

  static Map<String, Object> _computeAsJson(
    final List<PodResourceSeries> series,
  ) => {
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

  static Map<String, Object> _networkAsJson(
    final CapsuleNetworkSeries series,
  ) => {
    'requestsPerSecond': series.requestsPerSecond.map(_sampleAsJson).toList(),
    'responses': series.responses
        .map(
          (final responseClass) => {
            'responseClass': responseClass.responseClass.name,
            'responsesPerSecond': responseClass.responsesPerSecond
                .map(_sampleAsJson)
                .toList(),
          },
        )
        .toList(),
  };

  static Map<String, Object> _databaseAsJson(final DatabaseMetrics metrics) => {
    'status': metrics.status.name,
    'cpuCores': metrics.cpuCores.map(_sampleAsJson).toList(),
    'memoryBytes': metrics.memoryBytes.map(_sampleAsJson).toList(),
    'connections': metrics.connections.map(_sampleAsJson).toList(),
    'storageBytes': metrics.storageBytes.map(_sampleAsJson).toList(),
  };

  static Map<String, Object> _sampleAsJson(final MetricSample sample) => {
    'timestamp': sample.timestamp.toUtc().toIso8601String(),
    'value': sample.value,
  };
}

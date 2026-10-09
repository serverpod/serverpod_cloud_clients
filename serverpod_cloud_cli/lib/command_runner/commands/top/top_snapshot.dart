import 'package:ground_control_client/ground_control_client.dart';

/// Everything the `top` screen shows about a project at one moment.
///
/// [runtime] is always present. A panel whose data could not be fetched is
/// null, so the screen can say that it is unavailable.
class TopSnapshot {
  final CapsuleRuntimeStatus runtime;

  /// When [runtime] was last fetched.
  final DateTime updatedAt;

  /// Whether the latest refresh of [runtime] failed, so [runtime] holds the
  /// values from [updatedAt] instead of the current ones.
  final bool isStatusStale;

  /// The most recent deploy attempts, newest first.
  final List<DeployAttempt>? deployments;

  final List<PodResourceSeries>? podResources;
  final CapsuleNetworkSeries? network;
  final DatabaseMetrics? database;

  /// The end of the window that the metrics series cover.
  final DateTime metricsUntil;

  /// The most recent log records, oldest first.
  final List<LogRecord>? logs;

  const TopSnapshot({
    required this.runtime,
    required this.updatedAt,
    required this.deployments,
    required this.podResources,
    required this.network,
    required this.database,
    required this.metricsUntil,
    required this.logs,
    this.isStatusStale = false,
  });

  /// Returns a copy with the metrics of the window ending at [metricsUntil].
  ///
  /// Unlike [copyWith], a null series replaces the current one, so a panel
  /// whose metrics could not be fetched shows as unavailable instead of
  /// showing samples from an older window.
  TopSnapshot withMetrics({
    required final List<PodResourceSeries>? podResources,
    required final CapsuleNetworkSeries? network,
    required final DatabaseMetrics? database,
    required final DateTime metricsUntil,
  }) {
    return TopSnapshot(
      runtime: runtime,
      updatedAt: updatedAt,
      deployments: deployments,
      podResources: podResources,
      network: network,
      database: database,
      metricsUntil: metricsUntil,
      logs: logs,
      isStatusStale: isStatusStale,
    );
  }

  /// Returns a copy where each given value replaces the current one.
  TopSnapshot copyWith({
    final CapsuleRuntimeStatus? runtime,
    final DateTime? updatedAt,
    final List<DeployAttempt>? deployments,
    final List<PodResourceSeries>? podResources,
    final CapsuleNetworkSeries? network,
    final DatabaseMetrics? database,
    final DateTime? metricsUntil,
    final List<LogRecord>? logs,
    final bool? isStatusStale,
  }) {
    return TopSnapshot(
      runtime: runtime ?? this.runtime,
      updatedAt: updatedAt ?? this.updatedAt,
      deployments: deployments ?? this.deployments,
      podResources: podResources ?? this.podResources,
      network: network ?? this.network,
      database: database ?? this.database,
      metricsUntil: metricsUntil ?? this.metricsUntil,
      logs: logs ?? this.logs,
      isStatusStale: isStatusStale ?? this.isStatusStale,
    );
  }
}

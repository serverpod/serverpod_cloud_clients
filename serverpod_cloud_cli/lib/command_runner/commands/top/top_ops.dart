import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/top_snapshot.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

typedef _Metrics = ({
  List<PodResourceSeries>? podResources,
  CapsuleNetworkSeries? network,
  DatabaseMetrics? database,
});

abstract class TopOperations {
  /// The length of the window that the metrics series cover.
  static const Duration metricsWindow = Duration(hours: 1);

  static const MetricsRange _metricsRange = MetricsRange.oneHour;

  /// Fetches the status, deployments, metrics and recent logs of [projectId].
  ///
  /// Throws a [FailureException] if the status cannot be fetched. Deployments,
  /// metrics and logs that cannot be fetched are null in the snapshot
  /// instead, so one missing panel does not block the others.
  static Future<TopSnapshot> fetchSnapshot(
    final Client cloudApiClient, {
    required final String projectId,
    required final int deploymentLimit,
    required final int logLimit,
  }) async {
    final CapsuleRuntimeStatus runtime =
        await StatusCommands.fetchRuntimeStatus(
          cloudApiClient,
          projectId: projectId,
        );
    final DateTime now = DateTime.now();
    final (
      List<DeployAttempt>? deployments,
      _Metrics metrics,
      List<LogRecord>? logs,
    ) = await (
      _fetchDeployments(
        cloudApiClient,
        projectId: projectId,
        limit: deploymentLimit,
      ),
      _fetchMetrics(cloudApiClient, projectId: projectId, until: now),
      _orNull(() {
        return cloudApiClient.logs
            .fetchRecentRecords(cloudCapsuleId: projectId, limit: logLimit)
            .toList();
      }),
    ).wait;

    return TopSnapshot(
      runtime: runtime,
      updatedAt: now,
      deployments: deployments,
      podResources: metrics.podResources,
      network: metrics.network,
      database: metrics.database,
      metricsUntil: now,
      logs: logs,
    );
  }

  /// Keeps [initial] up to date and emits a snapshot on every change, until
  /// the listener cancels.
  ///
  /// The status and deployments refresh every [interval], the metrics every
  /// [metricsInterval], and log records arrive as they are written. A failed
  /// status refresh keeps the previous values and marks the status as stale
  /// until a refresh succeeds, a failed deployments refresh keeps the previous
  /// values, a failed metrics request leaves its panel unavailable, and an
  /// ended log tail reconnects after [interval].
  ///
  /// Ends with a [FailureException] if a status refresh is refused because
  /// the credentials are no longer valid or the access to [projectId] is lost.
  static Stream<TopSnapshot> watchSnapshots(
    final Client cloudApiClient, {
    required final TopSnapshot initial,
    required final String projectId,
    required final Duration interval,
    required final Duration metricsInterval,
    required final int deploymentLimit,
    required final int logLimit,
  }) {
    late final StreamController<TopSnapshot> controller;
    StreamSubscription<LogRecord>? logSubscription;
    Timer? statusTimer;
    Timer? metricsTimer;
    Timer? logTimer;
    TopSnapshot snapshot = initial;
    bool watching = false;

    void emit(final TopSnapshot next) {
      if (!watching) {
        return;
      }
      snapshot = next;
      controller.add(next);
    }

    void stop() {
      watching = false;
      statusTimer?.cancel();
      metricsTimer?.cancel();
      logTimer?.cancel();
    }

    Future<CapsuleRuntimeStatus?> fetchRuntime() async {
      try {
        return await cloudApiClient.status.getCapsuleRuntimeStatus(
          cloudCapsuleId: projectId,
        );
      } on Exception catch (e, s) {
        if (watching && _isAccessFailure(e)) {
          stop();
          controller.addError(
            FailureException.nested(
              e,
              s,
              'Lost access to the project "$projectId".',
            ),
            s,
          );
          unawaited(logSubscription?.cancel());
          unawaited(controller.close());
        }
        return null;
      }
    }

    Future<void> pollStatus() async {
      try {
        final (
          CapsuleRuntimeStatus? runtime,
          List<DeployAttempt>? deployments,
        ) = await (
          fetchRuntime(),
          _fetchDeployments(
            cloudApiClient,
            projectId: projectId,
            limit: deploymentLimit,
          ),
        ).wait;
        if (!watching) {
          return;
        }

        final bool isStatusStale = runtime == null;
        if (runtime != null ||
            deployments != null ||
            isStatusStale != snapshot.isStatusStale) {
          emit(
            snapshot.copyWith(
              runtime: runtime,
              updatedAt: runtime == null ? null : DateTime.now(),
              deployments: deployments,
              isStatusStale: isStatusStale,
            ),
          );
        }
      } finally {
        if (watching) {
          statusTimer = Timer(interval, () {
            unawaited(pollStatus());
          });
        }
      }
    }

    Future<void> pollMetrics() async {
      try {
        final DateTime until = DateTime.now();
        final _Metrics metrics = await _fetchMetrics(
          cloudApiClient,
          projectId: projectId,
          until: until,
        );
        if (!watching) {
          return;
        }

        emit(
          snapshot.withMetrics(
            podResources: metrics.podResources,
            network: metrics.network,
            database: metrics.database,
            metricsUntil: until,
          ),
        );
      } finally {
        if (watching) {
          metricsTimer = Timer(metricsInterval, () {
            unawaited(pollMetrics());
          });
        }
      }
    }

    void tailLogs() {
      void reconnect() {
        if (watching) {
          logTimer = Timer(interval, tailLogs);
        }
      }

      logSubscription = cloudApiClient.logs
          .tailRecords(cloudCapsuleId: projectId)
          .listen(
            (final LogRecord record) {
              final List<LogRecord> known = snapshot.logs ?? const [];
              final bool isKnown = known.any((final LogRecord known) {
                return known.recordId == record.recordId;
              });
              if (isKnown) {
                return;
              }

              final List<LogRecord> logs = [...known, record];
              emit(
                snapshot.copyWith(
                  logs: logs.length > logLimit
                      ? logs.sublist(logs.length - logLimit)
                      : logs,
                ),
              );
            },
            onError: (final Object error, final StackTrace stackTrace) {
              if (error is! Exception) {
                Error.throwWithStackTrace(error, stackTrace);
              }
              reconnect();
            },
            onDone: reconnect,
            cancelOnError: true,
          );
    }

    controller = StreamController<TopSnapshot>(
      onListen: () {
        watching = true;
        statusTimer = Timer(interval, () {
          unawaited(pollStatus());
        });
        metricsTimer = Timer(metricsInterval, () {
          unawaited(pollMetrics());
        });
        tailLogs();
      },
      onCancel: () async {
        stop();
        await logSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  static Future<List<DeployAttempt>?> _fetchDeployments(
    final Client cloudApiClient, {
    required final String projectId,
    required final int limit,
  }) {
    return _orNull(() {
      return cloudApiClient.status.getDeployAttempts(
        cloudCapsuleId: projectId,
        limit: limit,
      );
    });
  }

  static Future<_Metrics> _fetchMetrics(
    final Client cloudApiClient, {
    required final String projectId,
    required final DateTime until,
  }) async {
    final (
      List<PodResourceSeries>? podResources,
      CapsuleNetworkSeries? network,
      DatabaseMetrics? database,
    ) = await (
      _orNull(() {
        return cloudApiClient.metrics.fetchPodResourceMetrics(
          cloudCapsuleId: projectId,
          range: _metricsRange,
          until: until,
        );
      }),
      _orNull(() {
        return cloudApiClient.metrics.fetchNetworkMetrics(
          cloudCapsuleId: projectId,
          range: _metricsRange,
          until: until,
        );
      }),
      _orNull(() {
        return cloudApiClient.metrics.fetchDatabaseMetrics(
          cloudCapsuleId: projectId,
          range: _metricsRange,
          until: until,
        );
      }),
    ).wait;

    return (podResources: podResources, network: network, database: database);
  }

  static bool _isAccessFailure(final Exception e) {
    return e is ServerpodClientUnauthorized ||
        e is ServerpodClientForbidden ||
        e is UnauthorizedException;
  }

  static Future<T?> _orNull<T>(final Future<T> Function() fetch) async {
    try {
      return await fetch();
    } on Exception {
      return null;
    }
  }
}

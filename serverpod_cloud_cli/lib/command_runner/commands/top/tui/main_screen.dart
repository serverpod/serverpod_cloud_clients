import 'dart:math' as math;

import 'package:ground_control_client/ground_control_client.dart'
    hide VoidCallback;
import 'package:nocterm/nocterm.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/log/log_ui.dart'
    show logLevelOf, summarizeLogContent;
import 'package:serverpod_cloud_cli/command_runner/commands/status/capsule_state_look.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/top_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/top_snapshot.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/tui/state.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/tui/top_series.dart';
import 'package:serverpod_cloud_cli/util/byte_size.dart';
import 'package:serverpod_cloud_cli/util/capitalize.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/duration_formatter.dart';
import 'package:serverpod_tui/serverpod_tui.dart';

const TextStyle _dim = TextStyle(fontWeight: FontWeight.dim);
const double _labelWidth = 13.0;
const double _valueWidth = 11.0;
const int _wideLayoutColumns = 110;
const int _shortHashLength = 7;

typedef _AttemptLook = ({String label, StatusTone tone});
typedef _DeploymentLook = ({String glyph, StatusTone tone});
typedef _LogLook = ({String label, Color? color, bool isProblem});

class MainScreen extends StatelessComponent {
  const MainScreen({
    super.key,
    required this.state,
    required this.logScrollController,
    required this.onQuit,
  });

  final TopState state;
  final ScrollController logScrollController;
  final VoidCallback onQuit;

  @override
  Component build(BuildContext context) {
    final TopSnapshot snapshot = state.snapshot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusPanel(state: state),
        _MetricsPanels(snapshot: snapshot),
        _DeploymentsPanel(snapshot: snapshot, utc: state.utc),
        Expanded(
          child: _LogsPanel(
            logs: snapshot.logs,
            utc: state.utc,
            scrollController: logScrollController,
          ),
        ),
        ButtonBar(
          buttons: [
            Button(
              name: 'Quit',
              activationChar: 'Q',
              activationKeys: const [LogicalKey.keyQ, LogicalKey.escape],
              onActivate: (final LogicalKey _) {
                onQuit();
              },
            ),
            const Text('↑↓ Scroll logs', style: _dim),
            Text(
              'Refreshing every ${friendlyFormatDuration(state.interval)}',
              style: _dim,
            ),
          ],
        ),
      ],
    );
  }
}

class _Panel extends StatelessComponent {
  const _Panel({required this.title, required this.child});

  final String title;
  final Component child;

  @override
  Component build(BuildContext context) {
    final ServerpodThemeData theme = ServerpodTheme.of(context);

    return BorderedBox(
      title: BorderTitle(
        text: title,
        style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: child,
      ),
    );
  }
}

class _StatusPanel extends StatelessComponent {
  const _StatusPanel({required this.state});

  final TopState state;

  @override
  Component build(BuildContext context) {
    final ServerpodThemeData theme = ServerpodTheme.of(context);
    final TopSnapshot snapshot = state.snapshot;
    final CapsuleRuntimeStatus runtime = snapshot.runtime;
    final StatusLook look = capsuleStateLook(runtime.status.status);
    final int? ready = runtime.status.deployment?.readyReplicas;
    final int? desired = runtime.status.deployment?.desiredReplicas;
    final DeployAttemptSummary? serving = runtime.serving;
    final DeployAttemptSummary? incoming = runtime.incoming;
    final DeployAttemptSummary? latest = runtime.latestAttempt;
    final _AttemptLook? latestLook = _latestAttemptLook(latest?.status);
    final String updatedAt = snapshot.updatedAt.toLabeledTzTimeOfDayString(
      state.utc,
    );

    return _Panel(
      title: '${state.baseCommand} top · ${state.projectId}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${look.glyph} ${look.label}',
                style: TextStyle(
                  color: _toneColor(theme, look.tone),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (ready != null && desired != null)
                Text('   $ready/$desired podlets ready', style: _dim),
              const Spacer(),
              if (snapshot.isStatusStale)
                Text(
                  'Stale · ',
                  style: TextStyle(
                    color: _toneColor(theme, StatusTone.warning),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text('Updated $updatedAt', style: _dim),
            ],
          ),
          if (serving != null)
            _AttemptLine(
              label: 'Serving',
              tone: StatusTone.neutral,
              summary: serving,
              when: serving.endedAt ?? serving.startedAt,
              utc: state.utc,
            ),
          if (incoming != null)
            _AttemptLine(
              label: 'Incoming',
              tone: StatusTone.warning,
              summary: incoming,
              when: incoming.startedAt,
              utc: state.utc,
            ),
          if (latest != null && latestLook != null)
            _AttemptLine(
              label: latestLook.label,
              tone: latestLook.tone,
              summary: latest,
              when: latest.endedAt ?? latest.startedAt,
              utc: state.utc,
            ),
        ],
      ),
    );
  }

  _AttemptLook? _latestAttemptLook(final DeployProgressStatus? status) {
    return switch (status) {
      DeployProgressStatus.awaiting || DeployProgressStatus.running => (
        label: 'Building',
        tone: StatusTone.warning,
      ),
      DeployProgressStatus.failure => (label: 'Failed', tone: StatusTone.bad),
      DeployProgressStatus.cancelled => (
        label: 'Cancelled',
        tone: StatusTone.bad,
      ),
      DeployProgressStatus.success ||
      DeployProgressStatus.unknown ||
      null => null,
    };
  }
}

class _AttemptLine extends StatelessComponent {
  const _AttemptLine({
    required this.label,
    required this.tone,
    required this.summary,
    required this.when,
    required this.utc,
  });

  final String label;
  final StatusTone tone;
  final DeployAttemptSummary summary;
  final DateTime when;
  final bool utc;

  @override
  Component build(BuildContext context) {
    final ServerpodThemeData theme = ServerpodTheme.of(context);
    final Color? toneColor = _toneColor(theme, tone);
    final String? commitHash = summary.commitHash;
    final String? deployer =
        summary.deployedBy?.name ?? summary.deployedBy?.email;
    final String time = friendlyPastTimeFormat(when, inUtc: utc);

    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(
            label,
            style: toneColor == null ? _dim : TextStyle(color: toneColor),
          ),
        ),
        if (commitHash != null) ...[
          Text(_shortHash(commitHash), style: TextStyle(color: theme.primary)),
          const SizedBox(width: 2),
        ],
        Expanded(
          child: Text(
            summary.commitMessage ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 2),
        Text(deployer == null ? time : '$time by $deployer', style: _dim),
      ],
    );
  }
}

class _MetricsPanels extends StatelessComponent {
  const _MetricsPanels({required this.snapshot});

  final TopSnapshot snapshot;

  @override
  Component build(BuildContext context) {
    final DateTime to = snapshot.metricsUntil;
    final DateTime from = to.subtract(TopOperations.metricsWindow);
    final List<Component> panels = [
      _PodletsPanel(pods: snapshot.podResources, from: from, to: to),
      _TrafficPanel(network: snapshot.network, from: from, to: to),
      _DatabasePanel(database: snapshot.database, from: from, to: to),
    ];

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        if (constraints.maxWidth < _wideLayoutColumns) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: panels,
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final Component panel in panels) Expanded(child: panel),
          ],
        );
      },
    );
  }
}

class _PodletsPanel extends StatelessComponent {
  const _PodletsPanel({
    required this.pods,
    required this.from,
    required this.to,
  });

  final List<PodResourceSeries>? pods;
  final DateTime from;
  final DateTime to;

  @override
  Component build(BuildContext context) {
    final List<PodResourceSeries>? pods = this.pods;

    return _Panel(
      title: 'Podlets · last hour',
      child: pods == null
          ? const _PanelMessage('Not available.')
          : Column(
              children: [
                _MetricRow(
                  label: 'CPU',
                  series: [
                    for (final PodResourceSeries pod in pods) pod.cpuCores,
                  ],
                  from: from,
                  to: to,
                  format: formatCores,
                ),
                _MetricRow(
                  label: 'Memory',
                  series: [
                    for (final PodResourceSeries pod in pods) pod.memoryBytes,
                  ],
                  from: from,
                  to: to,
                  format: (final double bytes) {
                    return formatByteSize(bytes.round());
                  },
                ),
              ],
            ),
    );
  }
}

class _TrafficPanel extends StatelessComponent {
  const _TrafficPanel({
    required this.network,
    required this.from,
    required this.to,
  });

  final CapsuleNetworkSeries? network;
  final DateTime from;
  final DateTime to;

  @override
  Component build(BuildContext context) {
    final ServerpodThemeData theme = ServerpodTheme.of(context);
    final CapsuleNetworkSeries? network = this.network;
    if (network == null) {
      return const _Panel(
        title: 'Traffic · last hour',
        child: _PanelMessage('Not available.'),
      );
    }

    final List<List<MetricSample>> requests = [network.requestsPerSecond];
    final List<List<MetricSample>> serverErrors = [
      for (final ResponseClassSeries responses in network.responses)
        if (responses.responseClass == HttpResponseClass.serverError)
          responses.responsesPerSecond,
    ];
    final double? requestRate = latestValue(
      totalSeries(requests, from: from, to: to),
    );
    final double? errorRate = latestValue(
      totalSeries(serverErrors, from: from, to: to),
    );

    return _Panel(
      title: 'Traffic · last hour',
      child: Column(
        children: [
          _MetricRow(
            label: 'Requests',
            series: requests,
            from: from,
            to: to,
            format: formatRate,
          ),
          _MetricRow(
            label: '5xx errors',
            series: serverErrors,
            from: from,
            to: to,
            color: theme.failure,
            format: (final double rate) {
              return formatShare(rate, requestRate ?? 0);
            },
            emptyValue: requestRate == null ? null : formatShare(0, 1),
            valueColor: (errorRate ?? 0) > 0 ? theme.failure : null,
          ),
        ],
      ),
    );
  }
}

class _DatabasePanel extends StatelessComponent {
  const _DatabasePanel({
    required this.database,
    required this.from,
    required this.to,
  });

  final DatabaseMetrics? database;
  final DateTime from;
  final DateTime to;

  @override
  Component build(BuildContext context) {
    final DatabaseMetrics? database = this.database;

    return _Panel(
      title: 'Database · last hour',
      child: switch (database?.status) {
        null => const _PanelMessage('Not available.'),
        DatabaseMetricsStatus.idle => const _PanelMessage(
          'Idle, with no activity in the last hour.',
        ),
        DatabaseMetricsStatus.exportNotEnabled => const _PanelMessage(
          'Metrics are not enabled for this database.',
        ),
        DatabaseMetricsStatus.reporting => Column(
          children: [
            _MetricRow(
              label: 'CPU',
              series: [database?.cpuCores ?? const []],
              from: from,
              to: to,
              format: formatCores,
            ),
            _MetricRow(
              label: 'Connections',
              series: [database?.connections ?? const []],
              from: from,
              to: to,
              format: (final double connections) {
                return '${connections.round()} open';
              },
            ),
          ],
        ),
      },
    );
  }
}

/// Fills a metrics panel with a message, at the height of its two metric rows.
class _PanelMessage extends StatelessComponent {
  const _PanelMessage(this.message);

  final String message;

  @override
  Component build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, style: _dim, maxLines: 1),
        const Text(''),
      ],
    );
  }
}

class _MetricRow extends StatelessComponent {
  const _MetricRow({
    required this.label,
    required this.series,
    required this.from,
    required this.to,
    required this.format,
    this.emptyValue,
    this.color,
    this.valueColor,
  });

  final String label;
  final List<List<MetricSample>> series;
  final DateTime from;
  final DateTime to;
  final String Function(double value) format;

  /// The value to show when the series has no samples.
  final String? emptyValue;

  final Color? color;
  final Color? valueColor;

  @override
  Component build(BuildContext context) {
    final ServerpodThemeData theme = ServerpodTheme.of(context);
    final double? latest = latestValue(totalSeries(series, from: from, to: to));
    final String? value = latest == null ? emptyValue : format(latest);

    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(label, style: _dim),
        ),
        Expanded(
          child: LayoutBuilder(
            builder:
                (final BuildContext context, final BoxConstraints constraints) {
                  final int buckets = math.min(
                    constraints.maxWidth.floor(),
                    maxSparklineBuckets,
                  );
                  return Text(
                    sparkline(
                      totalSeries(series, from: from, to: to, buckets: buckets),
                    ),
                    style: TextStyle(color: color ?? theme.primary),
                    maxLines: 1,
                  );
                },
          ),
        ),
        SizedBox(
          width: _valueWidth,
          child: Text(
            value ?? 'no data',
            textAlign: TextAlign.right,
            style: value == null
                ? _dim
                : TextStyle(color: valueColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _DeploymentsPanel extends StatelessComponent {
  const _DeploymentsPanel({required this.snapshot, required this.utc});

  final TopSnapshot snapshot;
  final bool utc;

  @override
  Component build(BuildContext context) {
    final List<DeployAttempt>? deployments = snapshot.deployments;
    final String? servingId = snapshot.runtime.serving?.attemptId.toString();

    return _Panel(
      title: 'Deployments',
      child: deployments == null
          ? const Text('Not available.', style: _dim)
          : deployments.isEmpty
          ? const Text('No deployments yet.', style: _dim)
          : Column(
              children: [
                for (final DeployAttempt attempt in deployments)
                  _DeploymentRow(
                    attempt: attempt,
                    isServing: attempt.attemptId == servingId,
                    utc: utc,
                  ),
              ],
            ),
    );
  }
}

class _DeploymentRow extends StatelessComponent {
  const _DeploymentRow({
    required this.attempt,
    required this.isServing,
    required this.utc,
  });

  final DeployAttempt attempt;
  final bool isServing;
  final bool utc;

  @override
  Component build(BuildContext context) {
    final ServerpodThemeData theme = ServerpodTheme.of(context);
    final DeployProgressStatus? status = attempt.status;
    final _DeploymentLook look = _look(status);
    final Color? color = _toneColor(theme, look.tone);
    final String? commitHash = attempt.commitHash;
    final DateTime when =
        attempt.endedAt ?? attempt.startedAt ?? attempt.createdAt;

    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(
            '${look.glyph} ${(status ?? DeployProgressStatus.unknown).name.capitalize()}',
            style: TextStyle(color: color),
          ),
        ),
        SizedBox(
          width: _shortHashLength + 2,
          child: Text(
            commitHash == null ? '' : _shortHash(commitHash),
            style: TextStyle(color: theme.primary),
          ),
        ),
        Expanded(
          child: Text(
            attempt.commitMessage ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isServing) ...[
          const SizedBox(width: 2),
          Text('serving', style: TextStyle(color: theme.success)),
        ],
        const SizedBox(width: 2),
        Text(friendlyPastTimeFormat(when, inUtc: utc), style: _dim),
      ],
    );
  }

  _DeploymentLook _look(final DeployProgressStatus? status) {
    return switch (status) {
      DeployProgressStatus.success => (glyph: '●', tone: StatusTone.good),
      DeployProgressStatus.running => (glyph: '◐', tone: StatusTone.warning),
      DeployProgressStatus.awaiting => (glyph: '◌', tone: StatusTone.warning),
      DeployProgressStatus.failure => (glyph: '✖', tone: StatusTone.bad),
      DeployProgressStatus.cancelled => (glyph: '○', tone: StatusTone.neutral),
      DeployProgressStatus.unknown ||
      null => (glyph: '?', tone: StatusTone.neutral),
    };
  }
}

class _LogsPanel extends StatelessComponent {
  const _LogsPanel({
    required this.logs,
    required this.utc,
    required this.scrollController,
  });

  final List<LogRecord>? logs;
  final bool utc;
  final ScrollController scrollController;

  @override
  Component build(BuildContext context) {
    final List<LogRecord>? logs = this.logs;

    return _Panel(
      title: 'Logs (${timeZoneLabel(utc)})',
      child: logs == null
          ? const Center(child: Text('Not available.', style: _dim))
          : logs.isEmpty
          ? const Center(child: Text('No log records yet.', style: _dim))
          : Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: ListView.builder(
                controller: scrollController,
                reverse: true,
                keyboardScrollable: true,
                itemCount: logs.length,
                itemBuilder: (final BuildContext context, final int index) {
                  final LogRecord record = logs[logs.length - 1 - index];
                  return _LogLine(
                    key: ValueKey(record.recordId),
                    record: record,
                    utc: utc,
                  );
                },
              ),
            ),
    );
  }
}

class _LogLine extends StatelessComponent {
  const _LogLine({super.key, required this.record, required this.utc});

  final LogRecord record;
  final bool utc;

  @override
  Component build(BuildContext context) {
    final ServerpodThemeData theme = ServerpodTheme.of(context);
    final String level = logLevelOf(record).toLowerCase();
    final _LogLook look = _look(theme, level);

    return Row(
      children: [
        Text(record.timestamp.toTzTimeOfDayString(utc), style: _dim),
        const SizedBox(width: 1),
        SizedBox(
          width: 5,
          child: Text(look.label, style: TextStyle(color: look.color)),
        ),
        const SizedBox(width: 1),
        Expanded(
          child: Text(
            summarizeLogContent(record.content).replaceAll('\n', ' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: look.isProblem ? look.color : null),
          ),
        ),
      ],
    );
  }

  _LogLook _look(final ServerpodThemeData theme, final String level) {
    if (level.isEmpty) {
      return (label: '', color: null, isProblem: false);
    }
    if (level.startsWith('debug')) {
      return (label: 'debug', color: theme.debugLevel, isProblem: false);
    }
    if (level.startsWith('info') || level.startsWith('notice')) {
      return (label: 'info', color: theme.infoLevel, isProblem: false);
    }
    if (level.startsWith('warn')) {
      return (label: 'warn', color: theme.warningLevel, isProblem: true);
    }
    return (label: 'error', color: theme.errorLevel, isProblem: true);
  }
}

Color? _toneColor(final ServerpodThemeData theme, final StatusTone tone) {
  return switch (tone) {
    StatusTone.good => theme.success,
    StatusTone.warning => theme.warningLevel,
    StatusTone.bad => theme.failure,
    StatusTone.neutral => null,
  };
}

String _shortHash(final String hash) {
  return hash.length > _shortHashLength
      ? hash.substring(0, _shortHashLength)
      : hash;
}

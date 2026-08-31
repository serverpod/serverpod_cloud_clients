import 'package:cli_tools/logger.dart' as cli show AnsiStyle;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/duration_formatter.dart';

/// Runtime status command implementations.
abstract class RuntimeStatusCommands {
  /// Shows the live runtime status panel for a project's podlets.
  static Future<void> showRuntimeStatus(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String baseCommand,
    required final String projectId,
    final bool inUtc = false,
  }) async {
    final runtime = await cloudApiClient.status.getCapsuleRuntimeStatus(
      cloudCapsuleId: projectId,
    );

    _RuntimeStatusPanel(
      logger: logger,
      baseCommand: baseCommand,
      projectId: projectId,
      runtime: runtime,
      inUtc: inUtc,
    ).write();
  }
}

enum _LatestDeployPhase { building, failed, cancelled }

class _RuntimeStatusPanel {
  static const _indent = '  ';
  static const _labelWidth = 10;
  static const _labelStyle = cli.AnsiStyle.darkGray;
  static const _dimStyle = cli.AnsiStyle.darkGray;
  static const _commandStyle = cli.AnsiStyle.cyan;

  final CommandLogger logger;
  final String baseCommand;
  final String projectId;
  final CapsuleRuntimeStatus runtime;
  final bool inUtc;

  _RuntimeStatusPanel({
    required this.logger,
    required this.baseCommand,
    required this.projectId,
    required this.runtime,
    required this.inUtc,
  });

  void write() {
    final state = runtime.status.status;
    final hint = _resolveHint(state);

    logger.line('');
    _writeStatusRow(state);
    _writePodletsRow(state);
    _writeDeploymentRows(state);
    _writeHint(hint);
    _writeUrlFooter(state, hasHint: hint != null);
  }

  _LatestDeployPhase? get _latestPhase {
    return switch (runtime.latestAttempt?.status) {
      DeployProgressStatus.awaiting ||
      DeployProgressStatus.running => _LatestDeployPhase.building,
      DeployProgressStatus.failure => _LatestDeployPhase.failed,
      DeployProgressStatus.cancelled => _LatestDeployPhase.cancelled,
      _ => null,
    };
  }

  void _writeStatusRow(final CapsuleState state) {
    if (state == CapsuleState.notProvisioned &&
        _latestPhase == _LatestDeployPhase.building) {
      final stateWord = _style('◌ Building', cli.AnsiStyle.yellow);
      final suffix = ' ${_style('— first deploy in progress', _dimStyle)}';
      _writeRow('Status', '$stateWord$suffix');
      return;
    }

    final look = _stateLook(state);
    final stateWord = _style('${look.glyph} ${look.label}', look.style);
    final diagnosis = _diagnosis(state);
    final suffix = diagnosis != null
        ? ' ${_style('— $diagnosis', _dimStyle)}'
        : '';
    _writeRow('Status', '$stateWord$suffix');
  }

  void _writePodletsRow(final CapsuleState state) {
    final deployment = runtime.status.deployment;
    final desired = deployment?.desiredReplicas;
    final ready = deployment?.readyReplicas;
    if (desired == null || ready == null) {
      return;
    }
    if (state == CapsuleState.suspended ||
        state == CapsuleState.notProvisioned) {
      return;
    }

    final style = ready >= desired
        ? cli.AnsiStyle.lightGreen
        : ready > 0
        ? cli.AnsiStyle.yellow
        : cli.AnsiStyle.red;
    _writeRow('Podlets', _style('$ready/$desired ready', style));
  }

  void _writeDeploymentRows(final CapsuleState state) {
    final servingLabel = switch (state) {
      CapsuleState.ready ||
      CapsuleState.progressing ||
      CapsuleState.degraded => 'Serving',
      _ => 'Deployed',
    };

    final serving = runtime.serving;
    if (serving != null) {
      _writeAttemptRows(
        servingLabel,
        serving,
        prefix: 'Deployed',
        when: serving.endedAt ?? serving.startedAt,
      );
    }

    var pendingSeparator = serving != null;
    void separateFromServing() {
      if (!pendingSeparator) {
        return;
      }
      logger.line('');
      pendingSeparator = false;
    }

    final incoming = runtime.incoming;
    if (incoming != null) {
      separateFromServing();
      _writeAttemptRows(
        'Incoming',
        incoming,
        prefix: 'Started',
        when: incoming.startedAt,
      );
    }

    _writeLatestAttemptRows(separateFromServing);
  }

  void _writeLatestAttemptRows(final void Function() separateFromServing) {
    final latest = runtime.latestAttempt;
    final phase = _latestPhase;
    if (latest == null || phase == null) {
      return;
    }

    separateFromServing();

    switch (phase) {
      case _LatestDeployPhase.building:
        _writeAttemptRows(
          'Building',
          latest,
          prefix: 'Started',
          when: latest.startedAt,
        );
      case _LatestDeployPhase.failed:
        _writeAttemptRows(
          'Failed',
          latest,
          prefix: 'Deployment',
          when: latest.endedAt ?? latest.startedAt,
          labelStyle: cli.AnsiStyle.red,
        );
      case _LatestDeployPhase.cancelled:
        _writeAttemptRows(
          'Cancelled',
          latest,
          when: latest.endedAt ?? latest.startedAt,
          labelStyle: cli.AnsiStyle.red,
        );
    }
  }

  void _writeAttemptRows(
    final String label,
    final DeployAttemptSummary summary, {
    final String? prefix,
    required final DateTime when,
    final cli.AnsiStyle labelStyle = _labelStyle,
  }) {
    final deployedBy = summary.deployedBy;
    final deployerName = deployedBy?.name ?? deployedBy?.email;
    final by = deployerName != null ? ' by $deployerName' : '';
    final time = friendlyPastTimeFormat(when, inUtc: inUtc);
    final lead = prefix != null ? '$prefix $time' : time;
    _writeRow(label, '$lead$by', labelStyle: labelStyle);

    final commitHash = summary.commitHash;
    final commitMessage = summary.commitMessage;
    if (commitHash == null && commitMessage == null) {
      return;
    }
    final commitLine = [commitHash, commitMessage].nonNulls.join('  ');
    logger.line('$_indent${' ' * _labelWidth}${_style(commitLine, _dimStyle)}');
  }

  ({String message, String? command})? _resolveHint(final CapsuleState state) {
    final stateIsQuiet =
        state == CapsuleState.ready || state == CapsuleState.notProvisioned;
    if (stateIsQuiet) {
      switch (_latestPhase) {
        case _LatestDeployPhase.building:
          return (
            message: 'Follow the build:',
            command: '$baseCommand deployment show',
          );
        case _LatestDeployPhase.failed || _LatestDeployPhase.cancelled:
          return (
            message: 'See what went wrong:',
            command: '$baseCommand deployment show',
          );
        case null:
          break;
      }
    }

    return switch (state) {
      CapsuleState.ready => null,
      CapsuleState.progressing => (
        message: 'Follow the rollout:',
        command: '$baseCommand deployment show',
      ),
      CapsuleState.degraded => (
        message: 'Check for errors:',
        command: '$baseCommand log --tail',
      ),
      CapsuleState.unavailable => (
        message: 'Check for crash output:',
        command: '$baseCommand log',
      ),
      CapsuleState.suspended => (
        message: 'Resume the project from the Serverpod Cloud console.',
        command: null,
      ),
      CapsuleState.notProvisioned => (
        message: 'Launch your project:',
        command: '$baseCommand launch',
      ),
      CapsuleState.unknown => (
        message: 'If this persists, contact Serverpod support.',
        command: null,
      ),
    };
  }

  void _writeHint(final ({String message, String? command})? hint) {
    if (hint == null) {
      return;
    }

    final command = hint.command;
    final line = command != null
        ? '${_style(hint.message, _dimStyle)} ${_style(command, _commandStyle)}'
        : _style(hint.message, _dimStyle);
    logger.line('');
    logger.line('$_indent$line');
  }

  void _writeUrlFooter(
    final CapsuleState state, {
    required final bool hasHint,
  }) {
    if (state != CapsuleState.ready || hasHint) {
      return;
    }

    logger.line('');
    for (final (label, host) in [
      ('api', 'https://$projectId.api.${HostConstants.tenantDomain}/'),
      (
        'insights',
        'https://$projectId.insights.${HostConstants.tenantDomain}/',
      ),
      ('web', 'https://$projectId.${HostConstants.tenantDomain}/'),
    ]) {
      logger.line(
        '$_indent${_style('${label.padRight(_labelWidth)}$host', _dimStyle)}',
      );
    }
  }

  void _writeRow(
    final String label,
    final String value, {
    final cli.AnsiStyle labelStyle = _labelStyle,
  }) {
    logger.line(
      '$_indent${_style(label.padRight(_labelWidth), labelStyle)}$value',
    );
  }

  ({String glyph, String label, cli.AnsiStyle? style}) _stateLook(
    final CapsuleState state,
  ) {
    return switch (state) {
      CapsuleState.ready => (
        glyph: '●',
        label: 'Running',
        style: cli.AnsiStyle.lightGreen,
      ),
      CapsuleState.progressing => (
        glyph: '◐',
        label: 'Deploying',
        style: cli.AnsiStyle.yellow,
      ),
      CapsuleState.degraded => (
        glyph: '◑',
        label: 'Degraded',
        style: cli.AnsiStyle.yellow,
      ),
      CapsuleState.unavailable => (
        glyph: '✖',
        label: 'Down',
        style: cli.AnsiStyle.red,
      ),
      CapsuleState.suspended => (glyph: '⏸', label: 'Suspended', style: null),
      CapsuleState.notProvisioned => (
        glyph: '○',
        label: 'Not deployed',
        style: null,
      ),
      CapsuleState.unknown => (
        glyph: '?',
        label: 'Unknown',
        style: cli.AnsiStyle.yellow,
      ),
    };
  }

  String? _diagnosis(final CapsuleState state) {
    final deployment = runtime.status.deployment;
    final desired = deployment?.desiredReplicas;
    final ready = deployment?.readyReplicas;

    return switch (state) {
      CapsuleState.degraded when desired != null && ready != null =>
        _degradedDiagnosis(desired: desired, ready: ready),
      CapsuleState.unavailable => 'no podlets are ready',
      CapsuleState.unknown =>
        'the status service reported an unrecognized state',
      _ => null,
    };
  }

  String _degradedDiagnosis({
    required final int desired,
    required final int ready,
  }) {
    final notReady = desired - ready;
    final verb = notReady == 1 ? 'is' : 'are';
    return '$notReady of $desired podlets $verb not ready';
  }

  String _style(final String text, final cli.AnsiStyle? style) {
    if (style == null) {
      return text;
    }
    return logger.wrapStyle(text, style);
  }
}

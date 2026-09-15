import 'dart:async';

import 'package:cli_tools/logger.dart' as cli show AnsiStyle;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/duration_formatter.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart'
    show BottomRegionRenderer, fitAnsiToColumns;

class RuntimeStatusTextUi extends OutputWidget {
  final String baseCommand;
  final bool utc;

  const RuntimeStatusTextUi({required this.baseCommand, required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    return _RuntimeStatusPanel(
      runtime: context.get<CapsuleRuntimeStatus>(),
      baseCommand: baseCommand,
      utc: utc,
    );
  }
}

/// Renders each status of a watched project.
///
/// On an interactive terminal the panel is redrawn in place on every status,
/// and again every [interval] so relative times stay current.
class RuntimeStatusWatchTextUi extends OutputWidget {
  final String baseCommand;
  final bool utc;
  final Duration interval;

  const RuntimeStatusWatchTextUi({
    required this.baseCommand,
    required this.utc,
    required this.interval,
  });

  @override
  OutputWidget build(final OutputContext context) {
    return _RuntimeStatusWatch(
      statuses: context.get<Stream<CapsuleRuntimeStatus>>(),
      baseCommand: baseCommand,
      utc: utc,
      interval: interval,
    );
  }
}

class _RuntimeStatusPanel extends OutputWidget {
  final CapsuleRuntimeStatus runtime;
  final String baseCommand;
  final bool utc;

  const _RuntimeStatusPanel({
    required this.runtime,
    required this.baseCommand,
    required this.utc,
  });

  @override
  void render({required final CommandLogger logger}) {
    final lines = _RuntimeStatusLines(
      logger: logger,
      runtime: runtime,
      baseCommand: baseCommand,
      utc: utc,
    ).build();
    for (final line in lines) {
      logger.line(line);
    }
  }
}

class _RuntimeStatusWatch extends OutputWidget {
  final Stream<CapsuleRuntimeStatus> statuses;
  final String baseCommand;
  final bool utc;
  final Duration interval;

  const _RuntimeStatusWatch({
    required this.statuses,
    required this.baseCommand,
    required this.utc,
    required this.interval,
  });

  @override
  Future<void> renderAsync({required final CommandLogger logger}) async {
    if (logger.inlineTerminal.hasTerminal) {
      await _redrawInPlace(logger);
    } else {
      await _printEachStatus(logger);
    }
  }

  Future<void> _redrawInPlace(final CommandLogger logger) async {
    final terminal = logger.inlineTerminal;
    final renderer = BottomRegionRenderer(terminal);
    final footer = logger.wrapStyle(
      'Refreshing every ${friendlyFormatDuration(interval)}. '
      'Press Ctrl+C to stop.',
      cli.AnsiStyle.darkGray,
    );
    CapsuleRuntimeStatus? latest;

    void draw() {
      final runtime = latest;
      if (runtime == null) {
        return;
      }
      final lines = [..._linesFor(logger, runtime), '', '  $footer'];
      renderer.render([
        for (final line in lines)
          fitAnsiToColumns(line, terminal.columns, closeStyles: true),
      ]);
    }

    final redrawTimer = Timer.periodic(interval, (_) => draw());
    renderer.hideCursor();
    try {
      await for (final runtime in statuses) {
        latest = runtime;
        draw();
      }
    } finally {
      redrawTimer.cancel();
      renderer.finish();
    }
  }

  Future<void> _printEachStatus(final CommandLogger logger) async {
    var isFirst = true;
    await for (final runtime in statuses) {
      if (!isFirst) {
        logger.line('');
      }
      isFirst = false;
      final receivedAt = DateTime.now().toLabeledTzString(
        utc,
        numTimeStampChars,
      );
      logger.line('Status at $receivedAt');
      for (final line in _linesFor(logger, runtime)) {
        logger.line(line);
      }
    }
  }

  List<String> _linesFor(
    final CommandLogger logger,
    final CapsuleRuntimeStatus runtime,
  ) {
    return _RuntimeStatusLines(
      logger: logger,
      runtime: runtime,
      baseCommand: baseCommand,
      utc: utc,
    ).build();
  }
}

enum _LatestDeployPhase { building, failed, cancelled }

class _RuntimeStatusLines {
  static const _indent = '  ';
  static const _labelWidth = 10;
  static const _labelStyle = cli.AnsiStyle.darkGray;
  static const _dimStyle = cli.AnsiStyle.darkGray;
  static const _commandStyle = cli.AnsiStyle.cyan;

  final CommandLogger logger;
  final String baseCommand;
  final CapsuleRuntimeStatus runtime;
  final bool utc;
  final List<String> _lines = [];

  _RuntimeStatusLines({
    required this.logger,
    required this.runtime,
    required this.baseCommand,
    required this.utc,
  });

  List<String> build() {
    final state = runtime.status.status;
    final hint = _resolveHint(state);

    _lines.clear();
    _lines.add('');
    _writeStatusRow(state);
    _writePodletsRow(state);
    _writeDeploymentRows(state);
    _writeHint(hint);
    _writeUrlFooter(state, hasHint: hint != null);
    return _lines;
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
      _lines.add('');
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
    final time = friendlyPastTimeFormat(when, inUtc: utc);
    final lead = prefix != null ? '$prefix $time' : time;
    _writeRow(label, '$lead$by', labelStyle: labelStyle);

    final commitHash = summary.commitHash;
    final commitMessage = summary.commitMessage;
    if (commitHash == null && commitMessage == null) {
      return;
    }
    final commitLine = [commitHash, commitMessage].nonNulls.join('  ');
    _lines.add('$_indent${' ' * _labelWidth}${_style(commitLine, _dimStyle)}');
  }

  ({String message, String? command})? _resolveHint(CapsuleState state) {
    final stateIsQuiet =
        state == CapsuleState.ready || state == CapsuleState.notProvisioned;
    if (stateIsQuiet) {
      switch (_latestPhase) {
        case _LatestDeployPhase.building:
          return (
            message: 'Follow the build:',
            command: '$baseCommand status deployment show',
          );
        case _LatestDeployPhase.failed || _LatestDeployPhase.cancelled:
          return (
            message: 'See what went wrong:',
            command: '$baseCommand status deployment show',
          );
        case null:
          break;
      }
    }

    return switch (state) {
      CapsuleState.ready => null,
      CapsuleState.progressing => (
        message: 'Follow the rollout:',
        command: '$baseCommand status deployment show',
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
    _lines.add('');
    _lines.add('$_indent$line');
  }

  void _writeUrlFooter(
    final CapsuleState state, {
    required final bool hasHint,
  }) {
    if (state != CapsuleState.ready || hasHint) {
      return;
    }

    _lines.add('');
    for (final (label, host) in [
      ('api', 'https://$runtimeProjectId.api.${HostConstants.tenantDomain}/'),
      (
        'insights',
        'https://$runtimeProjectId.insights.${HostConstants.tenantDomain}/',
      ),
      ('web', 'https://$runtimeProjectId.${HostConstants.tenantDomain}/'),
    ]) {
      _lines.add(
        '$_indent${_style('${label.padRight(_labelWidth)}$host', _dimStyle)}',
      );
    }
  }

  String get runtimeProjectId => runtime.status.cloudCapsuleId;

  void _writeRow(
    final String label,
    final String value, {
    final cli.AnsiStyle labelStyle = _labelStyle,
  }) {
    _lines.add(
      '$_indent${_style(label.padRight(_labelWidth), labelStyle)}$value',
    );
  }

  ({String glyph, String label, cli.AnsiStyle? style}) _stateLook(
    CapsuleState state,
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

  String? _diagnosis(CapsuleState state) {
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

  String _degradedDiagnosis({required int desired, required int ready}) {
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

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:async/async.dart' show StreamGroup;
import 'package:ground_control_client/ground_control_client.dart'
    show
        AppBuildDetail,
        AppBuildRef,
        AppBuildStatus,
        AppPlatform,
        Client,
        UuidValue;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';

import 'app_build_status_formatter.dart';
import 'app_ops.dart';

/// Shows the progress of the app builds of an app upload.
abstract class AppBuildProgress {
  static const _spinnerInterval = Duration(milliseconds: 80);

  static const _logRows = 5;

  /// Shows a status line per build in [builds] of project [projectId],
  /// updated on every change until all builds have ended, and then their
  /// result.
  ///
  /// On an interactive terminal the lines are redrawn in place, with a
  /// spinner on the active stages. With [showLogs], the log of each build
  /// step scrolls below the lines as the step ends. The log is cleared when
  /// every build succeeds, and kept in full otherwise. Without an
  /// interactive terminal, a line is printed each time it changes, and no
  /// log is shown. A step log that cannot be fetched shows as error lines in
  /// the log, and its cause is logged at debug level once the builds end.
  ///
  /// Throws [FailureException] if a build does not succeed.
  static Future<void> follow(
    Client cloudApiClient, {
    required CommandLogger logger,
    required String projectId,
    required List<AppBuildRef> builds,
    required UuidValue uploadId,
    required String baseCommand,
    String? versionName,
    bool showLogs = false,
  }) async {
    logger.info(
      'App builds run one at a time per account. Other builds wait in the queue.',
    );
    logger.info(
      'Builds keep running if you stop following. Cancel them: '
      '$baseCommand app cancel $uploadId --project $projectId',
    );
    final detailStream = StreamGroup.merge([
      for (final build in builds)
        AppOperations.tailBuild(
          cloudApiClient,
          projectId: projectId,
          buildId: build.buildId,
        ),
    ]);
    final terminal = logger.inlineTerminal;
    final details = terminal.hasTerminal
        ? await _renderProgress(
            cloudApiClient,
            detailStream,
            logger: logger,
            terminal: terminal,
            projectId: projectId,
            builds: builds,
            showLogs: showLogs,
          )
        : await _printProgress(detailStream, logger: logger, builds: builds);

    _report(
      logger,
      platforms: [for (final build in builds) build.platform],
      details: details,
      versionName: versionName,
      projectId: projectId,
      baseCommand: baseCommand,
    );
  }

  /// Prints a status line per build in [details], which have all ended,
  /// and then their result.
  ///
  /// Throws [FailureException] if a build did not succeed.
  static void showEnded({
    required CommandLogger logger,
    required List<AppBuildDetail> details,
    required String projectId,
    required String baseCommand,
    String? versionName,
  }) {
    for (final detail in details) {
      logger.line(AppBuildStatusFormatter.line(detail.build.platform, detail));
    }

    _report(
      logger,
      platforms: [for (final detail in details) detail.build.platform],
      details: {for (final detail in details) detail.build.platform: detail},
      versionName: versionName,
      projectId: projectId,
      baseCommand: baseCommand,
    );
  }

  static Future<Map<AppPlatform, AppBuildDetail>> _renderProgress(
    Client cloudApiClient,
    Stream<AppBuildDetail> detailStream, {
    required CommandLogger logger,
    required InlineTerminal terminal,
    required String projectId,
    required List<AppBuildRef> builds,
    required bool showLogs,
  }) async {
    final details = <AppPlatform, AppBuildDetail>{};
    final logLines = <String>[];
    final logFailures = <FailureException>[];
    var spinnerFrame = 0;
    final renderer = BottomRegionRenderer(terminal)..hideCursor();
    List<String> statusLines() => [
      for (final build in builds)
        AppBuildStatusFormatter.line(
          build.platform,
          details[build.platform],
          spinnerFrame: spinnerFrame,
        ),
    ];
    void render() => renderer.render([
      ...statusLines(),
      for (final line in logLines.skip(max(0, logLines.length - _logRows)))
        _scrolledLogLine(terminal, line),
    ]);
    void addLogLines(List<String> lines) {
      logLines.addAll(lines);
      render();
    }

    final logFeeds = {
      if (showLogs)
        for (final build in builds)
          build.platform: StreamController<AppBuildDetail>(),
    };
    final logsFollowed = Future.wait([
      for (final build in builds)
        if (logFeeds[build.platform] case final feed?)
          _followLog(
            cloudApiClient,
            projectId: projectId,
            build: build,
            details: feed.stream,
            showPlatform: builds.length > 1,
            onLines: addLogLines,
            onFailure: logFailures.add,
          ),
    ])..ignore();

    render();
    final ticker = Timer.periodic(_spinnerInterval, (_) {
      spinnerFrame++;
      render();
    });
    var succeeded = false;
    try {
      await for (final detail in detailStream) {
        details[detail.build.platform] = detail;
        logFeeds[detail.build.platform]?.add(detail);
        render();
      }
      succeeded = builds.every(
        (build) =>
            AppBuildStatusFormatter.buildError(
              build.platform,
              details[build.platform],
            ) ==
            null,
      );
    } finally {
      ticker.cancel();
      for (final feed in logFeeds.values) {
        unawaited(feed.close());
      }
      try {
        await logsFollowed;
      } finally {
        renderer.finish(
          lines: [
            ...statusLines(),
            if (!succeeded)
              for (final line in logLines) _keptLogLine(terminal, line),
          ],
        );
        for (final failure in logFailures) {
          _logFailureCause(logger, failure);
        }
      }
    }
    return details;
  }

  /// Passes the lines of the log of each step of [build], whose changes are
  /// [details], to [onLines] as the step ends, below a heading for the step.
  /// The heading names the platform when [showPlatform] is set. A step log
  /// that cannot be fetched is passed as error lines and to [onFailure], and
  /// the log goes on with the next step.
  static Future<void> _followLog(
    Client cloudApiClient, {
    required String projectId,
    required AppBuildRef build,
    required Stream<AppBuildDetail> details,
    required bool showPlatform,
    required void Function(List<String> lines) onLines,
    required void Function(FailureException failure) onFailure,
  }) async {
    final stepLogs =
        AppOperations.stepLogs(
          cloudApiClient,
          projectId: projectId,
          buildId: build.buildId,
          details: details,
        ).handleError((Object error) {
          if (error is FailureException) {
            onLines(error.errors);
            onFailure(error);
          }
        }, test: (error) => error is FailureException);
    await for (final stepLog in stepLogs) {
      final log = stepLog.log;
      onLines([
        AppBuildStatusFormatter.stepLogHeading(
          stepLog.step,
          platform: showPlatform ? build.platform : null,
        ),
        if (log != null) ...LineSplitter.split(log),
      ]);
    }
  }

  /// Logs the cause of [failure] at debug level, when it has one.
  static void _logFailureCause(CommandLogger logger, FailureException failure) {
    final cause = failure.nestedException;
    if (cause == null) return;
    final stackTrace = failure.nestedStackTrace;
    logger.debug(
      [
        '${failure.errors.join(' ')} Cause: $cause',
        if (stackTrace != null) '$stackTrace',
      ].join('\n'),
    );
  }

  /// A log line in the scrolling log, with its tabs expanded, fitted to the
  /// terminal width, and dimmed when the terminal supports color.
  static String _scrolledLogLine(InlineTerminal terminal, String line) {
    final text = fitAnsiToColumns(
      line.replaceAll('\t', '    '),
      terminal.columns,
    );
    if (!terminal.supportsColor) return text;
    return '${AnsiStyle.gray.ansiCode}$text${AnsiStyle.reset.ansiCode}';
  }

  /// A log line kept after the builds end, in full, with any color it
  /// holds reset at its end.
  static String _keptLogLine(InlineTerminal terminal, String line) {
    if (!terminal.supportsColor || !line.contains('\x1b')) return line;
    return '$line${AnsiStyle.reset.ansiCode}';
  }

  static Future<Map<AppPlatform, AppBuildDetail>> _printProgress(
    Stream<AppBuildDetail> detailStream, {
    required CommandLogger logger,
    required List<AppBuildRef> builds,
  }) async {
    final details = <AppPlatform, AppBuildDetail>{};
    final lines = <AppPlatform, String>{
      for (final build in builds)
        build.platform: AppBuildStatusFormatter.line(build.platform, null),
    };
    lines.values.forEach(logger.line);

    await for (final detail in detailStream) {
      final platform = detail.build.platform;
      details[platform] = detail;
      final line = AppBuildStatusFormatter.line(platform, detail);
      if (line == lines[platform]) continue;
      lines[platform] = line;
      logger.line(line);
    }
    return details;
  }

  /// Logs that the builds for [platforms] succeeded, according to their
  /// last detail in [details].
  ///
  /// Throws [FailureException] if a build did not succeed.
  static void _report(
    CommandLogger logger, {
    required List<AppPlatform> platforms,
    required Map<AppPlatform, AppBuildDetail> details,
    required String projectId,
    required String baseCommand,
    String? versionName,
  }) {
    final errors = [
      for (final platform in platforms)
        ?AppBuildStatusFormatter.buildError(platform, details[platform]),
    ];
    final succeeded = [
      for (final platform in platforms)
        if (AppBuildStatusFormatter.buildError(platform, details[platform]) ==
            null)
          platform,
    ];
    if (succeeded.isNotEmpty) {
      logger.success(
        'Published ${versionName ?? 'the app'} to '
        '${AppBuildStatusFormatter.platformNames(succeeded)}.',
        newParagraph: true,
      );
    }
    if (errors.isNotEmpty) {
      for (final platform in platforms) {
        if (succeeded.contains(platform)) continue;
        final build = details[platform]?.build;
        if (build == null) continue;
        logger.info(
          'Read the ${AppBuildStatusFormatter.platformName(platform)} log: '
          '$baseCommand app log ${build.uploadId} '
          '--platform ${platform.name} --project $projectId',
        );
        if (build.status == AppBuildStatus.builtNotUploaded) {
          logger.info(
            'Download the built app for manual store upload: '
            '$baseCommand app artifacts ${build.uploadId} --project $projectId',
          );
        }
      }
      throw FailureException(errors: errors);
    }
  }
}

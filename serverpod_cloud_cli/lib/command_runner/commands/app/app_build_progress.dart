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
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart'
    show StatusCommands;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';
import 'package:serverpod_cloud_cli/util/stream_util.dart';

import 'app_build_status_formatter.dart';
import 'app_build_step_lines.dart';
import 'app_ops.dart';

/// Shows the progress of the app builds of an app upload.
abstract class AppBuildProgress {
  static const _spinnerInterval = Duration(milliseconds: 80);

  static const _logRows = 5;

  static const _longQueue = Duration(minutes: 1);

  static const _longQueueCheckInterval = Duration(seconds: 1);

  /// Shows the stages of each build in [builds] of the archive upload
  /// [uploadId] in project [projectId] as a vertical list of lines until all
  /// builds have ended, and then their result. The result names the app by
  /// [appNames], one name per platform, with [versionName].
  ///
  /// A stage that ended gets a line with its duration, such as
  /// `✓ Android build prepared.`, in the order the stages of all builds
  /// end. On an interactive terminal, the stage each build is in shows below
  /// those lines with a spinner and its running time. With [showLogs], the
  /// log of each build step scrolls below them as the step ends. The log is
  /// cleared when every build succeeds, and kept in full otherwise. Without
  /// an interactive terminal, a line is printed as each stage starts and
  /// ends, and no log is shown. A step log that cannot be fetched shows as
  /// error lines in the log, and its cause is logged at debug level once the
  /// builds end.
  ///
  /// While a build has been in the queue for a minute or longer, a note says
  /// why it waits and that following can stop while the builds go on. An
  /// interrupt, such as Ctrl+C, stops following and shows the command to
  /// follow the builds again, invoked through [baseCommand].
  ///
  /// Throws [FailureException] if a build does not succeed.
  /// Throws [UserAbortException] if following is interrupted.
  static Future<void> follow(
    Client cloudApiClient, {
    required CommandLogger logger,
    required String projectId,
    required UuidValue uploadId,
    required List<AppBuildRef> builds,
    required String baseCommand,
    String? versionName,
    Map<AppPlatform, String>? appNames,
    bool showLogs = false,
  }) async {
    final terminal = logger.inlineTerminal;
    final detailStream = cancelOnInterrupt(
      StreamGroup.merge([
        for (final build in builds)
          AppOperations.tailBuild(
            cloudApiClient,
            projectId: projectId,
            buildId: build.buildId,
          ),
      ]),
      terminal.interruptSignals,
    );
    final Map<AppPlatform, AppBuildDetail> details;
    try {
      details = terminal.hasTerminal
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
    } on StreamInterruptedException {
      logger.info(
        builds.length == 1
            ? 'The app build continues in Serverpod Cloud.'
            : 'The app builds continue in Serverpod Cloud.',
        newParagraph: true,
      );
      logger.terminalCommand(
        '$baseCommand app show $uploadId --project $projectId',
        message: 'To follow the progress again, run this command:',
      );
      throw UserAbortException();
    }

    _report(
      logger,
      platforms: [for (final build in builds) build.platform],
      details: details,
      versionName: versionName,
      appNames: appNames,
      projectId: projectId,
      baseCommand: baseCommand,
    );
  }

  /// Prints the lines of the stages of each build in [details], which have
  /// all ended, and then their result.
  ///
  /// Throws [FailureException] if a build did not succeed.
  static void showEnded({
    required CommandLogger logger,
    required List<AppBuildDetail> details,
    required String projectId,
    required String baseCommand,
    String? versionName,
  }) {
    final steps = AppBuildStepLines([
      for (final detail in details) detail.build.platform,
    ]);
    final now = DateTime.now();
    for (final detail in details) {
      for (final line in steps.update(detail)) {
        logger.line(_plainStepLine(line, now));
      }
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
    final steps = AppBuildStepLines([
      for (final build in builds) build.platform,
    ]);
    final endedLines = <AppBuildStepLine>[];
    final logLines = <String>[];
    final logFailures = <FailureException>[];
    var spinnerFrame = 0;
    final renderer = BottomRegionRenderer(terminal)..hideCursor();
    List<String> queueNoteLines() {
      final queued = steps.queuedFor(_longQueue);
      if (queued.isEmpty) return [];
      return [
        '',
        for (final line in AppBuildStatusFormatter.longQueueNote(
          queued,
          buildCount: builds.length,
        ))
          fitAnsiToColumns(line, terminal.columns),
      ];
    }

    List<String> stepLines() {
      final now = DateTime.now();
      return [
        for (final line in [...endedLines, ...steps.activeLines])
          _stepLine(terminal, line, spinnerFrame: spinnerFrame, now: now),
      ];
    }

    void render() => renderer.render([
      ...stepLines(),
      ...queueNoteLines(),
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
    var keepLog = true;
    try {
      await for (final detail in detailStream) {
        details[detail.build.platform] = detail;
        endedLines.addAll(steps.update(detail));
        logFeeds[detail.build.platform]?.add(detail);
        render();
      }
      keepLog = builds.any(
        (build) =>
            AppBuildStatusFormatter.buildError(
              build.platform,
              details[build.platform],
            ) !=
            null,
      );
    } on StreamInterruptedException {
      keepLog = false;
      rethrow;
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
            ...stepLines(),
            if (keepLog)
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
    final steps = AppBuildStepLines([
      for (final build in builds) build.platform,
    ]);
    final started = <String>{};
    void printStarted() {
      for (final line in steps.activeLines) {
        if (started.add(line.text)) logger.line(line.text);
      }
    }

    var queueNoteShown = false;
    void printQueueNote() {
      if (queueNoteShown) return;
      final queued = steps.queuedFor(_longQueue);
      if (queued.isEmpty) return;
      queueNoteShown = true;
      for (final line in AppBuildStatusFormatter.longQueueNote(
        queued,
        buildCount: builds.length,
      )) {
        logger.info(line);
      }
    }

    printStarted();
    final queueCheck = Timer.periodic(
      _longQueueCheckInterval,
      (_) => printQueueNote(),
    );
    try {
      await for (final detail in detailStream) {
        details[detail.build.platform] = detail;
        final now = DateTime.now();
        for (final line in steps.update(detail)) {
          logger.line(_plainStepLine(line, now));
        }
        printStarted();
        printQueueNote();
      }
    } finally {
      queueCheck.cancel();
    }
    return details;
  }

  /// The [line] of a stage on an interactive terminal: a spinner frame
  /// [spinnerFrame] while the stage runs, `✓` once done and `✗` when it
  /// failed, then its text and its time by [now], colored like the stages
  /// of a deploy when the terminal supports color.
  static String _stepLine(
    InlineTerminal terminal,
    AppBuildStepLine line, {
    required int spinnerFrame,
    required DateTime now,
  }) {
    final frames = AppBuildStatusFormatter.spinnerFrames;
    final (marker, style) = switch (line.state) {
      AppBuildStageState.done => ('✓', AnsiStyle.lightGreen),
      AppBuildStageState.failed => ('✗', AnsiStyle.red),
      AppBuildStageState.pending || AppBuildStageState.active => (
        frames[spinnerFrame % frames.length],
        AnsiStyle.lightGreen,
      ),
    };
    final elapsed = line.elapsed(now);
    final time = elapsed == null
        ? ''
        : ' (${ScrollingSection.formatElapsed(elapsed)})';
    final text = elapsed == null ? line.text : _padded(line.text);
    final plain = '$marker $text$time';
    final fitted = fitAnsiToColumns(plain, terminal.columns);
    if (!terminal.supportsColor || fitted != plain) return fitted;
    final reset = AnsiStyle.reset.ansiCode;
    return '${style.ansiCode}$marker$reset $text'
        '${time.isEmpty ? '' : ' ${AnsiStyle.darkGray.ansiCode}${time.trim()}$reset'}';
  }

  /// The [line] of a stage that ended, as plain text with its duration by
  /// [now], such as `✓ Android build prepared.   (1m 39s)`.
  static String _plainStepLine(AppBuildStepLine line, DateTime now) {
    final marker = line.state == AppBuildStageState.failed ? '✗' : '✓';
    final elapsed = line.elapsed(now);
    if (elapsed == null) return '$marker ${line.text}';
    return '$marker ${_padded(line.text)} '
        '(${ScrollingSection.formatElapsed(elapsed)})';
  }

  /// [text] padded to the width deploy stages use, so durations line up.
  static String _padded(String text) =>
      text.padRight(StatusCommands.progressMessagePadLength);

  /// Logs the stores that the builds for [platforms] uploaded the app to,
  /// according to their last detail in [details], naming the app by
  /// [appNames] with [versionName]. Platforms whose app has the same name
  /// share a line, such as `Uploaded Acme (1.0.0) to TestFlight and Google
  /// Play.`. An app without a name is `the app`, without its version.
  ///
  /// Throws [FailureException] if a build did not succeed.
  static void _report(
    CommandLogger logger, {
    required List<AppPlatform> platforms,
    required Map<AppPlatform, AppBuildDetail> details,
    required String projectId,
    required String baseCommand,
    String? versionName,
    Map<AppPlatform, String>? appNames,
  }) {
    final errors = [
      for (final platform in platforms)
        if (details[platform]?.build case final build?)
          ?AppBuildStatusFormatter.followError(
            platform,
            build,
            logCommand:
                '$baseCommand app log ${build.uploadId} '
                '--platform ${platform.name} --project $projectId',
          )
        else
          ?AppBuildStatusFormatter.buildError(platform, null),
    ];
    final succeeded = [
      for (final platform in platforms)
        if (details[platform]?.build.status == AppBuildStatus.succeeded)
          platform,
    ];
    final uploadsByName = AppBuildStatusFormatter.platformsByAppName(
      succeeded,
      appNames,
    );
    for (final (index, MapEntry(key: name, value: uploaded))
        in uploadsByName.entries.indexed) {
      final app = name == null
          ? 'the app'
          : versionName == null
          ? name
          : '$name ($versionName)';
      logger.success(
        'Uploaded $app to ${AppBuildStatusFormatter.storeNames(uploaded)}.',
        newParagraph: index == 0,
      );
    }
    if (errors.isNotEmpty) {
      for (final platform in platforms) {
        if (succeeded.contains(platform)) continue;
        final build = details[platform]?.build;
        if (build == null) continue;
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

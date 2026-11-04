import 'dart:async';

import 'package:async/async.dart' show StreamGroup;
import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildDetail, AppBuildRef, AppPlatform, Client;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';

import 'release_build_status.dart';
import 'release_ops.dart';

/// Shows the progress of the app builds of a release.
abstract class ReleaseBuildProgress {
  static const _spinnerInterval = Duration(milliseconds: 80);

  /// Shows a status line per build in [builds] of project [projectId],
  /// updated on every change until all builds have ended, and then their
  /// result.
  ///
  /// On an interactive terminal the lines are redrawn in place, with a
  /// spinner on the active stages. Otherwise a line is printed each time it
  /// changes.
  ///
  /// Throws [FailureException] if a build does not succeed.
  static Future<void> follow(
    Client cloudApiClient, {
    required CommandLogger logger,
    required String projectId,
    required List<AppBuildRef> builds,
    String? versionName,
  }) async {
    final detailStream = StreamGroup.merge([
      for (final build in builds)
        ReleaseOperations.tailBuild(
          cloudApiClient,
          projectId: projectId,
          buildId: build.buildId,
        ),
    ]);
    final terminal = logger.inlineTerminal;
    final details = terminal.hasTerminal
        ? await _renderProgress(
            detailStream,
            terminal: terminal,
            builds: builds,
          )
        : await _printProgress(detailStream, logger: logger, builds: builds);

    _report(
      logger,
      platforms: [for (final build in builds) build.platform],
      details: details,
      versionName: versionName,
    );
  }

  /// Prints a status line per build in [details], which have all ended,
  /// and then their result.
  ///
  /// Throws [FailureException] if a build did not succeed.
  static void showEnded({
    required CommandLogger logger,
    required List<AppBuildDetail> details,
    String? versionName,
  }) {
    for (final detail in details) {
      logger.line(ReleaseBuildStatus.line(detail.build.platform, detail));
    }

    _report(
      logger,
      platforms: [for (final detail in details) detail.build.platform],
      details: {for (final detail in details) detail.build.platform: detail},
      versionName: versionName,
    );
  }

  static Future<Map<AppPlatform, AppBuildDetail>> _renderProgress(
    Stream<AppBuildDetail> detailStream, {
    required InlineTerminal terminal,
    required List<AppBuildRef> builds,
  }) async {
    final details = <AppPlatform, AppBuildDetail>{};
    var spinnerFrame = 0;
    final renderer = BottomRegionRenderer(terminal)..hideCursor();
    void render() => renderer.render([
      for (final build in builds)
        ReleaseBuildStatus.line(
          build.platform,
          details[build.platform],
          spinnerFrame: spinnerFrame,
        ),
    ]);

    render();
    final ticker = Timer.periodic(_spinnerInterval, (_) {
      spinnerFrame++;
      render();
    });
    try {
      await for (final detail in detailStream) {
        details[detail.build.platform] = detail;
        render();
      }
    } finally {
      ticker.cancel();
      renderer.finish();
    }
    return details;
  }

  static Future<Map<AppPlatform, AppBuildDetail>> _printProgress(
    Stream<AppBuildDetail> detailStream, {
    required CommandLogger logger,
    required List<AppBuildRef> builds,
  }) async {
    final details = <AppPlatform, AppBuildDetail>{};
    final lines = <AppPlatform, String>{
      for (final build in builds)
        build.platform: ReleaseBuildStatus.line(build.platform, null),
    };
    lines.values.forEach(logger.line);

    await for (final detail in detailStream) {
      final platform = detail.build.platform;
      details[platform] = detail;
      final line = ReleaseBuildStatus.line(platform, detail);
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
    String? versionName,
  }) {
    final errors = [
      for (final platform in platforms)
        ?ReleaseBuildStatus.buildError(platform, details[platform]),
    ];
    if (errors.isNotEmpty) {
      throw FailureException(errors: errors);
    }

    logger.success(
      'Published ${versionName ?? 'the app'} to '
      '${ReleaseBuildStatus.platformNames(platforms)}.',
      newParagraph: true,
    );
  }
}

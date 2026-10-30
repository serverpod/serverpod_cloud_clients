import 'dart:async';
import 'dart:io';

import 'package:async/async.dart' show StreamGroup;
import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildDetail, AppBuildRef, AppBuildStatus, AppPlatform, Client;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy_archive.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/git_metadata.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';

import 'release_build_status.dart';
import 'release_ops.dart';

abstract class ReleaseApp {
  static const _spinnerInterval = Duration(milliseconds: 80);

  /// Releases the Flutter app in [appDirectory] in project [projectId] as
  /// one build per release platform, all from one uploaded archive.
  ///
  /// The archive holds only the code of the release platforms, together with
  /// the workspace packages the app depends on when it is resolved in a Dart
  /// workspace. The workspace in the archive only lists the included
  /// packages, and their pubspec files are stripped of dev dependencies.
  ///
  /// When [platforms] is null, the app is released for the
  /// [defaultPlatforms] it has code for.
  ///
  /// With [awaitBuilds], the progress of the builds is shown until they end.
  ///
  /// Throws [FailureException] if the app has no code for a platform to
  /// release, if the builds cannot be requested, or if an awaited build does
  /// not succeed.
  /// Throws [ErrorExitException] if the archive cannot be zipped or uploaded.
  static Future<void> release(
    Client cloudApiClient,
    FileUploaderFactory fileUploaderFactory, {
    required CommandLogger logger,
    required String projectId,
    required Directory appDirectory,
    required List<FlutterPlatform> defaultPlatforms,
    Set<FlutterPlatform>? platforms,
    bool awaitBuilds = false,
  }) async {
    logger.init('Releasing the app of Serverpod Cloud project "$projectId".');

    final requestedPlatforms =
        platforms ?? _presentDefaultPlatforms(appDirectory, defaultPlatforms);
    final releasePlatforms = FlutterPlatform.values
        .where(requestedPlatforms.contains)
        .toList();

    final preparer = TenantProject.prepareApp(
      appDirectory,
      platforms: releasePlatforms.toSet(),
    );
    if (preparer.isWorkspace) {
      logger.list(
        preparer.includedPackagePaths,
        title: 'Including workspace packages',
        level: LogLevel.debug,
        newParagraph: true,
      );
    }

    final appZip = await DeployArchive.zip(
      logger: logger,
      projectFilePreparer: preparer,
      showFiles: false,
      subject: 'app',
    );

    final gitMetadata = await readGitMetadata(
      appDirectory.path,
      logger: logger,
    );

    final versionName = _versionName(preparer.projectVersion);
    final upload = await ReleaseOperations.createBuilds(
      cloudApiClient,
      projectId: projectId,
      platforms: releasePlatforms,
      flutterAppDir: preparer.projectSubPath,
      archiveSize: appZip.length,
      versionName: versionName,
      gitMetadata: gitMetadata,
    );

    await DeployArchive.upload(
      logger: logger,
      fileUploaderFactory: fileUploaderFactory,
      uploadDescription: upload.uploadDescription,
      projectZip: appZip,
      subject: 'app',
    );

    final builds = [...upload.builds]
      ..sort((a, b) => a.platform.index.compareTo(b.platform.index));
    final platformNames = ReleaseBuildStatus.platformNames(
      builds.map((build) => build.platform),
    );
    logger.info(
      'Publishing ${versionName ?? 'the app'} to $platformNames',
      newParagraph: true,
    );
    if (!awaitBuilds) return;

    final finalDetails = await _showBuildProgress(
      cloudApiClient,
      logger: logger,
      projectId: projectId,
      builds: builds,
    );
    _requireSucceeded(builds, finalDetails);

    logger.success(
      'Published ${versionName ?? 'the app'} to $platformNames.',
      newParagraph: true,
    );
  }

  /// Shows a status line per build in [builds], updated on every change,
  /// and returns the last detail of each build when all builds have ended.
  ///
  /// On an interactive terminal the lines are redrawn in place, with a
  /// spinner on the active stages. Otherwise a line is printed each time it
  /// changes.
  static Future<Map<AppPlatform, AppBuildDetail>> _showBuildProgress(
    Client cloudApiClient, {
    required CommandLogger logger,
    required String projectId,
    required List<AppBuildRef> builds,
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
    if (!terminal.hasTerminal) {
      return _printBuildProgress(detailStream, logger: logger, builds: builds);
    }
    return _renderBuildProgress(
      detailStream,
      terminal: terminal,
      builds: builds,
    );
  }

  static Future<Map<AppPlatform, AppBuildDetail>> _renderBuildProgress(
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

  static Future<Map<AppPlatform, AppBuildDetail>> _printBuildProgress(
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

  /// Throws [FailureException] if a build in [builds] did not succeed,
  /// according to its last detail in [details].
  static void _requireSucceeded(
    List<AppBuildRef> builds,
    Map<AppPlatform, AppBuildDetail> details,
  ) {
    final errors = [
      for (final build in builds)
        ?_buildError(build.platform, details[build.platform]),
    ];
    if (errors.isNotEmpty) {
      throw FailureException(errors: errors);
    }
  }

  static String? _buildError(AppPlatform platform, AppBuildDetail? detail) {
    final name = ReleaseBuildStatus.platformName(platform);
    final build = detail?.build;
    if (build == null) return 'The $name build did not report its status.';
    final message = build.message;
    return switch (build.status) {
      AppBuildStatus.succeeded => null,
      AppBuildStatus.failed =>
        message == null
            ? 'The $name build failed.'
            : 'The $name build failed: $message',
      AppBuildStatus.cancelled => 'The $name build was cancelled.',
      AppBuildStatus.queued ||
      AppBuildStatus.waiting ||
      AppBuildStatus.running => 'The $name build did not finish.',
    };
  }

  /// Returns the version name of [version], without its build number.
  static String? _versionName(Version? version) {
    if (version == null) return null;
    return version.toString().split('+').first;
  }

  /// Returns the [defaultPlatforms] the app in [appDirectory] has code for.
  ///
  /// Throws [FailureException] if it has code for none of them.
  static Set<FlutterPlatform> _presentDefaultPlatforms(
    Directory appDirectory,
    List<FlutterPlatform> defaultPlatforms,
  ) {
    final presentPlatforms = TenantProject.presentPlatforms(appDirectory);
    final releasePlatforms = defaultPlatforms
        .where(presentPlatforms.contains)
        .toSet();
    if (releasePlatforms.isEmpty) {
      final names = defaultPlatforms.map((platform) => platform.name);
      throw FailureException(
        error: 'The app has no code for the platforms: ${names.join(', ')}.',
        hint:
            'Add one with "flutter create --platforms=${names.first} ." '
            'in the app directory.',
      );
    }
    return releasePlatforms;
  }
}

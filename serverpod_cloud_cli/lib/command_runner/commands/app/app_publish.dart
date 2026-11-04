import 'dart:io';

import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildRef, Client;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy_archive.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/git_metadata.dart';

import 'app_build_progress.dart';
import 'app_build_status_formatter.dart';
import 'app_ops.dart';

abstract class AppPublish {
  /// Publishes the Flutter app in [appDirectory] in project [projectId] as
  /// one build per platform to publish, all from one uploaded archive.
  ///
  /// The archive holds only the code of the platforms to publish, together with
  /// the workspace packages the app depends on when it is resolved in a Dart
  /// workspace. The workspace in the archive only lists the included
  /// packages, and their pubspec files are stripped of dev dependencies.
  ///
  /// When [platforms] is null, the app is published for the
  /// [defaultPlatforms] it has code for.
  ///
  /// With [awaitBuilds], the progress of the builds is shown until they end.
  /// Otherwise the command to follow them is shown, invoked through
  /// [baseCommand].
  ///
  /// Throws [FailureException] if the app has no code for a platform to
  /// publish, if the builds cannot be requested, or if an awaited build does
  /// not succeed.
  /// Throws [ErrorExitException] if the archive cannot be zipped or uploaded.
  /// The builds are cancelled when the archive cannot be uploaded.
  static Future<void> publish(
    Client cloudApiClient,
    FileUploaderFactory fileUploaderFactory, {
    required CommandLogger logger,
    required String baseCommand,
    required String projectId,
    required Directory appDirectory,
    required List<FlutterPlatform> defaultPlatforms,
    Set<FlutterPlatform>? platforms,
    bool awaitBuilds = false,
  }) async {
    logger.init('Publishing the app of Serverpod Cloud project "$projectId".');

    final requestedPlatforms =
        platforms ?? _presentDefaultPlatforms(appDirectory, defaultPlatforms);
    final publishPlatforms = FlutterPlatform.values
        .where(requestedPlatforms.contains)
        .toList();

    final preparer = TenantProject.prepareApp(
      appDirectory,
      platforms: publishPlatforms.toSet(),
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
    final upload = await AppOperations.createBuilds(
      cloudApiClient,
      projectId: projectId,
      platforms: publishPlatforms,
      flutterAppDir: preparer.projectSubPath,
      archiveSize: appZip.length,
      versionName: versionName,
      gitMetadata: gitMetadata,
    );

    try {
      await DeployArchive.upload(
        logger: logger,
        fileUploaderFactory: fileUploaderFactory,
        uploadDescription: upload.uploadDescription,
        projectZip: appZip,
        subject: 'app',
      );
    } on Exception {
      await _cancelBuilds(
        cloudApiClient,
        logger: logger,
        projectId: projectId,
        builds: upload.builds,
      );
      rethrow;
    }

    final builds = [...upload.builds]
      ..sort((a, b) => a.platform.index.compareTo(b.platform.index));
    final platformNames = AppBuildStatusFormatter.platformNames(
      builds.map((build) => build.platform),
    );
    logger.info(
      'Publishing ${versionName ?? 'the app'} to $platformNames',
      newParagraph: true,
    );
    if (!awaitBuilds) {
      logger.info('Follow it: $baseCommand app show ${upload.uploadId}');
      return;
    }

    await AppBuildProgress.follow(
      cloudApiClient,
      logger: logger,
      projectId: projectId,
      builds: builds,
      versionName: versionName,
    );
  }

  /// Cancels [builds], whose archive failed to upload, so they do not stay
  /// queued. A build that cannot be cancelled is reported as a warning.
  static Future<void> _cancelBuilds(
    Client cloudApiClient, {
    required CommandLogger logger,
    required String projectId,
    required List<AppBuildRef> builds,
  }) async {
    final failures = await AppOperations.cancelBuilds(
      cloudApiClient,
      projectId: projectId,
      buildIds: [for (final build in builds) build.buildId],
    );
    for (final MapEntry(key: buildId, value: exception) in failures.entries) {
      logger.warning('Failed to cancel the app build $buildId: $exception');
    }
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
    final publishPlatforms = defaultPlatforms
        .where(presentPlatforms.contains)
        .toSet();
    if (publishPlatforms.isEmpty) {
      final names = defaultPlatforms.map((platform) => platform.name);
      throw FailureException(
        error: 'The app has no code for the platforms: ${names.join(', ')}.',
        hint:
            'Add one with "flutter create --platforms=${names.first} ." '
            'in the app directory.',
      );
    }
    return publishPlatforms;
  }
}

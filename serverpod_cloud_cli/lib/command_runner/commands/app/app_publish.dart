import 'dart:io';

import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildRef, AppIdentifierChange, AppPlatform, Client;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy_archive.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_app_identifier.dart';
import 'package:serverpod_cloud_cli/util/flutter_app_name.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/git_metadata.dart';

import 'app_build_progress.dart';
import 'app_build_status_formatter.dart';
import 'app_ops.dart';
import 'app_setup.dart';

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
  /// [defaultPlatforms] it has code for. The app identifier of each
  /// platform is sent with the request for the builds: the one in
  /// [configuredAppIdentifiers], or else the one the app's project files
  /// declare. Messages about an app identifier name the project
  /// configuration file [configFileName].
  ///
  /// The builds are made with the Flutter release version of
  /// [flutterVersionOverride], or else of [configuredFlutterVersion], or
  /// else the one a `.tool-versions` file in [appDirectory] or its
  /// workspace root pins, or else the single version the app's pubspec
  /// requires. With none of them, the builds use the stable channel.
  ///
  /// When Serverpod Cloud reports that the builds wait in the queue behind
  /// other builds of the account, a note says so before the builds are
  /// followed or announced.
  ///
  /// With [awaitBuilds], the progress and logs of the builds are shown
  /// until they end, and then the stores the app was uploaded to, naming
  /// the app by its display name on each platform. Without it, the stores
  /// the app is published to are announced, naming the app the same way,
  /// with the command to follow the builds, invoked through [baseCommand].
  /// With [showFiles], the archive file tree is printed. With [outputPath],
  /// the archive is also saved to that path.
  /// With [wetRun], preparation ends after zipping and saving the archive,
  /// without uploading it or requesting builds.
  ///
  /// Throws [FailureException] if the app has no code for a platform to
  /// publish, if the app identifier of a platform cannot be read or is
  /// refused, if the Flutter version is unsupported or below the Flutter
  /// SDK constraint of the app's packages, if the app's lockfile cannot be
  /// read, if the builds cannot be requested, or if an awaited build does
  /// not succeed.
  /// Throws [ErrorExitException] if the archive cannot be zipped or uploaded.
  /// Throws [UserAbortException] if following the builds is interrupted.
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
    required Map<FlutterPlatform, String> configuredAppIdentifiers,
    required String configFileName,
    String? flutterVersionOverride,
    String? configuredFlutterVersion,
    bool awaitBuilds = true,
    bool showFiles = false,
    bool wetRun = false,
    String? outputPath,
  }) async {
    logger.init('Publishing the app of Serverpod Cloud project "$projectId".');

    final requestedPlatforms =
        platforms ??
        TenantProject.presentDefaultPlatforms(appDirectory, defaultPlatforms);
    final publishPlatforms = FlutterPlatform.values
        .where(requestedPlatforms.contains)
        .toList();

    final preparer = TenantProject.prepareApp(
      appDirectory,
      platforms: publishPlatforms.toSet(),
    );
    final appIdentifiers = {
      for (final platform in publishPlatforms)
        platform: resolveAppIdentifier(
          appDirectory,
          platform,
          configured: configuredAppIdentifiers[platform],
          configFileName: configFileName,
        ),
    };
    final appNames = {
      for (final platform in publishPlatforms)
        AppPlatform.values.byName(platform.name): readAppDisplayName(
          appDirectory,
          platform,
          fallback: preparer.projectPackageName,
        ),
    };

    final flutterVersion = AppSetup.selectFlutterVersion(
      appDirectory,
      rootDirectory: preparer.rootDirectory,
      isWorkspace: preparer.isWorkspace,
      commandLineVersion: flutterVersionOverride,
      configuredVersion: configuredFlutterVersion,
      configFileName: configFileName,
    )?.version;
    if (flutterVersion == null) {
      logger.debug('No Flutter version requested, building with stable.');
    } else {
      logger.info('Flutter version: $flutterVersion');
    }

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
      showFiles: showFiles,
      subject: 'app',
    );

    if (outputPath != null) {
      await DeployArchive.writeZipFile(
        logger: logger,
        outputPath: outputPath,
        projectZip: appZip,
      );
    }
    if (wetRun) {
      logger.success(
        'Wet run complete. No app was uploaded or builds started.',
      );
      return;
    }

    final gitMetadata = await readGitMetadata(
      appDirectory.path,
      logger: logger,
    );

    final versionName = _versionName(preparer.projectVersion);
    final upload = await AppOperations.createBuilds(
      cloudApiClient,
      projectId: projectId,
      platforms: publishPlatforms,
      appIdentifiers: appIdentifiers,
      flutterAppDir: preparer.projectSubPath,
      archiveSize: appZip.length,
      flutterVersion: flutterVersion,
      versionName: versionName,
      gitMetadata: gitMetadata,
    );
    for (final change
        in upload.appIdentifierChanges ?? <AppIdentifierChange>[]) {
      logger.warning(_appIdentifierChangeWarning(change));
    }

    try {
      await DeployArchive.upload(
        logger: logger,
        fileUploaderFactory: fileUploaderFactory,
        uploadDescription: upload.uploadDescription,
        projectZip: appZip,
        subject: 'app',
        action: 'Initiating app upload',
        stepName: 'Initiating app upload',
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
    final waitsForOtherBuilds = upload.waitsForOtherBuilds ?? false;
    if (waitsForOtherBuilds) {
      logger.info(
        'App builds run one at a time per account. '
        'Other builds wait in the queue.',
        newParagraph: true,
      );
    }
    if (!awaitBuilds) {
      final buildsByName = AppBuildStatusFormatter.platformsByAppName(
        builds.map((build) => build.platform),
        appNames,
      );
      for (final (index, MapEntry(key: name, value: platforms))
          in buildsByName.entries.indexed) {
        logger.info(
          'Publishing ${name ?? 'the app'} to '
          '${AppBuildStatusFormatter.storeNames(platforms)}',
          newParagraph: index == 0 && !waitsForOtherBuilds,
        );
      }
      logger.info(
        'Follow it: $baseCommand app show ${upload.uploadId} '
        '--project $projectId',
      );
      return;
    }

    await AppBuildProgress.follow(
      cloudApiClient,
      logger: logger,
      projectId: projectId,
      uploadId: upload.uploadId,
      baseCommand: baseCommand,
      builds: builds,
      versionName: versionName,
      appNames: appNames,
      showLogs: true,
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

  /// The warning that the app identifier of a platform changed.
  static String _appIdentifierChangeWarning(AppIdentifierChange change) {
    final name = switch (change.platform) {
      AppPlatform.ios => 'iOS bundle ID',
      AppPlatform.android => 'Android package name',
    };
    return 'The $name of the project changed from "${change.previous}" '
        'to "${change.current}".';
  }

  /// Returns the version name of [version], without its build number.
  static String? _versionName(Version? version) {
    if (version == null) return null;
    return version.toString().split('+').first;
  }
}

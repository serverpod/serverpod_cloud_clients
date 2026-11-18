import 'dart:io';

import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildRef, AppIdentifierChange, AppPlatform, Client;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy_archive.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/android_gradle_versions.dart';
import 'package:serverpod_cloud_cli/util/dart_defines.dart';
import 'package:serverpod_cloud_cli/util/flutter_app_identifier.dart';
import 'package:serverpod_cloud_cli/util/flutter_app_name.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/git_metadata.dart';
import 'package:serverpod_cloud_cli/util/local_flutter_sdk.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart';

import 'app_build_progress.dart';
import 'app_build_status_formatter.dart';
import 'app_doctor_check.dart';
import 'app_ops.dart';
import 'app_setup.dart';
import 'app_ui.dart';

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
  /// [defaultPlatforms] it has code for and whose publishing setup is
  /// complete. The others are skipped with a warning that links to their
  /// setup guide. The app identifier of each
  /// platform is sent with the request for the builds: the one in
  /// [configuredAppIdentifiers], or else the one the app's project files
  /// declare. Messages about an app identifier name the project
  /// configuration file [configFileName].
  ///
  /// The builds are made with the Flutter release version of
  /// [flutterVersionOverride], or else the single version the app's pubspec
  /// requires, or else of [configuredFlutterVersion], or else the version of
  /// the local Flutter SDK, read with [readLocalFlutterVersion]. With none of them, the builds use the
  /// stable channel.
  ///
  /// When iOS is published, the build is made with the Xcode version of
  /// [configuredXcodeVersion], or else with the one Serverpod Cloud pins.
  ///
  /// When Android is published, the Gradle and Android Gradle Plugin
  /// versions the app declares are sent with the request, each when it can
  /// be read.
  ///
  /// The builds are made with the dart defines of [dartDefineFiles], read
  /// in order, and then of [dartDefines], each a `KEY=VALUE` pair; a later
  /// value of a key replaces an earlier one. The keys are logged at debug
  /// level, never the values. A `SERVER_URL` among them is dropped with a warning
  /// as Serverpod Cloud sets it.
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
  /// Before the archive is zipped, the project files of each platform to
  /// publish are checked as `app doctor` checks them, see
  /// [AppSetup.checkProjectFiles]. Only the failed checks are shown. With
  /// [force], publishing goes on after a warning; without it, it stops.
  ///
  /// Throws [FailureException] if a check of the project files fails and
  /// [force] is not set, if a dart defines file cannot be read or is
  /// not in its format, if the app has no code for a platform to
  /// publish, if none of the default platforms is set up, if the app
  /// identifier of a platform cannot be read or is
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
    String? configuredXcodeVersion,
    required LocalFlutterVersionReader readLocalFlutterVersion,
    List<File> dartDefineFiles = const [],
    List<String> dartDefines = const [],
    bool awaitBuilds = true,
    bool showFiles = false,
    bool wetRun = false,
    bool force = false,
    String? outputPath,
  }) async {
    logger.init('Publishing the app of Serverpod Cloud project "$projectId".');

    final buildDartDefines = _collectDartDefines(
      logger,
      files: dartDefineFiles,
      defines: dartDefines,
    );

    var requestedPlatforms = platforms;
    if (requestedPlatforms == null) {
      final present = TenantProject.presentDefaultPlatforms(
        appDirectory,
        defaultPlatforms,
      );
      final notSetUp = await AppOperations.notSetUpMessages(
        cloudApiClient,
        projectId: projectId,
        platforms: present,
      );
      if (notSetUp.length == present.length) {
        throw FailureException(errors: notSetUp.values.toList());
      }
      notSetUp.values.forEach(logger.warning);
      requestedPlatforms = present.difference(notSetUp.keys.toSet());
    }
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

    final flutterVersion = (await AppSetup.selectFlutterVersion(
      appDirectory,
      rootDirectory: preparer.rootDirectory,
      commandLineVersion: flutterVersionOverride,
      configuredVersion: configuredFlutterVersion,
      configFileName: configFileName,
      readLocalFlutterVersion: readLocalFlutterVersion,
      logger: logger,
    ))?.version;
    if (flutterVersion == null) {
      logger.debug('No Flutter version requested, building with stable.');
    } else {
      logger.info('Flutter version: $flutterVersion');
    }

    final xcodeVersion = publishPlatforms.contains(FlutterPlatform.ios)
        ? configuredXcodeVersion
        : null;
    if (xcodeVersion != null) {
      logger.info('Xcode version: $xcodeVersion');
    }

    final publishesAndroid = publishPlatforms.contains(FlutterPlatform.android);
    final gradleVersion = publishesAndroid
        ? readGradleVersion(appDirectory)
        : null;
    final androidGradlePluginVersion = publishesAndroid
        ? readAndroidGradlePluginVersion(appDirectory)
        : null;
    if (publishesAndroid) {
      logger.debug(
        'Gradle version: ${gradleVersion ?? 'unknown'}, '
        'Android Gradle Plugin version: '
        '${androidGradlePluginVersion ?? 'unknown'}',
      );
    }

    if (preparer.isWorkspace) {
      logger.list(
        preparer.includedPackagePaths,
        title: 'Including workspace packages',
        level: LogLevel.debug,
        newParagraph: true,
      );
    }

    await _checkProjectFiles(
      logger: logger,
      appDirectory: appDirectory,
      platforms: publishPlatforms.toSet(),
      force: force,
    );

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
      xcodeVersion: xcodeVersion,
      gradleVersion: gradleVersion,
      androidGradlePluginVersion: androidGradlePluginVersion,
      dartDefines: buildDartDefines,
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

  /// Checks the project files of [platforms] of the app in [appDirectory],
  /// see [AppSetup.checkProjectFiles], and shows the checks that failed.
  /// Warnings are not shown. With [force], a warning says that publishing
  /// goes on.
  ///
  /// Throws [FailureException] if a check failed and [force] is not set.
  static Future<void> _checkProjectFiles({
    required CommandLogger logger,
    required Directory appDirectory,
    required Set<FlutterPlatform> platforms,
    required bool force,
  }) async {
    final failed = [
      for (final check in AppSetup.checkProjectFiles(
        appDirectory,
        platforms: platforms,
      ))
        if (check.status == AppDoctorCheckStatus.failed) check,
    ];
    if (failed.isEmpty) return;

    await AppDoctorChecksWidget(
      failed,
    ).buildTree(OutputContext(OutputFormat.text)).renderTree(logger: logger);
    final summary = failed.length == 1
        ? '1 check of the app failed.'
        : '${failed.length} checks of the app failed.';
    if (force) {
      logger.warning('$summary Publishing anyway, as --force is set.');
      return;
    }
    throw FailureException(
      error: summary,
      hint:
          'Fix ${failed.length == 1 ? 'it' : 'them'} and publish again, or '
          'publish anyway with --force.',
    );
  }

  /// The dart defines of [files], read in order, and then of [defines], or
  /// null when there are none. A `SERVER_URL` is dropped with a warning.
  /// The keys are logged at debug level.
  ///
  /// Throws [FailureException] if a file cannot be read or is not in its
  /// format, or if a define is not a `KEY=VALUE` pair.
  static Map<String, String>? _collectDartDefines(
    CommandLogger logger, {
    required List<File> files,
    required List<String> defines,
  }) {
    final dartDefines = DartDefines.collect(files: files, defines: defines);
    if (dartDefines.remove(DartDefines.serverUrlKey) != null) {
      logger.warning(
        'The dart define ${DartDefines.serverUrlKey} is ignored. '
        "Serverpod Cloud sets it to the URL of the project's API server.",
      );
    }
    if (dartDefines.isEmpty) return null;
    logger.debug('Dart defines: ${dartDefines.keys.join(', ')}');
    return dartDefines;
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

import 'dart:io';

import 'package:ground_control_client/ground_control_client.dart' show Client;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy_archive.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/git_metadata.dart';

import 'release_ops.dart';

abstract class ReleaseApp {
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
  /// Throws [FailureException] if the app has no code for a platform to
  /// release, or if the builds cannot be requested.
  /// Throws [ErrorExitException] if the archive cannot be zipped or uploaded.
  static Future<void> release(
    Client cloudApiClient,
    FileUploaderFactory fileUploaderFactory, {
    required CommandLogger logger,
    required String projectId,
    required Directory appDirectory,
    required List<FlutterPlatform> defaultPlatforms,
    Set<FlutterPlatform>? platforms,
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

    final upload = await ReleaseOperations.createBuilds(
      cloudApiClient,
      projectId: projectId,
      platforms: releasePlatforms,
      flutterAppDir: preparer.projectSubPath,
      archiveSize: appZip.length,
      versionName: _versionName(preparer.projectVersion),
      gitMetadata: gitMetadata,
    );

    await DeployArchive.upload(
      logger: logger,
      fileUploaderFactory: fileUploaderFactory,
      uploadDescription: upload.uploadDescription,
      projectZip: appZip,
      subject: 'app',
    );

    final builds = upload.builds.map(
      (build) => '${build.platform.name} ${build.buildId}',
    );
    logger.success(
      'The app was uploaded for the builds: ${builds.join(', ')}.',
      newParagraph: true,
    );
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

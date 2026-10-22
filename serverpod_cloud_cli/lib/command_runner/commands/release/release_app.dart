import 'dart:io';

import 'package:ground_control_client/ground_control_client.dart' show Client;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy_archive.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';

import 'release_ops.dart';

abstract class ReleaseApp {
  /// Zips the Serverpod Flutter app in [appDirectory] together with the
  /// workspace packages it depends on, and uploads the archive to project
  /// [projectId].
  ///
  /// The workspace in the archive only lists the included packages, and
  /// their pubspec files are stripped of dev dependencies. When [platforms]
  /// is given, the archive only holds the code of those platforms.
  static Future<void> release(
    Client cloudApiClient,
    FileUploaderFactory fileUploaderFactory, {
    required CommandLogger logger,
    required String projectId,
    required Directory appDirectory,
    Set<FlutterPlatform>? platforms,
  }) async {
    logger.init('Releasing the app of Serverpod Cloud project "$projectId".');

    final projectFilePreparer = TenantProject.prepareApp(
      appDirectory,
      platforms: platforms,
    );
    logger.list(
      projectFilePreparer.includedPackagePaths,
      title: 'Including workspace packages',
      level: LogLevel.debug,
      newParagraph: true,
    );
    if (projectFilePreparer.excludedSubPaths.isNotEmpty) {
      logger.list(
        projectFilePreparer.excludedSubPaths,
        title: 'Excluding platform code',
        level: LogLevel.debug,
        newParagraph: true,
      );
    }

    final appZip = await DeployArchive.zip(
      logger: logger,
      projectFilePreparer: projectFilePreparer,
      showFiles: false,
      subject: 'app',
    );

    final uploadDescription =
        await ReleaseOperations.createAppUploadDescription(
          cloudApiClient,
          projectId: projectId,
          archiveSize: appZip.length,
        );

    await DeployArchive.upload(
      logger: logger,
      fileUploaderFactory: fileUploaderFactory,
      uploadDescription: uploadDescription,
      projectZip: appZip,
      subject: 'app',
    );

    logger.success('The app was uploaded.', newParagraph: true);
  }
}

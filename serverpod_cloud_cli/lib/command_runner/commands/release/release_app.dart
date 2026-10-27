import 'dart:io';

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy_archive.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart';
import 'package:serverpod_cloud_cli/util/byte_size.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';

abstract class ReleaseApp {
  /// Zips the Flutter app in [appDirectory], together with the workspace
  /// packages it depends on when it is resolved in a Dart workspace, and
  /// reports the archive size. The archive is not uploaded yet.
  ///
  /// The workspace in the archive only lists the included packages, and
  /// their pubspec files are stripped of dev dependencies. When [platforms]
  /// is given, the archive only holds the code of those platforms.
  static Future<void> release({
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
    if (projectFilePreparer.isWorkspace) {
      logger.list(
        projectFilePreparer.includedPackagePaths,
        title: 'Including workspace packages',
        level: LogLevel.debug,
        newParagraph: true,
      );
    }
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

    logger.success(
      'The app was zipped (${formatByteSize(appZip.length)}).',
      newParagraph: true,
    );
  }
}

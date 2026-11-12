import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildRef, AppBuildStatus, AppBuildSummary, Client, UuidValue;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

import 'app_build_progress.dart';
import 'app_build_status_formatter.dart';
import 'app_ops.dart';

abstract class AppShow {
  /// Shows the app builds made from the archive upload [uploadId] in project
  /// [projectId]: their progress until they end, or their final status when
  /// they have all ended.
  ///
  /// Throws [FailureException] if the upload has no builds in the project,
  /// or if a build does not succeed.
  static Future<void> show(
    Client cloudApiClient, {
    required CommandLogger logger,
    required String projectId,
    required UuidValue uploadId,
    required String baseCommand,
  }) async {
    final builds = await AppOperations.getUploadBuilds(
      cloudApiClient,
      projectId: projectId,
      uploadId: uploadId,
    );
    final versionName = builds.firstOrNull?.versionName;

    if (builds.every(_hasEnded)) {
      final details = await Future.wait([
        for (final build in builds)
          AppOperations.getBuild(
            cloudApiClient,
            projectId: projectId,
            buildId: build.id,
          ),
      ]);
      AppBuildProgress.showEnded(
        logger: logger,
        details: details,
        projectId: projectId,
        baseCommand: baseCommand,
        versionName: versionName,
      );
      return;
    }

    final platformNames = AppBuildStatusFormatter.platformNames(
      builds.map((build) => build.platform),
    );
    logger.info('Publishing ${versionName ?? 'the app'} to $platformNames');
    await AppBuildProgress.follow(
      cloudApiClient,
      logger: logger,
      projectId: projectId,
      uploadId: uploadId,
      baseCommand: baseCommand,
      builds: [
        for (final build in builds)
          AppBuildRef(buildId: build.id, platform: build.platform),
      ],
      versionName: versionName,
    );
  }

  static bool _hasEnded(AppBuildSummary build) {
    return switch (build.status) {
      AppBuildStatus.succeeded ||
      AppBuildStatus.builtNotUploaded ||
      AppBuildStatus.failed ||
      AppBuildStatus.cancelled => true,
      AppBuildStatus.queued ||
      AppBuildStatus.waiting ||
      AppBuildStatus.running => false,
    };
  }
}

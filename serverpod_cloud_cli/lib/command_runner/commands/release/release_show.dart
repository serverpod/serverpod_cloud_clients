import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildRef, AppBuildStatus, AppBuildSummary, Client, UuidValue;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

import 'release_build_progress.dart';
import 'release_build_status.dart';
import 'release_ops.dart';

abstract class ReleaseShow {
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
  }) async {
    final builds = await ReleaseOperations.getUploadBuilds(
      cloudApiClient,
      projectId: projectId,
      uploadId: uploadId,
    );
    final versionName = builds.firstOrNull?.versionName;

    if (builds.every(_hasEnded)) {
      final details = await Future.wait([
        for (final build in builds)
          ReleaseOperations.getBuild(
            cloudApiClient,
            projectId: projectId,
            buildId: build.id,
          ),
      ]);
      ReleaseBuildProgress.showEnded(
        logger: logger,
        details: details,
        versionName: versionName,
      );
      return;
    }

    final platformNames = ReleaseBuildStatus.platformNames(
      builds.map((build) => build.platform),
    );
    logger.info('Publishing ${versionName ?? 'the app'} to $platformNames');
    await ReleaseBuildProgress.follow(
      cloudApiClient,
      logger: logger,
      projectId: projectId,
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
      AppBuildStatus.failed ||
      AppBuildStatus.cancelled => true,
      AppBuildStatus.queued ||
      AppBuildStatus.waiting ||
      AppBuildStatus.running => false,
    };
  }
}

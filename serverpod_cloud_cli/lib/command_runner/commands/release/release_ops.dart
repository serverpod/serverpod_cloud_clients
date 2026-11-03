import 'package:ground_control_client/ground_control_client.dart'
    show
        AppBuildDetail,
        AppBuildSummary,
        AppBuildsUpload,
        AppPlatform,
        AppPublishingDisabledException,
        Client,
        InvalidValueException,
        NotFoundException,
        UploadTooLargeException,
        UuidValue,
        isRetryableMethodStreamDisconnect,
        reconnectStream;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/git_metadata.dart';

abstract class ReleaseOperations {
  /// Requests a build of the Flutter app in [flutterAppDir] of the archive
  /// for each of [platforms] in project [projectId], and returns the build
  /// ids with the upload description for an archive of [archiveSize] bytes.
  ///
  /// [versionName] is the app version the builds are made with.
  ///
  /// Throws [FailureException] if the request fails.
  static Future<AppBuildsUpload> createBuilds(
    Client cloudApiClient, {
    required String projectId,
    required List<FlutterPlatform> platforms,
    required String flutterAppDir,
    required int archiveSize,
    String? versionName,
    GitMetadata? gitMetadata,
  }) async {
    final appPlatforms = platforms.map(_appPlatform).toList();

    try {
      return await cloudApiClient.appBuilds.createBuilds(
        cloudCapsuleId: projectId,
        platforms: appPlatforms,
        flutterAppDir: flutterAppDir,
        archiveSize: archiveSize,
        versionName: versionName,
        commitHash: gitMetadata?.commitHash,
        commitMessage: gitMetadata?.commitMessage,
        branch: gitMetadata?.branch,
      );
    } on UploadTooLargeException catch (e) {
      throw FailureException(
        error: e.message,
        hint: 'Exclude files from the app with a .scloudignore file.',
      );
    } on AppPublishingDisabledException catch (e) {
      throw FailureException(error: e.message);
    } on InvalidValueException catch (e) {
      throw FailureException(error: e.message);
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to request the app builds.',
      );
    }
  }

  /// Returns the app builds made from the archive upload [uploadId] in
  /// project [projectId], in platform order.
  ///
  /// Throws [FailureException] if the upload has no builds in the project,
  /// or if they cannot be fetched.
  static Future<List<AppBuildSummary>> getUploadBuilds(
    Client cloudApiClient, {
    required String projectId,
    required UuidValue uploadId,
  }) async {
    try {
      return await cloudApiClient.appBuilds.getUploadBuilds(
        cloudCapsuleId: projectId,
        uploadId: uploadId,
      );
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on AppPublishingDisabledException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to fetch the app builds of the upload $uploadId.',
      );
    }
  }

  /// Returns the app build [buildId] of project [projectId] with its steps.
  ///
  /// Throws [FailureException] if the build is not in the project, or if it
  /// cannot be fetched.
  static Future<AppBuildDetail> getBuild(
    Client cloudApiClient, {
    required String projectId,
    required UuidValue buildId,
  }) async {
    try {
      return await cloudApiClient.appBuilds.getBuild(
        cloudCapsuleId: projectId,
        buildId: buildId,
      );
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to fetch the app build $buildId.',
      );
    }
  }

  /// Returns the app build [buildId] of project [projectId] on every change,
  /// until it reaches a final status.
  ///
  /// The stream reconnects when the connection drops, and emits a
  /// [FailureException] if it cannot.
  static Stream<AppBuildDetail> tailBuild(
    Client cloudApiClient, {
    required String projectId,
    required UuidValue buildId,
  }) {
    return reconnectStream<AppBuildDetail>(
      (_) => cloudApiClient.appBuilds.tailBuild(
        cloudCapsuleId: projectId,
        buildId: buildId,
      ),
      shouldRetry: isRetryableMethodStreamDisconnect,
    ).handleError((Object e, StackTrace stackTrace) {
      if (e is! Exception) throw e;
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to follow the app build $buildId.',
      );
    });
  }

  /// Cancels the app builds [buildIds] of project [projectId], and returns
  /// the builds that could not be cancelled, with the exception of each. A
  /// build that no longer exists is skipped.
  static Future<Map<UuidValue, Exception>> cancelBuilds(
    Client cloudApiClient, {
    required String projectId,
    required List<UuidValue> buildIds,
  }) async {
    final failures = <UuidValue, Exception>{};
    for (final buildId in buildIds) {
      try {
        await cloudApiClient.appBuilds.cancelBuild(
          cloudCapsuleId: projectId,
          buildId: buildId,
        );
      } on NotFoundException {
        continue;
      } on Exception catch (e) {
        failures[buildId] = e;
      }
    }
    return failures;
  }

  static AppPlatform _appPlatform(FlutterPlatform platform) {
    return switch (platform) {
      FlutterPlatform.android => AppPlatform.android,
      FlutterPlatform.ios => AppPlatform.ios,
      FlutterPlatform.linux ||
      FlutterPlatform.macos ||
      FlutterPlatform.windows => throw FailureException(
        error: 'Releasing for ${platform.name} is not supported yet.',
      ),
    };
  }
}

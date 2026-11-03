import 'dart:math';

import 'package:collection/collection.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show
        AppBuildDetail,
        AppBuildStatus,
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

import 'app_upload_row.dart';

abstract class ReleaseOperations {
  static const _maxPageSize = 100;

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

  /// Lists the [limit] most recent app uploads of project [projectId] with
  /// their builds, newest first.
  ///
  /// Throws [FailureException] if the builds cannot be fetched.
  static Future<List<AppUploadRow>> listUploads(
    Client cloudApiClient, {
    required String projectId,
    required int limit,
  }) async {
    final builds = await _fetchBuilds(
      cloudApiClient,
      projectId: projectId,
      pageSize: min((limit + 1) * AppPlatform.values.length, _maxPageSize),
      isEnough: (builds) =>
          builds.map((build) => build.uploadId).toSet().length > limit,
    );
    final uploads = groupBy(builds, (build) => build.uploadId);
    return [
      for (final MapEntry(key: uploadId, value: uploadBuilds)
          in uploads.entries.take(limit))
        _uploadRow(uploadId, uploadBuilds),
    ];
  }

  /// Lists the [limit] most recent app builds of project [projectId] for
  /// [platforms], newest first.
  ///
  /// Throws [FailureException] if the builds cannot be fetched.
  static Future<List<AppBuildSummary>> listBuilds(
    Client cloudApiClient, {
    required String projectId,
    required List<AppPlatform> platforms,
    required int limit,
  }) async {
    final builds = [
      for (final platform in platforms)
        ...await _fetchBuilds(
          cloudApiClient,
          projectId: projectId,
          platform: platform,
          pageSize: min(limit, _maxPageSize),
          isEnough: (builds) => builds.length >= limit,
        ),
    ];
    mergeSort(builds, compare: (a, b) => b.createdAt.compareTo(a.createdAt));
    return builds.take(limit).toList();
  }

  /// Fetches the builds of project [projectId], only for [platform] if set,
  /// newest first, a page of [pageSize] builds at a time until [isEnough]
  /// holds for the builds fetched or there are no more.
  static Future<List<AppBuildSummary>> _fetchBuilds(
    Client cloudApiClient, {
    required String projectId,
    AppPlatform? platform,
    required int pageSize,
    required bool Function(List<AppBuildSummary> builds) isEnough,
  }) async {
    final builds = <AppBuildSummary>[];
    try {
      while (true) {
        final page = await cloudApiClient.appBuilds.listBuilds(
          cloudCapsuleId: projectId,
          platform: platform,
          limit: pageSize,
          afterBuildId: builds.lastOrNull?.id,
        );
        builds.addAll(page);
        if (page.length < pageSize || isEnough(builds)) {
          return builds;
        }
      }
    } on AppPublishingDisabledException catch (e) {
      throw FailureException(error: e.message);
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to list the app builds.',
      );
    }
  }

  static AppUploadRow _uploadRow(
    UuidValue uploadId,
    List<AppBuildSummary> builds,
  ) {
    final platformBuilds = builds.sortedBy<num>(
      (build) => build.platform.index,
    );
    return AppUploadRow(
      uploadId: uploadId,
      versionName: builds.first.versionName,
      platforms: [for (final build in platformBuilds) build.platform],
      status: _uploadStatus(builds),
      createdAt: builds.map((build) => build.createdAt).min,
      builds: platformBuilds,
    );
  }

  /// The status of an upload with [builds]: the furthest status of the
  /// builds still in progress, or else the worst final status.
  static AppBuildStatus _uploadStatus(List<AppBuildSummary> builds) {
    final statuses = builds.map((build) => build.status).toSet();
    const precedence = [
      AppBuildStatus.running,
      AppBuildStatus.waiting,
      AppBuildStatus.queued,
      AppBuildStatus.failed,
      AppBuildStatus.cancelled,
    ];
    return precedence.firstWhere(
      statuses.contains,
      orElse: () => AppBuildStatus.succeeded,
    );
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

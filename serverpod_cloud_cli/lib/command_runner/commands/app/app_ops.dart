import 'dart:math';

import 'package:collection/collection.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show
        AppBuildDetail,
        AppBuildStatus,
        AppBuildStepInfo,
        AppBuildStepStatus,
        AppBuildSummary,
        AppBuildsUpload,
        AppPlatform,
        AppPublishingDisabledException,
        AppPublishingSetup,
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

import 'app_build_step_log.dart';
import 'app_status_row.dart';
import 'app_upload_row.dart';
import 'app_build_status_formatter.dart';

abstract class AppOperations {
  static const _maxPageSize = 100;

  static const _maxSilentTails = 3;

  static const _tailReconnectDelay = Duration(seconds: 1);

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
  /// The stream reconnects when the connection drops, or when it closes
  /// before the build has ended, and emits a [FailureException] if it cannot
  /// reconnect. It closes before the build has ended only when several
  /// connections in a row close without reporting the build.
  static Stream<AppBuildDetail> tailBuild(
    Client cloudApiClient, {
    required String projectId,
    required UuidValue buildId,
  }) async* {
    AppBuildDetail? lastDetail;
    var silentTails = 0;
    while (true) {
      var reported = false;
      await for (final detail in _tailBuildConnection(
        cloudApiClient,
        projectId: projectId,
        buildId: buildId,
      )) {
        reported = true;
        lastDetail = detail;
        yield detail;
      }
      if (lastDetail != null && _hasBuildEnded(lastDetail.build.status)) {
        return;
      }
      silentTails = reported ? 0 : silentTails + 1;
      if (silentTails >= _maxSilentTails) {
        return;
      }
      await Future<void>.delayed(_tailReconnectDelay);
    }
  }

  static Stream<AppBuildDetail> _tailBuildConnection(
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

  /// Returns each platform of project [projectId] that has a connected
  /// store, in display order, with its most recent build. The builds are
  /// only fetched when a store is connected.
  ///
  /// Throws [FailureException] if the publishing setup or the builds cannot
  /// be fetched.
  static Future<List<AppStatusRow>> getStatus(
    Client cloudApiClient, {
    required String projectId,
  }) async {
    final AppPublishingSetup setup;
    final List<AppBuildSummary> latestBuilds;
    try {
      setup = await cloudApiClient.appPublishing.getSetup(
        cloudCapsuleId: projectId,
      );
      final hasConnectedStore =
          setup.ios.store != null || setup.android.store != null;
      latestBuilds = hasConnectedStore
          ? await cloudApiClient.appBuilds.getLatestBuilds(
              cloudCapsuleId: projectId,
            )
          : const [];
    } on AppPublishingDisabledException catch (e) {
      throw FailureException(error: e.message);
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to fetch the app status.',
      );
    }

    final connectedPlatforms = [
      if (setup.ios.store != null)
        (platform: AppPlatform.ios, store: AppStore.appStore),
      if (setup.android.store != null)
        (platform: AppPlatform.android, store: AppStore.googlePlay),
    ];
    return [
      for (final (:platform, :store) in connectedPlatforms)
        AppStatusRow(
          platform: platform,
          store: store,
          latestBuild: latestBuilds
              .where((build) => build.platform == platform)
              .firstOrNull,
        ),
    ];
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

  /// Returns the log of each step of the [platform] build made from the
  /// archive upload [uploadId] in project [projectId], in run order, as each
  /// step ends. Once the build has ended, the steps that have not ended
  /// follow, and the stream closes.
  ///
  /// Throws [FailureException] if the upload has no [platform] build in the
  /// project, or if the build cannot be fetched. The stream emits a
  /// [FailureException] if the build or a step log cannot be fetched, and
  /// last if the build did not succeed.
  static Future<Stream<AppBuildStepLog>> followBuildLog(
    Client cloudApiClient, {
    required String projectId,
    required UuidValue uploadId,
    required AppPlatform platform,
  }) async {
    final builds = await getUploadBuilds(
      cloudApiClient,
      projectId: projectId,
      uploadId: uploadId,
    );
    final build = builds
        .where((build) => build.platform == platform)
        .firstOrNull;
    if (build == null) {
      throw FailureException(
        error:
            'The upload $uploadId has no '
            '${AppBuildStatusFormatter.platformName(platform)} build.',
      );
    }

    return _stepLogs(
      cloudApiClient,
      projectId: projectId,
      buildId: build.id,
      platform: platform,
    );
  }

  static Stream<AppBuildStepLog> _stepLogs(
    Client cloudApiClient, {
    required String projectId,
    required UuidValue buildId,
    required AppPlatform platform,
  }) async* {
    AppBuildDetail? lastDetail;
    yield* stepLogs(
      cloudApiClient,
      projectId: projectId,
      buildId: buildId,
      details: tailBuild(
        cloudApiClient,
        projectId: projectId,
        buildId: buildId,
      ).map((detail) => lastDetail = detail),
    );

    final error = AppBuildStatusFormatter.buildError(platform, lastDetail);
    if (error != null) {
      throw FailureException(error: error);
    }
  }

  /// Returns the log of each step of the app build [buildId] of project
  /// [projectId], in run order, as the build [details] show the step has
  /// ended. Once a detail shows the build has ended, the steps that have not
  /// ended follow.
  ///
  /// The stream emits a [FailureException] for each step whose log cannot be
  /// fetched, and goes on with the next step.
  static Stream<AppBuildStepLog> stepLogs(
    Client cloudApiClient, {
    required String projectId,
    required UuidValue buildId,
    required Stream<AppBuildDetail> details,
  }) async* {
    var loggedStepCount = 0;
    await for (final detail in details) {
      final remainingSteps = detail.steps.skip(loggedStepCount);
      final stepsToLog = _hasBuildEnded(detail.build.status)
          ? remainingSteps
          : remainingSteps.takeWhile((step) => _hasEnded(step.status));
      for (final step in stepsToLog) {
        loggedStepCount++;
        final String? log;
        try {
          log = _hasLog(step)
              ? await _getStepLog(
                  cloudApiClient,
                  projectId: projectId,
                  buildId: buildId,
                  stepIndex: step.index,
                )
              : null;
        } on FailureException catch (e, stackTrace) {
          yield* Stream.error(e, stackTrace);
          continue;
        }
        yield AppBuildStepLog(step: step, log: log);
      }
    }
  }

  static Future<String?> _getStepLog(
    Client cloudApiClient, {
    required String projectId,
    required UuidValue buildId,
    required int stepIndex,
  }) async {
    try {
      return await cloudApiClient.appBuilds.getStepLog(
        cloudCapsuleId: projectId,
        buildId: buildId,
        stepIndex: stepIndex,
      );
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on AppPublishingDisabledException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to fetch the log of step $stepIndex of the app build '
        '$buildId.',
      );
    }
  }

  static bool _hasEnded(AppBuildStepStatus status) {
    return switch (status) {
      AppBuildStepStatus.succeeded ||
      AppBuildStepStatus.failed ||
      AppBuildStepStatus.cancelled ||
      AppBuildStepStatus.skipped => true,
      AppBuildStepStatus.pending || AppBuildStepStatus.running => false,
    };
  }

  static bool _hasLog(AppBuildStepInfo step) {
    return switch (step.status) {
      AppBuildStepStatus.succeeded ||
      AppBuildStepStatus.failed ||
      AppBuildStepStatus.cancelled => true,
      AppBuildStepStatus.pending ||
      AppBuildStepStatus.running => step.startedAt != null,
      AppBuildStepStatus.skipped => false,
    };
  }

  static bool _hasBuildEnded(AppBuildStatus status) {
    return switch (status) {
      AppBuildStatus.succeeded ||
      AppBuildStatus.failed ||
      AppBuildStatus.cancelled => true,
      AppBuildStatus.queued ||
      AppBuildStatus.waiting ||
      AppBuildStatus.running => false,
    };
  }

  static AppPlatform _appPlatform(FlutterPlatform platform) {
    return switch (platform) {
      FlutterPlatform.android => AppPlatform.android,
      FlutterPlatform.ios => AppPlatform.ios,
      FlutterPlatform.linux ||
      FlutterPlatform.macos ||
      FlutterPlatform.windows => throw FailureException(
        error: 'Publishing for ${platform.name} is not supported yet.',
      ),
    };
  }
}

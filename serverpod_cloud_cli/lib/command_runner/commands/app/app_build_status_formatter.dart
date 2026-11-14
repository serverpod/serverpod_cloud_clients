import 'dart:math';

import 'package:ground_control_client/ground_control_client.dart'
    show
        AppBuildDetail,
        AppBuildStage,
        AppBuildStatus,
        AppBuildStepInfo,
        AppBuildSummary,
        AppBuildStepStatus,
        AppPlatform;

import 'app_build_failure_advice.dart';

/// The progress of one stage of an app build.
enum AppBuildStageState { pending, active, done, failed }

typedef _StageNames = ({String activeName, String doneName});

/// Formats the progress of app builds by stage: the queue, then the
/// prepare, build and upload stages the console shows, such as
/// `Android build preparing...` and `Android build prepared.`.
///
/// The platform and each stage are columns of a fixed width, so the lines
/// of all platforms line up whatever the state of their stages.
abstract class AppBuildStatusFormatter {
  /// The spinner frames cycled through by the icon of an active stage.
  static const spinnerFrames = '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏';

  static const _stageNames = <_StageNames>[
    (activeName: 'queuing', doneName: 'queued'),
    (activeName: 'preparing', doneName: 'prepared'),
    (activeName: 'building', doneName: 'built'),
    (activeName: 'uploading', doneName: 'uploaded'),
  ];

  /// The number of stages of a build: queue, prepare, build and upload.
  static int get stageCount => _stageNames.length;

  /// The display names of [platforms], in display order, joined as a
  /// sentence, such as `iOS and Android`.
  static String platformNames(Iterable<AppPlatform> platforms) {
    return _joined(sortedPlatforms(platforms).map(platformName).toList());
  }

  /// [names] joined as a sentence, such as `A, B and C`.
  static String _joined(List<String> names) {
    if (names.length < 2) return names.join();
    return '${names.sublist(0, names.length - 1).join(', ')} '
        'and ${names.last}';
  }

  /// The stores that builds for [platforms] upload to, in display order,
  /// joined as a sentence, such as `TestFlight and Google Play`.
  static String storeNames(Iterable<AppPlatform> platforms) {
    return _joined(sortedPlatforms(platforms).map(storeName).toList());
  }

  /// [platforms] grouped by the name of their app in [appNames], in display
  /// order of the first platform of each group. Platforms without a name
  /// share the null group.
  static Map<String?, List<AppPlatform>> platformsByAppName(
    Iterable<AppPlatform> platforms,
    Map<AppPlatform, String>? appNames,
  ) {
    final groups = <String?, List<AppPlatform>>{};
    for (final platform in sortedPlatforms(platforms)) {
      groups.putIfAbsent(appNames?[platform], () => []).add(platform);
    }
    return groups;
  }

  /// The store that a build for [platform] uploads to.
  static String storeName(AppPlatform platform) {
    return switch (platform) {
      AppPlatform.ios => 'TestFlight',
      AppPlatform.android => 'Google Play',
    };
  }

  /// Returns [platforms] in display order.
  static List<AppPlatform> sortedPlatforms(Iterable<AppPlatform> platforms) {
    return AppPlatform.values.where(platforms.contains).toList();
  }

  /// The display name of [platform].
  static String platformName(AppPlatform platform) {
    return switch (platform) {
      AppPlatform.ios => 'iOS',
      AppPlatform.android => 'Android',
    };
  }

  /// The heading of the log of [step], such as `--- Build (Succeeded) ---`,
  /// with the name of [platform] before the step name when it is set.
  static String stepLogHeading(AppBuildStepInfo step, {AppPlatform? platform}) {
    final prefix = platform == null ? '' : '${platformName(platform)}: ';
    return '--- $prefix${step.name} (${_stepStatusName(step.status)}) ---';
  }

  /// The error of the build for [platform] in [detail], or null when the
  /// build succeeded. A null [detail] is reported as a build that did not
  /// report its status, and a build that has not ended as one that did not
  /// finish.
  static String? buildError(AppPlatform platform, AppBuildDetail? detail) {
    return summaryError(platform, detail?.build);
  }

  /// The error of the [build] for [platform], or null when it succeeded. A
  /// null [build] is reported as a build that did not report its status,
  /// and a build that has not ended as one that did not finish.
  static String? summaryError(AppPlatform platform, AppBuildSummary? build) {
    final name = platformName(platform);
    if (build == null) return 'The $name build did not report its status.';
    return switch (build.status) {
      AppBuildStatus.succeeded => null,
      AppBuildStatus.builtNotUploaded =>
        'The $name build was built but not uploaded to the store.',
      AppBuildStatus.failed => 'The $name build failed.',
      AppBuildStatus.cancelled => 'The $name build was cancelled.',
      AppBuildStatus.queued ||
      AppBuildStatus.waiting ||
      AppBuildStatus.running => 'The $name build did not finish.',
    };
  }

  /// The error of the [build] for [platform] of project [projectId] that a
  /// follow of its upload reports, or null when it succeeded. A build that
  /// failed for a known reason gets the advice for it, as
  /// [adviceError] has it, then [logCommand] to read its log. Any other
  /// build that failed, was not uploaded to the store, or did not finish
  /// points to [logCommand] for the reason, such as `The Android build
  /// failed. Find out why in the logs: scloud app log …`.
  static String? followError(
    AppPlatform platform,
    AppBuildSummary build, {
    required String logCommand,
    required String projectId,
    required String baseCommand,
  }) {
    final error = summaryError(platform, build);
    if (error == null || build.status == AppBuildStatus.cancelled) {
      return error;
    }
    final advice = AppBuildFailureAdvice.of(
      build.failureReason,
      platform,
      projectId: projectId,
      baseCommand: baseCommand,
    );
    if (advice == null) {
      return '$error Find out why in the logs: $logCommand';
    }
    return '${_withAdvice(error, advice, build, projectId: projectId, baseCommand: baseCommand)}\nRead the log: $logCommand';
  }

  /// The error of the [build] for [platform] of project [projectId], as
  /// [summaryError] has it, followed by what went wrong and what to do about
  /// it when the build failed for a known reason, such as:
  ///
  /// ```text
  /// The iOS build failed. Apple has no room for another certificate.
  /// Your Apple team already has as many distribution certificates …
  /// Open Certificates: https://developer.apple.com/…
  /// ```
  ///
  /// Advice to upload the build by hand ends with the command to download
  /// it. Commands in the advice are named with [baseCommand].
  static String? adviceError(
    AppPlatform platform,
    AppBuildSummary? build, {
    required String projectId,
    required String baseCommand,
  }) {
    final error = summaryError(platform, build);
    if (error == null || build == null) return error;
    final advice = AppBuildFailureAdvice.of(
      build.failureReason,
      platform,
      projectId: projectId,
      baseCommand: baseCommand,
    );
    return advice == null
        ? error
        : _withAdvice(
            error,
            advice,
            build,
            projectId: projectId,
            baseCommand: baseCommand,
          );
  }

  static String _withAdvice(
    String error,
    AppBuildFailureAdvice advice,
    AppBuildSummary build, {
    required String projectId,
    required String baseCommand,
  }) {
    return [
      '$error ${advice.title}.',
      advice.description,
      if (advice.link case final link?) '${link.label}: ${link.url}',
      if (advice.downloadsBuild)
        'Download build: $baseCommand app artifacts ${build.uploadId} '
            '--project $projectId',
    ].join('\n');
  }

  /// The note that [queuedBuilds] have waited long in the queue, out of
  /// [buildCount] builds followed, as lines: why they wait, then that
  /// following can stop while the builds go on. They wait for a build
  /// machine when one of them was handed to the build service, and else for
  /// other app builds of the account.
  static List<String> longQueueNote(
    List<AppBuildSummary> queuedBuilds, {
    required int buildCount,
  }) {
    final waitsForMachine = queuedBuilds.any(
      (build) => build.status == AppBuildStatus.waiting,
    );
    final builds = buildCount == 1
        ? 'The build continues'
        : 'The builds continue';
    return [
      waitsForMachine
          ? 'Waiting for a build machine to be ready. This can take a while.'
          : 'Waiting for other app builds of the account to end. '
                'This can take a while.',
      'Press Ctrl+C to stop following. $builds in Serverpod Cloud.',
    ];
  }

  /// The text of [stage] of the build for [platform] in [state], such as
  /// `Android build preparing...` while it runs, `Android build prepared.`
  /// once done, and `Android build failed while preparing.` when it failed,
  /// or `cancelled while` when the build was [cancelled].
  static String stageText(
    AppPlatform platform,
    int stage,
    AppBuildStageState state, {
    bool cancelled = false,
  }) {
    final build = '${platformName(platform)} build';
    final names = _stageNames[stage];
    return switch (state) {
      AppBuildStageState.pending ||
      AppBuildStageState.active => '$build ${names.activeName}...',
      AppBuildStageState.done => '$build ${names.doneName}.',
      AppBuildStageState.failed =>
        '$build ${cancelled ? 'cancelled' : 'failed'} while '
            '${names.activeName}.',
    };
  }

  /// When [stage] of the build in [detail] started, or null when unknown.
  ///
  /// The queue stage starts when the build is requested. Any other stage
  /// starts with its first started step, or else when an earlier stage
  /// ended.
  static DateTime? stageStartedAt(AppBuildDetail detail, int stage) {
    if (stage == 0) return detail.build.createdAt;
    return _stepStarts(detail, stage).firstOrNull ??
        stageEndedAt(detail, stage - 1);
  }

  /// When [stage] of the build in [detail] ended, or null when unknown.
  ///
  /// The queue stage ends when a build machine starts on the build: when
  /// its first step starts. Handing the build to the build service, its
  /// [AppBuildSummary.startedAt], does not end it, since the build can wait
  /// there for a machine. A build that ended in the queue ends it then. Any
  /// other stage ends with its last ended step, or else when a step of a
  /// later stage started, or else when the build ended.
  static DateTime? stageEndedAt(AppBuildDetail detail, int stage) {
    if (stage == 0) {
      final machineStarted = detail.steps
          .map((step) => step.startedAt)
          .nonNulls
          .fold<DateTime?>(
            null,
            (earliest, startedAt) =>
                earliest == null || startedAt.isBefore(earliest)
                ? startedAt
                : earliest,
          );
      return machineStarted ?? detail.build.endedAt;
    }
    final ended = _stepsOf(
      detail,
      stage,
    ).map((step) => step.endedAt).nonNulls.lastOrNull;
    if (ended != null) return ended;
    for (var later = stage + 1; later < stageCount; later++) {
      final started = _stepStarts(detail, later).firstOrNull;
      if (started != null) return started;
    }
    return detail.build.endedAt;
  }

  /// The start times of the started steps of [stage] of the build in
  /// [detail], in run order.
  static Iterable<DateTime> _stepStarts(AppBuildDetail detail, int stage) {
    return _stepsOf(detail, stage).map((step) => step.startedAt).nonNulls;
  }

  /// The states of the queue, prepare, build and upload stages of the build
  /// in [detail].
  ///
  /// The build leaves the queue when a build machine starts on it. It is
  /// then in the latest stage with a step that has started, as
  /// [AppBuildStepInfo.stage] tells, or in the prepare stage before any step
  /// starts. The upload stage ends when the build succeeds. The stage the
  /// build is in is active. A failed or cancelled build fails the stage it
  /// stopped in, and a build the store refused fails the upload stage.
  static List<AppBuildStageState> stageStates(AppBuildDetail detail) {
    final build = detail.build;
    final currentStage = switch (build.status) {
      AppBuildStatus.queued || AppBuildStatus.waiting => 0,
      AppBuildStatus.succeeded => _stageNames.length,
      AppBuildStatus.builtNotUploaded => _stageNames.length - 1,
      AppBuildStatus.running => _stageAtBuildMachine(detail.steps),
      AppBuildStatus.failed || AppBuildStatus.cancelled =>
        build.startedAt == null ? 0 : _stageAtBuildMachine(detail.steps),
    };
    final isFailure =
        build.status == AppBuildStatus.builtNotUploaded ||
        build.status == AppBuildStatus.failed ||
        build.status == AppBuildStatus.cancelled;

    return [
      for (var stage = 0; stage < _stageNames.length; stage++)
        if (stage < currentStage)
          AppBuildStageState.done
        else if (stage == currentStage)
          isFailure ? AppBuildStageState.failed : AppBuildStageState.active
        else
          AppBuildStageState.pending,
    ];
  }

  static String _stepStatusName(AppBuildStepStatus status) {
    return switch (status) {
      AppBuildStepStatus.pending => 'Pending',
      AppBuildStepStatus.running => 'Running',
      AppBuildStepStatus.succeeded => 'Succeeded',
      AppBuildStepStatus.failed => 'Failed',
      AppBuildStepStatus.cancelled => 'Cancelled',
      AppBuildStepStatus.skipped => 'Skipped',
    };
  }

  /// The latest stage with a step in [steps] that has started, or the
  /// prepare stage when none has.
  static int _stageAtBuildMachine(List<AppBuildStepInfo> steps) {
    return steps
        .where(
          (step) =>
              step.status != AppBuildStepStatus.pending &&
              step.status != AppBuildStepStatus.skipped,
        )
        .map((step) => _stageOf(step.stage))
        .fold(1, max);
  }

  /// The steps of [stage] of the build in [detail], in run order.
  static Iterable<AppBuildStepInfo> _stepsOf(AppBuildDetail detail, int stage) {
    return detail.steps.where((step) => _stageOf(step.stage) == stage);
  }

  /// The stage, after the queue stage, that the steps of [stage] belong to.
  static int _stageOf(AppBuildStage stage) {
    return switch (stage) {
      AppBuildStage.upload => 1,
      AppBuildStage.build => 2,
      AppBuildStage.publish => 3,
    };
  }
}

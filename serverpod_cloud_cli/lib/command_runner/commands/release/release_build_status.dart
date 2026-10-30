import 'dart:math';

import 'package:ground_control_client/ground_control_client.dart'
    show
        AppBuildDetail,
        AppBuildStatus,
        AppBuildStepInfo,
        AppBuildStepStatus,
        AppPlatform;

/// The progress of one stage of an app build.
enum ReleaseStageState { pending, active, done, failed }

typedef _StageNames = ({String name, String activeName, String doneName});

/// Formats the progress of app builds as status lines, such as
/// `iOS      ✓ Queued    ⠹ Building  ● Upload → TestFlight`.
///
/// The platform and each stage are columns of a fixed width, so the lines
/// of all platforms line up whatever the state of their stages.
abstract class ReleaseBuildStatus {
  /// The name of the build step that uploads the app to the store.
  static const publishingStepName = 'Publishing';

  /// The spinner frames cycled through by the icon of an active stage.
  static const spinnerFrames = '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏';

  static const _columnSeparator = '  ';

  static const _stageCount = 3;

  /// The display names of [platforms], in display order, joined as a
  /// sentence, such as `iOS and Android`.
  static String platformNames(Iterable<AppPlatform> platforms) {
    final names = sortedPlatforms(platforms).map(platformName).toList();
    if (names.length < 2) return names.join();
    return '${names.sublist(0, names.length - 1).join(', ')} '
        'and ${names.last}';
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

  /// The status line of the build for [platform], with the queue stage
  /// active while [detail] is null.
  ///
  /// A stage is named after its state, such as `Queue`, `Queueing` and
  /// `Queued`. An active stage shows frame [spinnerFrame] of
  /// [spinnerFrames].
  static String line(
    AppPlatform platform,
    AppBuildDetail? detail, {
    int spinnerFrame = 0,
  }) {
    final states = detail == null
        ? [
            ReleaseStageState.active,
            ReleaseStageState.pending,
            ReleaseStageState.pending,
          ]
        : stageStates(detail);
    final cells = [
      platformName(platform),
      for (final (stage, names) in _stageNames(platform).indexed)
        _stage(states[stage], spinnerFrame, names),
    ];
    final widths = _columnWidths();
    return [
      for (final (column, cell) in cells.indexed)
        column == cells.length - 1 ? cell : cell.padRight(widths[column]),
    ].join(_columnSeparator);
  }

  /// The states of the queue, build and upload stages of the build in
  /// [detail].
  ///
  /// The build leaves the queue when a build machine starts on it. The
  /// build stage ends when the [publishingStepName] step starts, and the
  /// upload stage when the build succeeds. The stage the build is in is
  /// active. A failed or cancelled build fails the stage it stopped in.
  static List<ReleaseStageState> stageStates(AppBuildDetail detail) {
    final build = detail.build;
    final currentStage = switch (build.status) {
      AppBuildStatus.queued || AppBuildStatus.waiting => 0,
      AppBuildStatus.succeeded => 3,
      AppBuildStatus.running => _stageAtBuildMachine(detail.steps),
      AppBuildStatus.failed || AppBuildStatus.cancelled =>
        build.startedAt == null ? 0 : _stageAtBuildMachine(detail.steps),
    };
    final isFailure =
        build.status == AppBuildStatus.failed ||
        build.status == AppBuildStatus.cancelled;

    return [
      for (var stage = 0; stage < _stageCount; stage++)
        if (stage < currentStage)
          ReleaseStageState.done
        else if (stage == currentStage)
          isFailure ? ReleaseStageState.failed : ReleaseStageState.active
        else
          ReleaseStageState.pending,
    ];
  }

  static List<_StageNames> _stageNames(AppPlatform platform) {
    final store = ' → ${_storeName(platform)}';
    return [
      (name: 'Queue', activeName: 'Queueing', doneName: 'Queued'),
      (name: 'Build', activeName: 'Building', doneName: 'Built'),
      (
        name: 'Upload$store',
        activeName: 'Uploading$store',
        doneName: 'Uploaded$store',
      ),
    ];
  }

  /// The width of the platform column and of each stage column, wide enough
  /// for every platform in every state.
  static List<int> _columnWidths() {
    int widest(Iterable<String> texts) =>
        texts.fold(0, (width, text) => max(width, text.length));
    return [
      widest(AppPlatform.values.map(platformName)),
      for (var stage = 0; stage < _stageCount; stage++)
        widest([
          for (final platform in AppPlatform.values)
            for (final state in ReleaseStageState.values)
              _stage(state, 0, _stageNames(platform)[stage]),
        ]),
    ];
  }

  static String _stage(
    ReleaseStageState state,
    int spinnerFrame,
    _StageNames names,
  ) {
    return switch (state) {
      ReleaseStageState.pending => '● ${names.name}',
      ReleaseStageState.active =>
        '${spinnerFrames[spinnerFrame % spinnerFrames.length]} '
            '${names.activeName}',
      ReleaseStageState.done => '✓ ${names.doneName}',
      ReleaseStageState.failed => '✗ ${names.name}',
    };
  }

  static int _stageAtBuildMachine(List<AppBuildStepInfo> steps) {
    final isPublishing = steps.any(
      (step) =>
          step.name == publishingStepName &&
          step.status != AppBuildStepStatus.pending &&
          step.status != AppBuildStepStatus.skipped,
    );
    return isPublishing ? 2 : 1;
  }

  static String _storeName(AppPlatform platform) {
    return switch (platform) {
      AppPlatform.ios => 'TestFlight',
      AppPlatform.android => 'Play internal',
    };
  }
}

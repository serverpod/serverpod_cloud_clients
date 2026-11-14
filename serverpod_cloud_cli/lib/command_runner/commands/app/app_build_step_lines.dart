import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildDetail, AppBuildStatus, AppBuildSummary, AppPlatform;

import 'app_build_status_formatter.dart';

/// One stage of one build, as a line of the vertical build progress.
class AppBuildStepLine {
  /// The platform of the build.
  final AppPlatform platform;

  /// The state of the stage.
  final AppBuildStageState state;

  /// What the line says, such as `Android build prepared.`.
  final String text;

  /// When the stage started, or null when unknown.
  final DateTime? startedAt;

  /// When the stage ended, or null while it runs or when unknown.
  final DateTime? endedAt;

  const AppBuildStepLine({
    required this.platform,
    required this.state,
    required this.text,
    this.startedAt,
    this.endedAt,
  });

  /// How long the stage took, or has taken by [now] while it runs. Null
  /// when its start is unknown.
  Duration? elapsed(DateTime now) {
    final start = startedAt;
    if (start == null) return null;
    final elapsed = (endedAt ?? now).difference(start);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }
}

/// Tracks the stages of the builds of an app upload as vertical progress
/// lines: a line per stage that ended, in the order the stages ended, and
/// the line of the stage each build is in.
///
/// Stage times come from the build and its steps. A stage that ended
/// without a recorded end, such as the queue of a build whose machine
/// started before its first step is listed, ends when [clock] saw it end,
/// and the next stage starts then.
class AppBuildStepLines {
  /// The platforms of the builds, in display order.
  final List<AppPlatform> platforms;

  /// The current time.
  final DateTime Function() clock;

  final _details = <AppPlatform, AppBuildDetail>{};

  /// The number of stages of each build whose ended line was returned.
  final _endedCount = <AppPlatform, int>{};

  /// When each ended stage of each build ended, by stage.
  final _endedAt = <AppPlatform, Map<int, DateTime>>{};

  AppBuildStepLines(this.platforms, {this.clock = DateTime.now});

  /// Records [detail] and returns the lines of the stages of its build that
  /// ended since the previous detail, in stage order. Once a stage failed,
  /// no later stage of the build gets a line.
  List<AppBuildStepLine> update(AppBuildDetail detail) {
    final platform = detail.build.platform;
    _details[platform] = detail;
    final states = AppBuildStatusFormatter.stageStates(detail);
    var ended = _endedCount[platform] ?? 0;
    final lines = <AppBuildStepLine>[];
    while (ended < AppBuildStatusFormatter.stageCount) {
      final state = states[ended];
      if (state != AppBuildStageState.done &&
          state != AppBuildStageState.failed) {
        break;
      }
      lines.add(_line(platform, ended, state, detail));
      ended = state == AppBuildStageState.failed
          ? AppBuildStatusFormatter.stageCount
          : ended + 1;
    }
    _endedCount[platform] = ended;
    return lines;
  }

  /// The line of the stage each build is in, in platform order. A build
  /// without a detail yet is in the queue, and a build that ended has no
  /// line.
  List<AppBuildStepLine> get activeLines {
    return [for (final platform in platforms) ?_activeLine(platform)];
  }

  /// The builds that have been in the queue for [duration] or longer by
  /// [clock], in platform order. A build without a detail yet is left out.
  List<AppBuildSummary> queuedFor(Duration duration) {
    final now = clock();
    return [
      for (final platform in platforms)
        if (_details[platform] case final detail?)
          if ((_endedCount[platform] ?? 0) == 0 &&
              AppBuildStatusFormatter.stageStates(detail).first ==
                  AppBuildStageState.active &&
              now.difference(detail.build.createdAt) >= duration)
            detail.build,
    ];
  }

  AppBuildStepLine? _activeLine(AppPlatform platform) {
    final detail = _details[platform];
    if (detail == null) {
      return AppBuildStepLine(
        platform: platform,
        state: AppBuildStageState.active,
        text: AppBuildStatusFormatter.stageText(
          platform,
          0,
          AppBuildStageState.active,
        ),
      );
    }
    final stage = _endedCount[platform] ?? 0;
    if (stage >= AppBuildStatusFormatter.stageCount) return null;
    final state = AppBuildStatusFormatter.stageStates(detail)[stage];
    if (state != AppBuildStageState.active) return null;
    return _line(platform, stage, state, detail);
  }

  AppBuildStepLine _line(
    AppPlatform platform,
    int stage,
    AppBuildStageState state,
    AppBuildDetail detail,
  ) {
    final active = state == AppBuildStageState.active;
    final ends = _endedAt.putIfAbsent(platform, () => {});
    final startedAt =
        AppBuildStatusFormatter.stageStartedAt(detail, stage) ??
        ends[stage - 1];
    final endedAt = active
        ? null
        : AppBuildStatusFormatter.stageEndedAt(detail, stage) ?? clock();
    if (endedAt != null) ends[stage] = endedAt;
    return AppBuildStepLine(
      platform: platform,
      state: state,
      text: AppBuildStatusFormatter.stageText(
        platform,
        stage,
        state,
        cancelled: detail.build.status == AppBuildStatus.cancelled,
      ),
      startedAt: startedAt,
      endedAt: endedAt,
    );
  }
}

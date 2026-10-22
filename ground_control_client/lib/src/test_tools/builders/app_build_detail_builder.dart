import 'package:ground_control_client/ground_control_client.dart';

import 'app_build_summary_builder.dart';

/// Builds an [AppBuildDetail]. The default is a succeeded build with its
/// build and publish steps done.
class AppBuildDetailBuilder {
  AppBuildSummary _build;
  List<AppBuildStepInfo> _steps;

  AppBuildDetailBuilder()
    : _build = AppBuildSummaryBuilder().build(),
      _steps = [
        _step(0, 'Build', AppBuildStepStatus.succeeded),
        _step(1, 'Publish', AppBuildStepStatus.succeeded),
      ];

  AppBuildDetailBuilder withPublishRunning() {
    _build = AppBuildSummaryBuilder().withRunning().build();
    _steps = [
      _step(0, 'Build', AppBuildStepStatus.succeeded),
      _step(1, 'Publish', AppBuildStepStatus.running),
    ];
    return this;
  }

  AppBuildDetailBuilder withPublishFailed() {
    _build = AppBuildSummaryBuilder()
        .withFailed('Publishing failed with exit code 1')
        .build();
    _steps = [
      _step(0, 'Build', AppBuildStepStatus.succeeded),
      _step(1, 'Publish', AppBuildStepStatus.failed),
    ];
    return this;
  }

  AppBuildDetailBuilder withBuild(AppBuildSummary build) {
    _build = build;
    return this;
  }

  AppBuildDetailBuilder withSteps(List<AppBuildStepInfo> steps) {
    _steps = steps;
    return this;
  }

  AppBuildDetail build() {
    return AppBuildDetail(build: _build, steps: _steps);
  }

  static AppBuildStepInfo _step(
    int index,
    String name,
    AppBuildStepStatus status,
  ) {
    final now = DateTime.now();
    final started = status == AppBuildStepStatus.pending
        ? null
        : now.subtract(Duration(minutes: 10 - index * 4));
    final ended = status == AppBuildStepStatus.running || started == null
        ? null
        : started.add(const Duration(minutes: 3));
    return AppBuildStepInfo(
      index: index,
      name: name,
      status: status,
      startedAt: started,
      endedAt: ended,
    );
  }
}

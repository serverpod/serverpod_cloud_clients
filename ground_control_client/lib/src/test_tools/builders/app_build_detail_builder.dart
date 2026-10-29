import 'package:ground_control_client/ground_control_client.dart';

import 'app_build_summary_builder.dart';

class AppBuildDetailBuilder {
  AppBuildSummary _build = AppBuildSummaryBuilder().build();
  List<AppBuildStepInfo> _steps = [
    AppBuildStepInfo(
      index: 0,
      name: 'Build',
      status: AppBuildStepStatus.succeeded,
      startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      endedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

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
}

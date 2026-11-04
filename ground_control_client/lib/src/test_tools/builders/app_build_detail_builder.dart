import 'package:ground_control_client/ground_control_client.dart';

import 'app_build_step_info_builder.dart';
import 'app_build_summary_builder.dart';

class AppBuildDetailBuilder {
  AppBuildSummary _build = AppBuildSummaryBuilder().build();
  List<AppBuildStepInfo> _steps = [AppBuildStepInfoBuilder().build()];

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

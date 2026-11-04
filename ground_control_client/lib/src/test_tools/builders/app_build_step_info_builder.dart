import 'package:ground_control_client/ground_control_client.dart';

class AppBuildStepInfoBuilder {
  int _index = 0;
  String _name = 'Build';
  AppBuildStage _stage = AppBuildStage.build;
  AppBuildStepStatus _status = AppBuildStepStatus.succeeded;
  DateTime? _startedAt = DateTime.now().subtract(const Duration(minutes: 10));
  DateTime? _endedAt = DateTime.now().subtract(const Duration(minutes: 2));

  AppBuildStepInfoBuilder withIndex(int index) {
    _index = index;
    return this;
  }

  AppBuildStepInfoBuilder withName(String name) {
    _name = name;
    return this;
  }

  AppBuildStepInfoBuilder withStage(AppBuildStage stage) {
    _stage = stage;
    return this;
  }

  AppBuildStepInfoBuilder withStatus(AppBuildStepStatus status) {
    _status = status;
    if (status == AppBuildStepStatus.pending ||
        status == AppBuildStepStatus.running) {
      _endedAt = null;
    }
    return this;
  }

  AppBuildStepInfoBuilder withStartedAt(DateTime? startedAt) {
    _startedAt = startedAt;
    return this;
  }

  AppBuildStepInfoBuilder withEndedAt(DateTime? endedAt) {
    _endedAt = endedAt;
    return this;
  }

  AppBuildStepInfo build() {
    return AppBuildStepInfo(
      index: _index,
      name: _name,
      stage: _stage,
      status: _status,
      startedAt: _startedAt,
      endedAt: _endedAt,
    );
  }
}

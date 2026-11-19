import 'package:ground_control_client/ground_control_client.dart';

class AppBuildStepLogBuilder {
  int _index = 0;
  String _name = 'Build';
  AppBuildStage _stage = AppBuildStage.build;
  AppBuildStepStatus _status = AppBuildStepStatus.succeeded;
  String? _log = 'Built the release';

  AppBuildStepLogBuilder withIndex(int index) {
    _index = index;
    return this;
  }

  AppBuildStepLogBuilder withName(String name) {
    _name = name;
    return this;
  }

  AppBuildStepLogBuilder withStage(AppBuildStage stage) {
    _stage = stage;
    return this;
  }

  AppBuildStepLogBuilder withStatus(AppBuildStepStatus status) {
    _status = status;
    return this;
  }

  AppBuildStepLogBuilder withLog(String? log) {
    _log = log;
    return this;
  }

  AppBuildStepLog build() {
    return AppBuildStepLog(
      index: _index,
      name: _name,
      stage: _stage,
      status: _status,
      log: _log,
    );
  }
}

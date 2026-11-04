import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildStepInfo, SerializableModel;

/// The log of one step of an app build.
class AppBuildStepLog implements SerializableModel {
  const AppBuildStepLog({required this.step, this.log});

  /// The step the log belongs to.
  final AppBuildStepInfo step;

  /// The step's log. Null when the step was skipped or never started, or
  /// when the build service has discarded the log.
  final String? log;

  @override
  Map<String, Object?> toJson() {
    return {...step.toJson(), 'log': log};
  }
}

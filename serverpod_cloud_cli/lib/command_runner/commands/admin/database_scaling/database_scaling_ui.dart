import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class ReconcileDatabaseScalingTextUi extends OutputWidget {
  final bool apply;
  final int projectCount;

  const ReconcileDatabaseScalingTextUi({
    required this.apply,
    required this.projectCount,
  });

  @override
  OutputWidget build(final OutputContext context) {
    final scope = projectCount == 0
        ? 'all databases'
        : '$projectCount project(s)';

    final followUp = apply
        ? 'The pass runs on the server. See the server log for what it '
              'inspected, reset, and failed. Databases that are reset have '
              'their compute endpoint restarted.'
        : 'The pass runs on the server. See the server log for the drift it '
              'finds.';

    return SuccessTextWidget(
      apply
          ? 'Started reconciling the compute scaling of $scope.'
          : 'Started a dry run over $scope. Nothing will be changed.',
      followUp: followUp,
      newParagraph: true,
    );
  }
}

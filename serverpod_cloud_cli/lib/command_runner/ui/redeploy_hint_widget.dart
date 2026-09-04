import 'package:serverpod_cloud_cli/util/output/output.dart';

/// Renders a hint that changes take effect only after the next deploy.
class RedeployHintWidget extends OutputWidget {
  final String baseCommand;

  const RedeployHintWidget({required this.baseCommand});

  @override
  OutputWidget build(OutputContext context) {
    return CommandHintTextWidget(
      'The changes will not take effect until your server is re-deployed.',
      command: '$baseCommand deploy',
    );
  }
}

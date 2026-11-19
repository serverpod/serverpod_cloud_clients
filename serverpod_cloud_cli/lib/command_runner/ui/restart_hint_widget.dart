import 'package:serverpod_cloud_cli/util/output/output.dart';

/// Renders a hint that changes take effect only after the next restart.
class RestartHintWidget extends OutputWidget {
  final String baseCommand;

  const RestartHintWidget({required this.baseCommand});

  @override
  OutputWidget build(OutputContext context) {
    return CommandHintTextWidget(
      'The changes will not take effect until your server is restarted.',
      command: '$baseCommand deploy --restart',
    );
  }
}

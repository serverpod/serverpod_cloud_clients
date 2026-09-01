import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class RedeployTextUi extends OutputWidget {
  const RedeployTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'Redeployment triggered for project: ${result['projectId']}',
      newParagraph: true,
    );
  }
}

import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class BuildSecretSetTextUi extends OutputWidget {
  const BuildSecretSetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'Successfully set build secret: ${result['name']}.',
    );
  }
}

class BuildSecretUnsetTextUi extends OutputWidget {
  const BuildSecretUnsetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'Successfully removed build secret: ${result['name']}.',
    );
  }
}

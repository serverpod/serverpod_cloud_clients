import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class VersionTextUi extends OutputWidget {
  const VersionTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final version = context.get<String>();
    return InfoTextWidget('Serverpod Cloud CLI version: $version');
  }
}

import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class SettingsShowTextUi extends OutputWidget {
  const SettingsShowTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final settings = context.get<Map<String, Object?>>();
    return ListTextWidget([
      'Analytics = ${settings['analytics'] ?? 'not set'}',
    ], title: 'Local settings');
  }
}

class SettingsSetTextUi extends OutputWidget {
  const SettingsSetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final settings = context.get<Map<String, Object?>>();
    return InfoTextWidget('Analytics set to "${settings['analytics']}".');
  }
}

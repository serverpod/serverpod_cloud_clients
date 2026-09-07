import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class SettingsSetTextUi extends OutputWidget {
  const SettingsSetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget('Set ${result['name']} to "${result['value']}".');
  }
}

class SettingsUnsetTextUi extends OutputWidget {
  const SettingsUnsetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget('Unset ${result['name']}.');
  }
}

class SettingsListUi extends OutputWidget {
  const SettingsListUi();

  @override
  OutputWidget build(final OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<Map<String, Object?>>(
        columns: [
          TableColumnFormatter.forKey('Name', key: 'name'),
          TableColumnFormatter.forElement(
            'Value',
            getter: (final row) => row['value'] ?? 'not set',
          ),
        ],
        utc: false,
      ),
    );
  }
}

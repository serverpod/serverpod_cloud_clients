import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

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

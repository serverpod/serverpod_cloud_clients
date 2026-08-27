import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class VariableListTextUi extends OutputWidget {
  const VariableListTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<Map<String, Object?>>(
        columns: [
          TableColumnFormatter.forKey('Name', key: 'name'),
          TableColumnFormatter.forKey('Value', key: 'value'),
        ],
        utc: false,
      ),
    );
  }
}

import 'package:serverpod_cloud_cli/util/output/output.dart';

class VariableListUi extends OutputWidget {
  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(textOutputUi: const _VariableListTextUi());
  }
}

class _VariableListTextUi extends OutputWidget {
  const _VariableListTextUi();

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

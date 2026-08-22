import 'package:ground_control_client/ground_control_client.dart';
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
      formatter: TextTableOutputFormatter<EnvironmentVariable>(
        columns: [
          TableColumnFormatter.forElement(
            'Name',
            getter: (final variable) => variable.name,
          ),
          TableColumnFormatter.forElement(
            'Value',
            getter: (final variable) => variable.value,
          ),
        ],
        utc: false,
      ),
    );
  }
}

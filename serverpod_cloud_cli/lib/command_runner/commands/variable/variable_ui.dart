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

class VariableSetTextUi extends OutputWidget {
  final String baseCommand;

  const VariableSetTextUi({required this.baseCommand});

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final name = result['name'];
    final isSecret = result['secret'] == true;
    return OutputWidgetList([
      SuccessTextWidget(
        isSecret
            ? 'Successfully set secret: $name.'
            : 'Successfully set environment variable: $name.',
      ),
      CommandHintTextWidget(
        'The changes will not take effect until your server is re-deployed.',
        command: '$baseCommand deploy',
      ),
    ]);
  }
}

class VariableUnsetTextUi extends OutputWidget {
  final String baseCommand;

  const VariableUnsetTextUi({required this.baseCommand});

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final name = result['name'];
    final isSecret = result['secret'] == true;
    return OutputWidgetList([
      SuccessTextWidget(
        isSecret
            ? 'Successfully removed secret: $name.'
            : 'Successfully removed environment variable: $name.',
      ),
      CommandHintTextWidget(
        'The changes will not take effect until your server is re-deployed.',
        command: '$baseCommand deploy',
      ),
    ]);
  }
}

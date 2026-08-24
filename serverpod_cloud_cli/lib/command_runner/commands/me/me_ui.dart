import 'package:ground_control_client/ground_control_client.dart' show User;
import 'package:serverpod_cloud_cli/util/output/output.dart';

class MeUi extends OutputWidget {
  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(textOutputUi: const _MeTextUi());
  }
}

class _MeTextUi extends OutputWidget {
  const _MeTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<User>(
        columns: [
          TableColumnFormatter.forElement(
            'Email',
            getter: (final user) => user.email,
          ),
        ],
        utc: false,
      ),
    );
  }
}

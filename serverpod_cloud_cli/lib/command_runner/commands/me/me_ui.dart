import 'package:ground_control_client/ground_control_client.dart' show User;
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class MeTextUi extends OutputWidget {
  const MeTextUi();

  @override
  OutputWidget build(OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<User>(
        columns: [
          TableColumnFormatter.forElement(
            'Email',
            getter: (user) => user.email,
          ),
        ],
        utc: false,
      ),
    );
  }
}

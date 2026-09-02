import 'package:ground_control_client/ground_control_client.dart' show User;
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class ProjectUserListTextUi extends OutputWidget {
  final String projectId;

  ProjectUserListTextUi({required this.projectId});

  @override
  OutputWidget build(OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<User>(
        columns: [
          TableColumnFormatter.forElement('User', getter: (user) => user.email),
          TableColumnFormatter.forElement(
            'Project',
            getter: (user) => projectId,
          ),
          TableColumnFormatter.forElement(
            'Project roles',
            getter: (user) =>
                user.memberships
                    ?.map((membership) => membership.role?.name)
                    .nonNulls
                    .toList() ??
                const <String>[],
          ),
        ],
        utc: false,
      ),
    );
  }
}

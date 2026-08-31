import 'package:ground_control_client/ground_control_client.dart' show User;
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class ProjectUserListTextUi extends OutputWidget {
  final String projectId;

  ProjectUserListTextUi({required this.projectId});

  @override
  OutputWidget build(final OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<User>(
        columns: [
          TableColumnFormatter.forElement(
            'User',
            getter: (final user) => user.email,
          ),
          TableColumnFormatter.forElement(
            'Project',
            getter: (final user) => projectId,
          ),
          TableColumnFormatter.forElement(
            'Project roles',
            getter: (final user) =>
                user.memberships
                    ?.map((final membership) => membership.role?.name)
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

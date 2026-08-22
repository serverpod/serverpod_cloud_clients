import 'package:ground_control_client/ground_control_client.dart' show User;
import 'package:serverpod_cloud_cli/util/output/output.dart';

class ProjectUserListUi extends OutputWidget {
  final String projectId;

  ProjectUserListUi({required this.projectId});

  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(
      textOutputUi: _ProjectUserListTextUi(projectId: projectId),
    );
  }
}

class _ProjectUserListTextUi extends OutputWidget {
  final String projectId;

  _ProjectUserListTextUi({required this.projectId});

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

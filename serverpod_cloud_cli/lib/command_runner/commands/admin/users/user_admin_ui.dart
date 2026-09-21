import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class AdminUserListTextUi extends OutputWidget {
  final bool utc;

  AdminUserListTextUi({required this.utc});

  @override
  OutputWidget build(OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter(
        columns: [
          TableColumnFormatter.forKey('User', key: 'email'),
          TableColumnFormatter.forKey('Account status', key: 'accountStatus'),
          TableColumnFormatter.forTimestampKey('Created at', key: 'createdAt'),
          TableColumnFormatter.forTimestampKey(
            'Archived at',
            key: 'archivedAt',
          ),
          TableColumnFormatter.forKey(
            'Subscribed Plans',
            key: 'subscribedPlans',
          ),
        ],
        utc: utc,
      ),
    );
  }
}

class AdminInviteUserTextUi extends OutputWidget {
  const AdminInviteUserTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return const SuccessTextWidget(
      'User invited to Serverpod Cloud.',
      newParagraph: true,
    );
  }
}

class AdminUserAttachTextUi extends OutputWidget {
  const AdminUserAttachTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final roles = result['roles'];
    final roleNames = roles is List ? roles.join(', ') : '';
    return SuccessTextWidget(
      'User attached to the project with roles: $roleNames.',
      newParagraph: true,
    );
  }
}

class AdminUserDetachTextUi extends OutputWidget {
  final bool unassignAllRoles;

  const AdminUserDetachTextUi({required this.unassignAllRoles});

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final unassigned = result['unassigned'];
    final names = unassigned is List
        ? unassigned.cast<String>()
        : const <String>[];

    if (names.isEmpty) {
      return InfoTextWidget(
        unassignAllRoles
            ? 'The user has no access roles to detach from the project.'
            : 'The user does not have any of the specified project roles.',
      );
    }

    final message = unassignAllRoles
        ? 'Detached all access roles of the user from the project: ${names.join(', ')}'
        : 'Detached access roles of the user from the project: ${names.join(', ')}';

    return SuccessTextWidget(message, newParagraph: true);
  }
}

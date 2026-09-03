import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class AdminUserListTextUi extends OutputWidget {
  final bool utc;

  AdminUserListTextUi({required this.utc});

  @override
  OutputWidget build(OutputContext context) {
    final timezoneName = utc ? 'UTC' : 'local';
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter(
        columns: [
          TableColumnFormatter.forKey('User', key: 'email'),
          TableColumnFormatter.forKey('Account status', key: 'accountStatus'),
          TableColumnFormatter.forKey(
            'Created at ($timezoneName)',
            key: 'createdAt',
          ),
          TableColumnFormatter.forKey(
            'Archived at ($timezoneName)',
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

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

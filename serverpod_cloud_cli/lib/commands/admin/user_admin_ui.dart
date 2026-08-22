import 'package:serverpod_cloud_cli/util/output/output.dart';

class AdminUserListUi extends OutputWidget {
  final bool utc;

  AdminUserListUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(textOutputUi: _AdminUserListTextUi(utc: utc));
  }
}

class _AdminUserListTextUi extends OutputWidget {
  final bool utc;

  _AdminUserListTextUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
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

import 'package:ground_control_client/ground_control_client.dart'
    show AuthTokenInfo;
import 'package:serverpod_cloud_cli/util/output/output.dart';

class AuthSessionListUi extends OutputWidget {
  final bool utc;

  AuthSessionListUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(textOutputUi: _AuthSessionListTextUi(utc: utc));
  }
}

class _AuthSessionListTextUi extends OutputWidget {
  final bool utc;

  _AuthSessionListTextUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<AuthTokenInfo>(
        columns: [
          TableColumnFormatter.forElement(
            'Token Id',
            getter: (final session) => session.tokenId,
          ),
          TableColumnFormatter.forElement(
            'Method',
            getter: (final session) => session.method,
          ),
          TableColumnFormatter.forElement(
            'Created',
            getter: (final session) => session.createdAt,
          ),
          TableColumnFormatter.forElement(
            'Last Used',
            getter: (final session) => session.lastUsedAt,
          ),
          TableColumnFormatter.forElement(
            'Expires',
            getter: (final session) => session.expiresAt,
          ),
          TableColumnFormatter.forElement(
            'TTL on non-use',
            getter: (final session) => session.expireAfterUnusedFor,
          ),
        ],
        utc: utc,
      ),
    );
  }
}

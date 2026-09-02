import 'package:ground_control_client/ground_control_client.dart'
    show AuthTokenInfo;
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class AuthSessionListTextUi extends OutputWidget {
  final bool utc;

  AuthSessionListTextUi({required this.utc});

  @override
  OutputWidget build(OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<AuthTokenInfo>(
        columns: [
          TableColumnFormatter.forElement(
            'Token Id',
            getter: (session) => session.tokenId,
          ),
          TableColumnFormatter.forElement(
            'Method',
            getter: (session) => session.method,
          ),
          TableColumnFormatter.forElement(
            'Created',
            getter: (session) => session.createdAt,
          ),
          TableColumnFormatter.forElement(
            'Last Used',
            getter: (session) => session.lastUsedAt,
          ),
          TableColumnFormatter.forElement(
            'Expires',
            getter: (session) => session.expiresAt,
          ),
          TableColumnFormatter.forElement(
            'TTL on non-use',
            getter: (session) => session.expireAfterUnusedFor,
          ),
        ],
        utc: utc,
      ),
    );
  }
}

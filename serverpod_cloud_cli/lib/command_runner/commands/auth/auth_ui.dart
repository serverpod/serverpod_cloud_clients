import 'package:ground_control_client/ground_control_client.dart'
    show AuthTokenInfo;
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class AuthSessionListTextUi extends OutputWidget {
  final bool utc;

  AuthSessionListTextUi({required this.utc});

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

class AuthCreateTokenTextUi extends OutputWidget {
  final String baseCommand;

  const AuthCreateTokenTextUi({required this.baseCommand});

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return OutputWidgetList([
      SuccessTextWidget(
        'Successfully created an API token.',
        newParagraph: true,
        followUp:
            '''
Use the --token option or the SERVERPOD_CLOUD_TOKEN environment variable to
authenticate with this token in $baseCommand commands.''',
      ),
      InfoTextWidget(
        'The token is only visible once:\n${result['token']}\n',
        newParagraph: true,
      ),
    ]);
  }
}

class AuthLogoutTextUi extends OutputWidget {
  const AuthLogoutTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    if (result['hadCredentials'] == false) {
      return const InfoTextWidget(
        'No stored Serverpod Cloud credentials found.',
      );
    }
    if (result['currentSessionLoggedOut'] == false) {
      return const SuccessTextWidget(
        'Successfully logged out the selected sessions.',
      );
    }
    return const SuccessTextWidget(
      'Successfully logged out from Serverpod cloud.',
    );
  }
}

class AuthRevokeTokenTextUi extends OutputWidget {
  const AuthRevokeTokenTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    if (result['currentSessionRevoked'] == false) {
      return const SuccessTextWidget(
        'Successfully logged out the selected sessions.',
      );
    }
    return const SuccessTextWidget(
      'Successfully logged out from Serverpod cloud.',
    );
  }
}

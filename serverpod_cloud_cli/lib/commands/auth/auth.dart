import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/output/command_output.dart';

class AuthSessionListItem {
  final String tokenId;
  final String method;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final DateTime? expiresAt;
  final Duration? expireAfterUnusedFor;

  const AuthSessionListItem({
    required this.tokenId,
    required this.method,
    required this.createdAt,
    this.lastUsedAt,
    this.expiresAt,
    this.expireAfterUnusedFor,
  });
}

abstract class Auth {
  static Future<void> createApiToken(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    final DateTime? expiresAt,
    final Duration? expiresAfter,
  }) async {
    final authSuccess = await cloudApiClient.authWithAuth.createCliToken(
      expiresAt: expiresAt,
      expiresAfter: expiresAfter,
    );
    logger.success(
      'Successfully created an API token.',
      newParagraph: true,
      followUp: '''
Use the --token option or the SERVERPOD_CLOUD_TOKEN environment variable to
authenticate with this token in scloud commands.''',
    );
    logger.info(
      'The token is only visible once:\n${authSuccess.token}\n',
      newParagraph: true,
    );
  }

  static Future<void> listAuthSessions(
    final Client cloudApiClient, {
    required final CommandOutput output,
  }) async {
    final tokenInfos = await cloudApiClient.authWithAuth.listAuthSessions();
    final items = tokenInfos
        .map(
          (final tokenInfo) => AuthSessionListItem(
            tokenId: tokenInfo.tokenId,
            method: tokenInfo.method,
            createdAt: tokenInfo.createdAt,
            lastUsedAt: tokenInfo.lastUsedAt,
            expiresAt: tokenInfo.expiresAt,
            expireAfterUnusedFor: tokenInfo.expireAfterUnusedFor,
          ),
        )
        .toList();

    output.outputList(
      items,
      OutputSchemaObject<AuthSessionListItem>([
        OutputSchemaField(
          name: 'tokenId',
          label: 'Token Id',
          value: (final item) => item.tokenId,
        ),
        OutputSchemaField(
          name: 'method',
          label: 'Method',
          value: (final item) => item.method,
        ),
        OutputSchemaField(
          name: 'createdAt',
          label: 'Created',
          value: (final item) => item.createdAt,
        ),
        OutputSchemaField(
          name: 'lastUsedAt',
          label: 'Last Used',
          value: (final item) => item.lastUsedAt,
        ),
        OutputSchemaField(
          name: 'expiresAt',
          label: 'Expires',
          value: (final item) => item.expiresAt,
        ),
        OutputSchemaField(
          name: 'expireAfterUnusedFor',
          label: 'TTL on non-use',
          value: (final item) => item.expireAfterUnusedFor,
        ),
      ]),
    );
  }
}

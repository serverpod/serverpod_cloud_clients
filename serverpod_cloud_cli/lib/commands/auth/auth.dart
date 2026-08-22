import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

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

  static Future<List<AuthTokenInfo>> listAuthSessionsOperation(
    final Client cloudApiClient,
  ) {
    return cloudApiClient.authWithAuth.listAuthSessions();
  }
}

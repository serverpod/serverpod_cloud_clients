import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

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

  static Future<void> revokeToken(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String tokenId,
    required final String localStoragePath,
  }) async {
    final bool currentSessionRevoked;
    try {
      currentSessionRevoked = await cloudApiClient.authWithAuth.logoutDevice(
        authTokenId: tokenId,
      );
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to revoke token');
    }

    if (!currentSessionRevoked) {
      logger.success('Successfully logged out the selected sessions.');
      return;
    }

    try {
      await ResourceManager.removeServerpodCloudAuthData(
        localStoragePath: localStoragePath,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to remove stored credentials',
        'Please remove these manually. '
            'They should be located in $localStoragePath.',
      );
    }

    logger.success('Successfully logged out from Serverpod cloud.');
  }
}

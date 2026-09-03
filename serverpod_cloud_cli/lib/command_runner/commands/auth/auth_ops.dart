import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class Auth {
  static Future<Map<String, Object?>> createApiToken(
    final Client cloudApiClient, {
    final DateTime? expiresAt,
    final Duration? expiresAfter,
  }) async {
    final authSuccess = await cloudApiClient.authWithAuth.createCliToken(
      expiresAt: expiresAt,
      expiresAfter: expiresAfter,
    );
    return {'token': authSuccess.token};
  }

  static Future<List<AuthTokenInfo>> listAuthSessionsOperation(
    Client cloudApiClient,
  ) {
    return cloudApiClient.authWithAuth.listAuthSessions();
  }

  static Future<Map<String, Object?>> revokeToken(
    final Client cloudApiClient, {
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

    if (currentSessionRevoked) {
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
    }

    return {'currentSessionRevoked': currentSessionRevoked};
  }

  static Future<Map<String, Object?>> logout(
    final Client cloudApiClient, {
    required final String localStoragePath,
    required final List<String> tokenIds,
    required final bool all,
  }) async {
    final currentSessionLoggedOut = await _logoutDevices(
      cloudApiClient,
      tokenIds,
      all,
    );

    if (currentSessionLoggedOut) {
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
    }

    return {'currentSessionLoggedOut': currentSessionLoggedOut};
  }

  static Future<bool> _logoutDevices(
    final Client cloudClient,
    final List<String> tokenIds,
    final bool all,
  ) async {
    if (tokenIds.isNotEmpty) {
      var currentSessionLoggedOut = false;
      for (final tokenId in tokenIds) {
        currentSessionLoggedOut |= await cloudClient.authWithAuth.logoutDevice(
          authTokenId: tokenId,
        );
      }
      return currentSessionLoggedOut;
    }

    if (all) {
      await cloudClient.authWithAuth.logoutAll();
    } else {
      try {
        await cloudClient.authWithAuth.logoutDevice();
      } on Exception catch (_) {
        // continue even if server logout fails
      }
    }
    return true;
  }
}

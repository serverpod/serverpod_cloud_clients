import 'dart:async';
import 'dart:convert';

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';

abstract final class BuildTokenProvider {
  static FutureOr<String?> Function() build({
    required final String? authTokenOverride,
    required final String localStoragePath,
    required final CommandLogger logger,
  }) {
    return switch (authTokenOverride) {
      final String token => _maybeFormatToken(token),
      null => _getStoredToken(localStoragePath, logger),
    };
  }

  static String Function() _maybeFormatToken(final String token) {
    return () {
      if (!token.startsWith('sas')) {
        return token;
      }

      final tokenParts = token.split(':');
      if (tokenParts.length != 3) {
        return token;
      }

      final sessionKeyPrefix = tokenParts[0];
      final serverSideSessionId = tokenParts[1];
      final secret = tokenParts[2];

      return base64Url.encode([
        ...utf8.encode(sessionKeyPrefix),
        ...base64Url.decode(serverSideSessionId),
        ...base64Url.decode(secret),
      ]);
    };
  }

  static FutureOr<String?> Function() _getStoredToken(
    final String localStoragePath,
    final CommandLogger logger,
  ) {
    return () async {
      final rawToken = await ResourceManager.tryFetchServerpodCloudAuthData(
        localStoragePath: localStoragePath,
        logger: logger,
      );

      if (rawToken == null) {
        return null;
      }

      final formattedToken = _maybeFormatToken(rawToken.token)();
      if (formattedToken != rawToken.token) {
        await ResourceManager.storeServerpodCloudAuthData(
          authData: ServerpodCloudAuthData(formattedToken),
          localStoragePath: localStoragePath,
        );
      }

      return formattedToken;
    };
  }
}

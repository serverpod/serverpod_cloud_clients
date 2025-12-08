import 'dart:convert';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/helpers/build_token_provider.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../../test_utils/test_command_logger.dart' show TestCommandLogger;

void main() {
  late String testFolderPath;
  late TestCommandLogger logger;

  setUp(() async {
    await d.dir('test_storage').create();
    testFolderPath = p.join(d.sandbox, 'test_storage');
    logger = TestCommandLogger();
  });

  test(
      'Given token builder built with an override from legacy token when '
      'fetching the token '
      'then the token is formatted correctly', () async {
    final legacyKeyResult = _buildLegacySessionKeyResult();
    final legacyToken = legacyKeyResult.sessionKey;

    final tokenProvider = BuildTokenProvider.build(
      authTokenOverride: legacyToken,
      localStoragePath: testFolderPath,
      logger: logger,
    );

    final tokenProviderResult = await tokenProvider();

    expect(tokenProviderResult, isNotNull);
    expect(tokenProviderResult, isNot(equals(legacyToken)));

    final validated = _tryParseServerSideSessionToken(tokenProviderResult!);
    expect(validated, isNotNull);
    expect(validated?.serverSideSessionId, legacyKeyResult.authSessionId);
    expect(validated?.secret, legacyKeyResult.secret);
  });

  test(
      'Given token builder built with an override from a non-legacy token '
      'when fetching the token '
      'then the token is returned as is unchanged', () async {
    const nonLegacyToken = 'not-a-legacy-token-format';

    final tokenProvider = BuildTokenProvider.build(
      authTokenOverride: nonLegacyToken,
      localStoragePath: testFolderPath,
      logger: logger,
    );

    final tokenProviderResult = await tokenProvider();

    expect(tokenProviderResult, equals(nonLegacyToken));
  });

  group(
      'Given token builder built with no override and a legacy token stored in the local storage when fetching the token',
      () {
    late String? tokenProviderResult;
    late SessionKeyResult legacyKeyResult;

    setUp(() async {
      legacyKeyResult = _buildLegacySessionKeyResult();

      await ResourceManager.storeServerpodCloudAuthData(
        authData: ServerpodCloudAuthData(legacyKeyResult.sessionKey),
        localStoragePath: testFolderPath,
      );

      final tokenProvider = BuildTokenProvider.build(
        authTokenOverride: null,
        localStoragePath: testFolderPath,
        logger: logger,
      );

      tokenProviderResult = await tokenProvider();
    });

    test('then the token is formatted correctly', () async {
      expect(tokenProviderResult, isNotNull);
      expect(tokenProviderResult, isNot(equals(legacyKeyResult.sessionKey)));

      final validated = _tryParseServerSideSessionToken(tokenProviderResult!);
      expect(validated, isNotNull);
      expect(validated?.serverSideSessionId, legacyKeyResult.authSessionId);
      expect(validated?.secret, legacyKeyResult.secret);
    });

    test('then the stored token is updated to the new format', () async {
      final storedData = await ResourceManager.tryFetchServerpodCloudAuthData(
        localStoragePath: testFolderPath,
        logger: logger,
      );

      expect(storedData, isNotNull);
      expect(storedData!.token, isNot(equals(legacyKeyResult.sessionKey)));

      final validated = _tryParseServerSideSessionToken(storedData.token);
      expect(validated, isNotNull);
      expect(validated?.serverSideSessionId, legacyKeyResult.authSessionId);
      expect(validated?.secret, legacyKeyResult.secret);
    });
  });

  group(
      'Given a token does not conform to legacy format that is stored in the local storage when building a token provider',
      () {
    late String? tokenProviderResult;
    const nonLegacyToken = 'not-a-legacy-token-format';

    setUp(() async {
      await ResourceManager.storeServerpodCloudAuthData(
        authData: ServerpodCloudAuthData(nonLegacyToken),
        localStoragePath: testFolderPath,
      );

      final tokenProvider = BuildTokenProvider.build(
        authTokenOverride: null,
        localStoragePath: testFolderPath,
        logger: logger,
      );

      tokenProviderResult = await tokenProvider();
    });

    test('then the token is returned as is', () async {
      expect(tokenProviderResult, equals(nonLegacyToken));
    });

    test('then the stored token is not updated', () async {
      final storedData = await ResourceManager.tryFetchServerpodCloudAuthData(
        localStoragePath: testFolderPath,
        logger: logger,
      );

      expect(storedData, isNotNull);
      expect(storedData!.token, equals(nonLegacyToken));
    });
  });
}

typedef SessionKeyResult = ({
  String sessionKey,
  UuidValue authSessionId,
  Uint8List secret,
});

SessionKeyResult _buildLegacySessionKeyResult() {
// This is how we built the session key in 3.0.0-alpha.2
// Source: https://github.com/serverpod/serverpod/blob/8640fbc1c6400839e5274309cc039193d58fb700/modules/new_serverpod_auth/serverpod_auth_core/serverpod_auth_core_server/lib/src/session/business/session_key.dart#L12-L20
  String buildLegacySessionKey({
    required final UuidValue authSessionId,
    required final Uint8List secret,
  }) {
    const sessionKeyPrefix = 'sas';
    return '$sessionKeyPrefix:${base64Url.encode(authSessionId.toBytes())}:${base64Url.encode(secret)}';
  }

  final authSessionId = Uuid().v4obj();
  final secret = utf8.encode('my-secret');

  return (
    sessionKey:
        buildLegacySessionKey(authSessionId: authSessionId, secret: secret),
    authSessionId: authSessionId,
    secret: secret,
  );
}

typedef SessionKeyData = ({UuidValue serverSideSessionId, Uint8List secret});

/// This is how we parse server side session tokens in 3.0.0-rc.4
/// Minor modification to remove dependency on the Session class.
/// Source: https://github.com/serverpod/serverpod/blob/a9069564a0ba14054963988deac2f12623ce5e1a/modules/new_serverpod_auth/serverpod_auth_core/serverpod_auth_core_server/lib/src/session/business/server_side_sessions_token.dart#L29-L69
SessionKeyData? _tryParseServerSideSessionToken(
  // final Session session,
  final String key,
) {
  final sessionKeyPrefix = utf8.encode('sas');
  final sessionKeyPrefixBase64 = base64Url.encode(sessionKeyPrefix);
  try {
    if (!key.startsWith(sessionKeyPrefixBase64)) {
      return null;
    }

    final decoded = base64Url.decode(key);

    final serverSideSessionId = UuidValue.fromByteList(
      Uint8List.sublistView(
        decoded,
        sessionKeyPrefix.lengthInBytes,
        sessionKeyPrefix.lengthInBytes + 16,
      ),
    )..validate();

    final secret = Uint8List.sublistView(
      decoded,
      sessionKeyPrefix.lengthInBytes + 16,
    );

    return (serverSideSessionId: serverSideSessionId, secret: secret);
  } catch (_, __) {
    // session.log(
    //   'Failed to parse session key: "$key"',
    //   level: LogLevel.error,
    //   exception: e,
    //   stackTrace: stackTrace,
    // );

    return null;
  }
}

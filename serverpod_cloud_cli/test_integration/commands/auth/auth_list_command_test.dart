import 'dart:convert';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/auth/auth_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();

  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );

  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (globalCfg) => client,
    ),
  );

  tearDown(() {
    logger.clear();
  });

  test('Given auth list command when instantiated then requires login', () {
    expect(ListAuthSessionsCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given authenticated', () {
    setUpAll(() async {
      final createdAt = DateTime.utc(2026, 2, 11, 16, 50, 06);
      final sessions = [
        AuthTokenInfoBuilder()
            .withTokenId('tid-1')
            .withCreatedAt(createdAt)
            .withLastUsedAt(DateTime.utc(2026, 2, 12, 16, 50, 06))
            .withExpireAfterUnusedFor(Duration(days: 30))
            .build(),
        AuthTokenInfoBuilder()
            .withTokenId('tid-2')
            .withMethod('CLI token')
            .withCreatedAt(createdAt)
            .withExpiresAt(DateTime.utc(2026, 3, 11, 16, 50, 06))
            .build(),
      ];

      when(
        () => client.authWithAuth.listAuthSessions(),
      ).thenAnswer((_) async => sessions);
    });

    tearDownAll(() {
      reset(client.authWithAuth);
    });

    group('when executing auth list with --utc', () {
      late Future commandResult;
      setUp(() {
        commandResult = cli.run(['auth', 'list', '--utc']);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs table', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            'Token Id | Method    | Created              | Last Used            | Expires              | TTL on non-use',
            '---------+-----------+----------------------+----------------------+----------------------+---------------',
            'tid-1    | email     | 2026-02-11 16:50:06z | 2026-02-12 16:50:06z |                      | 30d           ',
            'tid-2    | CLI token | 2026-02-11 16:50:06z |                      | 2026-03-11 16:50:06z |               ',
          ]),
        );
      });
    });

    group('when executing auth list with --format json', () {
      late Future commandResult;
      setUp(() {
        commandResult = cli.run(['auth', 'list', '--format', 'json']);
      });

      test('then emits session objects', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(2));
        expect((payload[0] as Map)['tokenId'], 'tid-1');
        expect((payload[0] as Map)['issuer'], 'test-auth-issuer');
        expect((payload[0] as Map)['method'], 'email');
        expect((payload[0] as Map)['createdAt'], '2026-02-11T16:50:06.000Z');
        expect((payload[1] as Map)['tokenId'], 'tid-2');
        expect((payload[1] as Map)['method'], 'CLI token');
        expect((payload[1] as Map)['expiresAt'], '2026-03-11T16:50:06.000Z');
      });
    });

    group('when executing auth list with --format yaml', () {
      late Future commandResult;
      setUp(() {
        commandResult = cli.run(['auth', 'list', '--format', 'yaml']);
      });

      test('then emits session objects', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(2));
        expect((payload[0] as Map)['tokenId'], 'tid-1');
        expect((payload[0] as Map)['issuer'], 'test-auth-issuer');
        expect((payload[0] as Map)['method'], 'email');
        expect((payload[1] as Map)['tokenId'], 'tid-2');
        expect((payload[1] as Map)['method'], 'CLI token');
      });
    });
  });
}

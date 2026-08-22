import 'dart:async';
import 'dart:convert';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/me_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();

  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );

  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  tearDown(() async {
    logger.clear();
  });

  test('Given me command when instantiated then requires login', () {
    expect(CloudMeCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given authenticated user', () {
    group('when executing me command with subscription', () {
      late Future commandResult;
      setUp(() {
        when(() => client.users.readUser()).thenAnswer(
          (_) async => UserBuilder().withEmail('test@example.com').build(),
        );

        commandResult = cli.run(['me']);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs user information in table format', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls.map((final l) => l.line),
          containsAllInOrder([
            'Email           ',
            '----------------',
            contains('test@example.com'),
          ]),
        );
      });
    });

    group('when executing me command without subscription', () {
      late Future commandResult;
      setUp(() {
        when(() => client.users.readUser()).thenAnswer(
          (_) async => UserBuilder().withEmail('test@example.com').build(),
        );

        commandResult = cli.run(['me']);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs user information with no plan', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls.map((final l) => l.line),
          containsAllInOrder([
            'Email           ',
            '----------------',
            'test@example.com',
          ]),
        );
      });
    });

    group('when executing me command with --format json', () {
      late Future commandResult;
      setUp(() {
        when(() => client.users.readUser()).thenAnswer(
          (_) async => UserBuilder().withEmail('test@example.com').build(),
        );

        commandResult = cli.run(['me', '--format', 'json']);
      });

      test('then emits a user object', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(1));
        expect((payload.single as Map)['email'], 'test@example.com');
      });
    });

    group('when executing me command with --format yaml', () {
      late Future commandResult;
      setUp(() {
        when(() => client.users.readUser()).thenAnswer(
          (_) async => UserBuilder().withEmail('test@example.com').build(),
        );

        commandResult = cli.run(['me', '--format', 'yaml']);
      });

      test('then emits a user object', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(1));
        expect((payload.single as Map)['email'], 'test@example.com');
      });
    });
  });
}

import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/me_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

import '../../test_utils/command_logger_matchers.dart';
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

        when(() => client.plans.getSubscriptionInfo()).thenAnswer(
          (_) async => SubscriptionInfoBuilder()
              .withPlanDisplayName('Early Access')
              .build(),
        );

        commandResult = cli.run(['me']);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs user information in table format', () async {
        await commandResult;

        expect(logger.outputTableCalls, isNotEmpty);
        final call = logger.outputTableCalls.first;
        expect(call.headers, ['Email', 'Plan', 'Status']);
        expect(call.rows, hasLength(1));
        expect(call.rows.first[0], 'test@example.com');
        expect(call.rows.first[1], 'Early Access');
        expect(call.rows.first[2], startsWith('Trial until 20'));
      });
    });

    group('when executing me command without subscription', () {
      late Future commandResult;
      setUp(() {
        when(() => client.users.readUser()).thenAnswer(
          (_) async => UserBuilder().withEmail('test@example.com').build(),
        );

        when(
          () => client.plans.getSubscriptionInfo(),
        ).thenThrow(NoSubscriptionException(message: 'No subscription'));

        commandResult = cli.run(['me']);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs user information with no plan', () async {
        await commandResult;

        expect(logger.outputTableCalls, isNotEmpty);
        expect(
          logger.outputTableCalls.first,
          equalsOutputTableCall(
            headers: ['Email', 'Plan', 'Status'],
            rows: [
              ['test@example.com', 'No plan', ''],
            ],
          ),
        );
      });
    });
  });
}

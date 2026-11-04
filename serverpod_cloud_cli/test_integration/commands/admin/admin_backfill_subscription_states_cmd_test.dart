import 'dart:convert';

import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/billing/admin_billing_commands.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

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
    adminUserMode: true,
  );

  tearDown(() => logger.clear());

  test('Given the admin backfill-subscription-states command when'
      ' instantiated then it requires login', () {
    expect(
      AdminBackfillSubscriptionStatesCommand(logger: logger).requireLogin,
      isTrue,
    );
  });

  group('Given the backfill starts', () {
    setUp(() {
      when(
        () => client.adminBilling.backfillSubscriptionStates(),
      ).thenAnswer((final _) async {});
    });

    group('when running admin backfill-subscription-states', () {
      late Future commandResult;

      setUp(() {
        commandResult = cli.run(['admin', 'backfill-subscription-states']);
      });

      test('then the command completes', () async {
        await expectLater(commandResult, completes);
      });

      test('then the start is logged as a success', () async {
        await commandResult;

        expect(
          logger.successCalls,
          contains(
            equalsSuccessCall(
              message: 'Started the subscription state backfill.',
              followUp:
                  'The backfill runs on the server. See the server log for'
                  ' the counts of subscriptions inserted, unpaid, recorded'
                  ' before, and failed.',
              newParagraph: true,
            ),
          ),
        );
      });
    });

    group('when running admin backfill-subscription-states --format json', () {
      late Future commandResult;

      setUp(() {
        commandResult = cli.run([
          'admin',
          'backfill-subscription-states',
          '--format',
          'json',
        ]);
      });

      test('then the start is written as json', () async {
        await commandResult;

        expect(jsonDecode(logger.rawCalls.single.content), {'started': true});
        expect(logger.lineCalls, isEmpty);
      });
    });

    group('when running admin backfill-subscription-states --format yaml', () {
      late Future commandResult;

      setUp(() {
        commandResult = cli.run([
          'admin',
          'backfill-subscription-states',
          '--format',
          'yaml',
        ]);
      });

      test('then the start is written as yaml', () async {
        await commandResult;

        expect(yamlDecode(logger.rawCalls.single.content), {'started': true});
        expect(logger.lineCalls, isEmpty);
      });
    });
  });

  group('Given the backfill fails to start', () {
    setUp(() {
      when(
        () => client.adminBilling.backfillSubscriptionStates(),
      ).thenThrow(Exception('API Error'));
    });

    group('when running admin backfill-subscription-states', () {
      late Future commandResult;

      setUp(() {
        commandResult = cli.run(['admin', 'backfill-subscription-states']);
      });

      test('then the command fails with an error', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the failure is logged', () async {
        await commandResult.catchError((final _) {});

        expect(
          logger.errorCalls.first.message,
          'Failed to start the subscription state backfill',
        );
        expect(logger.errorCalls.first.exception, isNotNull);
      });
    });
  });
}

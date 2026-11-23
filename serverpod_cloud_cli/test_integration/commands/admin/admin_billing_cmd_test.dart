import 'dart:async';
import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/billing/admin_billing_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

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
      apiClientFactory: (globalCfg) => client,
    ),
    adminUserMode: true,
  );

  tearDown(() async {
    logger.clear();
  });

  test(
    'Given admin billing reissue command when instantiated then requires login',
    () {
      expect(AdminReissueInvoiceCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    group('when the invoice is issued', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.reissueInvoice(
            invoiceId: any(named: 'invoiceId'),
          ),
        ).thenAnswer((_) async => {'invoiceId': 'inv_1', 'outcome': 'issued'});

        commandResult = cli.run([
          'admin',
          'billing',
          'reissue',
          '--invoice-id',
          'inv_1',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then command logs success', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.successCalls,
          contains(
            equalsSuccessCall(
              message: 'Invoice "inv_1" issued.',
              newParagraph: true,
            ),
          ),
        );
      });
    });

    group('when the invoice issue fails', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.reissueInvoice(
            invoiceId: any(named: 'invoiceId'),
          ),
        ).thenAnswer(
          (_) async => {'invoiceId': 'inv_1', 'outcome': 'issueFailed'},
        );

        commandResult = cli.run([
          'admin',
          'billing',
          'reissue',
          '--invoice-id',
          'inv_1',
        ]);
      });

      test('then command logs that the failure was recorded', () async {
        await expectLater(commandResult, completes);

        expect(
          logger.infoCalls,
          contains(
            equalsInfoCall(
              message:
                  'Invoice "inv_1" could not be issued. Ground Control recorded the failure.',
              newParagraph: true,
            ),
          ),
        );
      });
    });

    group('when executing with --format json', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.reissueInvoice(
            invoiceId: any(named: 'invoiceId'),
          ),
        ).thenAnswer((_) async => {'invoiceId': 'inv_1', 'outcome': 'issued'});

        commandResult = cli.run([
          'admin',
          'billing',
          'reissue',
          '--invoice-id',
          'inv_1',
          '--format',
          'json',
        ]);
      });

      test('then emits the outcome as JSON', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'invoiceId': 'inv_1',
          'outcome': 'issued',
        });
      });
    });

    group('when executing with --format yaml', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.reissueInvoice(
            invoiceId: any(named: 'invoiceId'),
          ),
        ).thenAnswer(
          (_) async => {'invoiceId': 'inv_1', 'outcome': 'issueFailed'},
        );

        commandResult = cli.run([
          'admin',
          'billing',
          'reissue',
          '--invoice-id',
          'inv_1',
          '--format',
          'yaml',
        ]);
      });

      test('then emits the outcome as YAML', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(yamlDecode(logger.rawCalls.single.content), {
          'invoiceId': 'inv_1',
          'outcome': 'issueFailed',
        });
      });
    });

    group('when Orb rejects the invoice for another reason', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.reissueInvoice(
            invoiceId: any(named: 'invoiceId'),
          ),
        ).thenThrow(InvalidValueException(message: 'invoice is not eligible'));

        commandResult = cli.run([
          'admin',
          'billing',
          'reissue',
          '--invoice-id',
          'inv_1',
        ]);
      });

      test('then command prints the reason', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));

        expect(
          logger.errorCalls,
          contains(equalsErrorCall(message: 'invoice is not eligible')),
        );
      });
    });

    group('when the invoice is not found', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.reissueInvoice(
            invoiceId: any(named: 'invoiceId'),
          ),
        ).thenThrow(NotFoundException(message: 'Invoice not found'));

        commandResult = cli.run([
          'admin',
          'billing',
          'reissue',
          '--invoice-id',
          'missing',
        ]);
      });

      test('then command fails with the server message', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));

        expect(
          logger.errorCalls,
          contains(equalsErrorCall(message: 'Invoice not found')),
        );
      });
    });
  });

  test(
    'Given admin billing record-payment-failed command when instantiated then requires login',
    () {
      expect(
        AdminRecordPaymentFailedCommand(logger: logger).requireLogin,
        isTrue,
      );
    },
  );

  group('Given authenticated', () {
    group('when the payment failure is recorded', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordPaymentFailed(invoiceId: 'inv_1'),
        ).thenAnswer(
          (_) async => {'invoiceId': 'inv_1', 'outcome': 'recorded'},
        );

        commandResult = cli.run([
          'admin',
          'billing',
          'record-payment-failed',
          '--invoice-id',
          'inv_1',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then command logs success', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.successCalls,
          contains(
            equalsSuccessCall(
              message: 'Invoice "inv_1" payment failure recorded.',
              newParagraph: true,
            ),
          ),
        );
      });
    });

    group('when executing with --format json', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordPaymentFailed(invoiceId: 'inv_1'),
        ).thenAnswer(
          (_) async => {'invoiceId': 'inv_1', 'outcome': 'recorded'},
        );

        commandResult = cli.run([
          'admin',
          'billing',
          'record-payment-failed',
          '--invoice-id',
          'inv_1',
          '--format',
          'json',
        ]);
      });

      test('then emits the outcome as JSON', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'invoiceId': 'inv_1',
          'outcome': 'recorded',
        });
      });
    });

    group('when executing with --format yaml', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordPaymentFailed(invoiceId: 'inv_1'),
        ).thenAnswer(
          (_) async => {'invoiceId': 'inv_1', 'outcome': 'recorded'},
        );

        commandResult = cli.run([
          'admin',
          'billing',
          'record-payment-failed',
          '--invoice-id',
          'inv_1',
          '--format',
          'yaml',
        ]);
      });

      test('then emits the outcome as YAML', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(yamlDecode(logger.rawCalls.single.content), {
          'invoiceId': 'inv_1',
          'outcome': 'recorded',
        });
      });
    });

    group('when the invoice cannot be recorded', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordPaymentFailed(invoiceId: 'inv_1'),
        ).thenThrow(InvalidValueException(message: 'Invoice is not unpaid'));

        commandResult = cli.run([
          'admin',
          'billing',
          'record-payment-failed',
          '--invoice-id',
          'inv_1',
        ]);
      });

      test('then command prints the reason', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));

        expect(
          logger.errorCalls,
          contains(equalsErrorCall(message: 'Invoice is not unpaid')),
        );
      });
    });

    group('when the invoice is not found', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordPaymentFailed(invoiceId: 'missing'),
        ).thenThrow(NotFoundException(message: 'Invoice not found'));

        commandResult = cli.run([
          'admin',
          'billing',
          'record-payment-failed',
          '--invoice-id',
          'missing',
        ]);
      });

      test('then command fails with the server message', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));

        expect(
          logger.errorCalls,
          contains(equalsErrorCall(message: 'Invoice not found')),
        );
      });
    });
  });

  test(
    'Given admin billing record-trial-ended command when instantiated then requires login',
    () {
      expect(AdminRecordTrialEndedCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    group('when the trial end is recorded', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordTrialEnded(subscriptionId: 'sub_1'),
        ).thenAnswer(
          (_) async => {'subscriptionId': 'sub_1', 'outcome': 'recorded'},
        );

        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'admin',
          'billing',
          'record-trial-ended',
          '--subscription-id',
          'sub_1',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then command logs success', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.successCalls,
          contains(
            equalsSuccessCall(
              message: 'Subscription "sub_1" trial end recorded.',
              newParagraph: true,
            ),
          ),
        );
      });
    });

    group('when executing with --format json', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordTrialEnded(subscriptionId: 'sub_1'),
        ).thenAnswer(
          (_) async => {'subscriptionId': 'sub_1', 'outcome': 'recorded'},
        );

        commandResult = cli.run([
          'admin',
          'billing',
          'record-trial-ended',
          '--subscription-id',
          'sub_1',
          '--yes',
          '--format',
          'json',
        ]);
      });

      test('then emits the outcome as JSON', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'subscriptionId': 'sub_1',
          'outcome': 'recorded',
        });
      });
    });

    group('when executing with --format yaml', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordTrialEnded(subscriptionId: 'sub_1'),
        ).thenAnswer(
          (_) async => {'subscriptionId': 'sub_1', 'outcome': 'recorded'},
        );

        commandResult = cli.run([
          'admin',
          'billing',
          'record-trial-ended',
          '--subscription-id',
          'sub_1',
          '--yes',
          '--format',
          'yaml',
        ]);
      });

      test('then emits the outcome as YAML', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(yamlDecode(logger.rawCalls.single.content), {
          'subscriptionId': 'sub_1',
          'outcome': 'recorded',
        });
      });
    });

    group('when the trial end cannot be recorded', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordTrialEnded(subscriptionId: 'sub_1'),
        ).thenThrow(
          InvalidValueException(message: 'Subscription has no trial'),
        );

        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'admin',
          'billing',
          'record-trial-ended',
          '--subscription-id',
          'sub_1',
        ]);
      });

      test('then command prints the reason', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));

        expect(
          logger.errorCalls,
          contains(equalsErrorCall(message: 'Subscription has no trial')),
        );
      });
    });

    group('when the subscription is not found', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordTrialEnded(subscriptionId: 'missing'),
        ).thenThrow(NotFoundException(message: 'Subscription not found'));

        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'admin',
          'billing',
          'record-trial-ended',
          '--subscription-id',
          'missing',
        ]);
      });

      test('then command fails with the server message', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));

        expect(
          logger.errorCalls,
          contains(equalsErrorCall(message: 'Subscription not found')),
        );
      });
    });

    group('when the confirmation is declined', () {
      late Future commandResult;
      setUp(() async {
        logger.answerNextConfirmWith(false);

        commandResult = cli.run([
          'admin',
          'billing',
          'record-trial-ended',
          '--subscription-id',
          'sub_declined',
        ]);
      });

      test('then command throws exit exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then no trial end is recorded', () async {
        await commandResult.catchError((_) {});

        verifyNever(
          () => client.adminBilling.recordTrialEnded(
            subscriptionId: 'sub_declined',
          ),
        );
      });
    });
  });

  test(
    'Given admin billing record-trials-ended command when instantiated then requires login',
    () {
      expect(
        AdminRecordTrialsEndedCommand(logger: logger).requireLogin,
        isTrue,
      );
    },
  );

  group('Given authenticated', () {
    final since = DateTime.utc(2026, 11, 5);

    group('when the trial ends are recorded', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordTrialsEnded(
            since: since,
            dryRun: false,
          ),
        ).thenAnswer(
          (_) async => [
            {'subscriptionId': 'sub_1', 'outcome': 'recorded', 'reason': ''},
            {
              'subscriptionId': 'sub_2',
              'outcome': 'skipped',
              'reason': 'Owner billing setup is complete',
            },
          ],
        );

        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'admin',
          'billing',
          'record-trials-ended',
          '--since',
          '2026-11-05T00:00:00Z',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then command lists the recorded subscription', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((final call) => call.line).join('\n'),
          allOf(contains('sub_1'), contains('recorded')),
        );
      });

      test(
        'then command lists the skipped subscription and its reason',
        () async {
          await commandResult;

          expect(
            logger.lineCalls.map((final call) => call.line).join('\n'),
            allOf(
              contains('sub_2'),
              contains('skipped'),
              contains('Owner billing setup is complete'),
            ),
          );
        },
      );
    });

    group('when executing with --dry-run and --format json', () {
      late Future commandResult;
      setUp(() async {
        when(
          () =>
              client.adminBilling.recordTrialsEnded(since: since, dryRun: true),
        ).thenAnswer(
          (_) async => [
            {'subscriptionId': 'sub_1', 'outcome': 'dryRun', 'reason': ''},
          ],
        );

        commandResult = cli.run([
          'admin',
          'billing',
          'record-trials-ended',
          '--since',
          '2026-11-05T00:00:00Z',
          '--dry-run',
          '--format',
          'json',
        ]);
      });

      test('then emits the subscriptions as JSON', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect((payload.single as Map)['subscriptionId'], 'sub_1');
        expect((payload.single as Map)['outcome'], 'dryRun');
      });

      test('then does not ask for confirmation', () async {
        await commandResult;

        expect(logger.confirmCalls, isEmpty);
      });
    });

    group('when the confirmation is declined', () {
      late Future commandResult;
      setUp(() async {
        logger.answerNextConfirmWith(false);

        commandResult = cli.run([
          'admin',
          'billing',
          'record-trials-ended',
          '--since',
          '2026-11-06T00:00:00Z',
        ]);
      });

      test('then command throws exit exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then no trial end is recorded', () async {
        await commandResult.catchError((_) {});

        verifyNever(
          () => client.adminBilling.recordTrialsEnded(
            since: DateTime.utc(2026, 11, 6),
            dryRun: false,
          ),
        );
      });
    });

    group('when executing with --format yaml', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordTrialsEnded(
            since: since,
            dryRun: false,
          ),
        ).thenAnswer(
          (_) async => [
            {'subscriptionId': 'sub_1', 'outcome': 'recorded', 'reason': ''},
          ],
        );

        commandResult = cli.run([
          'admin',
          'billing',
          'record-trials-ended',
          '--since',
          '2026-11-05T00:00:00Z',
          '--yes',
          '--format',
          'yaml',
        ]);
      });

      test('then emits the subscriptions as YAML', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as List;
        expect((payload.single as Map)['subscriptionId'], 'sub_1');
        expect((payload.single as Map)['outcome'], 'recorded');
      });
    });

    group('when no subscription has a trial that ended in the period', () {
      setUp(() async {
        when(
          () => client.adminBilling.recordTrialsEnded(
            since: since,
            dryRun: false,
          ),
        ).thenAnswer((_) async => []);
      });

      test('then the text output is the empty message', () async {
        logger.answerNextConfirmWith(true);

        await cli.run([
          'admin',
          'billing',
          'record-trials-ended',
          '--since',
          '2026-11-05T00:00:00Z',
        ]);

        expect(
          logger.infoCalls.map((final call) => call.message),
          contains('No subscription has a trial that ended in that period.'),
        );
      });

      test('then the JSON output is an empty list', () async {
        await cli.run([
          'admin',
          'billing',
          'record-trials-ended',
          '--since',
          '2026-11-05T00:00:00Z',
          '--yes',
          '--format',
          'json',
        ]);

        expect(logger.infoCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), isEmpty);
      });
    });

    group('when the request fails', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminBilling.recordTrialsEnded(
            since: since,
            dryRun: false,
          ),
        ).thenThrow(Exception('boom'));

        logger.answerNextConfirmWith(true);

        commandResult = cli.run([
          'admin',
          'billing',
          'record-trials-ended',
          '--since',
          '2026-11-05T00:00:00Z',
        ]);
      });

      test('then command fails', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });
    });
  });
}

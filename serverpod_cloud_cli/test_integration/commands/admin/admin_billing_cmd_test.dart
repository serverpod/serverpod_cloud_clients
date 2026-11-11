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
}

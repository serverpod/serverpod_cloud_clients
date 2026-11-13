import 'dart:async';
import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/voucher/admin_voucher_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
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
      apiClientFactory: (final globalCfg) => client,
    ),
    adminUserMode: true,
  );

  tearDown(() {
    logger.clear();
    reset(client.adminVouchers);
  });

  test('Given the admin voucher create command '
      'when instantiated then requires login', () {
    expect(AdminCreateVoucherCommand(logger: logger).requireLogin, isTrue);
  });

  test('Given the admin voucher list command '
      'when instantiated then requires login', () {
    expect(AdminListVouchersCommand(logger: logger).requireLogin, isTrue);
  });

  test('Given the admin voucher archive command '
      'when instantiated then requires login', () {
    expect(AdminArchiveVoucherCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given authenticated and a server that creates the voucher', () {
    setUp(() {
      when(
        () => client.adminVouchers.createVoucher(
          code: any(named: 'code'),
          name: any(named: 'name'),
          creditAmountCents: any(named: 'creditAmountCents'),
          paysForItemIds: any(named: 'paysForItemIds'),
          redeemableUntil: any(named: 'redeemableUntil'),
          creditLifetimeDays: any(named: 'creditLifetimeDays'),
          creditExpiresBy: any(named: 'creditExpiresBy'),
          maxRedemptions: any(named: 'maxRedemptions'),
          maxRedemptionsPerOwner: any(named: 'maxRedemptionsPerOwner'),
        ),
      ).thenAnswer(
        (_) async => AdminVoucherBuilder()
            .withCode('SHIPIT60')
            .withCreditAmountCents(5999)
            .withPaysForItemIds(['starterFee', 'growthFee'])
            .withCreditLifetimeDays(95)
            .build(),
      );
    });

    group('when creating a voucher for 59.99 dollars', () {
      late Future commandResult;

      setUp(() {
        commandResult = cli.run([
          'admin',
          'voucher',
          'create',
          'SHIPIT60',
          '--name',
          'Ship it',
          '--amount',
          '59.99',
          '--pays-for',
          'starterFee,growthFee',
          '--credit-lifetime-days',
          '95',
        ]);
      });

      test('then the server is asked for the amount in cents '
          'and the given terms', () async {
        await commandResult;

        verify(
          () => client.adminVouchers.createVoucher(
            code: 'SHIPIT60',
            name: 'Ship it',
            creditAmountCents: 5999,
            paysForItemIds: ['starterFee', 'growthFee'],
            redeemableUntil: null,
            creditLifetimeDays: 95,
            creditExpiresBy: null,
            maxRedemptions: null,
            maxRedemptionsPerOwner: 1,
          ),
        ).called(1);
      });

      test('then the command logs that the voucher is created', () async {
        await commandResult;

        expect(
          logger.successCalls,
          contains(
            equalsSuccessCall(
              message: 'Voucher "SHIPIT60" created.',
              newParagraph: true,
            ),
          ),
        );
      });

      test('then the command lists the terms of the voucher', () async {
        await commandResult;

        expect(
          logger.listCalls.single.items,
          containsAll([
            'Credit: \$59.99',
            'Pays for: starterFee, growthFee',
            'Credit lifetime in days: 95',
          ]),
        );
      });
    });

    test('when creating a voucher for a whole dollar amount '
        'then the server is asked for that amount in cents', () async {
      await cli.run([
        'admin',
        'voucher',
        'create',
        'SHIPIT60',
        '--name',
        'Ship it',
        '--amount',
        '60',
      ]);

      verify(
        () => client.adminVouchers.createVoucher(
          code: any(named: 'code'),
          name: any(named: 'name'),
          creditAmountCents: 6000,
          paysForItemIds: [],
          redeemableUntil: any(named: 'redeemableUntil'),
          creditLifetimeDays: any(named: 'creditLifetimeDays'),
          creditExpiresBy: any(named: 'creditExpiresBy'),
          maxRedemptions: any(named: 'maxRedemptions'),
          maxRedemptionsPerOwner: any(named: 'maxRedemptionsPerOwner'),
        ),
      ).called(1);
    });

    test('when creating a voucher for 59.9 dollars '
        'then the server is asked for 5990 cents', () async {
      await cli.run([
        'admin',
        'voucher',
        'create',
        'SHIPIT60',
        '--name',
        'Ship it',
        '--amount',
        '59.9',
      ]);

      verify(
        () => client.adminVouchers.createVoucher(
          code: any(named: 'code'),
          name: any(named: 'name'),
          creditAmountCents: 5990,
          paysForItemIds: any(named: 'paysForItemIds'),
          redeemableUntil: any(named: 'redeemableUntil'),
          creditLifetimeDays: any(named: 'creditLifetimeDays'),
          creditExpiresBy: any(named: 'creditExpiresBy'),
          maxRedemptions: any(named: 'maxRedemptions'),
          maxRedemptionsPerOwner: any(named: 'maxRedemptionsPerOwner'),
        ),
      ).called(1);
    });

    test('when creating a voucher with a deadline, a latest credit expiry '
        'and caps '
        'then the server is asked for those terms', () async {
      await cli.run([
        'admin',
        'voucher',
        'create',
        'SHIPIT60',
        '--name',
        'Ship it',
        '--amount',
        '60',
        '--redeemable-until',
        '2026-12-31T23:59:00Z',
        '--credit-expires-by',
        '2027-06-30T00:00:00Z',
        '--max-redemptions',
        '100',
        '--max-redemptions-per-owner',
        '2',
      ]);

      verify(
        () => client.adminVouchers.createVoucher(
          code: any(named: 'code'),
          name: any(named: 'name'),
          creditAmountCents: any(named: 'creditAmountCents'),
          paysForItemIds: any(named: 'paysForItemIds'),
          redeemableUntil: DateTime.utc(2026, 12, 31, 23, 59),
          creditLifetimeDays: null,
          creditExpiresBy: DateTime.utc(2027, 6, 30),
          maxRedemptions: 100,
          maxRedemptionsPerOwner: 2,
        ),
      ).called(1);
    });

    test('when creating a voucher with an amount of more than two decimals '
        'then the command throws CloudCliUsageException', () async {
      await expectLater(
        cli.run([
          'admin',
          'voucher',
          'create',
          'SHIPIT60',
          '--name',
          'Ship it',
          '--amount',
          '59.999',
        ]),
        throwsA(isA<CloudCliUsageException>()),
      );
    });

    test('when creating a voucher with an amount that is not a number '
        'then the command throws CloudCliUsageException', () async {
      await expectLater(
        cli.run([
          'admin',
          'voucher',
          'create',
          'SHIPIT60',
          '--name',
          'Ship it',
          '--amount',
          'sixty',
        ]),
        throwsA(isA<CloudCliUsageException>()),
      );
    });

    test('when creating a voucher with --format json '
        'then the voucher is emitted as JSON', () async {
      await cli.run([
        'admin',
        'voucher',
        'create',
        'SHIPIT60',
        '--name',
        'Ship it',
        '--amount',
        '59.99',
        '--format',
        'json',
      ]);

      final voucher = jsonDecode(logger.rawCalls.single.content) as Map;
      expect(logger.lineCalls, isEmpty);
      expect(voucher['code'], 'SHIPIT60');
      expect(voucher['creditAmountCents'], 5999);
      expect(voucher['status'], 'active');
    });

    test('when creating a voucher with --format yaml '
        'then the voucher is emitted as YAML', () async {
      await cli.run([
        'admin',
        'voucher',
        'create',
        'SHIPIT60',
        '--name',
        'Ship it',
        '--amount',
        '59.99',
        '--format',
        'yaml',
      ]);

      final voucher = yamlDecode(logger.rawCalls.single.content) as Map;
      expect(logger.lineCalls, isEmpty);
      expect(voucher['code'], 'SHIPIT60');
      expect(voucher['creditAmountCents'], 5999);
    });
  });

  group('Given authenticated and a server that has a voucher '
      'with the same code', () {
    setUp(() {
      when(
        () => client.adminVouchers.createVoucher(
          code: any(named: 'code'),
          name: any(named: 'name'),
          creditAmountCents: any(named: 'creditAmountCents'),
          paysForItemIds: any(named: 'paysForItemIds'),
          redeemableUntil: any(named: 'redeemableUntil'),
          creditLifetimeDays: any(named: 'creditLifetimeDays'),
          creditExpiresBy: any(named: 'creditExpiresBy'),
          maxRedemptions: any(named: 'maxRedemptions'),
          maxRedemptionsPerOwner: any(named: 'maxRedemptionsPerOwner'),
        ),
      ).thenThrow(
        DuplicateEntryException(
          message: 'A voucher with the code SHIPIT60 already exists.',
        ),
      );
    });

    group('when creating the voucher', () {
      late Future commandResult;

      setUp(() {
        commandResult = cli.run([
          'admin',
          'voucher',
          'create',
          'SHIPIT60',
          '--name',
          'Ship it',
          '--amount',
          '60',
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the command logs the reason from the server', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls.single.message,
          'A voucher with the code SHIPIT60 already exists.',
        );
      });
    });
  });

  group('Given authenticated and a server that rejects the voucher terms', () {
    setUp(() {
      when(
        () => client.adminVouchers.createVoucher(
          code: any(named: 'code'),
          name: any(named: 'name'),
          creditAmountCents: any(named: 'creditAmountCents'),
          paysForItemIds: any(named: 'paysForItemIds'),
          redeemableUntil: any(named: 'redeemableUntil'),
          creditLifetimeDays: any(named: 'creditLifetimeDays'),
          creditExpiresBy: any(named: 'creditExpiresBy'),
          maxRedemptions: any(named: 'maxRedemptions'),
          maxRedemptionsPerOwner: any(named: 'maxRedemptionsPerOwner'),
        ),
      ).thenThrow(
        InvalidValueException(message: 'Unknown billing item "otherFee".'),
      );
    });

    group('when creating the voucher', () {
      late Future commandResult;

      setUp(() {
        commandResult = cli.run([
          'admin',
          'voucher',
          'create',
          'SHIPIT60',
          '--name',
          'Ship it',
          '--amount',
          '60',
          '--pays-for',
          'otherFee',
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the command logs the reason from the server', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls.single.message,
          'Unknown billing item "otherFee".',
        );
      });
    });
  });

  group('Given authenticated and a server with a redeemed voucher', () {
    setUp(() {
      when(
        () => client.adminVouchers.listVouchers(
          includeArchived: any(named: 'includeArchived'),
        ),
      ).thenAnswer(
        (_) async => [
          AdminVoucherBuilder()
              .withCode('SHIPIT60')
              .withName('Ship it')
              .withCreditAmountCents(6000)
              .withPaysForItemIds(['starterFee', 'growthFee'])
              .withMaxRedemptions(100)
              .withRedemptionCount(3)
              .build(),
        ],
      );
    });

    test('when listing the vouchers '
        'then the command logs the headings and the voucher '
        'as a table', () async {
      await cli.run(['admin', 'voucher', 'list']);

      final lines = [for (final call in logger.lineCalls) call.line];
      expect(
        lines.first,
        stringContainsInOrder([
          'Code',
          'Name',
          'Credit',
          'Pays for',
          'Status',
          'Redemptions',
          'Redeemable until (local)',
        ]),
      );
      expect(
        lines.last,
        stringContainsInOrder([
          'SHIPIT60',
          'Ship it',
          '\$60.00',
          'starterFee, growthFee',
          'active',
          '3 of 100',
        ]),
      );
    });

    test('when listing the vouchers '
        'then the server is asked without the archived vouchers', () async {
      await cli.run(['admin', 'voucher', 'list']);

      verify(
        () => client.adminVouchers.listVouchers(includeArchived: false),
      ).called(1);
    });

    test('when listing the vouchers with --include-archived '
        'then the server is asked for the archived vouchers too', () async {
      await cli.run(['admin', 'voucher', 'list', '--include-archived']);

      verify(
        () => client.adminVouchers.listVouchers(includeArchived: true),
      ).called(1);
    });

    test('when listing the vouchers with --format json '
        'then the vouchers are emitted as a JSON list', () async {
      await cli.run(['admin', 'voucher', 'list', '--format', 'json']);

      final vouchers = jsonDecode(logger.rawCalls.single.content) as List;
      final voucher = vouchers.single as Map;
      expect(logger.lineCalls, isEmpty);
      expect(voucher['code'], 'SHIPIT60');
      expect(voucher['redemptionCount'], 3);
      expect(voucher['maxRedemptions'], 100);
    });

    test('when listing the vouchers with --format yaml '
        'then the vouchers are emitted as a YAML list', () async {
      await cli.run(['admin', 'voucher', 'list', '--format', 'yaml']);

      final vouchers = yamlDecode(logger.rawCalls.single.content) as List;
      final voucher = vouchers.single as Map;
      expect(logger.lineCalls, isEmpty);
      expect(voucher['code'], 'SHIPIT60');
      expect(voucher['redemptionCount'], 3);
    });
  });

  group('Given authenticated and a server without vouchers', () {
    setUp(() {
      when(
        () => client.adminVouchers.listVouchers(
          includeArchived: any(named: 'includeArchived'),
        ),
      ).thenAnswer((_) async => []);
    });

    test('when listing the vouchers '
        'then the command logs that there are none', () async {
      await cli.run(['admin', 'voucher', 'list']);

      expect(
        logger.infoCalls,
        contains(equalsInfoCall(message: 'No vouchers available.')),
      );
      expect(logger.lineCalls, isEmpty);
    });

    test('when listing the vouchers with --format json '
        'then an empty JSON list is emitted', () async {
      await cli.run(['admin', 'voucher', 'list', '--format', 'json']);

      expect(jsonDecode(logger.rawCalls.single.content), isEmpty);
      expect(logger.infoCalls, isEmpty);
    });
  });

  group('Given authenticated and a server that archives the voucher', () {
    setUp(() {
      when(
        () => client.adminVouchers.archiveVoucher(code: any(named: 'code')),
      ).thenAnswer(
        (_) async =>
            AdminVoucherBuilder().withCode('SHIPIT60').withArchived().build(),
      );
    });

    group('when archiving the voucher and accepting the prompt', () {
      late Future commandResult;

      setUp(() {
        logger.answerNextConfirmWith(true);
        commandResult = cli.run(['admin', 'voucher', 'archive', 'SHIPIT60']);
      });

      test('then the command asks for confirmation', () async {
        await commandResult;

        expect(
          logger.confirmCalls.single,
          equalsConfirmCall(
            message:
                'Are you sure you want to archive the voucher "SHIPIT60"? '
                'This cannot be undone.',
            defaultValue: false,
          ),
        );
      });

      test('then the server is asked to archive the voucher', () async {
        await commandResult;

        verify(
          () => client.adminVouchers.archiveVoucher(code: 'SHIPIT60'),
        ).called(1);
      });

      test('then the command logs that the voucher is archived', () async {
        await commandResult;

        expect(
          logger.successCalls,
          contains(
            equalsSuccessCall(
              message: 'Voucher "SHIPIT60" archived.',
              newParagraph: true,
            ),
          ),
        );
      });
    });

    group('when archiving the voucher and declining the prompt', () {
      late Future commandResult;

      setUp(() {
        logger.answerNextConfirmWith(false);
        commandResult = cli.run(['admin', 'voucher', 'archive', 'SHIPIT60']);
      });

      test('then the command throws UserAbortException', () async {
        await expectLater(commandResult, throwsA(isA<UserAbortException>()));
      });

      test('then the server is not asked to archive the voucher', () async {
        await commandResult.catchError((_) {});

        verifyNever(
          () => client.adminVouchers.archiveVoucher(code: any(named: 'code')),
        );
      });
    });

    test('when archiving the voucher with --yes and --format json '
        'then the voucher is emitted as JSON', () async {
      await cli.run([
        'admin',
        'voucher',
        'archive',
        'SHIPIT60',
        '--yes',
        '--format',
        'json',
      ]);

      final voucher = jsonDecode(logger.rawCalls.single.content) as Map;
      expect(logger.lineCalls, isEmpty);
      expect(voucher['code'], 'SHIPIT60');
      expect(voucher['status'], 'archived');
    });

    test('when archiving the voucher with --yes and --format yaml '
        'then the voucher is emitted as YAML', () async {
      await cli.run([
        'admin',
        'voucher',
        'archive',
        'SHIPIT60',
        '--yes',
        '--format',
        'yaml',
      ]);

      final voucher = yamlDecode(logger.rawCalls.single.content) as Map;
      expect(logger.lineCalls, isEmpty);
      expect(voucher['status'], 'archived');
    });
  });

  group('Given authenticated and a server without the voucher', () {
    setUp(() {
      when(
        () => client.adminVouchers.archiveVoucher(code: any(named: 'code')),
      ).thenThrow(NotFoundException(message: 'Voucher not found: OTHER'));
    });

    group('when archiving the voucher and accepting the prompt', () {
      late Future commandResult;

      setUp(() {
        logger.answerNextConfirmWith(true);
        commandResult = cli.run(['admin', 'voucher', 'archive', 'OTHER']);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the command logs that the voucher is not found', () async {
        await commandResult.catchError((_) {});

        expect(logger.errorCalls.single.message, 'Voucher not found: OTHER');
      });
    });
  });
}

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/voucher/voucher_admin_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given an AdminVoucherListTextUi', () {
    group('when rendered with a voucher without limits '
        'and a voucher with a deadline and a total cap', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminVoucherListTextUi(utc: true),
          data: <AdminVoucher>[
            AdminVoucherBuilder()
                .withCode('OPEN')
                .withCreditAmountCents(1205)
                .withRedemptionCount(7)
                .build(),
            AdminVoucherBuilder()
                .withCode('SHIPIT60')
                .withPaysForItemIds(['starterFee', 'growthFee'])
                .withRedeemableUntil(DateTime.utc(2026, 12, 31, 23, 59))
                .withMaxRedemptions(100)
                .withRedemptionCount(3)
                .build(),
          ],
        );
        stdout = io.stdout;
      });

      test('then the timestamp heading states the UTC zone', () {
        expect(stdout, contains('Redeemable until (UTC)'));
      });

      test('then the voucher without limits shows its credit, '
          'all items and its redemption count', () {
        expect(
          stdout,
          stringContainsInOrder(['OPEN', '\$12.05', 'all items', '7']),
        );
      });

      test('then the voucher with limits shows its items, '
          'its redemptions against the cap and its deadline', () {
        expect(
          stdout,
          stringContainsInOrder([
            'SHIPIT60',
            'starterFee, growthFee',
            '3 of 100',
            '2026-12-31 23:59:00',
          ]),
        );
      });
    });

    group('when rendered without vouchers', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminVoucherListTextUi(utc: true),
          data: <AdminVoucher>[],
        );
        stdout = io.stdout;
      });

      test('then stdout says that there are no vouchers', () {
        expect(stdout, contains('No vouchers available.'));
      });
    });
  });

  group('Given an AdminVoucherCreateTextUi', () {
    group('when rendered with a voucher with a deadline', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminVoucherCreateTextUi(utc: true),
          data: AdminVoucherBuilder()
              .withCode('SHIPIT60')
              .withRedeemableUntil(DateTime.utc(2026, 12, 31, 23, 59))
              .build(),
        );
        stdout = io.stdout;
      });

      test('then stdout says that the voucher is created', () {
        expect(stdout, contains('Voucher "SHIPIT60" created.'));
      });

      test('then stdout states the deadline with its time zone', () {
        expect(stdout, contains('Redeemable until: 2026-12-31 23:59:00 (UTC)'));
      });
    });

    group('when rendered with a voucher without a deadline', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminVoucherCreateTextUi(utc: true),
          data: AdminVoucherBuilder().build(),
        );
        stdout = io.stdout;
      });

      test('then stdout has no deadline line', () {
        expect(stdout, isNot(contains('Redeemable until')));
      });
    });
  });

  group('Given an AdminVoucherArchiveTextUi', () {
    group('when rendered with an archived voucher', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminVoucherArchiveTextUi(utc: true),
          data: AdminVoucherBuilder()
              .withCode('SHIPIT60')
              .withArchived()
              .build(),
        );
        stdout = io.stdout;
      });

      test('then stdout says that the voucher is archived', () {
        expect(stdout, contains('Voucher "SHIPIT60" archived.'));
      });

      test('then stdout states the archived status', () {
        expect(stdout, contains('Status: archived'));
      });
    });
  });
}

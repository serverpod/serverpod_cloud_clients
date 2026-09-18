import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/admin_project_list_row.dart';
import 'package:test/test.dart';

void main() {
  group('Given an admin project with payments omitted', () {
    test('when mapped to a list row then the plan product id is included', () {
      final row = AdminProjectListRow.fromAdminProjectInfo(
        AdminProjectInfoBuilder()
            .withPlanProductId('growth-private:0')
            .withSubscriptionId('orb_sub_1')
            .build(),
      );

      expect(row.planProductId, 'growth-private:0');
    });

    test('when mapped to a list row then overdue fields are absent', () {
      final row = AdminProjectListRow.fromAdminProjectInfo(
        AdminProjectInfoBuilder()
            .withSubscriptionId('orb_sub_1')
            .withOverduePaymentsStatuses([
              PaymentsStatusBuilder()
                  .withOutstandingAmount('10.00')
                  .withDueDate(DateTime.utc(2024, 1, 1))
                  .build(),
            ])
            .build(),
      );

      expect(row.subscriptionId, 'orb_sub_1');
      expect(row.includePaymentsStatus, isFalse);
      expect(row.oldestOverdueUnpaidAmount, isNull);
      expect(row.invoicedAmountOverdue, isNull);
      expect(row.uninvoicedAmountOverdue, isNull);
    });

    test('when serialized then overdue fields are omitted', () {
      final row = AdminProjectListRow.fromAdminProjectInfo(
        AdminProjectInfoBuilder().withSubscriptionId('orb_sub_1').build(),
      );

      expect(row.toJson()['planProductId'], 'closed-beta:0');
      expect(row.toJson().containsKey('oldestOverdueUnpaidAmount'), isFalse);
      expect(row.toJson().containsKey('oldestOverdueUnpaidDueDate'), isFalse);
      expect(row.toJson().containsKey('newestOverdueUnpaidAmount'), isFalse);
      expect(row.toJson().containsKey('newestOverdueUnpaidDueDate'), isFalse);
      expect(row.toJson().containsKey('invoicedAmountOverdue'), isFalse);
      expect(row.toJson().containsKey('uninvoicedAmountOverdue'), isFalse);
    });
  });

  group('Given an admin project with no overdue invoices', () {
    test('when mapped to a list row then overdue amounts and dates are absent '
        'and invoiced and uninvoiced totals are 0.00', () {
      final row = AdminProjectListRow.fromAdminProjectInfo(
        AdminProjectInfoBuilder().withSubscriptionId('orb_sub_1').build(),
        includePaymentsStatus: true,
      );

      expect(row.subscriptionId, 'orb_sub_1');
      expect(row.oldestOverdueUnpaidAmount, isNull);
      expect(row.oldestOverdueUnpaidDueDate, isNull);
      expect(row.newestOverdueUnpaidAmount, isNull);
      expect(row.newestOverdueUnpaidDueDate, isNull);
      expect(row.invoicedAmountOverdue, '0.00');
      expect(row.uninvoicedAmountOverdue, '0.00');
    });
  });

  group('Given an admin project with one overdue invoice', () {
    test('when mapped to a list row then oldest and newest are that invoice '
        'and the invoiced total is its outstanding amount', () {
      final dueDate = DateTime.utc(2024, 3, 15);
      final row = AdminProjectListRow.fromAdminProjectInfo(
        AdminProjectInfoBuilder().withOverduePaymentsStatuses([
          PaymentsStatusBuilder()
              .withOutstandingAmount('17.13')
              .withDueAmount('27.13')
              .withDueDate(dueDate)
              .withStatus(PaymentsInvoiceStatus.issued)
              .build(),
        ]).build(),
        includePaymentsStatus: true,
      );

      expect(row.oldestOverdueUnpaidAmount, '17.13');
      expect(row.oldestOverdueUnpaidDueDate, dueDate);
      expect(row.newestOverdueUnpaidAmount, '17.13');
      expect(row.newestOverdueUnpaidDueDate, dueDate);
      expect(row.invoicedAmountOverdue, '17.13');
      expect(row.uninvoicedAmountOverdue, '0.00');
    });
  });

  group('Given an admin project with overdue invoices out of date order', () {
    test('when mapped to a list row then oldest and newest follow due date '
        'and the invoiced total is the sum of outstanding amounts', () {
      final row = AdminProjectListRow.fromAdminProjectInfo(
        AdminProjectInfoBuilder().withOverduePaymentsStatuses([
          PaymentsStatusBuilder()
              .withInvoiceId('inv-new')
              .withOutstandingAmount('5.50')
              .withDueDate(DateTime.utc(2024, 6, 1))
              .withStatus(PaymentsInvoiceStatus.issued)
              .build(),
          PaymentsStatusBuilder()
              .withInvoiceId('inv-old')
              .withOutstandingAmount('10.00')
              .withDueDate(DateTime.utc(2024, 1, 1))
              .withStatus(PaymentsInvoiceStatus.issued)
              .build(),
        ]).build(),
        includePaymentsStatus: true,
      );

      expect(row.oldestOverdueUnpaidAmount, '10.00');
      expect(row.oldestOverdueUnpaidDueDate, DateTime.utc(2024, 1, 1));
      expect(row.newestOverdueUnpaidAmount, '5.50');
      expect(row.newestOverdueUnpaidDueDate, DateTime.utc(2024, 6, 1));
      expect(row.invoicedAmountOverdue, '15.50');
      expect(row.uninvoicedAmountOverdue, '0.00');
    });

    test('when serialized then due dates are calendar dates', () {
      final row = AdminProjectListRow.fromAdminProjectInfo(
        AdminProjectInfoBuilder().withOverduePaymentsStatuses([
          PaymentsStatusBuilder()
              .withInvoiceId('inv-new')
              .withOutstandingAmount('5.50')
              .withDueDate(DateTime.utc(2024, 6, 1, 12))
              .build(),
          PaymentsStatusBuilder()
              .withInvoiceId('inv-old')
              .withOutstandingAmount('10.00')
              .withDueDate(DateTime.utc(2024, 1, 1, 18))
              .build(),
        ]).build(),
        includePaymentsStatus: true,
      );

      expect(row.toJson()['oldestOverdueUnpaidDueDate'], '2024-01-01');
      expect(row.toJson()['newestOverdueUnpaidDueDate'], '2024-06-01');
    });
  });

  group('Given an admin project with issued and action needed invoices', () {
    test(
      'when mapped to a list row then invoiced and uninvoiced totals split by status',
      () {
        final row = AdminProjectListRow.fromAdminProjectInfo(
          AdminProjectInfoBuilder().withOverduePaymentsStatuses([
            PaymentsStatusBuilder()
                .withInvoiceId('inv-issued')
                .withOutstandingAmount('10.00')
                .withDueDate(DateTime.utc(2024, 1, 1))
                .withStatus(PaymentsInvoiceStatus.issued)
                .build(),
            PaymentsStatusBuilder()
                .withInvoiceId('inv-action-needed')
                .withOutstandingAmount('5.50')
                .withDueDate(DateTime.utc(2024, 6, 1))
                .withStatus(PaymentsInvoiceStatus.actionNeeded)
                .build(),
          ]).build(),
          includePaymentsStatus: true,
        );

        expect(row.invoicedAmountOverdue, '10.00');
        expect(row.uninvoicedAmountOverdue, '5.50');
      },
    );
  });

  group('Given an admin project with only action needed invoices', () {
    test(
      'when mapped to a list row then the uninvoiced total is the outstanding amount',
      () {
        final row = AdminProjectListRow.fromAdminProjectInfo(
          AdminProjectInfoBuilder().withOverduePaymentsStatuses([
            PaymentsStatusBuilder()
                .withOutstandingAmount('8.25')
                .withDueDate(DateTime.utc(2024, 2, 1))
                .withStatus(PaymentsInvoiceStatus.actionNeeded)
                .build(),
          ]).build(),
          includePaymentsStatus: true,
        );

        expect(row.invoicedAmountOverdue, '0.00');
        expect(row.uninvoicedAmountOverdue, '8.25');
      },
    );
  });
}

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/admin_project_list_row.dart';
import 'package:test/test.dart';

void main() {
  group('Given an admin project with payments omitted', () {
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
      expect(row.totalAmountOverdue, isNull);
    });

    test('when serialized then overdue fields are omitted', () {
      final row = AdminProjectListRow.fromAdminProjectInfo(
        AdminProjectInfoBuilder().withSubscriptionId('orb_sub_1').build(),
      );

      expect(row.toJson().containsKey('oldestOverdueUnpaidAmount'), isFalse);
      expect(row.toJson().containsKey('oldestOverdueUnpaidDueDate'), isFalse);
      expect(row.toJson().containsKey('newestOverdueUnpaidAmount'), isFalse);
      expect(row.toJson().containsKey('newestOverdueUnpaidDueDate'), isFalse);
      expect(row.toJson().containsKey('totalAmountOverdue'), isFalse);
    });
  });

  group('Given an admin project with no overdue invoices', () {
    test('when mapped to a list row then overdue amounts and dates are absent '
        'and the total is 0.00', () {
      final row = AdminProjectListRow.fromAdminProjectInfo(
        AdminProjectInfoBuilder().withSubscriptionId('orb_sub_1').build(),
        includePaymentsStatus: true,
      );

      expect(row.subscriptionId, 'orb_sub_1');
      expect(row.oldestOverdueUnpaidAmount, isNull);
      expect(row.oldestOverdueUnpaidDueDate, isNull);
      expect(row.newestOverdueUnpaidAmount, isNull);
      expect(row.newestOverdueUnpaidDueDate, isNull);
      expect(row.totalAmountOverdue, '0.00');
    });
  });

  group('Given an admin project with one overdue invoice', () {
    test('when mapped to a list row then oldest and newest are that invoice '
        'and the total is its outstanding amount', () {
      final dueDate = DateTime.utc(2024, 3, 15);
      final row = AdminProjectListRow.fromAdminProjectInfo(
        AdminProjectInfoBuilder().withOverduePaymentsStatuses([
          PaymentsStatusBuilder()
              .withOutstandingAmount('17.13')
              .withDueAmount('27.13')
              .withDueDate(dueDate)
              .build(),
        ]).build(),
        includePaymentsStatus: true,
      );

      expect(row.oldestOverdueUnpaidAmount, '17.13');
      expect(row.oldestOverdueUnpaidDueDate, dueDate);
      expect(row.newestOverdueUnpaidAmount, '17.13');
      expect(row.newestOverdueUnpaidDueDate, dueDate);
      expect(row.totalAmountOverdue, '17.13');
    });
  });

  group('Given an admin project with overdue invoices out of date order', () {
    test('when mapped to a list row then oldest and newest follow due date '
        'and the total is the sum of outstanding amounts', () {
      final row = AdminProjectListRow.fromAdminProjectInfo(
        AdminProjectInfoBuilder().withOverduePaymentsStatuses([
          PaymentsStatusBuilder()
              .withInvoiceId('inv-new')
              .withOutstandingAmount('5.50')
              .withDueDate(DateTime.utc(2024, 6, 1))
              .build(),
          PaymentsStatusBuilder()
              .withInvoiceId('inv-old')
              .withOutstandingAmount('10.00')
              .withDueDate(DateTime.utc(2024, 1, 1))
              .build(),
        ]).build(),
        includePaymentsStatus: true,
      );

      expect(row.oldestOverdueUnpaidAmount, '10.00');
      expect(row.oldestOverdueUnpaidDueDate, DateTime.utc(2024, 1, 1));
      expect(row.newestOverdueUnpaidAmount, '5.50');
      expect(row.newestOverdueUnpaidDueDate, DateTime.utc(2024, 6, 1));
      expect(row.totalAmountOverdue, '15.50');
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
}

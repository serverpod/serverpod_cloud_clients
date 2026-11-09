import 'package:ground_control_client/ground_control_client.dart';

class AdminProjectListRow implements SerializableModel {
  const AdminProjectListRow({
    required this.projectInfo,
    required this.status,
    this.suspendedAt,
    this.suspensionReason,
    required this.planProductId,
    required this.subscriptionId,
    this.firstInvoicePaidAt,
    this.firstPaidInvoiceId,
    this.gracePeriodInvoiceId,
    this.gracePeriodSuspendAt,
    this.gracePeriodConcludedAt,
    this.includePaymentsStatus = false,
    this.oldestOverdueUnpaidAmount,
    this.oldestOverdueUnpaidDueDate,
    this.newestOverdueUnpaidAmount,
    this.newestOverdueUnpaidDueDate,
    this.invoicedAmountOverdue,
    this.uninvoicedAmountOverdue,
  });

  factory AdminProjectListRow.fromAdminProjectInfo(
    final AdminProjectInfo info, {
    final bool includePaymentsStatus = false,
  }) {
    String? oldestOverdueUnpaidAmount;
    DateTime? oldestOverdueUnpaidDueDate;
    String? newestOverdueUnpaidAmount;
    DateTime? newestOverdueUnpaidDueDate;
    String? invoicedAmountOverdue;
    String? uninvoicedAmountOverdue;
    if (includePaymentsStatus) {
      final overdue = List<PaymentsStatus>.of(info.overduePaymentsStatuses)
        ..sort((final a, final b) => a.dueDate.compareTo(b.dueDate));

      final oldest = overdue.firstOrNull;
      final newest = overdue.lastOrNull;
      var invoicedCents = 0;
      var uninvoicedCents = 0;
      for (final payment in overdue) {
        final cents = _centsFromDecimalString(payment.outstandingAmount);
        switch (payment.status) {
          case PaymentsInvoiceStatus.issued:
            invoicedCents += cents;
          case PaymentsInvoiceStatus.actionNeeded:
            uninvoicedCents += cents;
        }
      }
      oldestOverdueUnpaidAmount = oldest?.outstandingAmount;
      oldestOverdueUnpaidDueDate = oldest?.dueDate;
      newestOverdueUnpaidAmount = newest?.outstandingAmount;
      newestOverdueUnpaidDueDate = newest?.dueDate;
      invoicedAmountOverdue = _decimalStringFromCents(invoicedCents);
      uninvoicedAmountOverdue = _decimalStringFromCents(uninvoicedCents);
    }

    return AdminProjectListRow(
      projectInfo: info.projectInfo,
      status: info.status,
      suspendedAt: info.suspendedAt,
      suspensionReason: info.suspensionReason,
      planProductId: info.planProductId,
      subscriptionId: info.subscriptionId,
      firstInvoicePaidAt: info.firstInvoicePaidAt,
      firstPaidInvoiceId: info.firstPaidInvoiceId,
      gracePeriodInvoiceId: info.gracePeriodInvoiceId,
      gracePeriodSuspendAt: info.gracePeriodSuspendAt,
      gracePeriodConcludedAt: info.gracePeriodConcludedAt,
      includePaymentsStatus: includePaymentsStatus,
      oldestOverdueUnpaidAmount: oldestOverdueUnpaidAmount,
      oldestOverdueUnpaidDueDate: oldestOverdueUnpaidDueDate,
      newestOverdueUnpaidAmount: newestOverdueUnpaidAmount,
      newestOverdueUnpaidDueDate: newestOverdueUnpaidDueDate,
      invoicedAmountOverdue: invoicedAmountOverdue,
      uninvoicedAmountOverdue: uninvoicedAmountOverdue,
    );
  }

  final ProjectInfo projectInfo;
  final ProjectLifecycleStatus status;
  final DateTime? suspendedAt;
  final ProjectSuspensionReason? suspensionReason;
  final String planProductId;
  final String subscriptionId;
  final DateTime? firstInvoicePaidAt;
  final String? firstPaidInvoiceId;
  final String? gracePeriodInvoiceId;
  final DateTime? gracePeriodSuspendAt;
  final DateTime? gracePeriodConcludedAt;
  final bool includePaymentsStatus;
  final String? oldestOverdueUnpaidAmount;
  final DateTime? oldestOverdueUnpaidDueDate;
  final String? newestOverdueUnpaidAmount;
  final DateTime? newestOverdueUnpaidDueDate;
  final String? invoicedAmountOverdue;
  final String? uninvoicedAmountOverdue;

  @override
  Map<String, Object?> toJson() {
    final suspendedAtValue = suspendedAt;
    final suspensionReasonValue = suspensionReason;
    final firstInvoicePaidAtValue = firstInvoicePaidAt;
    final firstPaidInvoiceIdValue = firstPaidInvoiceId;
    final gracePeriodInvoiceIdValue = gracePeriodInvoiceId;
    final gracePeriodSuspendAtValue = gracePeriodSuspendAt;
    final gracePeriodConcludedAtValue = gracePeriodConcludedAt;
    return {
      ...projectInfo.toJson(),
      'status': status.toJson(),
      if (suspendedAtValue != null)
        'suspendedAt': suspendedAtValue.toUtc().toIso8601String(),
      if (suspensionReasonValue != null)
        'suspensionReason': suspensionReasonValue.toJson(),
      'planProductId': planProductId,
      'subscriptionId': subscriptionId,
      if (firstInvoicePaidAtValue != null)
        'firstInvoicePaidAt': firstInvoicePaidAtValue.toUtc().toIso8601String(),
      'firstPaidInvoiceId': ?firstPaidInvoiceIdValue,
      'gracePeriodInvoiceId': ?gracePeriodInvoiceIdValue,
      if (gracePeriodSuspendAtValue != null)
        'gracePeriodSuspendAt': gracePeriodSuspendAtValue
            .toUtc()
            .toIso8601String(),
      if (gracePeriodConcludedAtValue != null)
        'gracePeriodConcludedAt': gracePeriodConcludedAtValue
            .toUtc()
            .toIso8601String(),
      if (includePaymentsStatus) ...{
        'oldestOverdueUnpaidAmount': oldestOverdueUnpaidAmount,
        'oldestOverdueUnpaidDueDate': dueDateOnly(oldestOverdueUnpaidDueDate),
        'newestOverdueUnpaidAmount': newestOverdueUnpaidAmount,
        'newestOverdueUnpaidDueDate': dueDateOnly(newestOverdueUnpaidDueDate),
        'invoicedAmountOverdue': invoicedAmountOverdue,
        'uninvoicedAmountOverdue': uninvoicedAmountOverdue,
      },
    };
  }
}

String? dueDateOnly(final DateTime? dueDate) {
  if (dueDate == null) {
    return null;
  }
  return dueDate.toUtc().toIso8601String().substring(0, 10);
}

int _centsFromDecimalString(final String amount) {
  final match = RegExp(r'^(-?)(\d+)(?:\.(\d{0,2}))?$').firstMatch(amount);
  if (match == null) {
    return 0;
  }
  final wholeDigits = match.group(2);
  if (wholeDigits == null) {
    return 0;
  }
  final sign = match.group(1) == '-' ? -1 : 1;
  final whole = int.parse(wholeDigits);
  final fraction = match.group(3) ?? '';
  return sign * (whole * 100 + int.parse(fraction.padRight(2, '0')));
}

String _decimalStringFromCents(final int cents) {
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  final whole = absolute ~/ 100;
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  return '$sign$whole.$fraction';
}

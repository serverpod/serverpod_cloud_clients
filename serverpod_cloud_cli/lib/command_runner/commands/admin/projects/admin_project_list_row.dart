import 'package:ground_control_client/ground_control_client.dart';

class AdminProjectListRow implements SerializableModel {
  const AdminProjectListRow({
    required this.projectInfo,
    required this.subscriptionId,
    this.includePaymentsStatus = false,
    this.oldestOverdueUnpaidAmount,
    this.oldestOverdueUnpaidDueDate,
    this.newestOverdueUnpaidAmount,
    this.newestOverdueUnpaidDueDate,
    this.totalAmountOverdue,
  });

  factory AdminProjectListRow.fromAdminProjectInfo(
    final AdminProjectInfo info, {
    final bool includePaymentsStatus = false,
  }) {
    if (!includePaymentsStatus) {
      return AdminProjectListRow(
        projectInfo: info.projectInfo,
        subscriptionId: info.subscriptionId,
      );
    }

    final overdue = List<PaymentsStatus>.of(info.overduePaymentsStatuses)
      ..sort((final a, final b) => a.dueDate.compareTo(b.dueDate));

    final oldest = overdue.firstOrNull;
    final newest = overdue.lastOrNull;
    var totalCents = 0;
    for (final status in overdue) {
      totalCents += _centsFromDecimalString(status.outstandingAmount);
    }

    return AdminProjectListRow(
      projectInfo: info.projectInfo,
      subscriptionId: info.subscriptionId,
      includePaymentsStatus: true,
      oldestOverdueUnpaidAmount: oldest?.outstandingAmount,
      oldestOverdueUnpaidDueDate: oldest?.dueDate,
      newestOverdueUnpaidAmount: newest?.outstandingAmount,
      newestOverdueUnpaidDueDate: newest?.dueDate,
      totalAmountOverdue: _decimalStringFromCents(totalCents),
    );
  }

  final ProjectInfo projectInfo;
  final String subscriptionId;
  final bool includePaymentsStatus;
  final String? oldestOverdueUnpaidAmount;
  final DateTime? oldestOverdueUnpaidDueDate;
  final String? newestOverdueUnpaidAmount;
  final DateTime? newestOverdueUnpaidDueDate;
  final String? totalAmountOverdue;

  @override
  Map<String, Object?> toJson() {
    return {
      ...projectInfo.toJson(),
      'subscriptionId': subscriptionId,
      if (includePaymentsStatus) ...{
        'oldestOverdueUnpaidAmount': oldestOverdueUnpaidAmount,
        'oldestOverdueUnpaidDueDate': dueDateOnly(oldestOverdueUnpaidDueDate),
        'newestOverdueUnpaidAmount': newestOverdueUnpaidAmount,
        'newestOverdueUnpaidDueDate': dueDateOnly(newestOverdueUnpaidDueDate),
        'totalAmountOverdue': totalAmountOverdue,
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

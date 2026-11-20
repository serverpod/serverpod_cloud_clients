import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class ReissueInvoiceTextUi extends OutputWidget {
  const ReissueInvoiceTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final invoiceId = result['invoiceId'];
    if (result['outcome'] == 'issueFailed') {
      return InfoTextWidget(
        'Invoice "$invoiceId" could not be issued. Ground Control recorded the failure.',
        newParagraph: true,
      );
    }
    return SuccessTextWidget(
      'Invoice "$invoiceId" issued.',
      newParagraph: true,
    );
  }
}

class RecordPaymentFailedTextUi extends OutputWidget {
  const RecordPaymentFailedTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final invoiceId = result['invoiceId'];
    return SuccessTextWidget(
      'Invoice "$invoiceId" payment failure recorded.',
      newParagraph: true,
    );
  }
}

class RecordTrialEndedTextUi extends OutputWidget {
  const RecordTrialEndedTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final subscriptionId = result['subscriptionId'];
    return SuccessTextWidget(
      'Subscription "$subscriptionId" trial end recorded.',
      newParagraph: true,
    );
  }
}

class RecordTrialsEndedTextUi extends OutputWidget {
  const RecordTrialsEndedTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final rows = context.get<List<Map<String, Object?>>>();
    if (rows.isEmpty) {
      return const InfoTextWidget(
        'No subscription has a trial that ended in that period.',
      );
    }
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<Map<String, Object?>>(
        columns: [
          TableColumnFormatter.forKey('Subscription', key: 'subscriptionId'),
          TableColumnFormatter.forKey('Outcome', key: 'outcome'),
          TableColumnFormatter.forKey('Reason', key: 'reason'),
        ],
        utc: false,
      ),
    );
  }
}

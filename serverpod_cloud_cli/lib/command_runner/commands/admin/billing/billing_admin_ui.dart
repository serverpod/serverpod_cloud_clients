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

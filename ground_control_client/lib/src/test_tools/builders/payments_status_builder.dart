import 'package:ground_control_client/ground_control_client.dart';

class PaymentsStatusBuilder {
  String _invoiceId;
  DateTime _dueDate;
  String _dueAmount;
  String _outstandingAmount;
  PaymentsInvoiceStatus _status;

  PaymentsStatusBuilder()
    : _invoiceId = 'inv-1',
      _dueDate = DateTime.utc(2024, 1, 1),
      _dueAmount = '10.00',
      _outstandingAmount = '10.00',
      _status = PaymentsInvoiceStatus.issued;

  PaymentsStatusBuilder withInvoiceId(final String invoiceId) {
    _invoiceId = invoiceId;
    return this;
  }

  PaymentsStatusBuilder withDueDate(final DateTime dueDate) {
    _dueDate = dueDate;
    return this;
  }

  PaymentsStatusBuilder withDueAmount(final String dueAmount) {
    _dueAmount = dueAmount;
    return this;
  }

  PaymentsStatusBuilder withOutstandingAmount(final String outstandingAmount) {
    _outstandingAmount = outstandingAmount;
    return this;
  }

  PaymentsStatusBuilder withStatus(final PaymentsInvoiceStatus status) {
    _status = status;
    return this;
  }

  PaymentsStatus build() {
    return PaymentsStatus(
      invoiceId: _invoiceId,
      dueDate: _dueDate,
      dueAmount: _dueAmount,
      outstandingAmount: _outstandingAmount,
      status: _status,
    );
  }
}

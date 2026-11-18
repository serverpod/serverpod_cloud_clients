import 'package:serverpod_cloud_cli/command_runner/commands/admin/billing/billing_admin_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a RecordPaymentFailedTextUi', () {
    group('when rendered after recording a payment failure', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const RecordPaymentFailedTextUi(),
          data: const {'invoiceId': 'inv_1', 'outcome': 'recorded'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the recorded message', () {
        expect(stdout, contains('Invoice "inv_1" payment failure recorded.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}

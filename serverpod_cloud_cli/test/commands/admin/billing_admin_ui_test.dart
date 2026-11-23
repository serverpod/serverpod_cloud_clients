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

  group('Given a RecordTrialEndedTextUi', () {
    group('when rendered after recording a trial end', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const RecordTrialEndedTextUi(),
          data: const {'subscriptionId': 'sub_1', 'outcome': 'recorded'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the recorded message', () {
        expect(stdout, contains('Subscription "sub_1" trial end recorded.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a RecordTrialsEndedTextUi', () {
    group('when rendered with a recorded and a skipped subscription', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const RecordTrialsEndedTextUi(),
          data: const <Map<String, Object?>>[
            {'subscriptionId': 'sub_1', 'outcome': 'recorded', 'reason': ''},
            {
              'subscriptionId': 'sub_2',
              'outcome': 'skipped',
              'reason': 'Owner billing setup is complete',
            },
          ],
        );
        stdout = io.stdout;
      });

      test('then stdout contains the table headers', () {
        expect(
          stdout,
          allOf(
            contains('Subscription'),
            contains('Outcome'),
            contains('Reason'),
          ),
        );
      });

      test('then stdout contains the recorded subscription', () {
        expect(stdout, allOf(contains('sub_1'), contains('recorded')));
      });

      test('then stdout contains the skipped subscription and its reason', () {
        expect(
          stdout,
          allOf(
            contains('sub_2'),
            contains('skipped'),
            contains('Owner billing setup is complete'),
          ),
        );
      });
    });

    group('when rendered with no subscription', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const RecordTrialsEndedTextUi(),
          data: const <Map<String, Object?>>[],
        );
        stdout = io.stdout;
      });

      test('then stdout contains the empty message', () {
        expect(
          stdout,
          contains('No subscription has a trial that ended in that period.'),
        );
      });
    });
  });
}

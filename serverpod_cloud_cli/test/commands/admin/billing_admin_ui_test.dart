import 'package:serverpod_cloud_cli/command_runner/commands/admin/billing/billing_admin_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a BackfillSubscriptionStatesTextUi', () {
    group('when rendered after the backfill is started', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const BackfillSubscriptionStatesTextUi(),
          data: const {'started': true},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout says the backfill is started', () {
        expect(stdout, contains('Started the subscription state backfill.'));
      });

      test('then stdout points to the server log', () {
        expect(
          stdout.replaceAll('\n', ' '),
          contains('See the server log for the counts'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}

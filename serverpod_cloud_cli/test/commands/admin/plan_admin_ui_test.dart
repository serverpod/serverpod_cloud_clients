import 'package:serverpod_cloud_cli/command_runner/commands/admin/plan/plan_admin_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a PlanUpdateTextUi', () {
    group('when rendered after applying a new version', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const PlanUpdateTextUi(),
          data: const {'externalPlanId': 'starter', 'appliedVersion': '3'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the update success message', () {
        expect(
          stdout,
          contains('Orb plan "starter" successfully updated to version 3.'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered when the plan is already current', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const PlanUpdateTextUi(),
          data: const {'externalPlanId': 'starter'},
        );
        stdout = io.stdout;
      });

      test('then stdout reports that the plan is already up to date', () {
        expect(stdout, contains('Orb plan "starter" already up to date.'));
      });
    });
  });
}

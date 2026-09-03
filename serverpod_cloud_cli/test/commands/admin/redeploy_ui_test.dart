import 'package:serverpod_cloud_cli/command_runner/commands/admin/redeploy/redeploy_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a RedeployTextUi', () {
    group('when rendered after triggering a redeploy', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const RedeployTextUi(),
          data: const {'projectId': 'my-project'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the redeploy success message', () {
        expect(
          stdout,
          contains('Redeployment triggered for project: my-project'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}

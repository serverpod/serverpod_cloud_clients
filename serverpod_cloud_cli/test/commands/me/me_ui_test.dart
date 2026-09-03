import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/me/me_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a MeTextUi', () {
    group('when rendered with the current user', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const MeTextUi(),
          data: [UserBuilder().withEmail('ada@example.com').build()],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the email heading', () {
        expect(stdout, contains('Email'));
      });

      test('then stdout contains the user email', () {
        expect(stdout, contains('ada@example.com'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}

import 'package:serverpod_cloud_cli/command_runner/commands/builds/builds_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a BuildSecretSetTextUi', () {
    group('when rendered after setting a secret', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const BuildSecretSetTextUi(),
          data: const {'name': 'SSH_KEY'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the set success message', () {
        expect(stdout, contains('Successfully set build secret: SSH_KEY.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a BuildSecretUnsetTextUi', () {
    group('when rendered after removing a secret', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const BuildSecretUnsetTextUi(),
          data: const {'name': 'SSH_KEY'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the removal success message', () {
        expect(stdout, contains('Successfully removed build secret: SSH_KEY.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}

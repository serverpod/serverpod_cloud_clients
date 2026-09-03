import 'package:serverpod_cloud_cli/command_runner/commands/context/context_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a ContextShowTextUi', () {
    group('when rendered with no project context', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ContextShowTextUi(),
          data: const <String, Object?>{},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports that no context is set', () {
        expect(stdout, contains('No global project context is set.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered with a project context', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const ContextShowTextUi(),
          data: const {'projectContext': 'my-project'},
        );
        stdout = io.stdout;
      });

      test('then stdout contains the project id', () {
        expect(stdout, contains('my-project'));
      });
    });
  });

  group('Given a ContextSetTextUi', () {
    group('when rendered after setting a context', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ContextSetTextUi(),
          data: const {'projectId': 'my-project'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the success message', () {
        expect(
          stdout,
          contains('Set the global project context to "my-project".'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a ContextUnsetTextUi', () {
    group('when rendered', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ContextUnsetTextUi(),
          data: const <String, Object?>{},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the success message', () {
        expect(stdout, contains('Unset the global project context.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}

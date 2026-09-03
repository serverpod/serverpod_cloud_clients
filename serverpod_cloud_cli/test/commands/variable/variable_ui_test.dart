import 'package:serverpod_cloud_cli/command_runner/commands/variable/variable_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a VariableListTextUi', () {
    group('when rendered with environment variables', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const VariableListTextUi(),
          data: [
            {'name': 'SERVICE_EMAIL', 'value': 'ops@example.com'},
            {'name': 'API_KEY', 'value': '••••••••'},
          ],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('Name'));
        expect(stdout, contains('Value'));
      });

      test('then stdout contains the unmasked variable', () {
        expect(stdout, contains('SERVICE_EMAIL'));
        expect(stdout, contains('ops@example.com'));
      });

      test('then stdout contains the masked secret', () {
        expect(stdout, contains('API_KEY'));
        expect(stdout, contains('••••••••'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a VariableSetTextUi', () {
    group('when rendered after setting an unmasked variable', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const VariableSetTextUi(baseCommand: 'scloud'),
          data: const {'name': 'SERVICE_EMAIL', 'secret': false},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the variable success message', () {
        expect(
          stdout,
          contains('Successfully set environment variable: SERVICE_EMAIL.'),
        );
      });

      test('then stdout hints to redeploy', () {
        expect(stdout, contains('scloud deploy'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered after setting a secret', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const VariableSetTextUi(baseCommand: 'scloud'),
          data: const {'name': 'API_KEY', 'secret': true},
        );
        stdout = io.stdout;
      });

      test('then stdout contains the secret success message', () {
        expect(stdout, contains('Successfully set secret: API_KEY.'));
      });
    });
  });

  group('Given a VariableUnsetTextUi', () {
    group('when rendered after removing an unmasked variable', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const VariableUnsetTextUi(baseCommand: 'scloud'),
          data: const {'name': 'SERVICE_EMAIL', 'secret': false},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the variable removal message', () {
        expect(
          stdout,
          contains('Successfully removed environment variable: SERVICE_EMAIL.'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered after removing a secret', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const VariableUnsetTextUi(baseCommand: 'scloud'),
          data: const {'name': 'API_KEY', 'secret': true},
        );
        stdout = io.stdout;
      });

      test('then stdout contains the secret removal message', () {
        expect(stdout, contains('Successfully removed secret: API_KEY.'));
      });
    });
  });
}

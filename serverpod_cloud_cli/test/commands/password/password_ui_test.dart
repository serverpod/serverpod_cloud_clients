import 'package:serverpod_cloud_cli/command_runner/commands/password/password_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/password/password_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a PasswordListTextUi', () {
    group('when rendered with no passwords', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const PasswordListTextUi(),
          data: const <Map<String, Object?>>[],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports that no passwords are available', () {
        expect(stdout, contains('No passwords available.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered with a custom password', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const PasswordListTextUi(),
          data: [
            {
              'name': 'apiKey',
              'category': PasswordCategory.custom,
              'status': 'SET (User)',
              'notes': 'User-defined password',
            },
          ],
        );
        stdout = io.stdout;
      });

      test('then stdout contains the Custom heading', () {
        expect(stdout, contains('Custom'));
      });

      test('then stdout contains the password name', () {
        expect(stdout, contains('apiKey'));
      });

      test('then stdout contains the password status', () {
        expect(stdout, contains('SET (User)'));
      });
    });
  });

  group('Given a PasswordSetTextUi', () {
    group('when rendered after setting a named password', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const PasswordSetTextUi(baseCommand: 'scloud'),
          data: const {'name': 'database'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the success message', () {
        expect(stdout, contains('Successfully set password "database".'));
      });

      test('then stdout hints to redeploy', () {
        expect(
          stdout,
          contains(
            'The changes will not take effect until your server is re-deployed.',
          ),
        );
        expect(stdout, contains('scloud deploy'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a PasswordUnsetTextUi', () {
    group('when rendered after unsetting a named password', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const PasswordUnsetTextUi(baseCommand: 'scloud'),
          data: const {'name': 'database'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the success message', () {
        expect(stdout, contains('Successfully unset password "database".'));
      });

      test('then stdout hints to redeploy', () {
        expect(stdout, contains('scloud deploy'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}

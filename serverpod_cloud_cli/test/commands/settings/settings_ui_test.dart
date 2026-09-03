import 'package:serverpod_cloud_cli/command_runner/commands/settings/settings_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a SettingsListUi', () {
    group('when rendered with analytics enabled', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const SettingsListUi(),
          data: [
            {'name': 'analytics', 'value': true},
          ],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('Name'));
        expect(stdout, contains('Value'));
      });

      test('then stdout contains the analytics value', () {
        expect(stdout, contains('analytics'));
        expect(stdout, contains('true'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered without an analytics value', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const SettingsListUi(),
          data: [
            {'name': 'analytics', 'value': null},
          ],
        );
        stdout = io.stdout;
      });

      test('then stdout reports analytics as not set', () {
        expect(stdout, contains('analytics'));
        expect(stdout, contains('not set'));
      });
    });
  });
}

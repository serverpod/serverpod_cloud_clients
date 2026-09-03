import 'package:serverpod_cloud_cli/command_runner/commands/settings/settings_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a SettingsShowTextUi', () {
    group('when rendered with analytics enabled', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const SettingsShowTextUi(),
          data: const {'analytics': true},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the settings title', () {
        expect(stdout, contains('Local settings'));
      });

      test('then stdout contains the analytics value', () {
        expect(stdout, contains('Analytics = true'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered without an analytics value', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const SettingsShowTextUi(),
          data: const <String, Object?>{},
        );
        stdout = io.stdout;
      });

      test('then stdout reports analytics as not set', () {
        expect(stdout, contains('Analytics = not set'));
      });
    });
  });

  group('Given a SettingsSetTextUi', () {
    group('when rendered after toggling analytics', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const SettingsSetTextUi(),
          data: const {'analytics': false},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the updated analytics value', () {
        expect(stdout, contains('Analytics set to "false".'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}

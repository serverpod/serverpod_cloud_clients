import 'package:serverpod_cloud_cli/command_runner/commands/version/version_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a VersionTextUi', () {
    group('when rendered with a version string', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(const VersionTextUi(), data: '1.2.3');
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the version line', () {
        expect(stdout, contains('Serverpod Cloud CLI version: 1.2.3'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}

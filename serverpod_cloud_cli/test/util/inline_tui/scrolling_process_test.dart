import 'dart:io';

import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';
import 'package:test/test.dart';

import 'helpers/fake_terminal.dart';

void main() {
  group('Given ScrollingProcess.run', () {
    test('when a process succeeds then its output is tailed and exit code 0 '
        'is returned', () async {
      final term = FakeTerminal();

      final result = await ScrollingProcess.run(
        Platform.resolvedExecutable,
        ['--version'],
        terminal: term,
        rows: 5,
      );

      expect(result.exitCode, 0);
      expect(result.succeeded, isTrue);
      // The version output was rendered into the section.
      expect(term.output, contains('Dart'));

      result.clear();
      expect(result.section.isFinished, isTrue);
    });

    test('when a process fails then a non-zero exit code is returned and its '
        'error output is captured', () async {
      final term = FakeTerminal();

      final result = await ScrollingProcess.run(
        Platform.resolvedExecutable,
        ['--this-option-does-not-exist'],
        terminal: term,
        rows: 5,
      );

      expect(result.exitCode, isNot(0));
      expect(result.succeeded, isFalse);
      expect(term.output, isNotEmpty);

      result.keep();
    });
  });
}

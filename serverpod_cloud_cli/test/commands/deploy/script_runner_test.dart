import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod_cloud_cli/commands/deploy/script_runner.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';

import '../../../test_utils/test_command_logger.dart';
import '../../util/inline_tui/helpers/fake_terminal.dart';

/// An [IOSink] that captures everything written to it as a string.
class _CapturingSink {
  final StreamController<List<int>> _controller = StreamController<List<int>>();
  final StringBuffer _buffer = StringBuffer();
  late final Future<void> _done;
  late final IOSink sink = IOSink(_controller.sink);

  _CapturingSink() {
    _done = _controller.stream.transform(utf8.decoder).forEach(_buffer.write);
  }

  String get text => _buffer.toString();

  Future<void> close() async {
    await _controller.close();
    await _done;
  }
}

void main() {
  late TestCommandLogger logger;
  final workingDirectory = Directory.current.path;

  setUp(() {
    logger = TestCommandLogger();
  });

  group('Given an interactive terminal', () {
    test(
      'when a script succeeds then its output is rendered then cleared',
      () async {
        final term = FakeTerminal(hasTerminal: true);
        logger.inlineTerminal = term;

        await ScriptRunner.runScripts(
          ['echo hello-from-script'],
          workingDirectory,
          logger,
          scriptType: 'test',
        );

        expect(term.output, contains('hello-from-script'));
        // The scrolling section is cleared on success (ends with the clear and
        // show-cursor escape codes).
        expect(term.output, endsWith('\x1b[?25h'));
      },
    );

    test(
      'when a script fails then its output is kept and an error is thrown',
      () async {
        final term = FakeTerminal(hasTerminal: true);
        logger.inlineTerminal = term;

        // cmd.exe (Windows) uses '&' to separate commands and does not treat
        // ';' as a separator, so use the shell-appropriate command.
        final failingScript = Platform.isWindows
            ? 'echo boom-output& exit 3'
            : 'echo boom-output; exit 3';

        await expectLater(
          ScriptRunner.runScripts(
            [failingScript],
            workingDirectory,
            logger,
            scriptType: 'test',
          ),
          throwsA(
            isA<ErrorExitException>().having(
              (final e) => e.reason,
              'reason',
              contains('exit code 3'),
            ),
          ),
        );

        expect(term.output, contains('boom-output'));
        // On failure the output is kept: the cursor is moved below it and shown,
        // rather than the region being cleared.
        expect(term.output, endsWith('\n\x1b[?25h'));
      },
    );

    test(
      'when an earlier script fails then later scripts are not run',
      () async {
        final term = FakeTerminal(hasTerminal: true);
        logger.inlineTerminal = term;

        await expectLater(
          ScriptRunner.runScripts(
            ['exit 1', 'echo should-not-run'],
            workingDirectory,
            logger,
            scriptType: 'test',
          ),
          throwsA(isA<ErrorExitException>()),
        );

        expect(term.output, isNot(contains('should-not-run')));
      },
    );
  });

  group('Given an interactive terminal but redirected output sinks', () {
    test('when a script runs then output goes to the sinks and the scrolling '
        'section is not used', () async {
      // This mirrors the launch TUI, which routes script output into its own
      // log view instead of the terminal.
      final term = FakeTerminal(hasTerminal: true);
      logger.inlineTerminal = term;
      final out = _CapturingSink();
      final err = _CapturingSink();

      await ScriptRunner.runScripts(
        ['echo routed-output'],
        workingDirectory,
        logger,
        scriptType: 'test',
        stdout: out.sink,
        stderr: err.sink,
      );
      await out.close();
      await err.close();

      expect(out.text, contains('routed-output'));
      // Nothing was written to the terminal, so the TUI is left untouched.
      expect(term.output, isEmpty);
    });
  });

  group('Given no commands', () {
    test('when running scripts then nothing is logged', () async {
      final term = FakeTerminal(hasTerminal: true);
      logger.inlineTerminal = term;

      await ScriptRunner.runScripts(
        [],
        workingDirectory,
        logger,
        scriptType: 'test',
      );

      expect(logger.infoCalls, isEmpty);
      expect(term.output, isEmpty);
    });
  });
}

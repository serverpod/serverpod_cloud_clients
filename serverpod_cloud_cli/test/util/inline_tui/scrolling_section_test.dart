import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';
import 'package:test/test.dart';

import 'helpers/fake_terminal.dart';

/// A spinner scheduler that never ticks, for tests that don't drive the
/// animation themselves.
void Function() _noTicker(
  final Duration period,
  final void Function() onTick,
) => () {};

void main() {
  group('Given a ScrollingSection', () {
    test('when fewer lines than rows are appended then all are visible', () {
      final term = FakeTerminal();
      final section = ScrollingSection(terminal: term, rows: 5);

      section
        ..appendLine('one')
        ..appendLine('two');

      expect(section.visibleLines, ['one', 'two']);
    });

    test('when more lines than rows are appended then only the last rows are '
        'visible', () {
      final term = FakeTerminal();
      final section = ScrollingSection(terminal: term, rows: 3);

      for (var i = 1; i <= 6; i++) {
        section.appendLine('line $i');
      }

      expect(section.visibleLines, ['line 4', 'line 5', 'line 6']);
    });

    test('when a line contains newlines then each part is a separate row', () {
      final term = FakeTerminal();
      final section = ScrollingSection(terminal: term, rows: 5);

      section.appendLine('a\nb\nc');

      expect(section.visibleLines, ['a', 'b', 'c']);
    });

    test('when the first line is appended then the cursor is hidden', () {
      final term = FakeTerminal();
      final section = ScrollingSection(terminal: term, rows: 5);

      section.appendLine('hello');

      expect(term.output, contains('\x1b[?25l'));
      expect(term.output, contains('hello'));
    });

    test('when a long line is appended then it is truncated to the width', () {
      final term = FakeTerminal(columns: 10);
      final section = ScrollingSection(terminal: term, rows: 5);

      section.appendLine('0123456789ABCDEF');

      expect(section.visibleLines, ['0123456789ABCDEF']);
      // Rendered text is fitted to the terminal width with an ellipsis.
      expect(term.output, contains('01234567\u2026'));
    });

    test('when a colored line exceeds the width then escape sequences are not '
        'counted as columns nor cut mid-sequence', () {
      final term = FakeTerminal(columns: 10, supportsColor: true);
      final section = ScrollingSection(terminal: term, rows: 5, dim: false);

      // 16 visible columns wrapped in color codes; only the visible columns
      // should count towards the width.
      section.appendLine('\x1b[31m0123456789ABCDEF\x1b[0m');

      // The leading escape is preserved intact and exactly 8 visible columns
      // are kept before the ellipsis (width 10 -> 9 visible, minus 1 for the
      // ellipsis).
      expect(term.output, contains('\x1b[31m01234567\u2026'));
    });

    test('when a colored line fits within the width then it is not truncated '
        'even though its raw length exceeds the width', () {
      final term = FakeTerminal(columns: 10, supportsColor: true);
      final section = ScrollingSection(terminal: term, rows: 5, dim: false);

      // Raw length is 12 (> 9) but only 3 visible columns, so it must not be
      // truncated.
      section.appendLine('\x1b[31mABC\x1b[0m');

      expect(term.output, contains('\x1b[31mABC\x1b[0m'));
      expect(term.output, isNot(contains('\u2026')));
    });

    test('when keep is called then it leaves output in place and shows the '
        'cursor', () {
      final term = FakeTerminal();
      final section = ScrollingSection(terminal: term, rows: 3)
        ..appendLine('one')
        ..appendLine('two');

      section.keep();

      expect(term.output, endsWith('\n\x1b[?25h'));
      expect(section.isFinished, isTrue);
    });

    test(
      'when clear is called then it clears the region and shows the cursor',
      () {
        final term = FakeTerminal();
        final section = ScrollingSection(terminal: term, rows: 3)
          ..appendLine('one')
          ..appendLine('two');

        section.clear();

        expect(term.output, endsWith('\x1b[0J\x1b[?25h'));
        expect(section.isFinished, isTrue);
      },
    );

    test('when appending after finishing then it throws', () {
      final term = FakeTerminal();
      final section = ScrollingSection(terminal: term, rows: 3)
        ..appendLine('one');
      section.keep();

      expect(() => section.appendLine('two'), throwsStateError);
    });

    test('when captureOutput is enabled then all appended lines are retained '
        'even after scrolling out of view', () {
      final term = FakeTerminal();
      final section = ScrollingSection(
        terminal: term,
        rows: 2,
        captureOutput: true,
      );

      for (var i = 1; i <= 5; i++) {
        section.appendLine('line $i');
      }

      expect(section.visibleLines, ['line 4', 'line 5']);
      expect(section.capturedOutput, [
        'line 1',
        'line 2',
        'line 3',
        'line 4',
        'line 5',
      ]);
    });

    test('when captureOutput is disabled then no output is retained', () {
      final term = FakeTerminal();
      final section = ScrollingSection(terminal: term, rows: 2);

      section.appendLine('line 1');

      expect(section.capturedOutput, isEmpty);
    });

    test('when kept with full then the complete captured output is rendered '
        'untruncated', () {
      final term = FakeTerminal(columns: 10);
      final section = ScrollingSection(
        terminal: term,
        rows: 2,
        captureOutput: true,
      );

      section
        ..appendLine('first line is quite long')
        ..appendLine('second')
        ..appendLine('third')
        ..appendLine('fourth');

      section.keep(full: true);

      // Lines that had scrolled out of the 2-row view are shown again, and the
      // long line is not truncated to the width.
      expect(term.output, contains('first line is quite long'));
      expect(term.output, contains('second'));
      expect(term.output, contains('third'));
      expect(term.output, contains('fourth'));
    });

    test(
      'when kept without full then only the last visible lines are kept',
      () {
        final term = FakeTerminal();
        final section = ScrollingSection(
          terminal: term,
          rows: 2,
          captureOutput: true,
        )..appendLine('finish: keep');

        section
          ..appendLine('a')
          ..appendLine('b')
          ..appendLine('c');

        section.keep();

        expect(section.visibleLines, ['b', 'c']);
      },
    );

    test(
      'when color is supported and dim is enabled then lines are dimmed',
      () {
        final term = FakeTerminal(supportsColor: true);
        final section = ScrollingSection(terminal: term, rows: 3);

        section.appendLine('hello');

        expect(term.output, contains('\x1b[2mhello\x1b[0m'));
      },
    );
  });

  group('Given a ScrollingSection with a heading', () {
    test('when constructed then the heading is shown immediately and the '
        'cursor is hidden', () {
      final term = FakeTerminal();
      ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Preparing',
        scheduleTicker: _noTicker,
      );

      expect(term.output, contains('\x1b[?25l'));
      expect(term.output, contains('Preparing'));
    });

    test('when color is supported then the heading is undimmed while the lines '
        'are dimmed', () {
      final term = FakeTerminal(supportsColor: true);
      ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        scheduleTicker: _noTicker,
      ).appendLine('step');

      // The heading is rendered without the dim style.
      expect(term.output, contains('Building'));
      expect(term.output, isNot(contains('\x1b[2mBuilding')));
      // The scrolling line is dimmed.
      expect(term.output, contains('\x1b[2mstep\x1b[0m'));
    });

    test('when keep is called and a failedMessage is set then the heading is '
        'replaced and the lines are kept', () {
      final term = FakeTerminal();
      final section = ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        failedMessage: 'Build failed',
        scheduleTicker: _noTicker,
      )..appendLine('error output');

      section.keep();

      expect(term.output, contains('Build failed'));
      expect(term.output, contains('error output'));
      expect(term.output, endsWith('\n\x1b[?25h'));
      expect(section.isFinished, isTrue);
    });

    test('when clear is called and a successMessage is set then the heading is '
        'replaced and the lines are removed', () {
      final term = FakeTerminal();
      final section = ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        successMessage: 'Build succeeded',
        scheduleTicker: _noTicker,
      )..appendLine('noise');

      section.clear();

      expect(term.output, contains('Build succeeded'));
      // The success message is left in place (cursor moved below it), rather
      // than the region being fully cleared.
      expect(term.output, endsWith('\n\x1b[?25h'));
      expect(section.isFinished, isTrue);
    });

    test('when clear is called without a successMessage then the heading is '
        'left in place', () {
      final term = FakeTerminal();
      final section = ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'H',
        elapsed: () => Duration.zero,
        scheduleTicker: _noTicker,
      )..appendLine('a');

      section.clear();

      // The heading line is kept (with the success icon), not cleared.
      expect(term.output, contains('\u2713 H (0ms)'));
      expect(term.output, endsWith('\n\x1b[?25h'));
      expect(section.isFinished, isTrue);
    });
  });

  group('Given a ScrollingSection with a spinner heading', () {
    test('when constructed then the spinner, heading and elapsed are rendered '
        'in order', () {
      final term = FakeTerminal();
      ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        elapsed: () => Duration.zero,
        scheduleTicker: _noTicker,
      );

      expect(term.output, contains('\u280b Building (0ms)'));
    });

    test('when the spinner ticks then the braille frame advances', () {
      final term = FakeTerminal();
      void Function()? tick;
      ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        elapsed: () => Duration.zero,
        scheduleTicker: (final period, final onTick) {
          tick = onTick;
          return () {};
        },
      );

      expect(term.output, contains('\u280b Building'));
      tick!();
      expect(term.output, contains('\u2819 Building'));
      tick!();
      expect(term.output, contains('\u2839 Building'));
    });

    test('when elapsed exceeds 100ms then it is shown in seconds with one '
        'decimal', () {
      final term = FakeTerminal();
      var elapsed = const Duration(milliseconds: 1234);
      void Function()? tick;
      ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        elapsed: () => elapsed,
        scheduleTicker: (final period, final onTick) {
          tick = onTick;
          return () {};
        },
      );

      tick!();
      expect(term.output, contains('Building (1.2s)'));

      elapsed = const Duration(milliseconds: 50);
      tick!();
      expect(term.output, contains('Building (50ms)'));
    });

    test('when finished with keep then the spinner is cancelled and the final '
        'elapsed time is kept with the failed message', () {
      final term = FakeTerminal();
      var cancelled = false;
      final section = ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        failedMessage: 'Build failed',
        elapsed: () => const Duration(milliseconds: 500),
        scheduleTicker: (final period, final onTick) =>
            () => cancelled = true,
      )..appendLine('boom');

      section.keep();

      expect(cancelled, isTrue);
      expect(term.output, contains('Build failed (0.5s)'));
      expect(term.output, contains('boom'));
      expect(term.output, endsWith('\n\x1b[?25h'));
    });

    test('when finished with clear then the success message keeps the final '
        'elapsed time', () {
      final term = FakeTerminal();
      final section = ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        successMessage: 'Build succeeded',
        elapsed: () => const Duration(seconds: 2),
        scheduleTicker: _noTicker,
      )..appendLine('noise');

      section.clear();

      expect(term.output, contains('Build succeeded (2.0s)'));
      expect(term.output, endsWith('\n\x1b[?25h'));
    });

    test('when color is supported then the spinner is green and the elapsed is '
        'gray', () {
      final term = FakeTerminal(supportsColor: true);
      ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        elapsed: () => const Duration(milliseconds: 0),
        scheduleTicker: _noTicker,
      );

      expect(term.output, contains('\x1b[92m\u280b\x1b[0m Building '));
      expect(term.output, contains('\x1b[90m(0ms)\x1b[0m'));
    });

    test('when finished with color then the failed message keeps a gray '
        'elapsed time', () {
      final term = FakeTerminal(supportsColor: true);
      final section = ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        failedMessage: 'Build failed',
        elapsed: () => const Duration(milliseconds: 500),
        scheduleTicker: _noTicker,
      )..appendLine('boom');

      section.keep();

      expect(term.output, contains('Build failed \x1b[90m(0.5s)\x1b[0m'));
    });

    test('when finished with keep then the spinner is replaced with a failure '
        'icon', () {
      final term = FakeTerminal();
      final section = ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        failedMessage: 'Build failed',
        elapsed: () => const Duration(seconds: 1),
        scheduleTicker: _noTicker,
      );

      section.keep();

      expect(term.output, contains('\u2717 Build failed (1.0s)'));
    });

    test('when finished with clear then the spinner is replaced with a success '
        'icon', () {
      final term = FakeTerminal();
      final section = ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        successMessage: 'Build succeeded',
        elapsed: () => const Duration(seconds: 1),
        scheduleTicker: _noTicker,
      );

      section.clear();

      expect(term.output, contains('\u2713 Build succeeded (1.0s)'));
    });

    test(
      'when finished with color then the icons are green for success and red '
      'for failure',
      () {
        final successTerm = FakeTerminal(supportsColor: true);
        ScrollingSection(
          terminal: successTerm,
          rows: 3,
          heading: 'Building',
          elapsed: () => Duration.zero,
          scheduleTicker: _noTicker,
        ).clear();
        expect(successTerm.output, contains('\x1b[92m\u2713\x1b[0m Building'));

        final failTerm = FakeTerminal(supportsColor: true);
        ScrollingSection(
          terminal: failTerm,
          rows: 3,
          heading: 'Building',
          elapsed: () => Duration.zero,
          scheduleTicker: _noTicker,
        ).keep();
        expect(failTerm.output, contains('\x1b[91m\u2717\x1b[0m Building'));
      },
    );

    test('when the terminal is not interactive then no spinner or elapsed is '
        'shown', () {
      final term = FakeTerminal(hasTerminal: false);
      ScrollingSection(
        terminal: term,
        rows: 3,
        heading: 'Building',
        elapsed: () => Duration.zero,
        scheduleTicker: _noTicker,
      );

      expect(term.output, contains('Building'));
      expect(term.output, isNot(contains('\u280b')));
      expect(term.output, isNot(contains('(0ms)')));
    });
  });
}

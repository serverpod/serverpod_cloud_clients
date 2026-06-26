import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/src/select_list.dart';
import 'package:test/test.dart';

import 'helpers/fake_terminal.dart';

const _down = [0x1b, 0x5b, 0x42];
const _up = [0x1b, 0x5b, 0x41];
const _enter = [0x0d];
const _space = [0x20];
const _escape = [0x1b];
const _ctrlC = [0x03];

void main() {
  group('Given a single-select SelectList', () {
    test(
      'when navigating down and confirming then it returns the choice',
      () async {
        final term = FakeTerminal();
        final future = SelectList.choose<String>(
          options: ['Apple', 'Banana', 'Cherry'],
          terminal: term,
        );

        await pumpEventQueue();
        term.sendBytes(_down);
        await pumpEventQueue();
        term.sendBytes(_enter);

        expect(await future, 'Banana');
        expect(term.enableRawModeCount, 1);
        expect(term.disableRawModeCount, 1);
      },
    );

    test('when a selection is made then the hint row is cleared and the '
        'cursor is left at its start for subsequent output', () async {
      final term = FakeTerminal();
      final future = SelectList.choose<String>(
        prompt: 'Pick one',
        options: ['Apple', 'Banana'],
        terminal: term,
      );

      await pumpEventQueue();
      term.sendBytes(_enter);
      await future;

      // Output ends by moving to the start of the hint row and clearing it
      // (no trailing newline), so the next output starts there.
      expect(term.output, endsWith('\r\x1b[0J\x1b[?25h'));
    });

    test('when pressing Escape then it returns null', () async {
      final term = FakeTerminal();
      final future = SelectList.choose<String>(
        options: ['Apple', 'Banana'],
        terminal: term,
      );

      await pumpEventQueue();
      term.sendBytes(_escape);

      expect(await future, isNull);
    });

    test('when pressing Ctrl+C then it throws UserAbortException and '
        'restores the terminal', () async {
      final term = FakeTerminal();
      final future = SelectList.choose<String>(
        options: ['Apple', 'Banana'],
        terminal: term,
      );

      await pumpEventQueue();
      term.sendBytes(_ctrlC);

      await expectLater(future, throwsA(isA<UserAbortException>()));
      expect(term.disableRawModeCount, 1);
    });

    test(
      'when an interrupt signal is received then it throws '
      'UserAbortException and restores the terminal the same way as cancel',
      () async {
        final term = FakeTerminal();
        final future = SelectList.choose<String>(
          options: ['Apple', 'Banana'],
          terminal: term,
        );

        await pumpEventQueue();
        term.sendInterrupt();

        await expectLater(future, throwsA(isA<UserAbortException>()));
        expect(term.enableRawModeCount, 1);
        expect(term.disableRawModeCount, 1);
        expect(term.rawModeEnabled, isFalse);
      },
    );

    test('when the input stream closes then it returns null', () async {
      final term = FakeTerminal();
      final future = SelectList.choose<String>(
        options: ['Apple'],
        terminal: term,
      );

      await pumpEventQueue();
      await term.close();

      expect(await future, isNull);
      expect(term.disableRawModeCount, 1);
    });
  });

  group('Given a multi-select SelectList', () {
    test('when toggling several items then it returns all of them', () async {
      final term = FakeTerminal();
      final future = SelectList.chooseMultiple<String>(
        options: ['Apple', 'Banana', 'Cherry'],
        terminal: term,
      );

      await pumpEventQueue();
      term.sendBytes(_space); // Apple
      await pumpEventQueue();
      term.sendBytes(_down);
      await pumpEventQueue();
      term.sendBytes(_down);
      await pumpEventQueue();
      term.sendBytes(_space); // Cherry
      await pumpEventQueue();
      term.sendBytes(_enter);

      expect(await future, ['Apple', 'Cherry']);
    });

    test(
      'when nothing is selected and min is 1 then Enter is ignored',
      () async {
        final term = FakeTerminal();
        final future = SelectList.chooseMultiple<String>(
          options: ['Apple', 'Banana'],
          minSelections: 1,
          terminal: term,
        );

        await pumpEventQueue();
        term.sendBytes(_enter); // ignored, nothing selected
        await pumpEventQueue();
        term.sendBytes(_space); // Apple
        await pumpEventQueue();
        term.sendBytes(_enter);

        expect(await future, ['Apple']);
      },
    );
  });

  group('Given the same terminal used for several prompts in a row', () {
    test(
      'when running a second prompt then it does not fail to listen',
      () async {
        final term = FakeTerminal();

        final firstFuture = SelectList.choose<String>(
          options: ['Apple', 'Banana'],
          terminal: term,
        );
        await pumpEventQueue();
        term.sendBytes(_down);
        await pumpEventQueue();
        term.sendBytes(_enter);
        expect(await firstFuture, 'Banana');

        // Re-using the terminal previously threw
        // "Bad state: Stream has already been listened to".
        final secondFuture = SelectList.chooseMultiple<String>(
          options: ['Sprinkles', 'Caramel', 'Nuts'],
          terminal: term,
        );
        await pumpEventQueue();
        term.sendBytes(_space); // Sprinkles
        await pumpEventQueue();
        term.sendBytes(_enter);

        expect(await secondFuture, ['Sprinkles']);
        expect(term.enableRawModeCount, 2);
        expect(term.disableRawModeCount, 2);
      },
    );
  });

  group('Given a multi-line prompt', () {
    test('when re-rendering after navigation then the prompt is printed only '
        'once and excluded from re-renders', () async {
      const prompt = 'Choose an option:\nMore details on a second line';
      final term = FakeTerminal();
      final future = SelectList.choose<String>(
        prompt: prompt,
        options: ['Apple', 'Banana', 'Cherry'],
        terminal: term,
      );

      await pumpEventQueue();
      // Trigger several re-renders by navigating.
      term.sendBytes(_down);
      await pumpEventQueue();
      term.sendBytes(_down);
      await pumpEventQueue();
      term.sendBytes(_up);
      await pumpEventQueue();
      term.sendBytes(_enter);

      expect(await future, 'Banana');
      // The prompt is rendered exactly once, above the re-rendered region.
      expect(prompt.allMatches(term.output).length, 1);
    });
  });

  group('Given a custom label mapper', () {
    test('when rendering then the mapped labels are shown', () async {
      final term = FakeTerminal();
      final future = SelectList.choose<int>(
        options: [1, 2, 3],
        label: (final n) => 'Number $n',
        terminal: term,
      );

      await pumpEventQueue();
      expect(term.output, contains('Number 1'));

      term.sendBytes(_up); // stays at top
      await pumpEventQueue();
      term.sendBytes(_enter);

      expect(await future, 1);
    });
  });
}

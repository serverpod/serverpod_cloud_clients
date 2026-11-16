import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/src/suggested_value_input.dart';
import 'package:test/test.dart';

import 'helpers/fake_terminal.dart';

const _down = [0x1b, 0x5b, 0x42];
const _up = [0x1b, 0x5b, 0x41];
const _enter = [0x0d];
const _escape = [0x1b];
const _ctrlC = [0x03];

void main() {
  group('Given a SuggestedValueInput', () {
    late FakeTerminal terminal;
    late Future<String?> result;

    setUp(() {
      terminal = FakeTerminal();
      result = SuggestedValueInput.read(
        terminal: terminal,
        prompt: 'Choose a new bundle ID:',
        suggestion: 'space.serverpod.app',
        suggestionLabel: 'Use space.serverpod.app',
        entryLabel: 'Bundle ID',
        entryPlaceholder: 'Enter a different bundle ID',
        hint: 'First line.\nSecond line.',
        validate: (value) => value.contains('_') ? 'Not valid.' : null,
      );
    });

    test('when it is shown then the suggestion and the input placeholder are '
        'listed, without the hint', () async {
      await pumpEventQueue();
      terminal.sendBytes(_escape);
      await result;

      expect(
        terminal.output,
        allOf(
          contains(
            '> (*) Use space.serverpod.app\n'
            '  ( ) Enter a different bundle ID\n'
            '\n'
            'up/down move, enter confirm, esc cancel',
          ),
          isNot(contains('First line.')),
        ),
      );
    });

    test('when pressing Enter then the suggestion is returned', () async {
      await pumpEventQueue();
      terminal.sendBytes(_enter);

      expect(await result, 'space.serverpod.app');
    });

    test('when moving to the input then the hint is shown beneath it after a '
        'blank line', () async {
      await pumpEventQueue();
      terminal.sendBytes(_down);
      await pumpEventQueue();
      terminal.sendBytes(_escape);
      await result;

      expect(
        terminal.output,
        contains(
          '> (*) Bundle ID: _\n'
          '\n'
          '      First line.\n'
          '      Second line.\n',
        ),
      );
    });

    test(
      'when typing and pressing Enter then the typed value is returned',
      () async {
        await pumpEventQueue();
        terminal.sendBytes([...'com.acme.app'.codeUnits, ..._enter]);

        expect(await result, 'com.acme.app');
      },
    );

    test(
      'when typing and pressing Enter then one line shows the value',
      () async {
        await pumpEventQueue();
        terminal.sendBytes([...'com.acme.app'.codeUnits, ..._enter]);
        await result;

        expect(terminal.output, endsWith('Bundle ID: com.acme.app\n\x1b[?25h'));
      },
    );

    test(
      'when typing, going back up and pressing Enter '
      'then the suggestion is returned without printing the prompt again',
      () async {
        await pumpEventQueue();
        terminal.sendBytes('com.acme'.codeUnits);
        await pumpEventQueue();
        terminal.sendBytes(_up);
        await pumpEventQueue();
        terminal.sendBytes(_enter);

        expect(await result, 'space.serverpod.app');
        expect(
          'Choose a new bundle ID:'.allMatches(terminal.output),
          hasLength(1),
        );
      },
    );

    test('when confirming a value that fails validation '
        'then the error is shown and the input continues', () async {
      await pumpEventQueue();
      terminal.sendBytes([...'com.my_app'.codeUnits, ..._enter]);
      await pumpEventQueue();

      expect(terminal.output, contains('      Not valid.'));

      terminal.sendBytes(_escape);
      expect(await result, isNull);
    });

    test('when pressing Escape then null is returned', () async {
      await pumpEventQueue();
      terminal.sendBytes(_escape);

      expect(await result, isNull);
    });

    test('when pressing Ctrl+C then throws UserAbortException', () async {
      await pumpEventQueue();
      terminal.sendBytes(_ctrlC);

      await expectLater(result, throwsA(isA<UserAbortException>()));
    });

    test('when it ends then raw mode is disabled', () async {
      await pumpEventQueue();
      terminal.sendBytes(_escape);
      await result;

      expect(terminal.rawModeEnabled, isFalse);
    });
  });

  group('Given a hint longer than the width', () {
    test('when wrapping it then it breaks at the last space that fits', () {
      expect(wrapText('one two three four', 9), ['one two', 'three', 'four']);
    });
  });

  group('Given a hint with line breaks', () {
    test('when wrapping it then each line starts a new line', () {
      expect(wrapText('one two\nthree', 80), ['one two', 'three']);
    });
  });

  group('Given a hint with a word longer than the width', () {
    test('when wrapping it then the word gets a line of its own', () {
      expect(wrapText('a com.yourcompany.app b', 5), [
        'a',
        'com.yourcompany.app',
        'b',
      ]);
    });
  });
}

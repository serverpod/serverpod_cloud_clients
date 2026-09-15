import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Given text that fits when fitted to the columns then it is unchanged',
    () {
      expect(fitAnsiToColumns('hello', 10), 'hello');
    },
  );

  test(
    'Given text wider than the columns when fitted then it is clipped with an ellipsis',
    () {
      expect(fitAnsiToColumns('hello world', 6), 'hell…');
    },
  );

  test(
    'Given colored text when fitted then escape sequences do not count as columns',
    () {
      const text = '\x1b[32mhello\x1b[0m';

      expect(fitAnsiToColumns(text, 6), text);
    },
  );

  test(
    'Given colored text wider than the columns when fitted with closeStyles then it ends with a reset',
    () {
      const text = '\x1b[90mhello world\x1b[0m';

      expect(
        fitAnsiToColumns(text, 6, closeStyles: true),
        '\x1b[90mhell…\x1b[0m',
      );
    },
  );

  test(
    'Given emoji wider than the columns when fitted then no emoji is split',
    () {
      expect(fitAnsiToColumns('😀😀😀', 3), '😀…');
    },
  );

  test(
    'Given an emoji and one column of room when fitted then the whole emoji is kept',
    () {
      expect(fitAnsiToColumns('😀x', 2), '😀');
    },
  );

  test(
    'Given a combining mark wider than the columns when fitted then it stays with its base letter',
    () {
      expect(fitAnsiToColumns('éxyz', 3), 'é…');
    },
  );
}

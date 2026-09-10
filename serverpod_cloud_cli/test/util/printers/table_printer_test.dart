import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:test/test.dart';

const _gray = '\x1B[90m';
const _reset = '\x1B[0m';

final _ansiStyleCode = RegExp(r'\x1B\[[0-9;]*m');

List<String> renderLines(final TablePrinter printer) {
  final lines = <String>[];
  printer.writeLines(lines.add);
  return lines;
}

String visible(final String line) => line.replaceAll(_ansiStyleCode, '');

void main() {
  group('Given a table with unstyled cells', () {
    test('when rendered then each column is padded to its widest cell', () {
      final lines = renderLines(
        TablePrinter(
          rows: [
            ['Project', 'my-project'],
            ['Database', 'small'],
          ],
          columnSeparator: '  ',
        ),
      );

      expect(lines, ['Project   my-project', 'Database  small     ']);
    });
  });

  group('Given a table whose first column is ANSI-styled', () {
    late List<String> lines;

    setUp(() {
      lines = renderLines(
        TablePrinter(
          rows: [
            ['${_gray}Project$_reset', 'my-project'],
            ['${_gray}Database$_reset', 'small'],
          ],
          columnSeparator: '  ',
        ),
      );
    });

    test('then the columns are padded to their visible width', () {
      expect(lines.map(visible), [
        'Project   my-project',
        'Database  small     ',
      ]);
    });

    test('then the style codes are preserved', () {
      expect(lines.first, startsWith(_gray));
      expect(lines.first, contains(_reset));
    });
  });

  group('Given a table with an ANSI-styled header', () {
    test('when rendered then the divider matches the visible width', () {
      final lines = renderLines(
        TablePrinter(
          headers: ['${_gray}Name$_reset'],
          rows: [
            ['alpha'],
          ],
        ),
      );

      expect(visible(lines[0]), 'Name ');
      expect(lines[1], '-----');
    });
  });
}

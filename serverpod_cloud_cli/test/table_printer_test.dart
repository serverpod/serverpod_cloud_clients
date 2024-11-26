import 'package:test/test.dart';
import 'package:serverpod_cloud_cli/util/table_printer.dart';

void main() async {
  group('Given an empty TablePrinter', () {
    final tablePrinter = TablePrinter();

    test('then the produced string is a no-rows symbol.', () {
      expect(tablePrinter.toString(), '<no rows data>\n');
    });

    test('then the produced stream is empty.', () async {
      expect(
        await tablePrinter.toStream(null).toList(),
        isEmpty,
      );
    });

    test('then the row count is zero.', () {
      expect(tablePrinter.rowCount, isZero);
    });
  });

  group('Given a TablePrinter with just a single column header', () {
    final tablePrinter = TablePrinter(
      headers: ['Header'],
    );

    test(
        'then the produced string contains the single header as well as a separator line and a no-rows symbol.',
        () {
      expect(
          tablePrinter.toString(),
          'Header\n'
          '------\n'
          '<no rows data>\n');
    });

    test(
        'then the produced stream contains the single header and separator line.',
        () async {
      expect(
        await tablePrinter.toStream(null).toList(),
        ['Header\n------\n'],
      );
    });

    test('then the row count is zero.', () {
      expect(tablePrinter.rowCount, isZero);
    });
  });

  group('Given a TablePrinter with just a header with 3 columns', () {
    final tablePrinter = TablePrinter(
      headers: ['Col1', 'Col2', 'Col3'],
    );

    test(
        'then the produced string contains all three columns as well as a seperator line and a no-rows symbol.',
        () {
      expect(
        tablePrinter.toString(),
        'Col1 | Col2 | Col3\n'
        '-----+------+-----\n'
        '<no rows data>\n',
      );
    });
  });

  group('Given a TablePrinter with just 1 row with 1 cell', () {
    final tablePrinter = TablePrinter(
      rows: [
        ['Cell1'],
      ],
    );

    test('then the produced string is a line with just the single value.', () {
      expect(
        tablePrinter.toString(),
        'Cell1\n',
      );
    });

    test('then the produced stream is a line with just the single value.',
        () async {
      expect(
        await tablePrinter.toStream(null).toList(),
        ['Cell1\n'],
      );
    });

    test('then the row count is one.', () {
      expect(tablePrinter.rowCount, 1);
    });
  });

  group('Given a TablePrinter with 1 row with 3 cells', () {
    final tablePrinter = TablePrinter(
      rows: [
        ['Cell1', 'Cell2', 'Cell3'],
      ],
    );

    test(
        'then the produced string is a line with the three cell values with column separators between them.',
        () {
      expect(
        tablePrinter.toString(),
        'Cell1 | Cell2 | Cell3\n',
      );
    });

    test(
        'then the produced stream is a line with the three cell values with column separators between them.',
        () async {
      expect(
        await tablePrinter.toStream(null).toList(),
        ['Cell1 | Cell2 | Cell3\n'],
      );
    });

    test('then the row count is one.', () {
      expect(tablePrinter.rowCount, 1);
    });
  });

  group('Given a TablePrinter with header and irregular rows content', () {
    final tablePrinter = TablePrinter(
      headers: ['Col1', 'Col2', 'Col3----------'],
      rows: [
        ['Row1-Cell1', 'Row1-Cell2----', 'Row1-Cell3'],
        ['Row2-Cell1-', 'Row2-Cell2---'],
        ['Row3-Cell1--', 'Row3-Cell2--', 'Row3-Cell3', 'Row3-Cell4'],
        [
          'Row4-Cell1---',
          'Row4-Cell2-',
          'Row4-Cell3',
          'Row4-Cell4     ',
          'Row4-Cell5'
        ],
        ['Row5-Cell1----', 'Row5-Cell2', 'Row5-Cell3', null, 'Row5-Cell5'],
      ],
    );

    test('then the produced string is a correctly aligned table.', () {
      expect(tablePrinter.toString(), '''
Col1           | Col2           | Col3---------- |                 |           
---------------+----------------+----------------+-----------------+-----------
Row1-Cell1     | Row1-Cell2---- | Row1-Cell3     |                 |           
Row2-Cell1-    | Row2-Cell2---  |                |                 |           
Row3-Cell1--   | Row3-Cell2--   | Row3-Cell3     | Row3-Cell4      |           
Row4-Cell1---  | Row4-Cell2-    | Row4-Cell3     | Row4-Cell4      | Row4-Cell5
Row5-Cell1---- | Row5-Cell2     | Row5-Cell3     |                 | Row5-Cell5
''');
    });

    test('then the produced stream is a correctly aligned table.', () async {
      expect(
        await tablePrinter.toStream(null).toList(),
        [
          'Col1           | Col2           | Col3---------- |                 |           \n'
              '---------------+----------------+----------------+-----------------+-----------\n',
          'Row1-Cell1     | Row1-Cell2---- | Row1-Cell3     |                 |           \n',
          'Row2-Cell1-    | Row2-Cell2---  |                |                 |           \n',
          'Row3-Cell1--   | Row3-Cell2--   | Row3-Cell3     | Row3-Cell4      |           \n',
          'Row4-Cell1---  | Row4-Cell2-    | Row4-Cell3     | Row4-Cell4      | Row4-Cell5\n',
          'Row5-Cell1---- | Row5-Cell2     | Row5-Cell3     |                 | Row5-Cell5\n',
        ],
      );
    });

    test('then the row count is 5.', () {
      expect(tablePrinter.rowCount, 5);
    });
  });
}

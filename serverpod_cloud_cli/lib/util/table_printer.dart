import 'package:collection/collection.dart';

import 'common.dart';

/// Helper class for formatting text as a table of rows with aligned columns.
/// It supports an optional header.
class TablePrinter {
  final List<String?> _columnHeaders;
  final List<int?> _columnMinWidths;
  final List<List<String?>> _rows;

  TablePrinter({
    final Iterable<String?>? headers,
    final Iterable<int?>? columnMinWidths,
    final Iterable<List<String?>>? rows,
  })  : _columnHeaders = List.from(headers ?? <String?>[]),
        _columnMinWidths = List.from(columnMinWidths ?? <int?>[]),
        _rows = List.from(rows ?? <List<String?>>[]);

  /// Adds column headers to the table.
  /// Can be called multiple times.
  void addHeaders(final Iterable<String?> headers) {
    _columnHeaders.addAll(headers);
  }

  /// Adds a row to the table.
  /// Can be called multiple times.
  void addRow(final Iterable<String?> row) {
    _rows.add(List.from(row));
  }

  /// Converts the table content to a formatted string.
  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();

    final nofColumns = max([
      _columnMinWidths,
      _columnHeaders,
      ..._rows,
    ].map((final ls) => ls.length));

    final columnWidths = List.generate(
        nofColumns,
        (final colIx) => max([
              _columnMinWidths.elementAtOrNull(colIx) ?? 0,
              _columnHeaders.elementAtOrNull(colIx)?.length ?? 0,
              ..._rows
                  .map((final row) => row.elementAtOrNull(colIx)?.length ?? 0),
            ]));

    if (_columnHeaders.isNotEmpty) {
      buffer.writeln(List.generate(
        nofColumns,
        (final colIx) => (_columnHeaders.elementAtOrNull(colIx) ?? '')
            .padRight(columnWidths[colIx]),
      ).join(' | '));

      buffer.writeln(
        columnWidths.map((final width) {
          return '-' * (width);
        }).join('-+-'),
      );
    }

    for (final row in _rows) {
      buffer.writeln(List.generate(
        nofColumns,
        (final colIx) =>
            (row.elementAtOrNull(colIx) ?? '').padRight(columnWidths[colIx]),
      ).join(' | '));
    }

    return buffer.toString();
  }
}

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

  /// Gets the number of rows currently added to this table.
  int get rowCount => _rows.length;

  /// Converts the table content to a stream of formatted strings,
  /// one for each row.
  ///
  /// The produced strings are not terminated with a newline.
  ///
  /// If this table already has rows, they will be included
  /// first in the stream and the column widths will be based on them.
  /// Subsequent rows might break the alignment if they have wider content.
  Stream<String> toStream(
    final Stream<Iterable<String>>? rowStream, {
    final int? limit,
  }) async* {
    final columnWidths = _getColumnWidths();

    if (_columnHeaders.isNotEmpty) {
      final headerLines = _formatHeader(columnWidths);
      for (final line in headerLines) {
        yield line;
      }
    }

    int count = 0;
    for (final row in _rows) {
      yield _formatLine(columnWidths, row);
      if (limit != null && ++count >= limit) return;
    }
    await for (final row in rowStream ?? Stream.empty()) {
      yield _formatLine(columnWidths, row);
      if (limit != null && ++count >= limit) return;
    }
  }

  /// Converts the table content to a formatted string,
  /// with rows separated by newlines.
  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();

    writeLines(buffer.writeln);

    return buffer.toString();
  }

  /// Puts the table content to the provided sink line by line.
  /// The line strings are not terminated with a newline.
  void writeLines(final void Function(String) lineSink) {
    final columnWidths = _getColumnWidths();

    if (_columnHeaders.isNotEmpty) {
      _formatHeader(columnWidths).forEach(lineSink);
    }

    if (_rows.isEmpty) {
      lineSink('<no rows data>');
    }

    for (final row in _rows) {
      lineSink(_formatLine(columnWidths, row));
    }
  }

  List<String> _formatHeader(final List<int> columnWidths) {
    final headerNames = List.generate(
      columnWidths.length,
      (final colIx) => (_columnHeaders.elementAtOrNull(colIx) ?? '')
          .padRight(columnWidths[colIx]),
    ).join(' | ');

    final headerDivider = columnWidths.map((final width) {
      return '-' * (width);
    }).join('-+-');

    return [headerNames, headerDivider];
  }

  String _formatLine(final List<int> columnWidths, final List<String?> row) {
    final line = List.generate(
      columnWidths.length,
      (final colIx) =>
          (row.elementAtOrNull(colIx) ?? '').padRight(columnWidths[colIx]),
    ).join(' | ');
    return line;
  }

  List<int> _getColumnWidths() {
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
    return columnWidths;
  }
}

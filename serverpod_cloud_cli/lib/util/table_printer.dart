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
  /// If this table already has rows, they will be included
  /// first in the stream and the column widths will be based on them.
  /// Subsequent rows might break the alignment if they have wider content.
  Stream<String> toStream(
    final Stream<Iterable<String>>? rowStream, {
    final int? limit,
  }) async* {
    final columnWidths = _getColumnWidths();

    if (_columnHeaders.isNotEmpty) {
      yield _formatHeader(columnWidths);
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

  /// Converts the table content to a formatted string.
  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();

    final columnWidths = _getColumnWidths();

    if (_columnHeaders.isNotEmpty) {
      buffer.write(_formatHeader(columnWidths));
      if (_rows.isEmpty) {
        buffer.write(_formatEmptyLine(columnWidths));
      }
    }

    for (final row in _rows) {
      buffer.write(_formatLine(columnWidths, row));
    }

    return buffer.toString();
  }

  String _formatHeader(final List<int> columnWidths) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(List.generate(
      columnWidths.length,
      (final colIx) => (_columnHeaders.elementAtOrNull(colIx) ?? '')
          .padRight(columnWidths[colIx]),
    ).join(' | '));

    buffer.writeln(
      columnWidths.map((final width) {
        return '-' * (width);
      }).join('-+-'),
    );
    return buffer.toString();
  }

  String _formatEmptyLine(final List<int> columnWidths) {
    final line = List.generate(
      columnWidths.length,
      (final colIx) => ('<empty>').padRight(columnWidths[colIx]),
    ).join(' | ');

    return '$line\n';
  }

  String _formatLine(final List<int> columnWidths, final List<String?> row) {
    final line = List.generate(
      columnWidths.length,
      (final colIx) =>
          (row.elementAtOrNull(colIx) ?? '').padRight(columnWidths[colIx]),
    ).join(' | ');
    return '$line\n';
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

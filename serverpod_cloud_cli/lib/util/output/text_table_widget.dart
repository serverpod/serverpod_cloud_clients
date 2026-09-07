import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

import 'output_context.dart';
import 'output_formatter.dart';
import 'output_widget.dart';

/// Text table rendering widget.
///
/// Commands will typically not use this directly,
/// see [FormattedTableWidget] instead.
class TextTableWidget extends OutputWidget {
  final TextTableData content;
  final List<int?>? columnMinWidths;
  final String? columnSeparator;
  final String? headerDividerColumnSeparator;

  const TextTableWidget(
    this.content, {
    this.columnMinWidths,
    this.columnSeparator,
    this.headerDividerColumnSeparator,
  });

  @override
  void render({required CommandLogger logger}) {
    final printer = TablePrinter(
      headers: content.headers,
      rows: content.rows,
      columnMinWidths: columnMinWidths,
      columnSeparator: columnSeparator,
      headerDividerColumnSeparator: headerDividerColumnSeparator,
    );
    printer.writeLines(logger.line);
  }
}

/// User-friendly text table widget.
///
/// R is the row object / list element type.
class FormattedTableWidget<R extends Object> extends OutputWidget {
  final TextTableOutputFormatter<R> formatter;
  final List<int?>? columnMinWidths;
  final String? columnSeparator;
  final String? headerDividerColumnSeparator;

  const FormattedTableWidget({
    required this.formatter,
    this.columnMinWidths,
    this.columnSeparator,
    this.headerDividerColumnSeparator,
  });

  @override
  OutputWidget build(OutputContext context) {
    final object = context.get<List<R>>();
    final content = formatter.format(object);
    return TextTableWidget(
      content,
      columnMinWidths: columnMinWidths,
      columnSeparator: columnSeparator,
      headerDividerColumnSeparator: headerDividerColumnSeparator,
    );
  }
}

class TextTableData {
  final List<String> headers;
  final List<List<String>> rows;

  TextTableData(this.headers, this.rows);
}

/// Formatting of a column, its heading and its cell value formatter.
///
/// R is the row object type.
class TableColumnFormatter<R extends Object> {
  final String heading;
  final ValueFormatter<R> formatter;

  const TableColumnFormatter(this.heading, {required this.formatter});

  TableColumnFormatter.forElement(
    this.heading, {
    required ValueGetter<R> getter,
  }) : formatter = objValueFormatter(getter: getter);

  static TableColumnFormatter<Map<String, Object?>> forKey(
    String heading, {
    required String key,
  }) {
    return TableColumnFormatter<Map<String, Object?>>(
      heading,
      formatter: mapValueFormatter<Map<String, Object?>>(key: key),
    );
  }
}

/// Formats a list of row objects into a [TextTableData] object,
/// needed for [FormattedTableWidget].
///
/// Composes a list of [TableColumnFormatter] objects for the columns and their
/// headings.
///
/// R is the row object type.
class TextTableOutputFormatter<R extends Object>
    extends OutputFormatter<List<R>, TextTableData> {
  final List<TableColumnFormatter<R>> columns;

  const TextTableOutputFormatter({required this.columns, required super.utc});

  @override
  TextTableData format(List<R> objects) {
    return TextTableData(headings, [for (final obj in objects) formatRow(obj)]);
  }

  List<String> get headings => [for (final column in columns) column.heading];

  List<String> formatRow(R object) {
    return [for (final column in columns) column.formatter(object, utc: utc)];
  }
}

/// Streams a text table: headers first, then one row as each element arrives.
///
/// R is the row object / stream element type.
class FormattedStreamTableWidget<R extends Object> extends OutputWidget {
  final TextTableOutputFormatter<R> formatter;
  final List<int?>? columnMinWidths;
  final String? columnSeparator;
  final String? headerDividerColumnSeparator;
  final Iterable<String> Function(int rowCount)? footerLines;

  const FormattedStreamTableWidget({
    required this.formatter,
    this.columnMinWidths,
    this.columnSeparator,
    this.headerDividerColumnSeparator,
    this.footerLines,
  });

  @override
  OutputWidget build(OutputContext context) {
    return _StreamTableWidget(
      stream: context.get<Stream<R>>(),
      formatter: formatter,
      columnMinWidths: columnMinWidths,
      columnSeparator: columnSeparator,
      headerDividerColumnSeparator: headerDividerColumnSeparator,
      footerLines: footerLines,
    );
  }
}

class _StreamTableWidget<R extends Object> extends OutputWidget {
  final Stream<R> stream;
  final TextTableOutputFormatter<R> formatter;
  final List<int?>? columnMinWidths;
  final String? columnSeparator;
  final String? headerDividerColumnSeparator;
  final Iterable<String> Function(int rowCount)? footerLines;

  const _StreamTableWidget({
    required this.stream,
    required this.formatter,
    this.columnMinWidths,
    this.columnSeparator,
    this.headerDividerColumnSeparator,
    this.footerLines,
  });

  @override
  Future<void> renderAsync({required CommandLogger logger}) async {
    var count = 0;
    final printer = TablePrinter(
      headers: formatter.headings,
      columnMinWidths: columnMinWidths,
      columnSeparator: columnSeparator,
      headerDividerColumnSeparator: headerDividerColumnSeparator,
    );
    final tableStream = printer.toStream(
      stream.map((final row) {
        count++;
        return formatter.formatRow(row);
      }),
    );
    await for (final line in tableStream) {
      logger.line(line.trimRight());
    }
    final footer = footerLines;
    if (footer == null) {
      return;
    }
    for (final line in footer(count)) {
      logger.line(line);
    }
  }
}

class StringColumnListWidget extends OutputWidget {
  final String heading;

  const StringColumnListWidget({required this.heading});

  @override
  OutputWidget build(OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter(
        columns: [
          TableColumnFormatter<String>.forElement(
            heading,
            getter: (value) => value,
          ),
        ],
        utc: false,
      ),
    );
  }
}

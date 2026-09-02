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
    final headers = [for (final column in columns) column.heading];

    return TextTableData(headers, [
      for (final obj in objects)
        [for (final column in columns) column.formatter(obj, utc: utc)],
    ]);
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

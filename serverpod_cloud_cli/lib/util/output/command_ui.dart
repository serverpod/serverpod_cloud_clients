import 'output_context.dart';
import 'output_format.dart';
import 'output_formatter.dart';
import 'text_table_widget.dart';
import 'widgets.dart';

/// A top-level command output widget that composes output widgets for different
/// output formats (text, json, yaml).
class CommandWidget extends OutputWidget {
  final OutputWidget textOutputUi;
  final OutputWidget jsonOutputUi;
  final OutputWidget yamlOutputUi;

  const CommandWidget({
    required this.textOutputUi,
    required this.jsonOutputUi,
    required this.yamlOutputUi,
  });

  /// Convenience constructor that auto-creates standard json and yaml widgets.
  CommandWidget.text({required this.textOutputUi})
    : jsonOutputUi = FormattedStringWidget(formatter: JsonOutputFormatter()),
      yamlOutputUi = FormattedStringWidget(formatter: YamlOutputFormatter());

  @override
  OutputWidget build(final OutputContext context) {
    final format = context.format;
    final error = context.error;
    if (error != null) {
      return switch (format) {
        OutputFormat.text => TextErrorWidget(error),
        OutputFormat.json => JsonErrorWidget(error),
        OutputFormat.yaml => YamlErrorWidget(error),
      };
    }
    return switch (format) {
      OutputFormat.text => textOutputUi,
      OutputFormat.json => jsonOutputUi,
      OutputFormat.yaml => yamlOutputUi,
    };
  }
}

/// A top command output widget for the common case of listing strings as a
/// single column with a heading.
class StringColumnListUi extends OutputWidget {
  final String heading;

  const StringColumnListUi({required this.heading});

  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(
      textOutputUi: StringColumnListWidget(heading: heading),
    );
  }
}

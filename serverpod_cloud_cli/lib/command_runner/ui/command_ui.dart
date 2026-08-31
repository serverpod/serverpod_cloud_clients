import 'package:serverpod_cloud_cli/util/output/output.dart';

/// A top-level command output widget that composes output widgets for different
/// output formats (text, json, yaml).
///
/// textOutputUi, jsonOutputUi, yamlOutputUi: Rendered on success.
///
/// textErrorUi, jsonErrorUi, yamlErrorUi: Rendered on error, typically an Exception.
class CommandWidget extends OutputWidget {
  final OutputWidget textOutputUi;
  final OutputWidget jsonOutputUi;
  final OutputWidget yamlOutputUi;
  final OutputWidget textErrorUi;
  final OutputWidget jsonErrorUi;
  final OutputWidget yamlErrorUi;

  const CommandWidget({
    required this.textOutputUi,
    required this.jsonOutputUi,
    required this.yamlOutputUi,
    required this.textErrorUi,
    required this.jsonErrorUi,
    required this.yamlErrorUi,
  });

  /// Convenience constructor that auto-creates standard json, yaml, and error
  /// widgets unless provided.
  CommandWidget.text({
    required this.textOutputUi,
    final OutputWidget? jsonOutputUi,
    final OutputWidget? yamlOutputUi,
    final OutputWidget? textErrorUi,
    final OutputWidget? jsonErrorUi,
    final OutputWidget? yamlErrorUi,
  }) : jsonOutputUi =
           jsonOutputUi ??
           FormattedStringWidget(formatter: JsonOutputFormatter()),
       yamlOutputUi =
           yamlOutputUi ??
           FormattedStringWidget(formatter: YamlOutputFormatter()),
       textErrorUi = textErrorUi ?? TextErrorWidget(),
       jsonErrorUi = jsonErrorUi ?? JsonErrorWidget(),
       yamlErrorUi = yamlErrorUi ?? YamlErrorWidget();

  @override
  OutputWidget build(final OutputContext context) {
    return FormatBranchingWidget(
      textWidget: ExceptionHandlingWidget(
        elseWidget: textOutputUi,
        errorWidgetMaker: (final e) => textErrorUi,
      ),
      jsonWidget: ExceptionHandlingWidget(
        elseWidget: jsonOutputUi,
        errorWidgetMaker: (final e) => jsonErrorUi,
      ),
      yamlWidget: ExceptionHandlingWidget(
        elseWidget: yamlOutputUi,
        errorWidgetMaker: (final e) => yamlErrorUi,
      ),
    );
  }
}

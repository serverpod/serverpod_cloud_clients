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
    OutputWidget? jsonOutputUi,
    OutputWidget? yamlOutputUi,
    OutputWidget? textErrorUi,
    OutputWidget? jsonErrorUi,
    OutputWidget? yamlErrorUi,
  }) : jsonOutputUi =
           jsonOutputUi ??
           FormattedStringWidget(formatter: JsonOutputFormatter()),
       yamlOutputUi =
           yamlOutputUi ??
           FormattedStringWidget(formatter: YamlOutputFormatter()),
       textErrorUi = textErrorUi ?? TextErrorWidget(),
       jsonErrorUi = jsonErrorUi ?? JsonErrorWidget(),
       yamlErrorUi = yamlErrorUi ?? YamlErrorWidget();

  /// Like [CommandWidget.text], but json/yaml emit one document per stream
  /// element instead of encoding the whole result.
  /// This is also used for operations that conceptually return a single result,
  /// but is awaited as a stream to allow for progress reporting.
  CommandWidget.stream({
    required this.textOutputUi,
    OutputWidget? jsonOutputUi,
    OutputWidget? yamlOutputUi,
    OutputWidget? textErrorUi,
    OutputWidget? jsonErrorUi,
    OutputWidget? yamlErrorUi,
  }) : jsonOutputUi =
           jsonOutputUi ??
           FormattedStreamStringWidget(formatter: JsonOutputFormatter()),
       yamlOutputUi =
           yamlOutputUi ??
           FormattedStreamStringWidget(formatter: YamlOutputFormatter()),
       textErrorUi = textErrorUi ?? TextErrorWidget(),
       jsonErrorUi = jsonErrorUi ?? JsonErrorWidget(),
       yamlErrorUi = yamlErrorUi ?? YamlErrorWidget();

  @override
  OutputWidget build(OutputContext context) {
    return FormatBranchingWidget(
      textWidget: ExceptionHandlingWidget(
        elseWidget: textOutputUi,
        errorWidgetMaker: (e) => textErrorUi,
      ),
      jsonWidget: ExceptionHandlingWidget(
        elseWidget: jsonOutputUi,
        errorWidgetMaker: (e) => jsonErrorUi,
      ),
      yamlWidget: ExceptionHandlingWidget(
        elseWidget: yamlOutputUi,
        errorWidgetMaker: (e) => yamlErrorUi,
      ),
    );
  }
}

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

import 'output_context.dart';

/// Base class for all command output widgets.
abstract class OutputWidget {
  const OutputWidget();

  /// Builds this widget using the output context.
  OutputWidget build(final OutputContext context) => this;

  /// Renders this widget using the given IO facade.
  void render({required final CommandLogger logger}) {}

  WidgetNode buildTree(final OutputContext context) {
    final child = build(context);
    if (child != this) {
      final childNode = child.buildTree(context);
      return WidgetNode(widget: this, children: [childNode]);
    }
    return WidgetNode(widget: this, children: []);
  }
}

class WidgetNode {
  final OutputWidget widget;
  final List<WidgetNode> children;

  WidgetNode({required this.widget, required this.children});

  void renderTree({required final CommandLogger logger}) {
    widget.render(logger: logger);
    for (final child in children) {
      child.renderTree(logger: logger);
    }
  }
}

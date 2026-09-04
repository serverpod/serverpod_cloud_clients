import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

import 'output_context.dart';

/// Base class for all command output widgets.
abstract class OutputWidget {
  const OutputWidget();

  /// Builds this widget using the output context.
  ///
  /// The build method is responsbile for building the tree of widgets below this one.
  /// It must never invoke the build or render methods of other widgets.
  OutputWidget build(OutputContext context) => this;

  /// Renders this widget using the given IO facade.
  ///
  /// The render method is responsible for rendering this widget.
  /// It must never invoke the build or render methods of other widgets.
  void render({required CommandLogger logger}) {}

  /// Renders this widget, awaiting stream or other async output.
  ///
  /// Sync widgets keep [render]; this default calls it and completes.
  /// Stream widgets override this method instead.
  Future<void> renderAsync({required CommandLogger logger}) async {
    render(logger: logger);
  }

  /// Builds the tree of widgets below this one.
  /// This is not usually to be overridden by subclasses.
  WidgetNode buildTree(OutputContext context) {
    final child = build(context);
    if (child != this) {
      final childNode = child.buildTree(context);
      return WidgetNode(widget: this, children: [childNode]);
    }
    return WidgetNode(widget: this, children: []);
  }
}

/// Renders its children in order.
class OutputWidgetList extends OutputWidget {
  final List<OutputWidget> children;

  const OutputWidgetList(this.children);

  @override
  WidgetNode buildTree(OutputContext context) {
    return WidgetNode(
      widget: this,
      children: [for (final child in children) child.buildTree(context)],
    );
  }
}

class WidgetNode {
  final OutputWidget widget;
  final List<WidgetNode> children;

  WidgetNode({required this.widget, required this.children});

  Future<void> renderTree({required CommandLogger logger}) async {
    await widget.renderAsync(logger: logger);
    for (final child in children) {
      await child.renderTree(logger: logger);
    }
  }
}

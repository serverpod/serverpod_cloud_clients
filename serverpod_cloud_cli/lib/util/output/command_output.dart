import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

import 'interactive_widgets.dart';
import 'output_context.dart';
import 'output_format.dart';
import 'output_widget.dart';

/// An "operation" function, for the business logic operations of commands
/// that produce some data that is rendered by the command output.
typedef Operation<O> = Future<O> Function();

/// Facade for the output of a command.
class CommandOutput {
  final OutputFormat format;
  final CommandLogger logger;

  CommandOutput({required this.format, required this.logger});

  /// Runs [operation] and renders [ui].
  ///
  /// Exceptions from the operation, or from consuming a stream result while
  /// rendering, are captured and rendered through the error branch of [ui].
  Future<OutputContext> render<O extends Object>({
    required Operation<O> operation,
    required OutputWidget ui,
  }) async {
    var context = await _doOperation(operation: operation);
    try {
      await ui.buildTree(context).renderTree(logger: logger);
    } on Exception catch (error, stackTrace) {
      if (context.find<QualifiedException>() != null) {
        rethrow;
      }
      context = OutputContext.exception(format, error, stackTrace);
      await ui.buildTree(context).renderTree(logger: logger);
    }
    return context;
  }

  Future<OutputContext> _doOperation<O extends Object>({
    required Operation<O> operation,
  }) async {
    try {
      final data = await operation();
      return OutputContext(format, data);
    } on Exception catch (error, stackTrace) {
      return OutputContext.exception(format, error, stackTrace);
    }
  }

  Future<OutputContext> renderStatic<O extends Object>({
    required OutputWidget ui,
  }) async {
    final context = OutputContext(format);
    await ui.buildTree(context).renderTree(logger: logger);
    return context;
  }

  Future<T> renderInteractive<T extends Object?>({
    required InteractiveWidget<T> ui,
  }) async {
    final context = OutputContext(format);
    await ui.buildTree(context).renderTree(logger: logger);
    return ui.completer.future;
  }
}

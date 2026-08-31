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

  Future<OutputContext> render<O extends Object>({
    required final Operation<O> operation,
    required final OutputWidget ui,
  }) async {
    final context = await _doOperation(operation: operation);
    ui.buildTree(context).renderTree(logger: logger);
    return context;
  }

  Future<OutputContext> _doOperation<O extends Object>({
    required final Operation<O> operation,
  }) async {
    try {
      final data = await operation();
      return OutputContext(format, data);
    } on Exception catch (error, stackTrace) {
      return OutputContext.exception(format, error, stackTrace);
    }
  }

  Future<T> renderInteractive<T extends Object?>({
    required final InteractiveWidget<T> ui,
  }) {
    final context = OutputContext(format);
    ui.buildTree(context).renderTree(logger: logger);
    return ui.completer.future;
  }
}

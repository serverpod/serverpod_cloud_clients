import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

import 'output_context.dart';
import 'output_format.dart';
import 'widgets.dart';

/// An "operation" function, for the business logic operations of commands
/// that produce some data that is rendered by the command output.
typedef Operation<O> = Future<O> Function();

/// Facade for the output of a command.
class CommandOutput {
  final OutputFormat format;
  final CommandLogger logger;

  CommandOutput({required this.format, required this.logger});

  Future<void> render<O extends Object>({
    required final Operation<O> operation,
    required final OutputWidget ui,
  }) async {
    try {
      final data = await operation();
      final context = OutputContext(format, data);
      ui.buildTree(context).renderTree(logger: logger);
    } catch (error, stackTrace) {
      if (format.isStructured) {
        final context = OutputContext.error(format, error);
        ui.buildTree(context).renderTree(logger: logger);
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

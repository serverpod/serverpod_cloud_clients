import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart'
    show FailureException;
import 'package:serverpod_cloud_cli/shared/helpers/common_client_exception_view.dart';
import 'package:serverpod_cloud_cli/util/output/output_context.dart';
import 'package:serverpod_cloud_cli/util/output/output_widget.dart';
import 'package:serverpod_cloud_cli/util/output/widgets.dart';

/// Displays text errors for common Ground Control client exceptions.
/// For other exceptions it renders [elseWidget] if provided.
class CommonClientExceptionsWidget extends OutputWidget {
  final String baseCommand;
  final OutputWidget? elseWidget;

  const CommonClientExceptionsWidget({
    required this.baseCommand,
    this.elseWidget,
  });

  @override
  OutputWidget build(final OutputContext context) {
    final error = context.find<QualifiedException>();
    if (error?.exception case final Exception exc) {
      final e = _unwrapException(exc);
      final view = CommonClientExceptionView.tryDescribe(
        e,
        baseCommand: baseCommand,
      );
      if (view != null) {
        final errorWidget = TextErrorOutputWidget(
          e,
          message: view.message,
          hint: view.hint,
          newParagraph: view.newParagraph,
        );
        if (view.commandHints.isEmpty) {
          return errorWidget;
        }
        return OutputWidgetList([
          errorWidget,
          for (final commandHint in view.commandHints)
            CommandHintTextWidget(
              commandHint.message,
              command: commandHint.command,
            ),
        ]);
      }
    }
    return elseWidget ?? this;
  }

  Exception _unwrapException(final Exception exc) {
    final exception = switch (exc) {
      FailureException(:final nestedException) when nestedException != null =>
        nestedException,
      _ => exc,
    };
    return exception;
  }
}

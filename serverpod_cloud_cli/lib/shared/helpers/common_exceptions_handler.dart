import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/common_client_exception_view.dart';

/// If the exception is a common client exception, process it by displaying
/// relevant messages to the user and throwing an [ErrorExitException].
///
/// If this function returns normally, no action was taken and the caller
/// needs to continue processing the exception.
void processCommonClientExceptions(
  final CommandLogger logger,
  final String baseCommand,
  final Exception e,
  final StackTrace stackTrace,
) {
  final view = CommonClientExceptionView.tryDescribe(
    e,
    baseCommand: baseCommand,
  );
  if (view == null) return;

  logger.error(view.message, hint: view.hint, newParagraph: view.newParagraph);
  for (final commandHint in view.commandHints) {
    logger.terminalCommand(commandHint.command, message: commandHint.message);
  }

  throw _exitException(e, stackTrace, view);
}

/// Returns the [ErrorExitException] that corresponds to a common client
/// exception, or null if the exception is not one of them.
///
/// Use this instead of [processCommonClientExceptions] when the exception
/// has already been displayed to the user, for instance by an error output
/// widget, and only the process exit remains to be performed.
///
/// A procurement-denied exception carries no nested cause or stack trace,
/// unlike the other common exceptions. That asymmetry is deliberate and
/// predates the shared view.
ErrorExitException? commonClientExceptionExit(
  final Exception e,
  final StackTrace stackTrace,
) {
  final view = CommonClientExceptionView.tryDescribe(e, baseCommand: '');
  if (view == null) return null;
  return _exitException(e, stackTrace, view);
}

ErrorExitException _exitException(
  final Exception e,
  final StackTrace stackTrace,
  final CommonClientExceptionView view,
) {
  if (view.attachCauseToExit) {
    return ErrorExitException(view.exitReason, e, stackTrace);
  }
  return ErrorExitException(view.exitReason);
}

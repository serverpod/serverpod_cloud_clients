import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:ground_control_client/ground_control_client.dart';

/// If the exception is a common client exception, process it by displaying
/// relevant messages to the user and throwing an [ErrorExitException].
///
/// If this function returns normally, no action was taken and the caller
/// needs to continue processing the exception.
void processCommonClientExceptions(
  final CommandLogger logger,
  final Exception e,
  final StackTrace stackTrace,
) {
  switch (e) {
    case ServerpodClientUnauthorized():
      logger.error(
        'The credentials for this session seem to no longer be valid.',
      );
      logger.terminalCommand(
        message: 'Run the following commands to re-authenticate:',
        'scloud auth logout',
      );
      logger.terminalCommand(
        'scloud auth login',
      );

      throw ErrorExitException(
        'The credentials for this session seem to no longer be valid.',
        e,
        stackTrace,
      );

    case UnauthorizedException():
      logger.error(
        'You are not authorized to perform this action.',
      );

      throw ErrorExitException(
        'You are not authorized to perform this action.',
        e,
        stackTrace,
      );

    case ResourceDeniedException():
      logger.error(
        'The resource was not allowed.',
        hint: e.message,
      );

      throw ErrorExitException(
        'The action was not allowed.',
        e,
        stackTrace,
      );

    case NotFoundException():
      logger.error(
        'The requested resource did not exist.',
        hint: e.message,
      );

      throw ErrorExitException(
        'The requested resource did not exist.',
        e,
        stackTrace,
      );
  }
}

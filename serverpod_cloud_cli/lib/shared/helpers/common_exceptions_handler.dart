import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/console_urls.dart';

/// If the exception is a common client exception, process it by displaying
/// relevant messages to the user and throwing an [ErrorExitException].
///
/// If this function returns normally, no action was taken and the caller
/// needs to continue processing the exception.
void processCommonClientExceptions(
  CommandLogger logger,
  String baseCommand,
  Exception e,
  StackTrace stackTrace,
) {
  final exitException = commonClientExceptionExit(e, stackTrace);
  if (exitException == null) return;

  switch (e) {
    case ServerpodClientUnauthorized():
      logger.error(
        'The credentials for this session seem to no longer be valid.',
      );
      logger.terminalCommand(
        message: 'Run the following commands to re-authenticate:',
        '$baseCommand auth logout',
      );
      logger.terminalCommand('$baseCommand auth login');

    case UnauthorizedException():
      logger.error('You are not authorized to perform this action.');

    case ProcurementDeniedException():
      final baseUrl = getConsoleBaseUrl();
      if (e.message.contains('no valid payment method')) {
        final setupUrl = '$baseUrl/project/create';
        logger.error(
          "You need a payment method!",
          hint: 'To set up your account, visit: $setupUrl\n',
          newParagraph: true,
        );
      } else if (e.reason == ProcurementDeniedReason.productNotAvailable &&
          e.message.toLowerCase().contains('backup')) {
        final projectsUrl = '$baseUrl/project';
        logger.error(
          e.message,
          hint:
              'Database backups are available on the Growth plan. '
              'To upgrade the plan, visit: $projectsUrl\n',
          newParagraph: true,
        );
      } else {
        final projectsUrl = '$baseUrl/project';
        logger.error(
          e.message,
          hint: 'To see your account, visit: $projectsUrl\n',
          newParagraph: true,
        );
      }

    case NotFoundException():
      logger.error('The requested resource did not exist.', hint: e.message);
  }

  throw exitException;
}

/// Returns the [ErrorExitException] that corresponds to a common client
/// exception, or null if the exception is not one of them.
///
/// Use this instead of [processCommonClientExceptions] when the exception
/// has already been displayed to the user, for instance by an error output
/// widget, and only the process exit remains to be performed.
ErrorExitException? commonClientExceptionExit(
  Exception e,
  StackTrace stackTrace,
) {
  return switch (e) {
    ServerpodClientUnauthorized() => ErrorExitException(
      'The credentials for this session seem to no longer be valid.',
      e,
      stackTrace,
    ),
    UnauthorizedException() => ErrorExitException(
      'You are not authorized to perform this action.',
      e,
      stackTrace,
    ),
    ProcurementDeniedException() => ErrorExitException(
      'The procurement was not allowed.',
    ),
    NotFoundException() => ErrorExitException(
      'The requested resource did not exist.',
      e,
      stackTrace,
    ),
    _ => null,
  };
}

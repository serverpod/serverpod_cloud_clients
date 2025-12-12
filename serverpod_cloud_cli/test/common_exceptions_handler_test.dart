import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/common_exceptions_handler.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:test/test.dart';

import '../test_utils/command_logger_matchers.dart';
import '../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();

  tearDown(() async {
    logger.clear();
  });

  test('Given a ServerpodClientUnauthorized '
      'when calling processCommonClientExceptions then '
      'should throw ExitErrorException and log error message', () {
    expect(
      () => processCommonClientExceptions(
        logger,
        ServerpodClientUnauthorized(),
        StackTrace.current,
      ),
      throwsA(isA<ErrorExitException>()),
    );

    expect(
      logger.errorCalls.last,
      equalsErrorCall(
        message: 'The credentials for this session seem to no longer be valid.',
      ),
    );
    expect(
      logger.terminalCommandCalls,
      containsAllInOrder([
        equalsTerminalCommandCall(
          message: 'Run the following commands to re-authenticate:',
          command: 'scloud auth logout',
        ),
        equalsTerminalCommandCall(command: 'scloud auth login'),
      ]),
    );
  });

  test('Given a UnauthorizedException '
      'when calling processCommonClientExceptions '
      'then should throw ExitErrorException and log error message', () {
    expect(
      () => processCommonClientExceptions(
        logger,
        UnauthorizedException(message: 'some error'),
        StackTrace.current,
      ),
      throwsA(isA<ErrorExitException>()),
    );

    expect(
      logger.errorCalls.last,
      equalsErrorCall(
        message: 'You are not authorized to perform this action.',
      ),
    );
  });

  test('Given a ProcurementDeniedException '
      'when calling processCommonClientExceptions '
      'then should throw ExitErrorException and log error message', () {
    expect(
      () => processCommonClientExceptions(
        logger,
        ProcurementDeniedException(
          message:
              'The maximum number of projects that can be created has been reached (5).',
        ),
        StackTrace.current,
      ),
      throwsA(isA<ErrorExitException>()),
    );

    expect(
      logger.errorCalls.last,
      equalsErrorCall(
        message:
            'The maximum number of projects that can be created has been reached (5).',
        hint:
            'To see your account, visit: https://console.serverpod.cloud/projects\n',
        newParagraph: true,
      ),
    );
  });

  test('Given a NotFoundException '
      'when calling processCommonClientExceptions '
      'then should throw ExitErrorException and log error message', () {
    expect(
      () => processCommonClientExceptions(
        logger,
        NotFoundException(message: 'No such project.'),
        StackTrace.current,
      ),
      throwsA(isA<ErrorExitException>()),
    );

    expect(
      logger.errorCalls.last,
      equalsErrorCall(
        message: 'The requested resource did not exist.',
        hint: 'No such project.',
      ),
    );
  });

  test('Given an exception that is not commonly handled '
      'when calling processCommonClientExceptions '
      'then should not throw an exception', () {
    expect(
      () => processCommonClientExceptions(
        logger,
        Exception(),
        StackTrace.current,
      ),
      returnsNormally,
    );
  });
}

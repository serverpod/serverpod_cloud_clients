import 'dart:async';

import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
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

  test(
      'Given a callback that throws ServerpodClientUnauthorized '
      'when calling handleCommonClientExceptions then '
      'should rethrow ExitErrorException and log error message', () {
    expect(
      () => handleCommonClientExceptions(
        logger,
        () {
          throw ServerpodClientUnauthorized();
        },
        (final e) => fail('callback should not have been called'),
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
        equalsTerminalCommandCall(
          command: 'scloud auth login',
        ),
      ]),
    );
  });

  test(
      'Given a callback that throws UnauthorizedException '
      'when calling handleCommonClientExceptions '
      'then should rethrow ExitErrorException and log error message', () {
    expect(
      () => handleCommonClientExceptions(
        logger,
        () {
          throw UnauthorizedException(message: 'some error');
        },
        (final e) => fail('callback should not have been called'),
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

  test(
      'Given a callback that throws ForbiddenException '
      'when calling handleCommonClientExceptions '
      'then should rethrow ExitErrorException and log error message', () {
    expect(
      () => handleCommonClientExceptions(
        logger,
        () {
          throw ForbiddenException(
              message:
                  'The maximum number of projects that can be created has been reached (5).');
        },
        (final e) => fail('callback should not have been called'),
      ),
      throwsA(isA<ErrorExitException>()),
    );

    expect(
      logger.errorCalls.last,
      equalsErrorCall(
        message: 'The action was not allowed.',
        hint:
            'The maximum number of projects that can be created has been reached (5).',
      ),
    );
  });

  test(
      'Given a callback that throws NotFoundException '
      'when calling handleCommonClientExceptions '
      'then should rethrow ExitErrorException and log error message', () {
    expect(
      () => handleCommonClientExceptions(
        logger,
        () {
          throw NotFoundException(message: 'No such project.');
        },
        (final e) => fail('callback should not have been called'),
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

  test(
      'Given a callback that throws an exception that is not commonly handled '
      'when calling handleCommonClientExceptions '
      'then should trigger the onUnhandledException callback', () {
    final completer = Completer<void>();

    handleCommonClientExceptions(
      logger,
      () {
        throw Exception();
      },
      (final e) => completer.complete(),
    );

    expect(
      completer.isCompleted,
      isTrue,
    );
  });
}

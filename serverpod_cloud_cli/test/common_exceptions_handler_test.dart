import 'dart:async';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/common_exceptions_handler.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';
import 'package:test/test.dart';

import '../test_utils/test_logger.dart';

void main() {
  final logger = TestLogger();

  test(
      'Given a callback that throws ServerpodClientUnauthorized '
      'when calling handleCommonClientExceptions then '
      'should rethrow ExitException and log error message', () {
    expect(
      () => handleCommonClientExceptions(
        logger,
        () {
          throw ServerpodClientUnauthorized();
        },
        (final e) => throw UnimplementedError(),
      ),
      throwsA(isA<ExitException>()),
    );

    expect(
        logger.errors,
        contains(
            'The credentials for this session seem to no longer be valid.\n'
            'Please run `scloud logout` followed by `scloud login` and try this command again.'));
  });

  test(
      'Given a callback that throws UnauthorizedException '
      'when calling handleCommonClientExceptions '
      'then should rethrow ExitException and log error message', () {
    expect(
      () => handleCommonClientExceptions(
        logger,
        () {
          throw UnauthorizedException(message: 'some error');
        },
        (final e) => throw UnimplementedError(),
      ),
      throwsA(isA<ExitException>()),
    );

    expect(
      logger.errors,
      contains('You are not authorized to perform this action.'),
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

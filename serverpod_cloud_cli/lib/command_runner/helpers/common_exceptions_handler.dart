import 'dart:async';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

FutureOr<T> handleCommonClientExceptions<T>(
  final CommandLogger logger,
  final FutureOr<T> Function() callback,
  final T Function(dynamic e) onUnhandledException,
) async {
  try {
    return await callback();
  } on ServerpodClientUnauthorized {
    logger.error(
      'The credentials for this session seem to no longer be valid.\n'
      'Please run `scloud logout` followed by `scloud login` and try this command again.',
    );

    throw ExitException();
  } on UnauthorizedException {
    logger.error(
      'You are not authorized to perform this action.',
    );

    throw ExitException();
  } on ForbiddenException catch (e) {
    logger.error(
      'The action was not allowed.',
      hint: e.message,
    );

    throw ExitException();
  } catch (e) {
    return onUnhandledException(e);
  }
}

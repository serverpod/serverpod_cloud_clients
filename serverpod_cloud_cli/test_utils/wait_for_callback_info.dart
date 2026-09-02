import 'dart:async';

import 'package:http/http.dart' as http;

import 'test_command_logger.dart';

abstract final class CallbackHelper {
  /// Simulates the browser hitting the authentication callback URL that the CLI
  /// logged, optionally providing an authentication [token].
  static Future<void> completeAuthCallback({
    required TestCommandLogger logger,
    required Completer<void> completer,
    String? token,
    Duration timeout = const Duration(seconds: 25),
  }) {
    return CallbackHelper.completeCallback(
      logger: logger,
      completer: completer,
      callbackUrlParameter: 'callback',
      responseParameter: 'token',
      responseValue: token,
      timeout: timeout,
    );
  }

  /// Simulates the console redirecting back to the CLI callback URL after a
  /// project has been created, optionally providing the created [projectId].
  static Future<void> completeProjectCreateCallback({
    required TestCommandLogger logger,
    required Completer<void> completer,
    String? projectId,
    Duration timeout = const Duration(seconds: 25),
  }) {
    return CallbackHelper.completeCallback(
      logger: logger,
      completer: completer,
      callbackUrlParameter: 'return-url',
      responseParameter: 'projectId',
      responseValue: projectId,
      timeout: timeout,
    );
  }

  /// Waits for an info log message that embeds a CLI callback URL in its
  /// `<callbackUrlParameter>=<url>` query parameter, then sends an HTTP GET to
  /// that URL — optionally with `<responseParameter>=<responseValue>` appended —
  /// to simulate the browser/console redirecting back to the local CLI server.
  static Future<void> completeCallback({
    required TestCommandLogger logger,
    required Completer<void> completer,
    required String callbackUrlParameter,
    required String responseParameter,
    String? responseValue,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final marker = '$callbackUrlParameter=';
    try {
      final deadline = DateTime.now().add(timeout);

      while (DateTime.now().isBefore(deadline)) {
        await logger.waitForLog();
        final callbackInfo = logger.infoCalls
            .where((call) => call.message.contains(marker))
            .firstOrNull;
        if (callbackInfo != null) {
          final loggedMessage = callbackInfo.message;
          final splitMessage = loggedMessage.split(marker);
          if (splitMessage.length != 2) {
            throw StateError('Expected callback URL in log message.');
          }

          final callbackUrl = Uri.parse(Uri.decodeFull(splitMessage[1]));
          final urlToCall = responseValue != null
              ? callbackUrl.replace(
                  queryParameters: {responseParameter: responseValue},
                )
              : callbackUrl;
          final response = await http.get(urlToCall);
          if (response.statusCode != 200) {
            throw StateError(
              'Expected callback response to have status code 200.',
            );
          }
          completer.complete();
          return;
        }
      }
      throw TimeoutException(
        'Timeout waiting for callback info log message',
        timeout,
      );
    } catch (e, st) {
      if (!completer.isCompleted) {
        completer.completeError(e, st);
      }
    }
  }
}

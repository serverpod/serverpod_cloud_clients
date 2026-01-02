import 'dart:async';

import 'package:http/http.dart' as http;

import 'test_command_logger.dart';

abstract final class AuthCallbackHelper {
  static Future<void> completeAuthCallback({
    required final TestCommandLogger logger,
    required final Completer<void> completer,
    final String? token,
    final Duration timeout = const Duration(seconds: 25),
  }) async {
    try {
      final deadline = DateTime.now().add(timeout);

      while (DateTime.now().isBefore(deadline)) {
        await logger.waitForLog();
        final callbackInfo = logger.infoCalls
            .where((final call) => call.message.contains('callback='))
            .firstOrNull;
        if (callbackInfo != null) {
          final loggedMessage = callbackInfo.message;
          final splitMessage = loggedMessage.split('callback=');
          if (splitMessage.length != 2) {
            throw StateError('Expected callback URL in log message.');
          }

          final callbackUrl = Uri.parse(Uri.decodeFull(splitMessage[1]));
          final urlToCall = token != null
              ? callbackUrl.replace(queryParameters: {'token': token})
              : callbackUrl;
          final response = await http.get(urlToCall);
          if (response.statusCode != 200) {
            throw StateError(
              'Expected token response to have status code 200.',
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

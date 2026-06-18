import 'dart:async';
import 'dart:io';

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

abstract final class ListenerServer {
  /// Starts a local HTTP server that waits for a single callback request and
  /// returns the value of the [queryParameter] query parameter from it.
  ///
  /// The server listens on an available `localhost` port and the resulting
  /// callback URL is reported through [onConnected] so the caller can hand it
  /// off to the browser flow. The returned value is `null` if the parameter is
  /// missing, the [timeLimit] is reached, or an error occurs.
  ///
  /// [successMessage] and [failureMessage] are shown in the browser when the
  /// callback is received with or without the [queryParameter] respectively.
  static Future<String?> listenForCallback({
    required final String queryParameter,
    required final CommandLogger logger,
    final void Function(Uri callbackUrl)? onConnected,
    final Duration timeLimit = const Duration(minutes: 2),
    final String successMessage = 'Success, you may now close this window.',
    final String failureMessage =
        'Something went wrong, please try again or contact support.',
  }) async {
    const host = 'localhost';
    final server = await HttpServer.bind(host, 0 /* Pick available port */);
    final localServerAddress = Uri.http('$host:${server.port}', '/callback');
    logger.debug('Listening for callback on $localServerAddress...');

    String? value;
    try {
      onConnected?.call(localServerAddress);
      value = await _processRequests(
        server,
        logger,
        queryParameter: queryParameter,
        successMessage: successMessage,
        failureMessage: failureMessage,
      ).timeout(timeLimit);
    } on TimeoutException {
      logger.debug('Callback listener server timed out.');
    } catch (error, stackTrace) {
      logger.error(
        'Callback listener server error: $error',
        stackTrace: stackTrace,
      );
    } finally {
      await server.close();
    }

    return value;
  }

  /// Starts a local HTTP server that waits for the authentication callback and
  /// returns the authentication token from it.
  static Future<String?> listenForAuthenticationToken({
    final void Function(Uri callbackUrl)? onConnected,
    final Duration timeLimit = const Duration(minutes: 2),
    required final CommandLogger logger,
  }) {
    return listenForCallback(
      queryParameter: 'token',
      logger: logger,
      onConnected: onConnected,
      timeLimit: timeLimit,
      successMessage: 'Login successful, you may now close this window.',
      failureMessage: 'Login failed, please try again or contact support.',
    );
  }

  static String _cliHtmlTemplate(final String message) =>
      '''
<!DOCTYPE html>
<html>
  <head>
    <title>Serverpod Cloud CLI</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 0;
        background-color: #f0f0f0;
      }
      .content {
        margin: 20px;
        padding: 20px;
        background-color: #fff;
        border-radius: 5px;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        display: flex;
        justify-content: center;
      }
    </style>
  </head>
  <body>
    <div class="content">
      $message
    </div>
  </body>
''';

  static Future<String?> _handleCallbackRequest(
    final HttpRequest request, {
    required final String queryParameter,
    required final String successMessage,
    required final String failureMessage,
  }) async {
    final value = request.uri.queryParameters[queryParameter];
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.html;
    request.response.headers
      ..add(HttpHeaders.accessControlAllowOriginHeader, '*')
      ..add(HttpHeaders.accessControlAllowHeadersHeader, '*');

    final message = value == null ? failureMessage : successMessage;

    request.response.write(_cliHtmlTemplate(message));

    return value;
  }

  static Future<void> _handlePreflightRequest(final HttpRequest request) async {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers
      ..add(HttpHeaders.accessControlAllowOriginHeader, '*')
      ..add(HttpHeaders.accessControlAllowMethodsHeader, 'GET, OPTIONS')
      ..add(HttpHeaders.accessControlAllowHeadersHeader, '*');
  }

  static Future<String?> _processRequests(
    final HttpServer server,
    final CommandLogger logger, {
    required final String queryParameter,
    required final String successMessage,
    required final String failureMessage,
  }) async {
    await for (var request in server) {
      logger.debug('Received request: ${request.method} ${request.uri}');
      try {
        switch ((method: request.method, path: request.uri.pathSegments)) {
          case (method: 'GET', path: ['callback']):
            return await _handleCallbackRequest(
              request,
              queryParameter: queryParameter,
              successMessage: successMessage,
              failureMessage: failureMessage,
            );
          case (method: 'OPTIONS', path: _):
            await _handlePreflightRequest(request);
            break;
          default:
            request.response.statusCode = HttpStatus.notFound;
            break;
        }
      } catch (error, stackTrace) {
        logger.error(
          'Callback listener server failed to handle request: $error',
          stackTrace: stackTrace,
        );
      } finally {
        await request.response.close();
      }
    }

    return null;
  }
}

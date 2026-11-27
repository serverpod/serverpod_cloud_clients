import 'dart:async';
import 'dart:io';

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

abstract final class ListenerServer {
  static const _tokenParameter = 'token';
  static const _projectIdParameter = 'projectId';

  /// Starts a local HTTP server that waits for a single callback request and
  /// returns all the query parameters of it.
  ///
  /// The server listens on an available `localhost` port and the resulting
  /// callback URL is reported through [onConnected] so the caller can hand it
  /// off to the browser flow. The returned map is `null` if the
  /// [requiredParameter] is missing, the [timeLimit] is reached, or an error
  /// occurs.
  ///
  /// [successMessage] and [failureMessage] are shown in the browser when the
  /// callback is received with or without the [requiredParameter]
  /// respectively.
  static Future<Map<String, String>?> _listenForCallbackQuery({
    required String requiredParameter,
    required CommandLogger logger,
    void Function(Uri callbackUrl)? onConnected,
    Duration timeLimit = const Duration(minutes: 2),
    String successMessage = 'Success, you may now close this window.',
    String failureMessage =
        'Something went wrong, please try again or contact support.',
  }) async {
    const host = 'localhost';
    final server = await HttpServer.bind(host, 0 /* Pick available port */);
    final localServerAddress = Uri.http('$host:${server.port}', '/callback');
    logger.debug('Listening for callback on $localServerAddress...');

    Map<String, String>? query;
    try {
      onConnected?.call(localServerAddress);
      query = await _processRequests(
        server,
        logger,
        requiredParameter: requiredParameter,
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

    return query;
  }

  /// Starts a local HTTP server that waits for a single callback request and
  /// returns the value of the [queryParameter] query parameter from it.
  ///
  /// The returned value is `null` if the parameter is missing, the
  /// [timeLimit] is reached, or an error occurs. See [_listenForCallbackQuery]
  /// for the other parameters.
  static Future<String?> listenForCallback({
    required String queryParameter,
    required CommandLogger logger,
    void Function(Uri callbackUrl)? onConnected,
    Duration timeLimit = const Duration(minutes: 2),
    String successMessage = 'Success, you may now close this window.',
    String failureMessage =
        'Something went wrong, please try again or contact support.',
  }) async {
    final query = await _listenForCallbackQuery(
      requiredParameter: queryParameter,
      logger: logger,
      onConnected: onConnected,
      timeLimit: timeLimit,
      successMessage: successMessage,
      failureMessage: failureMessage,
    );
    return query?[queryParameter];
  }

  /// Starts a local HTTP server that waits for the authentication callback and
  /// returns the authentication token and the id of the project selected in
  /// the console from it.
  ///
  /// The project id is `null` when the console did not select a project. Returns `null` if
  /// the token is missing, the [timeLimit] is reached, or an error occurs.
  static Future<({String token, String? projectId})?>
  listenForAuthenticationTokenAndProject({
    void Function(Uri callbackUrl)? onConnected,
    Duration timeLimit = const Duration(minutes: 2),
    required CommandLogger logger,
  }) async {
    final query = await _listenForCallbackQuery(
      requiredParameter: _tokenParameter,
      logger: logger,
      onConnected: onConnected,
      timeLimit: timeLimit,
      successMessage:
          'Login successful, you may now close this window and return to the CLI.',
      failureMessage: 'Login failed, please try again or contact support.',
    );
    final token = query?[_tokenParameter];
    if (token == null) return null;

    return (token: token, projectId: query?[_projectIdParameter]);
  }

  static String _cliHtmlTemplate(String message) =>
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

  static Future<Map<String, String>?> _handleCallbackRequest(
    HttpRequest request, {
    required String requiredParameter,
    required String successMessage,
    required String failureMessage,
  }) async {
    final query = request.uri.queryParameters;
    final hasRequiredParameter = query.containsKey(requiredParameter);

    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.html;
    request.response.headers
      ..add(HttpHeaders.accessControlAllowOriginHeader, '*')
      ..add(HttpHeaders.accessControlAllowHeadersHeader, '*');

    final message = hasRequiredParameter ? successMessage : failureMessage;

    request.response.write(_cliHtmlTemplate(message));

    return hasRequiredParameter ? query : null;
  }

  static Future<void> _handlePreflightRequest(HttpRequest request) async {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers
      ..add(HttpHeaders.accessControlAllowOriginHeader, '*')
      ..add(HttpHeaders.accessControlAllowMethodsHeader, 'GET, OPTIONS')
      ..add(HttpHeaders.accessControlAllowHeadersHeader, '*');
  }

  static Future<Map<String, String>?> _processRequests(
    HttpServer server,
    CommandLogger logger, {
    required String requiredParameter,
    required String successMessage,
    required String failureMessage,
  }) async {
    await for (var request in server) {
      logger.debug('Received request: ${request.method} ${request.uri}');
      try {
        switch ((method: request.method, path: request.uri.pathSegments)) {
          case (method: 'GET', path: ['callback']):
            return await _handleCallbackRequest(
              request,
              requiredParameter: requiredParameter,
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

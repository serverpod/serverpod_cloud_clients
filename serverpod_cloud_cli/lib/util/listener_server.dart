import 'dart:async';
import 'dart:io';

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

abstract final class ListenerServer {
  static Future<String?> listenForAuthenticationToken({
    final void Function(Uri callbackUrl)? onConnected,
    final Duration timeLimit = const Duration(minutes: 2),
    required final CommandLogger logger,
  }) async {
    const host = 'localhost';
    final server = await HttpServer.bind(host, 0 /* Pick available port */);
    final localServerAddress = Uri.http('$host:${server.port}', '/callback');
    logger.debug(
      'Listening for authentication token on $localServerAddress...',
    );

    String? token;
    try {
      onConnected?.call(localServerAddress);
      token = await _processRequests(server, logger).timeout(timeLimit);
    } on TimeoutException {
      logger.debug('Token listener server timed out.');
    } catch (error, stackTrace) {
      logger.error(
        'Token listener server error: $error',
        stackTrace: stackTrace,
      );
    } finally {
      await server.close();
    }

    return token;
  }

  static String _cliHtmlTemplate(final String message) => '''
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
      final HttpRequest request) async {
    final token = request.uri.queryParameters['token'];
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.html;
    request.response.headers
      ..add(HttpHeaders.accessControlAllowOriginHeader, '*')
      ..add(HttpHeaders.accessControlAllowHeadersHeader, '*');

    final message = token == null
        ? 'Login failed, please try again or contact support.'
        : 'Login successful, you may now close this window.';

    request.response.write(_cliHtmlTemplate(message));

    return token;
  }

  static Future<void> _handlePreflightRequest(final HttpRequest request) async {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers
      ..add(HttpHeaders.accessControlAllowOriginHeader, '*')
      ..add(HttpHeaders.accessControlAllowMethodsHeader, 'GET, OPTIONS')
      ..add(HttpHeaders.accessControlAllowHeadersHeader, '*');
  }

  static Future<String?> _processRequests(
      final HttpServer server, final CommandLogger logger) async {
    await for (var request in server) {
      logger.debug('Received request: ${request.method} ${request.uri}');
      try {
        switch ((method: request.method, path: request.uri.pathSegments)) {
          case (method: 'GET', path: ['callback']):
            return await _handleCallbackRequest(request);
          case (method: 'OPTIONS', path: _):
            await _handlePreflightRequest(request);
            break;
          default:
            request.response.statusCode = HttpStatus.notFound;
            break;
        }
      } catch (error, stackTrace) {
        logger.error(
          'Token listener server failed to handle request: $error',
          stackTrace: stackTrace,
        );
      } finally {
        await request.response.close();
      }
    }

    return null;
  }
}

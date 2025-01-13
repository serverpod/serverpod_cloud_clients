import 'dart:convert';
import 'dart:io';

import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

typedef _MethodHandler = void Function(
  HttpResponse response,
  Map<String, dynamic> parameters,
);

class HttpServerBuilder {
  String _host;
  String _path;
  final Map<String, _MethodHandler> _methodHandlers;
  void Function(HttpRequest request)? _onRequest;

  SerializationManager serializer = Protocol();

  HttpServerBuilder()
      : _host = 'localhost',
        _path = '/',
        _methodHandlers = {};

  HttpServerBuilder withHost(final String host) {
    _host = host;
    return this;
  }

  HttpServerBuilder withPath(final String path) {
    _path = path;
    return this;
  }

  /// Adds a handler for all requests.
  HttpServerBuilder withOnRequest(
    final void Function(HttpRequest request) onRequest,
  ) {
    _onRequest = onRequest;
    return this;
  }

  /// Adds a handler that gives a successful response for all requests.
  HttpServerBuilder withSuccessfulResponse([
    final Object? responseBody,
  ]) {
    return withOnRequest((final request) {
      request.response.statusCode = 200;

      if (responseBody != null) {
        request.response.write(
          responseBody is SerializableModel
              ? responseBody.toString()
              : responseBody,
        );
      }

      request.response.close();
    });
  }

  /// Adds a handler that gives a response for a specific endpoint method.
  HttpServerBuilder withMethodResponse(
    final String endpointName,
    final String methodName,
    final (int, Object?) Function(Map<String, dynamic> parameters)
        methodResponse,
  ) {
    final methodKey = '$endpointName.$methodName';
    _methodHandlers[methodKey] =
        (final response, final Map<String, dynamic> parameters) async {
      final (responseCode, responseBody) = methodResponse(parameters);

      response.statusCode = responseCode;

      if (responseBody != null) {
        response.write(
          switch (responseBody) {
            SerializableException() => serializer.encodeWithTypeForProtocol(
                responseBody,
              ),
            SerializableModel() => responseBody.toString(),
            _ => jsonEncode(responseBody),
          },
        );
      }
    };
    return this;
  }

  Future<(HttpServer server, Uri serverAddress)> build() async {
    final server = await HttpServer.bind(_host, 0 /* Pick available port */);
    final localServerAddress = Uri.http('$_host:${server.port}', _path);

    server.listen((final request) async {
      if (_onRequest != null) {
        _onRequest?.call(request);
        return;
      }

      final endpointPath = request.uri.pathSegments.first;
      final Map<String, dynamic> requestBody =
          jsonDecode(await utf8.decoder.bind(request).join())
              as Map<String, dynamic>;
      final methodName = requestBody.remove('method');
      final handler = _methodHandlers['$endpointPath.$methodName'];
      if (handler != null) {
        handler(request.response, requestBody);
      } else {
        request.response.statusCode = 404;
        request.response.write('Method not found');
      }
      await request.response.close();
    });

    return (server, localServerAddress);
  }
}

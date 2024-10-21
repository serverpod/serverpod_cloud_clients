import 'dart:io';

import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

class HttpServerBuilder {
  String _host;
  String _path;
  void Function(HttpRequest request)? _onRequest;

  HttpServerBuilder()
      : _host = 'localhost',
        _path = '/';

  HttpServerBuilder withHost(final String host) {
    _host = host;
    return this;
  }

  HttpServerBuilder withPath(final String path) {
    _path = path;
    return this;
  }

  HttpServerBuilder withOnRequest(
    final void Function(HttpRequest request) onRequest,
  ) {
    _onRequest = onRequest;
    return this;
  }

  HttpServerBuilder withSuccessfulResponse(
    final Object responseBody,
  ) {
    _onRequest = (final request) {
      request.response.statusCode = 200;
      request.response.write(
        responseBody is SerializableModel
            ? responseBody.toString()
            : responseBody,
      );
      request.response.close();
    };
    return this;
  }

  Future<(HttpServer server, Uri serverAddress)> build() async {
    final server = await HttpServer.bind(_host, 0 /* Pick available port */);
    final localServerAddress = Uri.http('$_host:${server.port}', _path);
    server.listen((final request) {
      _onRequest?.call(request);
    });
    return (server, localServerAddress);
  }
}

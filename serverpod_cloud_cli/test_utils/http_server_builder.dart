import 'dart:io';

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

  Future<(HttpServer server, Uri serverAddress)> build() async {
    final server = await HttpServer.bind(_host, 0 /* Pick available port */);
    final localServerAddress = Uri.http('$_host:${server.port}', _path);
    server.listen((final request) {
      _onRequest?.call(request);
    });
    return (server, localServerAddress);
  }
}

import 'dart:io';

class MockOfflineHttpClient implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(minutes: 2);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  void addCredentials(
    final Uri url,
    final String realm,
    final HttpClientCredentials credentials,
  ) {}

  @override
  void addProxyCredentials(
    final String host,
    final int port,
    final String realm,
    final HttpClientCredentials credentials,
  ) {}

  @override
  set authenticate(
    final Future<bool> Function(Uri url, String scheme, String? realm)? f,
  ) {}

  @override
  set authenticateProxy(
    final Future<bool> Function(
      String host,
      int port,
      String scheme,
      String? realm,
    )?
    f,
  ) {}

  @override
  set badCertificateCallback(
    final bool Function(X509Certificate cert, String host, int port)? callback,
  ) {}

  @override
  void close({final bool force = false}) {}

  @override
  set connectionFactory(
    final Future<ConnectionTask<Socket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    )?
    f,
  ) {}

  @override
  Future<HttpClientRequest> delete(
    final String host,
    final int port,
    final String path,
  ) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> deleteUrl(final Uri url) {
    throw SocketException('No internet connection');
  }

  @override
  set findProxy(final String Function(Uri url)? f) {}

  @override
  Future<HttpClientRequest> get(
    final String host,
    final int port,
    final String path,
  ) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> getUrl(final Uri url) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> head(
    final String host,
    final int port,
    final String path,
  ) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> headUrl(final Uri url) {
    throw SocketException('No internet connection');
  }

  @override
  set keyLog(final Function(String line)? callback) {}

  @override
  Future<HttpClientRequest> open(
    final String method,
    final String host,
    final int port,
    final String path,
  ) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> openUrl(final String method, final Uri url) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> patch(
    final String host,
    final int port,
    final String path,
  ) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> patchUrl(final Uri url) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> post(
    final String host,
    final int port,
    final String path,
  ) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> postUrl(final Uri url) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> put(
    final String host,
    final int port,
    final String path,
  ) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> putUrl(final Uri url) {
    throw SocketException('No internet connection');
  }
}

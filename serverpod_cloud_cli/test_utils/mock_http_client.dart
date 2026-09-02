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
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  set authenticate(
    Future<bool> Function(Uri url, String scheme, String? realm)? f,
  ) {}

  @override
  set authenticateProxy(
    Future<bool> Function(String host, int port, String scheme, String? realm)?
    f,
  ) {}

  @override
  set badCertificateCallback(
    bool Function(X509Certificate cert, String host, int port)? callback,
  ) {}

  @override
  void close({bool force = false}) {}

  @override
  set connectionFactory(
    Future<ConnectionTask<Socket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    )?
    f,
  ) {}

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    throw SocketException('No internet connection');
  }

  @override
  set findProxy(String Function(Uri url)? f) {}

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    throw SocketException('No internet connection');
  }

  @override
  set keyLog(Function(String line)? callback) {}

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    throw SocketException('No internet connection');
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    throw SocketException('No internet connection');
  }
}

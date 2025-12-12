import 'package:ground_control_client/ground_control_client.dart';

// This is the URL to the server and should be replaced with the actual URL to
// the server.
var url = 'http://localhost:8080/';

Future<void> main() async {
  var client = Client(url)
    ..authKeyProvider = _SimpleAuthenticationKeyManager('mock-token');

  client.close();
}

// Simple implementation for managing authentication keys.
class _SimpleAuthenticationKeyManager implements ClientAuthKeyProvider {
  String? _key;

  _SimpleAuthenticationKeyManager(this._key);

  @override
  Future<String?> get authHeaderValue async {
    return switch (_key) {
      final String key => wrapAsBearerAuthHeaderValue(key),
      null => null,
    };
  }
}

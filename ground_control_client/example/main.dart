import 'package:ground_control_client/ground_control_client.dart';

// This is the URL to the server and should be replaced with the actual URL to
// the server.
var url = 'http://localhost:8080/';

Future<void> main() async {
  var client = Client(
    url,
    authenticationKeyManager: _SimpleAuthenticationKeyManager(),
  );

  var isSignedIn = await client.modules.auth.status.isSignedIn();
  print('Is signed in: $isSignedIn');

  client.close();
}

// Simple implementation for managing authentication keys.
class _SimpleAuthenticationKeyManager extends AuthenticationKeyManager {
  String? _key;

  @override
  Future<String?> get() async {
    return _key;
  }

  @override
  Future<void> put(String key) async {
    _key = key;
  }

  @override
  Future<void> remove() async {
    _key = null;
  }
}

import 'dart:typed_data';

import 'package:ground_control_client/ground_control_client.dart';

class GeneratedAndroidKeystoreBuilder {
  ByteData _keystore = ByteData(8);
  String _password = 'generated-password';
  String _keyAlias = 'upload';

  GeneratedAndroidKeystoreBuilder withPassword(String password) {
    _password = password;
    return this;
  }

  GeneratedAndroidKeystoreBuilder withKeyAlias(String keyAlias) {
    _keyAlias = keyAlias;
    return this;
  }

  GeneratedAndroidKeystoreBuilder withKeystore(ByteData keystore) {
    _keystore = keystore;
    return this;
  }

  GeneratedAndroidKeystore build() {
    return GeneratedAndroidKeystore(
      keystore: _keystore,
      password: _password,
      keyAlias: _keyAlias,
    );
  }
}

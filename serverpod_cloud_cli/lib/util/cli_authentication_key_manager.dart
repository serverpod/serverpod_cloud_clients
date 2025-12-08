import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart';

class CliKeyProvider implements ClientAuthKeyProvider {
  final TokenProvider tokenProvider;

  String? _token;

  CliKeyProvider(this.tokenProvider);

  @override
  Future<String?> get authHeaderValue async {
    _token ??= await tokenProvider();

    return switch (_token) {
      final String token => wrapAsBearerAuthHeaderValue(token),
      null => null,
    };
  }
}

extension IsAuthenticated on ClientAuthKeyProvider {
  Future<bool> get isAuthenticated async => await authHeaderValue != null;
}

typedef TokenProvider = FutureOr<String?> Function();

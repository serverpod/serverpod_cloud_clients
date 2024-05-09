/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'protocol.dart' as _i3;

class _Modules {
  _Modules(Client client) {
    auth = _i1.Caller(client);
  }

  late final _i1.Caller auth;
}

class Client extends _i2.ServerpodClient {
  Client(
    String host, {
    dynamic securityContext,
    _i2.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
  }) : super(
          host,
          _i3.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
        ) {
    modules = _Modules(this);
  }

  late final _Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {};

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}

import 'package:mocktail/mocktail.dart';
import 'package:serverpod_ground_control_client/src/protocol/client.dart';
import 'package:serverpod_auth_client/serverpod_auth_client.dart';

class EndpointCustomDomainNameMock extends Mock
    implements EndpointCustomDomainName {}

class EndpointDeployMock extends Mock implements EndpointDeploy {}

class EndpointEnvironmentVariablesMock extends Mock
    implements EndpointEnvironmentVariables {}

class EndpointLogsMock extends Mock implements EndpointLogs {}

class EndpointInfraResourcesMock extends Mock
    implements EndpointInfraResources {}

class EndpointProjectsMock extends Mock implements EndpointProjects {}

class EndpointRolesMock extends Mock implements EndpointRoles {}

class EndpointSecretsMock extends Mock implements EndpointSecrets {}

class EndpointUsersMock extends Mock implements EndpointUsers {}

/// Modules mocks
class EndpointEmailMock extends Mock implements EndpointEmail {}

class AuthModule extends Mock implements Caller {
  @override
  final EndpointEmail email = EndpointEmailMock();
}

class ModulesMock extends Mock implements Modules {
  @override
  final AuthModule auth = AuthModule();
}

class AuthenticationKeyManagerMock extends Mock
    implements AuthenticationKeyManager {}

class InMemoryKeyManager extends AuthenticationKeyManager {
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

class ClientMock extends Mock implements Client {
  ClientMock({
    AuthenticationKeyManager? authenticationKeyManager,
  }) : authenticationKeyManager =
            authenticationKeyManager ?? InMemoryKeyManager();

  @override
  final AuthenticationKeyManager authenticationKeyManager;

  @override
  final EndpointCustomDomainName customDomainName =
      EndpointCustomDomainNameMock();

  @override
  final EndpointDeploy deploy = EndpointDeployMock();

  @override
  final EndpointEnvironmentVariables environmentVariables =
      EndpointEnvironmentVariablesMock();

  @override
  final EndpointLogs logs = EndpointLogsMock();

  @override
  final EndpointInfraResources infraResources = EndpointInfraResourcesMock();

  @override
  final EndpointProjects projects = EndpointProjectsMock();

  @override
  final EndpointRoles roles = EndpointRolesMock();

  @override
  final EndpointSecrets secrets = EndpointSecretsMock();

  @override
  final EndpointUsers users = EndpointUsersMock();

  @override
  final Modules modules = ModulesMock();
}

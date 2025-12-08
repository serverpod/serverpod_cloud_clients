import 'package:mocktail/mocktail.dart';
import 'package:ground_control_client/src/protocol/client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show wrapAsBearerAuthHeaderValue;
import 'package:serverpod_client/serverpod_client.dart'
    show ClientAuthKeyProvider;

class EndpointCustomDomainNameMock extends Mock
    implements EndpointCustomDomainName {}

class EndpointDeployMock extends Mock implements EndpointDeploy {}

class EndpointEnvironmentVariablesMock extends Mock
    implements EndpointEnvironmentVariables {}

class EndpointLogsMock extends Mock implements EndpointLogs {}

class EndpointInfraResourcesMock extends Mock
    implements EndpointInfraResources {}

class EndpointDatabaseMock extends Mock implements EndpointDatabase {}

class EndpointProjectsMock extends Mock implements EndpointProjects {}

class EndpointRolesMock extends Mock implements EndpointRoles {}

class EndpointSecretsMock extends Mock implements EndpointSecrets {}

class EndpointUsersMock extends Mock implements EndpointUsers {}

class EndpointStatusMock extends Mock implements EndpointStatus {}

class EndpointAuthMock extends Mock implements EndpointAuth {}

class EndpointAuthWithAuthMock extends Mock implements EndpointAuthWithAuth {}

class EndpointAdminUsersMock extends Mock implements EndpointAdminUsers {}

class EndpointAdminProjectsMock extends Mock implements EndpointAdminProjects {}

class EndpointAdminProcurementMock extends Mock
    implements EndpointAdminProcurement {}

class EndpointBillingMock extends Mock implements EndpointBilling {}

class EndpointPlansMock extends Mock implements EndpointPlans {}

/// Modules mocks
class ModulesMock extends Mock implements Modules {}

class InMemoryKeyManager implements ClientAuthKeyProvider {
  Future<bool> get isAuthenticated async => await authHeaderValue != null;

  final String? _token;

  InMemoryKeyManager([this._token]);

  @override
  Future<String?> get authHeaderValue async =>
      _token != null ? wrapAsBearerAuthHeaderValue(_token) : null;

  factory InMemoryKeyManager.authenticated() =>
      InMemoryKeyManager('mock-token');

  factory InMemoryKeyManager.unauthenticated() => InMemoryKeyManager(null);
}

class ClientMock extends Mock implements Client {
  ClientMock({
    ClientAuthKeyProvider? authKeyProvider,
  }) : authKeyProvider =
            authKeyProvider ?? InMemoryKeyManager.unauthenticated();

  @override
  final ClientAuthKeyProvider authKeyProvider;

  @override
  final Modules modules = ModulesMock();

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
  final EndpointDatabase database = EndpointDatabaseMock();

  @override
  final EndpointProjects projects = EndpointProjectsMock();

  @override
  final EndpointRoles roles = EndpointRolesMock();

  @override
  final EndpointSecrets secrets = EndpointSecretsMock();

  @override
  final EndpointUsers users = EndpointUsersMock();

  @override
  final EndpointStatus status = EndpointStatusMock();

  @override
  final EndpointAuth auth = EndpointAuthMock();

  @override
  final EndpointAuthWithAuth authWithAuth = EndpointAuthWithAuthMock();

  @override
  final EndpointAdminUsers adminUsers = EndpointAdminUsersMock();

  @override
  final EndpointAdminProjects adminProjects = EndpointAdminProjectsMock();

  @override
  final EndpointAdminProcurement adminProcurement =
      EndpointAdminProcurementMock();

  @override
  final EndpointBilling billing = EndpointBillingMock();

  @override
  final EndpointPlans plans = EndpointPlansMock();
}

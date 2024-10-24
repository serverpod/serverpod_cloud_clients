/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:serverpod_ground_control_client/src/protocol/infrastructure/domain_name_target.dart'
    as _i3;
import 'package:serverpod_ground_control_client/src/protocol/view_models/infrastructure/custom_domain_name_list.dart'
    as _i4;
import 'package:serverpod_ground_control_client/src/protocol/infrastructure/domain_name_status.dart'
    as _i5;
import 'package:serverpod_ground_control_client/src/protocol/tenant/environment_variable.dart'
    as _i6;
import 'package:serverpod_ground_control_client/src/protocol/logs/log_record.dart'
    as _i7;
import 'package:serverpod_ground_control_client/src/protocol/tenant/role.dart'
    as _i8;
import 'package:serverpod_ground_control_client/src/protocol/tenant/tenant_project.dart'
    as _i9;
import 'package:serverpod_ground_control_client/src/protocol/tenant/user.dart'
    as _i10;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i11;
import 'protocol.dart' as _i12;

/// {@category Endpoint}
class EndpointCustomDomainName extends _i1.EndpointRef {
  EndpointCustomDomainName(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'customDomainName';

  _i2.Future<void> add({
    required String domainName,
    required _i3.DomainNameTarget target,
    required String environmentCanonicalName,
  }) =>
      caller.callServerEndpoint<void>(
        'customDomainName',
        'add',
        {
          'domainName': domainName,
          'target': target,
          'environmentCanonicalName': environmentCanonicalName,
        },
      );

  _i2.Future<void> remove({
    required String domainName,
    required String environmentCanonicalName,
  }) =>
      caller.callServerEndpoint<void>(
        'customDomainName',
        'remove',
        {
          'domainName': domainName,
          'environmentCanonicalName': environmentCanonicalName,
        },
      );

  _i2.Future<_i4.CustomDomainNameList> list(
          {required String environmentCanonicalName}) =>
      caller.callServerEndpoint<_i4.CustomDomainNameList>(
        'customDomainName',
        'list',
        {'environmentCanonicalName': environmentCanonicalName},
      );

  _i2.Future<_i5.DomainNameStatus> refreshRecord({
    required String domainName,
    required String environmentCanonicalName,
  }) =>
      caller.callServerEndpoint<_i5.DomainNameStatus>(
        'customDomainName',
        'refreshRecord',
        {
          'domainName': domainName,
          'environmentCanonicalName': environmentCanonicalName,
        },
      );
}

/// {@category Endpoint}
class EndpointDeploy extends _i1.EndpointRef {
  EndpointDeploy(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'deploy';

  _i2.Future<String> createUploadDescription(String projectId) =>
      caller.callServerEndpoint<String>(
        'deploy',
        'createUploadDescription',
        {'projectId': projectId},
      );
}

/// Endpoint for managing environment variables.
/// {@category Endpoint}
class EndpointEnvironmentVariables extends _i1.EndpointRef {
  EndpointEnvironmentVariables(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'environmentVariables';

  /// Creates a new [EnvironmentVariable] with the specified [name] and [value].
  /// Throws a [DuplicateEntryException] if an environment variable with the same name already exists.
  _i2.Future<_i6.EnvironmentVariable> create(
    String name,
    String value,
    String canonicalName,
  ) =>
      caller.callServerEndpoint<_i6.EnvironmentVariable>(
        'environmentVariables',
        'create',
        {
          'name': name,
          'value': value,
          'canonicalName': canonicalName,
        },
      );

  /// Fetches the specified environment variable.
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i6.EnvironmentVariable> read({
    required String name,
    required String canonicalName,
  }) =>
      caller.callServerEndpoint<_i6.EnvironmentVariable>(
        'environmentVariables',
        'read',
        {
          'name': name,
          'canonicalName': canonicalName,
        },
      );

  /// Gets the list of environment variables for the given [canonicalName].
  _i2.Future<List<_i6.EnvironmentVariable>> list(String canonicalName) =>
      caller.callServerEndpoint<List<_i6.EnvironmentVariable>>(
        'environmentVariables',
        'list',
        {'canonicalName': canonicalName},
      );

  /// Creates a new [EnvironmentVariable] with the specified [name] and [value].
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i6.EnvironmentVariable> update({
    required String name,
    required String value,
    required String canonicalName,
  }) =>
      caller.callServerEndpoint<_i6.EnvironmentVariable>(
        'environmentVariables',
        'update',
        {
          'name': name,
          'value': value,
          'canonicalName': canonicalName,
        },
      );

  /// Permanently deletes an environment variable.
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i6.EnvironmentVariable> delete({
    required String canonicalName,
    required String name,
  }) =>
      caller.callServerEndpoint<_i6.EnvironmentVariable>(
        'environmentVariables',
        'delete',
        {
          'canonicalName': canonicalName,
          'name': name,
        },
      );
}

/// Endpoint for accessing cloud logs.
/// {@category Endpoint}
class EndpointLogs extends _i1.EndpointRef {
  EndpointLogs(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'logs';

  /// Fetches log records from the specified project.
  _i2.Stream<_i7.LogRecord> fetchRecords({
    required String canonicalName,
    DateTime? beforeTime,
    DateTime? afterTime,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i7.LogRecord>,
          _i7.LogRecord>(
        'logs',
        'fetchRecords',
        {
          'canonicalName': canonicalName,
          'beforeTime': beforeTime,
          'afterTime': afterTime,
          'limit': limit,
        },
        {},
      );

  /// Tails log records from the specified project.
  /// Continues until the client unsubscribes, [limit] is reached,
  /// or the internal max limit is reached.
  _i2.Stream<_i7.LogRecord> tailRecords({
    required String canonicalName,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i7.LogRecord>,
          _i7.LogRecord>(
        'logs',
        'tailRecords',
        {
          'canonicalName': canonicalName,
          'limit': limit,
        },
        {},
      );
}

/// Endpoint for managing access roles.
/// {@category Endpoint}
class EndpointRoles extends _i1.EndpointRef {
  EndpointRoles(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'roles';

  /// Fetches the user roles for a project.
  _i2.Future<List<_i8.Role>> fetchRolesForProject(
          {required String canonicalName}) =>
      caller.callServerEndpoint<List<_i8.Role>>(
        'roles',
        'fetchRolesForProject',
        {'canonicalName': canonicalName},
      );
}

/// Endpoint for managing tenant projects.
/// {@category Endpoint}
class EndpointTenantProjects extends _i1.EndpointRef {
  EndpointTenantProjects(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'tenantProjects';

  /// Creates a new tenant project with basic setup.
  /// The [canonicalName] must be globally unique.
  _i2.Future<_i9.TenantProject> createTenantProject(
          {required String canonicalName}) =>
      caller.callServerEndpoint<_i9.TenantProject>(
        'tenantProjects',
        'createTenantProject',
        {'canonicalName': canonicalName},
      );

  /// Fetches the specified tenant project.
  /// Its user roles are included in the response.
  _i2.Future<_i9.TenantProject> fetchTenantProject(
          {required String canonicalName}) =>
      caller.callServerEndpoint<_i9.TenantProject>(
        'tenantProjects',
        'fetchTenantProject',
        {'canonicalName': canonicalName},
      );

  /// Fetches the list of tenant projects the current user has access to.
  _i2.Future<List<_i9.TenantProject>> listTenantProjects() =>
      caller.callServerEndpoint<List<_i9.TenantProject>>(
        'tenantProjects',
        'listTenantProjects',
        {},
      );

  /// Deletes a tenant project permanently.
  _i2.Future<_i9.TenantProject> deleteTenantProject(
          {required String canonicalName}) =>
      caller.callServerEndpoint<_i9.TenantProject>(
        'tenantProjects',
        'deleteTenantProject',
        {'canonicalName': canonicalName},
      );
}

/// Endpoint for managing tenant users.
/// {@category Endpoint}
class EndpointUsers extends _i1.EndpointRef {
  EndpointUsers(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'users';

  /// Fetches the tenant user for the currently authenticated user.
  _i2.Future<_i10.User> fetchCurrentUser() =>
      caller.callServerEndpoint<_i10.User>(
        'users',
        'fetchCurrentUser',
        {},
      );

  /// Registers a new tenant user record for the current authenticated user.
  /// Throws [DuplicateEntryException] if the tenant user already exists.
  _i2.Future<_i10.User> registerCurrentUser({String? userDisplayName}) =>
      caller.callServerEndpoint<_i10.User>(
        'users',
        'registerCurrentUser',
        {'userDisplayName': userDisplayName},
      );
}

class _Modules {
  _Modules(Client client) {
    auth = _i11.Caller(client);
  }

  late final _i11.Caller auth;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i12.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    customDomainName = EndpointCustomDomainName(this);
    deploy = EndpointDeploy(this);
    environmentVariables = EndpointEnvironmentVariables(this);
    logs = EndpointLogs(this);
    roles = EndpointRoles(this);
    tenantProjects = EndpointTenantProjects(this);
    users = EndpointUsers(this);
    modules = _Modules(this);
  }

  late final EndpointCustomDomainName customDomainName;

  late final EndpointDeploy deploy;

  late final EndpointEnvironmentVariables environmentVariables;

  late final EndpointLogs logs;

  late final EndpointRoles roles;

  late final EndpointTenantProjects tenantProjects;

  late final EndpointUsers users;

  late final _Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'customDomainName': customDomainName,
        'deploy': deploy,
        'environmentVariables': environmentVariables,
        'logs': logs,
        'roles': roles,
        'tenantProjects': tenantProjects,
        'users': users,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}

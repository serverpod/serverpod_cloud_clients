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
import 'package:serverpod_ground_control_client/src/protocol/tenant/environment_variable.dart'
    as _i3;
import 'package:serverpod_ground_control_client/src/protocol/logs/log_record.dart'
    as _i4;
import 'package:serverpod_ground_control_client/src/protocol/tenant/role.dart'
    as _i5;
import 'package:serverpod_ground_control_client/src/protocol/tenant/tenant_project.dart'
    as _i6;
import 'package:serverpod_ground_control_client/src/protocol/tenant/user.dart'
    as _i7;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i8;
import 'protocol.dart' as _i9;

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
  _i2.Future<_i3.EnvironmentVariable> create(
    String name,
    String value,
    String envId,
  ) =>
      caller.callServerEndpoint<_i3.EnvironmentVariable>(
        'environmentVariables',
        'create',
        {
          'name': name,
          'value': value,
          'envId': envId,
        },
      );

  /// Fetches the specified environment variable.
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i3.EnvironmentVariable> read({
    required String name,
    required String envId,
  }) =>
      caller.callServerEndpoint<_i3.EnvironmentVariable>(
        'environmentVariables',
        'read',
        {
          'name': name,
          'envId': envId,
        },
      );

  /// Gets the list of environment variables for the given [envId].
  _i2.Future<List<_i3.EnvironmentVariable>> list(String envId) =>
      caller.callServerEndpoint<List<_i3.EnvironmentVariable>>(
        'environmentVariables',
        'list',
        {'envId': envId},
      );

  /// Creates a new [EnvironmentVariable] with the specified [name] and [value].
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i3.EnvironmentVariable> update({
    required String name,
    required String value,
    required String envId,
  }) =>
      caller.callServerEndpoint<_i3.EnvironmentVariable>(
        'environmentVariables',
        'update',
        {
          'name': name,
          'value': value,
          'envId': envId,
        },
      );

  /// Permanently deletes an environment variable.
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i3.EnvironmentVariable> delete({
    required String envId,
    required String name,
  }) =>
      caller.callServerEndpoint<_i3.EnvironmentVariable>(
        'environmentVariables',
        'delete',
        {
          'envId': envId,
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
  _i2.Stream<_i4.LogRecord> fetchRecords({
    required String canonicalName,
    DateTime? beforeTime,
    DateTime? afterTime,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i4.LogRecord>,
          _i4.LogRecord>(
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
  _i2.Stream<_i4.LogRecord> tailRecords({
    required String canonicalName,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i4.LogRecord>,
          _i4.LogRecord>(
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
  _i2.Future<List<_i5.Role>> fetchRolesForProject(
          {required String canonicalName}) =>
      caller.callServerEndpoint<List<_i5.Role>>(
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
  _i2.Future<_i6.TenantProject> createTenantProject(
          {required String canonicalName}) =>
      caller.callServerEndpoint<_i6.TenantProject>(
        'tenantProjects',
        'createTenantProject',
        {'canonicalName': canonicalName},
      );

  /// Fetches the specified tenant project.
  /// Its user roles are included in the response.
  _i2.Future<_i6.TenantProject> fetchTenantProject(
          {required String canonicalName}) =>
      caller.callServerEndpoint<_i6.TenantProject>(
        'tenantProjects',
        'fetchTenantProject',
        {'canonicalName': canonicalName},
      );

  /// Fetches the list of tenant projects the current user has access to.
  _i2.Future<List<_i6.TenantProject>> listTenantProjects() =>
      caller.callServerEndpoint<List<_i6.TenantProject>>(
        'tenantProjects',
        'listTenantProjects',
        {},
      );

  /// Deletes a tenant project permanently.
  _i2.Future<_i6.TenantProject> deleteTenantProject(
          {required String canonicalName}) =>
      caller.callServerEndpoint<_i6.TenantProject>(
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
  _i2.Future<_i7.User> fetchCurrentUser() =>
      caller.callServerEndpoint<_i7.User>(
        'users',
        'fetchCurrentUser',
        {},
      );

  /// Registers a new tenant user record for the current authenticated user.
  /// Throws [DuplicateEntryException] if the tenant user already exists.
  _i2.Future<_i7.User> registerCurrentUser({String? userDisplayName}) =>
      caller.callServerEndpoint<_i7.User>(
        'users',
        'registerCurrentUser',
        {'userDisplayName': userDisplayName},
      );
}

class _Modules {
  _Modules(Client client) {
    auth = _i8.Caller(client);
  }

  late final _i8.Caller auth;
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
          _i9.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    deploy = EndpointDeploy(this);
    environmentVariables = EndpointEnvironmentVariables(this);
    logs = EndpointLogs(this);
    roles = EndpointRoles(this);
    tenantProjects = EndpointTenantProjects(this);
    users = EndpointUsers(this);
    modules = _Modules(this);
  }

  late final EndpointDeploy deploy;

  late final EndpointEnvironmentVariables environmentVariables;

  late final EndpointLogs logs;

  late final EndpointRoles roles;

  late final EndpointTenantProjects tenantProjects;

  late final EndpointUsers users;

  late final _Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
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

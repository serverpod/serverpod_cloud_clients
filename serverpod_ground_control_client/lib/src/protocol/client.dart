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
import 'package:serverpod_ground_control_client/src/protocol/features/custom_domain_name/models/domain_name_target.dart'
    as _i3;
import 'package:serverpod_ground_control_client/src/protocol/features/custom_domain_name/models/custom_domain_name_list.dart'
    as _i4;
import 'package:serverpod_ground_control_client/src/protocol/features/custom_domain_name/models/domain_name_status.dart'
    as _i5;
import 'package:serverpod_ground_control_client/src/protocol/features/environment_variables/models/environment_variable.dart'
    as _i6;
import 'package:serverpod_ground_control_client/src/protocol/features/logs/models/log_record.dart'
    as _i7;
import 'package:serverpod_ground_control_client/src/protocol/features/project/models/project.dart'
    as _i8;
import 'package:serverpod_ground_control_client/src/protocol/features/project/models/project_config.dart'
    as _i9;
import 'package:serverpod_ground_control_client/src/protocol/features/project/models/role.dart'
    as _i10;
import 'package:serverpod_ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i11;
import 'package:serverpod_ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _i12;
import 'package:serverpod_ground_control_client/src/protocol/domains/users/models/user.dart'
    as _i13;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i14;
import 'protocol.dart' as _i15;

/// Endpoint for managing projects.
/// {@category Endpoint}
class EndpointAdmin extends _i1.EndpointRef {
  EndpointAdmin(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'admin';

  _i2.Future<void> deleteAllProjects() => caller.callServerEndpoint<void>(
        'admin',
        'deleteAllProjects',
        {},
      );
}

/// {@category Endpoint}
class EndpointCustomDomainName extends _i1.EndpointRef {
  EndpointCustomDomainName(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'customDomainName';

  _i2.Future<void> add({
    required String domainName,
    required _i3.DomainNameTarget target,
    required String cloudEnvironmentId,
  }) =>
      caller.callServerEndpoint<void>(
        'customDomainName',
        'add',
        {
          'domainName': domainName,
          'target': target,
          'cloudEnvironmentId': cloudEnvironmentId,
        },
      );

  _i2.Future<void> remove({
    required String domainName,
    required String cloudEnvironmentId,
  }) =>
      caller.callServerEndpoint<void>(
        'customDomainName',
        'remove',
        {
          'domainName': domainName,
          'cloudEnvironmentId': cloudEnvironmentId,
        },
      );

  _i2.Future<_i4.CustomDomainNameList> list(
          {required String cloudEnvironmentId}) =>
      caller.callServerEndpoint<_i4.CustomDomainNameList>(
        'customDomainName',
        'list',
        {'cloudEnvironmentId': cloudEnvironmentId},
      );

  _i2.Future<_i5.DomainNameStatus> refreshRecord({
    required String domainName,
    required String cloudEnvironmentId,
  }) =>
      caller.callServerEndpoint<_i5.DomainNameStatus>(
        'customDomainName',
        'refreshRecord',
        {
          'domainName': domainName,
          'cloudEnvironmentId': cloudEnvironmentId,
        },
      );
}

/// {@category Endpoint}
class EndpointDeploy extends _i1.EndpointRef {
  EndpointDeploy(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'deploy';

  _i2.Future<String> createUploadDescription(String cloudProjectId) =>
      caller.callServerEndpoint<String>(
        'deploy',
        'createUploadDescription',
        {'cloudProjectId': cloudProjectId},
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
    String cloudEnvironmentId,
  ) =>
      caller.callServerEndpoint<_i6.EnvironmentVariable>(
        'environmentVariables',
        'create',
        {
          'name': name,
          'value': value,
          'cloudEnvironmentId': cloudEnvironmentId,
        },
      );

  /// Fetches the specified environment variable.
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i6.EnvironmentVariable> read({
    required String name,
    required String cloudEnvironmentId,
  }) =>
      caller.callServerEndpoint<_i6.EnvironmentVariable>(
        'environmentVariables',
        'read',
        {
          'name': name,
          'cloudEnvironmentId': cloudEnvironmentId,
        },
      );

  /// Gets the list of environment variables for the given [cloudEnvironmentId].
  _i2.Future<List<_i6.EnvironmentVariable>> list(String cloudEnvironmentId) =>
      caller.callServerEndpoint<List<_i6.EnvironmentVariable>>(
        'environmentVariables',
        'list',
        {'cloudEnvironmentId': cloudEnvironmentId},
      );

  /// Creates a new [EnvironmentVariable] with the specified [name] and [value].
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i6.EnvironmentVariable> update({
    required String name,
    required String value,
    required String cloudEnvironmentId,
  }) =>
      caller.callServerEndpoint<_i6.EnvironmentVariable>(
        'environmentVariables',
        'update',
        {
          'name': name,
          'value': value,
          'cloudEnvironmentId': cloudEnvironmentId,
        },
      );

  /// Permanently deletes an environment variable.
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i6.EnvironmentVariable> delete({
    required String cloudEnvironmentId,
    required String name,
  }) =>
      caller.callServerEndpoint<_i6.EnvironmentVariable>(
        'environmentVariables',
        'delete',
        {
          'cloudEnvironmentId': cloudEnvironmentId,
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
    required String cloudProjectId,
    DateTime? beforeTime,
    DateTime? afterTime,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i7.LogRecord>,
          _i7.LogRecord>(
        'logs',
        'fetchRecords',
        {
          'cloudProjectId': cloudProjectId,
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
    required String cloudProjectId,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i7.LogRecord>,
          _i7.LogRecord>(
        'logs',
        'tailRecords',
        {
          'cloudProjectId': cloudProjectId,
          'limit': limit,
        },
        {},
      );

  /// Fetches the build log records for the specified deploy attempt.
  _i2.Stream<_i7.LogRecord> fetchBuildLog({
    required String cloudProjectId,
    required String attemptId,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i7.LogRecord>,
          _i7.LogRecord>(
        'logs',
        'fetchBuildLog',
        {
          'cloudProjectId': cloudProjectId,
          'attemptId': attemptId,
          'limit': limit,
        },
        {},
      );
}

/// Endpoint for infrastructure resource provisioning.
/// {@category Endpoint}
class EndpointInfraResources extends _i1.EndpointRef {
  EndpointInfraResources(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'infraResources';

  /// Enables the database for a project.
  _i2.Future<void> enableDatabase({required String cloudEnvironmentId}) =>
      caller.callServerEndpoint<void>(
        'infraResources',
        'enableDatabase',
        {'cloudEnvironmentId': cloudEnvironmentId},
      );
}

/// Endpoint for managing projects.
/// {@category Endpoint}
class EndpointProjects extends _i1.EndpointRef {
  EndpointProjects(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'projects';

  /// Creates a new project with basic setup.
  /// The [cloudProjectId] must be globally unique.
  _i2.Future<_i8.Project> createProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i8.Project>(
        'projects',
        'createProject',
        {'cloudProjectId': cloudProjectId},
      );

  /// Fetches the specified project.
  /// Its user roles are included in the response.
  _i2.Future<_i8.Project> fetchProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i8.Project>(
        'projects',
        'fetchProject',
        {'cloudProjectId': cloudProjectId},
      );

  /// Fetches the list of projects the current user has access to.
  _i2.Future<List<_i8.Project>> listProjects() =>
      caller.callServerEndpoint<List<_i8.Project>>(
        'projects',
        'listProjects',
        {},
      );

  /// Deletes a project permanently.
  _i2.Future<_i8.Project> deleteProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i8.Project>(
        'projects',
        'deleteProject',
        {'cloudProjectId': cloudProjectId},
      );

  _i2.Future<_i9.ProjectConfig> fetchProjectConfig(
          {required String cloudProjectId}) =>
      caller.callServerEndpoint<_i9.ProjectConfig>(
        'projects',
        'fetchProjectConfig',
        {'cloudProjectId': cloudProjectId},
      );
}

/// Endpoint for managing access roles.
/// {@category Endpoint}
class EndpointRoles extends _i1.EndpointRef {
  EndpointRoles(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'roles';

  /// Fetches the user roles for a project.
  _i2.Future<List<_i10.Role>> fetchRolesForProject(
          {required String cloudProjectId}) =>
      caller.callServerEndpoint<List<_i10.Role>>(
        'roles',
        'fetchRolesForProject',
        {'cloudProjectId': cloudProjectId},
      );
}

/// {@category Endpoint}
class EndpointSecrets extends _i1.EndpointRef {
  EndpointSecrets(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'secrets';

  _i2.Future<void> create({
    required Map<String, String> secrets,
    required String cloudEnvironmentId,
  }) =>
      caller.callServerEndpoint<void>(
        'secrets',
        'create',
        {
          'secrets': secrets,
          'cloudEnvironmentId': cloudEnvironmentId,
        },
      );

  _i2.Future<void> delete({
    required String key,
    required String cloudEnvironmentId,
  }) =>
      caller.callServerEndpoint<void>(
        'secrets',
        'delete',
        {
          'key': key,
          'cloudEnvironmentId': cloudEnvironmentId,
        },
      );

  _i2.Future<List<String>> list(String cloudEnvironmentId) =>
      caller.callServerEndpoint<List<String>>(
        'secrets',
        'list',
        {'cloudEnvironmentId': cloudEnvironmentId},
      );
}

/// Endpoint for accessing environment status.
/// {@category Endpoint}
class EndpointStatus extends _i1.EndpointRef {
  EndpointStatus(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'status';

  /// Gets deploy attempts of the specified environment.
  /// Gets the recent-most attempts, up till [limit] if specified.
  _i2.Future<List<_i11.DeployAttempt>> getDeployAttempts({
    required String cloudEnvironmentId,
    int? limit,
  }) =>
      caller.callServerEndpoint<List<_i11.DeployAttempt>>(
        'status',
        'getDeployAttempts',
        {
          'cloudEnvironmentId': cloudEnvironmentId,
          'limit': limit,
        },
      );

  /// Gets the specified deploy attempt status of the a environment.
  _i2.Future<List<_i12.DeployAttemptStage>> getDeployAttemptStatus({
    required String cloudEnvironmentId,
    required String attemptId,
  }) =>
      caller.callServerEndpoint<List<_i12.DeployAttemptStage>>(
        'status',
        'getDeployAttemptStatus',
        {
          'cloudEnvironmentId': cloudEnvironmentId,
          'attemptId': attemptId,
        },
      );

  /// Gets the deploy attempt id for the specified attempt number of a environment.
  /// This number enumerate the environment's deploy attempts as latest first, starting from 0.
  _i2.Future<String> getDeployAttemptId({
    required String cloudEnvironmentId,
    required int attemptNumber,
  }) =>
      caller.callServerEndpoint<String>(
        'status',
        'getDeployAttemptId',
        {
          'cloudEnvironmentId': cloudEnvironmentId,
          'attemptNumber': attemptNumber,
        },
      );
}

/// Endpoint for managing tenant users.
/// {@category Endpoint}
class EndpointUsers extends _i1.EndpointRef {
  EndpointUsers(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'users';

  /// Fetches the tenant user for the currently authenticated user.
  _i2.Future<_i13.User> fetchCurrentUser() =>
      caller.callServerEndpoint<_i13.User>(
        'users',
        'fetchCurrentUser',
        {},
      );

  /// Registers a new tenant user record for the current authenticated user.
  /// Throws [DuplicateEntryException] if the tenant user already exists.
  _i2.Future<_i13.User> registerCurrentUser({String? userDisplayName}) =>
      caller.callServerEndpoint<_i13.User>(
        'users',
        'registerCurrentUser',
        {'userDisplayName': userDisplayName},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i14.Caller(client);
  }

  late final _i14.Caller auth;
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
          _i15.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    admin = EndpointAdmin(this);
    customDomainName = EndpointCustomDomainName(this);
    deploy = EndpointDeploy(this);
    environmentVariables = EndpointEnvironmentVariables(this);
    logs = EndpointLogs(this);
    infraResources = EndpointInfraResources(this);
    projects = EndpointProjects(this);
    roles = EndpointRoles(this);
    secrets = EndpointSecrets(this);
    status = EndpointStatus(this);
    users = EndpointUsers(this);
    modules = Modules(this);
  }

  late final EndpointAdmin admin;

  late final EndpointCustomDomainName customDomainName;

  late final EndpointDeploy deploy;

  late final EndpointEnvironmentVariables environmentVariables;

  late final EndpointLogs logs;

  late final EndpointInfraResources infraResources;

  late final EndpointProjects projects;

  late final EndpointRoles roles;

  late final EndpointSecrets secrets;

  late final EndpointStatus status;

  late final EndpointUsers users;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'admin': admin,
        'customDomainName': customDomainName,
        'deploy': deploy,
        'environmentVariables': environmentVariables,
        'logs': logs,
        'infraResources': infraResources,
        'projects': projects,
        'roles': roles,
        'secrets': secrets,
        'status': status,
        'users': users,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}

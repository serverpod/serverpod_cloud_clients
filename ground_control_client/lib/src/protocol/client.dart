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
import 'package:ground_control_client/src/protocol/domains/users/models/user.dart'
    as _i3;
import 'package:ground_control_client/src/protocol/domains/users/models/user_account_status.dart'
    as _i4;
import 'package:ground_control_client/src/protocol/features/auth/models/required_terms.dart'
    as _i5;
import 'package:ground_control_client/src/protocol/features/auth/models/accepted_terms_dto.dart'
    as _i6;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i7;
import 'package:ground_control_client/src/protocol/features/custom_domain_name/models/view_models/custom_domain_name_with_default_domains.dart'
    as _i8;
import 'package:ground_control_client/src/protocol/features/custom_domain_name/models/domain_name_target.dart'
    as _i9;
import 'package:ground_control_client/src/protocol/features/custom_domain_name/models/custom_domain_name_list.dart'
    as _i10;
import 'package:ground_control_client/src/protocol/features/custom_domain_name/models/domain_name_status.dart'
    as _i11;
import 'package:ground_control_client/src/protocol/features/environment_variables/models/environment_variable.dart'
    as _i12;
import 'package:ground_control_client/src/protocol/domains/logs/models/log_record.dart'
    as _i13;
import 'package:ground_control_client/src/protocol/features/database/models/database_connection.dart'
    as _i14;
import 'package:ground_control_client/src/protocol/features/project/models/project.dart'
    as _i15;
import 'package:ground_control_client/src/protocol/features/project/models/project_config.dart'
    as _i16;
import 'package:ground_control_client/src/protocol/features/project/models/role.dart'
    as _i17;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i18;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _i19;
import 'protocol.dart' as _i20;

/// Endpoint for global administrator project access.
/// {@category Endpoint}
class EndpointAdminUsers extends _i1.EndpointRef {
  EndpointAdminUsers(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminUsers';

  /// Lists all users that match the specified criteria.
  _i2.Future<List<_i3.User>> listUsers({
    String? cloudProjectId,
    _i4.UserAccountStatus? ofAccountStatus,
    bool? includeArchived,
  }) =>
      caller.callServerEndpoint<List<_i3.User>>(
        'adminUsers',
        'listUsers',
        {
          'cloudProjectId': cloudProjectId,
          'ofAccountStatus': ofAccountStatus,
          'includeArchived': includeArchived,
        },
      );

  /// Invites a user to Serverpod Cloud.
  /// If the user does not exist, a user invitation email is sent.
  _i2.Future<void> inviteUser({
    required String email,
    int? maxOwnedProjectsQuota,
  }) =>
      caller.callServerEndpoint<void>(
        'adminUsers',
        'inviteUser',
        {
          'email': email,
          'maxOwnedProjectsQuota': maxOwnedProjectsQuota,
        },
      );
}

/// Endpoint for authentication.
/// {@category Endpoint}
class EndpointAuth extends _i1.EndpointRef {
  EndpointAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  _i2.Future<List<_i5.RequiredTerms>> readRequiredTerms() =>
      caller.callServerEndpoint<List<_i5.RequiredTerms>>(
        'auth',
        'readRequiredTerms',
        {},
      );

  _i2.Future<bool> createAccountRequest(
    String email,
    String password,
    List<_i6.AcceptedTermsDTO> acceptedTerms,
  ) =>
      caller.callServerEndpoint<bool>(
        'auth',
        'createAccountRequest',
        {
          'email': email,
          'password': password,
          'acceptedTerms': acceptedTerms,
        },
      );

  _i2.Future<_i7.AuthenticationResponse> createAccountAndSignIn(
    String email,
    String verificationCode,
  ) =>
      caller.callServerEndpoint<_i7.AuthenticationResponse>(
        'auth',
        'createAccountAndSignIn',
        {
          'email': email,
          'verificationCode': verificationCode,
        },
      );
}

/// Endpoint for authentication.
/// {@category Endpoint}
class EndpointAuthWithAuth extends _i1.EndpointRef {
  EndpointAuthWithAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'authWithAuth';

  _i2.Future<_i7.AuthenticationResponse> createCliToken() =>
      caller.callServerEndpoint<_i7.AuthenticationResponse>(
        'authWithAuth',
        'createCliToken',
        {},
      );
}

/// {@category Endpoint}
class EndpointCustomDomainName extends _i1.EndpointRef {
  EndpointCustomDomainName(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'customDomainName';

  _i2.Future<_i8.CustomDomainNameWithDefaultDomains> add({
    required String domainName,
    required _i9.DomainNameTarget target,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<_i8.CustomDomainNameWithDefaultDomains>(
        'customDomainName',
        'add',
        {
          'domainName': domainName,
          'target': target,
          'cloudCapsuleId': cloudCapsuleId,
        },
      );

  _i2.Future<void> remove({
    required String domainName,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<void>(
        'customDomainName',
        'remove',
        {
          'domainName': domainName,
          'cloudCapsuleId': cloudCapsuleId,
        },
      );

  _i2.Future<_i10.CustomDomainNameList> list(
          {required String cloudCapsuleId}) =>
      caller.callServerEndpoint<_i10.CustomDomainNameList>(
        'customDomainName',
        'list',
        {'cloudCapsuleId': cloudCapsuleId},
      );

  _i2.Future<_i11.DomainNameStatus> refreshRecord({
    required String domainName,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<_i11.DomainNameStatus>(
        'customDomainName',
        'refreshRecord',
        {
          'domainName': domainName,
          'cloudCapsuleId': cloudCapsuleId,
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
  _i2.Future<_i12.EnvironmentVariable> create(
    String name,
    String value,
    String cloudCapsuleId,
  ) =>
      caller.callServerEndpoint<_i12.EnvironmentVariable>(
        'environmentVariables',
        'create',
        {
          'name': name,
          'value': value,
          'cloudCapsuleId': cloudCapsuleId,
        },
      );

  /// Fetches the specified environment variable.
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i12.EnvironmentVariable> read({
    required String name,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<_i12.EnvironmentVariable>(
        'environmentVariables',
        'read',
        {
          'name': name,
          'cloudCapsuleId': cloudCapsuleId,
        },
      );

  /// Gets the list of environment variables for the given [cloudCapsuleId].
  _i2.Future<List<_i12.EnvironmentVariable>> list(String cloudCapsuleId) =>
      caller.callServerEndpoint<List<_i12.EnvironmentVariable>>(
        'environmentVariables',
        'list',
        {'cloudCapsuleId': cloudCapsuleId},
      );

  /// Creates a new [EnvironmentVariable] with the specified [name] and [value].
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i12.EnvironmentVariable> update({
    required String name,
    required String value,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<_i12.EnvironmentVariable>(
        'environmentVariables',
        'update',
        {
          'name': name,
          'value': value,
          'cloudCapsuleId': cloudCapsuleId,
        },
      );

  /// Permanently deletes an environment variable.
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i12.EnvironmentVariable> delete({
    required String cloudCapsuleId,
    required String name,
  }) =>
      caller.callServerEndpoint<_i12.EnvironmentVariable>(
        'environmentVariables',
        'delete',
        {
          'cloudCapsuleId': cloudCapsuleId,
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
  _i2.Stream<_i13.LogRecord> fetchRecords({
    required String cloudProjectId,
    DateTime? beforeTime,
    DateTime? afterTime,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i13.LogRecord>,
          _i13.LogRecord>(
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
  _i2.Stream<_i13.LogRecord> tailRecords({
    required String cloudProjectId,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i13.LogRecord>,
          _i13.LogRecord>(
        'logs',
        'tailRecords',
        {
          'cloudProjectId': cloudProjectId,
          'limit': limit,
        },
        {},
      );

  /// Fetches the build log records for the specified deploy attempt.
  _i2.Stream<_i13.LogRecord> fetchBuildLog({
    required String cloudProjectId,
    required String attemptId,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i13.LogRecord>,
          _i13.LogRecord>(
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

/// Endpoint for database management.
/// {@category Endpoint}
class EndpointDatabase extends _i1.EndpointRef {
  EndpointDatabase(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'database';

  _i2.Future<_i14.DatabaseConnection> getConnectionDetails(
          {required String cloudCapsuleId}) =>
      caller.callServerEndpoint<_i14.DatabaseConnection>(
        'database',
        'getConnectionDetails',
        {'cloudCapsuleId': cloudCapsuleId},
      );

  /// Creates a new super user in the database.
  /// Returns the password for the new user.
  _i2.Future<String> createSuperUser({
    required String cloudCapsuleId,
    required String username,
  }) =>
      caller.callServerEndpoint<String>(
        'database',
        'createSuperUser',
        {
          'cloudCapsuleId': cloudCapsuleId,
          'username': username,
        },
      );

  /// Resets the password for a user in the database.
  /// Returns the new password for the user.
  _i2.Future<String> resetDatabasePassword({
    required String cloudCapsuleId,
    required String username,
  }) =>
      caller.callServerEndpoint<String>(
        'database',
        'resetDatabasePassword',
        {
          'cloudCapsuleId': cloudCapsuleId,
          'username': username,
        },
      );
}

/// Endpoint for infrastructure resource provisioning.
/// {@category Endpoint}
class EndpointInfraResources extends _i1.EndpointRef {
  EndpointInfraResources(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'infraResources';

  /// Enables the database for a project.
  _i2.Future<void> enableDatabase({required String cloudCapsuleId}) =>
      caller.callServerEndpoint<void>(
        'infraResources',
        'enableDatabase',
        {'cloudCapsuleId': cloudCapsuleId},
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
  _i2.Future<_i15.Project> createProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i15.Project>(
        'projects',
        'createProject',
        {'cloudProjectId': cloudProjectId},
      );

  /// Fetches the specified project.
  /// Its user roles are included in the response.
  _i2.Future<_i15.Project> fetchProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i15.Project>(
        'projects',
        'fetchProject',
        {'cloudProjectId': cloudProjectId},
      );

  /// Fetches the list of projects the current user has access to.
  _i2.Future<List<_i15.Project>> listProjects() =>
      caller.callServerEndpoint<List<_i15.Project>>(
        'projects',
        'listProjects',
        {},
      );

  /// Deletes a project permanently.
  /// The id / name of the project is not immediately available for reuse.
  _i2.Future<_i15.Project> deleteProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i15.Project>(
        'projects',
        'deleteProject',
        {'cloudProjectId': cloudProjectId},
      );

  _i2.Future<_i16.ProjectConfig> fetchProjectConfig(
          {required String cloudProjectId}) =>
      caller.callServerEndpoint<_i16.ProjectConfig>(
        'projects',
        'fetchProjectConfig',
        {'cloudProjectId': cloudProjectId},
      );

  /// Invites a user to a project by assigning the specified project roles.
  ///
  /// @Deprecated Use [inviteUser] instead.
  @Deprecated('Use inviteUser instead.')
  _i2.Future<void> attachUser({
    required String cloudProjectId,
    required String email,
    required List<String> assignRoleNames,
  }) =>
      caller.callServerEndpoint<void>(
        'projects',
        'attachUser',
        {
          'cloudProjectId': cloudProjectId,
          'email': email,
          'assignRoleNames': assignRoleNames,
        },
      );

  /// Revokes a user from a project by unassigning the specified project roles.
  ///
  /// @Deprecated Use [revokeUser] instead.
  @Deprecated('Use revokeUser instead.')
  _i2.Future<List<String>> detachUser({
    required String cloudProjectId,
    required String email,
    List<String>? unassignRoleNames,
    bool? unassignAllRoles,
  }) =>
      caller.callServerEndpoint<List<String>>(
        'projects',
        'detachUser',
        {
          'cloudProjectId': cloudProjectId,
          'email': email,
          'unassignRoleNames': unassignRoleNames,
          'unassignAllRoles': unassignAllRoles,
        },
      );

  /// Invites a user to a project by assigning the specified project roles.
  /// If the user does not exist, a user invitation email is sent.
  ///
  /// Throws [NotFoundException] if the project or any of the roles
  /// do not exist.
  _i2.Future<void> inviteUser({
    required String cloudProjectId,
    required String email,
    required List<String> assignRoleNames,
  }) =>
      caller.callServerEndpoint<void>(
        'projects',
        'inviteUser',
        {
          'cloudProjectId': cloudProjectId,
          'email': email,
          'assignRoleNames': assignRoleNames,
        },
      );

  /// Revokes a user from a project by unassigning the specified project roles.
  /// If any of the roles do not exist or are not previously assigned to the
  /// user, they are simply ignored.
  /// If [unassignAllRoles] is true, all roles on the project are unassigned
  /// from the user.
  ///
  /// Returns the list of role names that were actually unassigned.
  /// Throws [NotFoundException] if the project does not exist.
  _i2.Future<List<String>> revokeUser({
    required String cloudProjectId,
    required String email,
    List<String>? unassignRoleNames,
    bool? unassignAllRoles,
  }) =>
      caller.callServerEndpoint<List<String>>(
        'projects',
        'revokeUser',
        {
          'cloudProjectId': cloudProjectId,
          'email': email,
          'unassignRoleNames': unassignRoleNames,
          'unassignAllRoles': unassignAllRoles,
        },
      );
}

/// Endpoint for managing access roles.
/// {@category Endpoint}
class EndpointRoles extends _i1.EndpointRef {
  EndpointRoles(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'roles';

  /// Fetches the user roles for a project.
  _i2.Future<List<_i17.Role>> fetchRolesForProject(
          {required String cloudProjectId}) =>
      caller.callServerEndpoint<List<_i17.Role>>(
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
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<void>(
        'secrets',
        'create',
        {
          'secrets': secrets,
          'cloudCapsuleId': cloudCapsuleId,
        },
      );

  _i2.Future<void> delete({
    required String key,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<void>(
        'secrets',
        'delete',
        {
          'key': key,
          'cloudCapsuleId': cloudCapsuleId,
        },
      );

  _i2.Future<List<String>> list(String cloudCapsuleId) =>
      caller.callServerEndpoint<List<String>>(
        'secrets',
        'list',
        {'cloudCapsuleId': cloudCapsuleId},
      );
}

/// Endpoint for accessing capsule deployment status.
/// {@category Endpoint}
class EndpointStatus extends _i1.EndpointRef {
  EndpointStatus(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'status';

  /// Gets deploy attempts of the specified capsule.
  /// Gets the recent-most attempts, up till [limit] if specified.
  _i2.Future<List<_i18.DeployAttempt>> getDeployAttempts({
    required String cloudCapsuleId,
    int? limit,
  }) =>
      caller.callServerEndpoint<List<_i18.DeployAttempt>>(
        'status',
        'getDeployAttempts',
        {
          'cloudCapsuleId': cloudCapsuleId,
          'limit': limit,
        },
      );

  /// Gets the specified deploy attempt status of the a capsule.
  _i2.Future<List<_i19.DeployAttemptStage>> getDeployAttemptStatus({
    required String cloudCapsuleId,
    required String attemptId,
  }) =>
      caller.callServerEndpoint<List<_i19.DeployAttemptStage>>(
        'status',
        'getDeployAttemptStatus',
        {
          'cloudCapsuleId': cloudCapsuleId,
          'attemptId': attemptId,
        },
      );

  /// Gets the deploy attempt id for the specified attempt number of a capsule.
  /// This number enumerate the capsule's deploy attempts as latest first, starting from 0.
  _i2.Future<String> getDeployAttemptId({
    required String cloudCapsuleId,
    required int attemptNumber,
  }) =>
      caller.callServerEndpoint<String>(
        'status',
        'getDeployAttemptId',
        {
          'cloudCapsuleId': cloudCapsuleId,
          'attemptNumber': attemptNumber,
        },
      );
}

/// Endpoint for managing users.
/// {@category Endpoint}
class EndpointUsers extends _i1.EndpointRef {
  EndpointUsers(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'users';

  /// Reads the current user's information.
  _i2.Future<_i3.User> readUser() => caller.callServerEndpoint<_i3.User>(
        'users',
        'readUser',
        {},
      );

  /// Reads all users that have a role in the specified project.
  _i2.Future<List<_i3.User>> listUsersInProject(
          {required String cloudProjectId}) =>
      caller.callServerEndpoint<List<_i3.User>>(
        'users',
        'listUsersInProject',
        {'cloudProjectId': cloudProjectId},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i7.Caller(client);
  }

  late final _i7.Caller auth;
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
          _i20.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    adminUsers = EndpointAdminUsers(this);
    auth = EndpointAuth(this);
    authWithAuth = EndpointAuthWithAuth(this);
    customDomainName = EndpointCustomDomainName(this);
    deploy = EndpointDeploy(this);
    environmentVariables = EndpointEnvironmentVariables(this);
    logs = EndpointLogs(this);
    database = EndpointDatabase(this);
    infraResources = EndpointInfraResources(this);
    projects = EndpointProjects(this);
    roles = EndpointRoles(this);
    secrets = EndpointSecrets(this);
    status = EndpointStatus(this);
    users = EndpointUsers(this);
    modules = Modules(this);
  }

  late final EndpointAdminUsers adminUsers;

  late final EndpointAuth auth;

  late final EndpointAuthWithAuth authWithAuth;

  late final EndpointCustomDomainName customDomainName;

  late final EndpointDeploy deploy;

  late final EndpointEnvironmentVariables environmentVariables;

  late final EndpointLogs logs;

  late final EndpointDatabase database;

  late final EndpointInfraResources infraResources;

  late final EndpointProjects projects;

  late final EndpointRoles roles;

  late final EndpointSecrets secrets;

  late final EndpointStatus status;

  late final EndpointUsers users;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'adminUsers': adminUsers,
        'auth': auth,
        'authWithAuth': authWithAuth,
        'customDomainName': customDomainName,
        'deploy': deploy,
        'environmentVariables': environmentVariables,
        'logs': logs,
        'database': database,
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

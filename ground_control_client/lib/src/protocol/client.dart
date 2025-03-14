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
import 'package:ground_control_client/src/protocol/features/auth/models/required_terms.dart'
    as _i3;
import 'package:ground_control_client/src/protocol/features/auth/models/accepted_terms_dto.dart'
    as _i4;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i5;
import 'package:ground_control_client/src/protocol/features/custom_domain_name/models/view_models/custom_domain_name_with_default_domains.dart'
    as _i6;
import 'package:ground_control_client/src/protocol/features/custom_domain_name/models/domain_name_target.dart'
    as _i7;
import 'package:ground_control_client/src/protocol/features/custom_domain_name/models/custom_domain_name_list.dart'
    as _i8;
import 'package:ground_control_client/src/protocol/features/custom_domain_name/models/domain_name_status.dart'
    as _i9;
import 'package:ground_control_client/src/protocol/features/environment_variables/models/environment_variable.dart'
    as _i10;
import 'package:ground_control_client/src/protocol/domains/logs/models/log_record.dart'
    as _i11;
import 'package:ground_control_client/src/protocol/features/database/models/database_connection.dart'
    as _i12;
import 'package:ground_control_client/src/protocol/features/project/models/project.dart'
    as _i13;
import 'package:ground_control_client/src/protocol/features/project/models/project_config.dart'
    as _i14;
import 'package:ground_control_client/src/protocol/features/project/models/role.dart'
    as _i15;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i16;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _i17;
import 'package:ground_control_client/src/protocol/domains/users/models/user.dart'
    as _i18;
import 'protocol.dart' as _i19;

/// Endpoint for managing projects.
/// {@category Endpoint}
class EndpointAuth extends _i1.EndpointRef {
  EndpointAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  _i2.Future<List<_i3.RequiredTerms>> readRequiredTerms() =>
      caller.callServerEndpoint<List<_i3.RequiredTerms>>(
        'auth',
        'readRequiredTerms',
        {},
      );

  _i2.Future<bool> createAccountRequest(
    String email,
    String password,
    List<_i4.AcceptedTermsDTO> acceptedTerms,
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

  _i2.Future<_i5.AuthenticationResponse> createAccountAndSignIn(
    String email,
    String verificationCode,
  ) =>
      caller.callServerEndpoint<_i5.AuthenticationResponse>(
        'auth',
        'createAccountAndSignIn',
        {
          'email': email,
          'verificationCode': verificationCode,
        },
      );
}

/// {@category Endpoint}
class EndpointCustomDomainName extends _i1.EndpointRef {
  EndpointCustomDomainName(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'customDomainName';

  _i2.Future<_i6.CustomDomainNameWithDefaultDomains> add({
    required String domainName,
    required _i7.DomainNameTarget target,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<_i6.CustomDomainNameWithDefaultDomains>(
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

  _i2.Future<_i8.CustomDomainNameList> list({required String cloudCapsuleId}) =>
      caller.callServerEndpoint<_i8.CustomDomainNameList>(
        'customDomainName',
        'list',
        {'cloudCapsuleId': cloudCapsuleId},
      );

  _i2.Future<_i9.DomainNameStatus> refreshRecord({
    required String domainName,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<_i9.DomainNameStatus>(
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
  _i2.Future<_i10.EnvironmentVariable> create(
    String name,
    String value,
    String cloudCapsuleId,
  ) =>
      caller.callServerEndpoint<_i10.EnvironmentVariable>(
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
  _i2.Future<_i10.EnvironmentVariable> read({
    required String name,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<_i10.EnvironmentVariable>(
        'environmentVariables',
        'read',
        {
          'name': name,
          'cloudCapsuleId': cloudCapsuleId,
        },
      );

  /// Gets the list of environment variables for the given [cloudCapsuleId].
  _i2.Future<List<_i10.EnvironmentVariable>> list(String cloudCapsuleId) =>
      caller.callServerEndpoint<List<_i10.EnvironmentVariable>>(
        'environmentVariables',
        'list',
        {'cloudCapsuleId': cloudCapsuleId},
      );

  /// Creates a new [EnvironmentVariable] with the specified [name] and [value].
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i10.EnvironmentVariable> update({
    required String name,
    required String value,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<_i10.EnvironmentVariable>(
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
  _i2.Future<_i10.EnvironmentVariable> delete({
    required String cloudCapsuleId,
    required String name,
  }) =>
      caller.callServerEndpoint<_i10.EnvironmentVariable>(
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
  _i2.Stream<_i11.LogRecord> fetchRecords({
    required String cloudProjectId,
    DateTime? beforeTime,
    DateTime? afterTime,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i11.LogRecord>,
          _i11.LogRecord>(
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
  _i2.Stream<_i11.LogRecord> tailRecords({
    required String cloudProjectId,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i11.LogRecord>,
          _i11.LogRecord>(
        'logs',
        'tailRecords',
        {
          'cloudProjectId': cloudProjectId,
          'limit': limit,
        },
        {},
      );

  /// Fetches the build log records for the specified deploy attempt.
  _i2.Stream<_i11.LogRecord> fetchBuildLog({
    required String cloudProjectId,
    required String attemptId,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i11.LogRecord>,
          _i11.LogRecord>(
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

  _i2.Future<_i12.DatabaseConnection> getConnectionDetails(
          {required String cloudCapsuleId}) =>
      caller.callServerEndpoint<_i12.DatabaseConnection>(
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
  _i2.Future<_i13.Project> createProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i13.Project>(
        'projects',
        'createProject',
        {'cloudProjectId': cloudProjectId},
      );

  /// Fetches the specified project.
  /// Its user roles are included in the response.
  _i2.Future<_i13.Project> fetchProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i13.Project>(
        'projects',
        'fetchProject',
        {'cloudProjectId': cloudProjectId},
      );

  /// Fetches the list of projects the current user has access to.
  _i2.Future<List<_i13.Project>> listProjects() =>
      caller.callServerEndpoint<List<_i13.Project>>(
        'projects',
        'listProjects',
        {},
      );

  /// Deletes a project permanently.
  /// The id / name of the project is not immediately available for reuse.
  _i2.Future<_i13.Project> deleteProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i13.Project>(
        'projects',
        'deleteProject',
        {'cloudProjectId': cloudProjectId},
      );

  _i2.Future<_i14.ProjectConfig> fetchProjectConfig(
          {required String cloudProjectId}) =>
      caller.callServerEndpoint<_i14.ProjectConfig>(
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
  _i2.Future<List<_i15.Role>> fetchRolesForProject(
          {required String cloudProjectId}) =>
      caller.callServerEndpoint<List<_i15.Role>>(
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
  _i2.Future<List<_i16.DeployAttempt>> getDeployAttempts({
    required String cloudCapsuleId,
    int? limit,
  }) =>
      caller.callServerEndpoint<List<_i16.DeployAttempt>>(
        'status',
        'getDeployAttempts',
        {
          'cloudCapsuleId': cloudCapsuleId,
          'limit': limit,
        },
      );

  /// Gets the specified deploy attempt status of the a capsule.
  _i2.Future<List<_i17.DeployAttemptStage>> getDeployAttemptStatus({
    required String cloudCapsuleId,
    required String attemptId,
  }) =>
      caller.callServerEndpoint<List<_i17.DeployAttemptStage>>(
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
  _i2.Future<_i18.User> readUser() => caller.callServerEndpoint<_i18.User>(
        'users',
        'readUser',
        {},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i5.Caller(client);
  }

  late final _i5.Caller auth;
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
          _i19.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    auth = EndpointAuth(this);
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

  late final EndpointAuth auth;

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
        'auth': auth,
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

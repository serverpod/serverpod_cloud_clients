/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:ground_control_client/src/protocol/features/projects/models/project.dart'
    as _i3;
import 'package:ground_control_client/src/protocol/features/projects/models/project_info/project_info.dart'
    as _i4;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i5;
import 'package:ground_control_client/src/protocol/domains/users/models/user.dart'
    as _i6;
import 'package:ground_control_client/src/protocol/domains/users/models/user_account_status.dart'
    as _i7;
import 'package:ground_control_client/src/protocol/features/auth/models/required_terms.dart'
    as _i8;
import 'package:ground_control_client/src/protocol/features/auth/models/accepted_terms_dto.dart'
    as _i9;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i10;
import 'package:uuid/uuid_value.dart' as _i11;
import 'package:ground_control_client/src/protocol/domains/billing/models/owner.dart'
    as _i12;
import 'package:ground_control_client/src/protocol/domains/billing/models/billing_info.dart'
    as _i13;
import 'package:ground_control_client/src/protocol/domains/billing/models/payment_setup_intent.dart'
    as _i14;
import 'package:ground_control_client/src/protocol/domains/billing/models/payment_method.dart'
    as _i15;
import 'package:ground_control_client/src/protocol/features/custom_domains/models/view_models/custom_domain_name_with_default_domains.dart'
    as _i16;
import 'package:ground_control_client/src/protocol/features/custom_domains/models/domain_name_target.dart'
    as _i17;
import 'package:ground_control_client/src/protocol/features/custom_domains/models/custom_domain_name_list.dart'
    as _i18;
import 'package:ground_control_client/src/protocol/features/custom_domains/models/domain_name_status.dart'
    as _i19;
import 'package:ground_control_client/src/protocol/features/environment_variables/models/environment_variable.dart'
    as _i20;
import 'package:ground_control_client/src/protocol/domains/logs/models/log_record.dart'
    as _i21;
import 'package:ground_control_client/src/protocol/features/databases/models/database_connection.dart'
    as _i22;
import 'package:ground_control_client/src/protocol/features/projects/models/project_config.dart'
    as _i23;
import 'package:ground_control_client/src/protocol/features/projects/models/role.dart'
    as _i24;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _i25;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i26;
import 'package:serverpod_auth_migration_client/serverpod_auth_migration_client.dart'
    as _i27;
import 'package:serverpod_auth_bridge_client/serverpod_auth_bridge_client.dart'
    as _i28;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i29;
import 'protocol.dart' as _i30;

/// Endpoint for global administrator to handle procurement for users.
/// {@category Endpoint}
class EndpointAdminProcurement extends _i1.EndpointRef {
  EndpointAdminProcurement(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminProcurement';

  /// Procures a product for a user.
  /// If [productVersion] is not provided, the latest version is used.
  /// If [overrideChecks] is true, the product availability checks are overridden.
  ///
  /// Throws a [NotFoundException] if the user or product is not found.
  /// Throws a [InvalidValueException] if the user has no owner (not fully registered).
  _i2.Future<void> procureProduct({
    required String userEmail,
    required String productName,
    int? productVersion,
    bool? overrideChecks,
  }) =>
      caller.callServerEndpoint<void>(
        'adminProcurement',
        'procureProduct',
        {
          'userEmail': userEmail,
          'productName': productName,
          'productVersion': productVersion,
          'overrideChecks': overrideChecks,
        },
      );

  /// Fetches a user's procured products.
  /// Returns a list of `(String, String)` with the product ID and its type.
  ///
  /// Throws a [NotFoundException] if the user is not found.
  /// Throws a [InvalidValueException] if the user has no owner (not fully registered).
  _i2.Future<List<(String, String)>> listProcuredProducts(
          {required String userEmail}) =>
      caller.callServerEndpoint<List<(String, String)>>(
        'adminProcurement',
        'listProcuredProducts',
        {'userEmail': userEmail},
      );
}

/// Endpoint for global administrator projects access.
/// {@category Endpoint}
class EndpointAdminProjects extends _i1.EndpointRef {
  EndpointAdminProjects(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminProjects';

  /// Fetches the list of all projects.
  /// The result includes the owners for each project.
  @Deprecated('Use listProjectsInfo instead')
  _i2.Future<List<_i3.Project>> listProjects({bool? includeArchived}) =>
      caller.callServerEndpoint<List<_i3.Project>>(
        'adminProjects',
        'listProjects',
        {'includeArchived': includeArchived},
      );

  /// Fetches the list of all projects.
  /// The result includes the owners for each project
  /// and the latest deploy attempt time (or null if undeployed).
  _i2.Future<List<_i4.ProjectInfo>> listProjectsInfo({
    bool? includeArchived,
    bool? includeLatestDeployAttemptTime,
  }) =>
      caller.callServerEndpoint<List<_i4.ProjectInfo>>(
        'adminProjects',
        'listProjectsInfo',
        {
          'includeArchived': includeArchived,
          'includeLatestDeployAttemptTime': includeLatestDeployAttemptTime,
        },
      );

  /// Gets deploy attempts of the specified capsule.
  /// Gets the recent-most attempts, up till [limit] if specified.
  _i2.Future<List<_i5.DeployAttempt>> getDeployAttempts({
    required String cloudCapsuleId,
    int? limit,
  }) =>
      caller.callServerEndpoint<List<_i5.DeployAttempt>>(
        'adminProjects',
        'getDeployAttempts',
        {
          'cloudCapsuleId': cloudCapsuleId,
          'limit': limit,
        },
      );

  /// Redeploys a capsule using its current image.
  /// Triggers a deploymentUpdated event to redeploy the infrastructure.
  _i2.Future<void> redeployCapsule(String cloudProjectId) =>
      caller.callServerEndpoint<void>(
        'adminProjects',
        'redeployCapsule',
        {'cloudProjectId': cloudProjectId},
      );
}

/// Endpoint for global administrator users access.
/// {@category Endpoint}
class EndpointAdminUsers extends _i1.EndpointRef {
  EndpointAdminUsers(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminUsers';

  /// Lists all users that match the specified criteria.
  _i2.Future<List<_i6.User>> listUsers({
    String? cloudProjectId,
    _i7.UserAccountStatus? ofAccountStatus,
    bool? includeArchived,
  }) =>
      caller.callServerEndpoint<List<_i6.User>>(
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
  _i2.Future<void> inviteUser({required String email}) =>
      caller.callServerEndpoint<void>(
        'adminUsers',
        'inviteUser',
        {'email': email},
      );
}

/// Endpoint for authentication.
/// {@category Endpoint}
class EndpointAuth extends _i1.EndpointRef {
  EndpointAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  _i2.Future<List<_i8.RequiredTerms>> readRequiredTerms() =>
      caller.callServerEndpoint<List<_i8.RequiredTerms>>(
        'auth',
        'readRequiredTerms',
        {},
      );

  /// Starts the registration for a new user account with an email-based login.
  ///
  /// Upon successful completion of this method, an email will have been sent
  /// to [email] with a verification link, which the user must open to complete
  /// the registration.
  ///
  /// Throws [UserAccountRegistrationDeniedException] if the user is not
  /// authorized to start an account registration, or has not
  /// accepted the required terms of service.
  ///
  /// Throws [EmailAccountPasswordPolicyViolationException] if the password
  /// does not meet the policy requirements.
  _i2.Future<void> startEmailAccountRegistration({
    required String email,
    required String password,
    required List<_i9.AcceptedTermsDTO> acceptedTerms,
  }) =>
      caller.callServerEndpoint<void>(
        'auth',
        'startEmailAccountRegistration',
        {
          'email': email,
          'password': password,
          'acceptedTerms': acceptedTerms,
        },
      );

  /// Completes a new account registration, creating a new auth user with a
  /// profile, and creating a new authenticated session for the user.
  ///
  /// If the registration failed, one of the following exceptions is thrown:
  /// - [EmailAccountRequestExpiredException]
  /// - [EmailAccountRequestNotFoundException]
  /// - [EmailAccountRequestTooManyAttemptsException]
  /// - [EmailAccountRequestUnauthorizedException]
  _i2.Future<_i10.AuthSuccess> finishEmailAccountRegistration({
    required _i11.UuidValue accountRequestId,
    required String verificationCode,
  }) =>
      caller.callServerEndpoint<_i10.AuthSuccess>(
        'auth',
        'finishEmailAccountRegistration',
        {
          'accountRequestId': accountRequestId,
          'verificationCode': verificationCode,
        },
      );

  /// Logs in the user and returns a new session.
  ///
  /// In case an expected error occurs, this throws a
  /// `EmailAccountLoginException`.
  _i2.Future<_i10.AuthSuccess> login({
    required String email,
    required String password,
  }) =>
      caller.callServerEndpoint<_i10.AuthSuccess>(
        'auth',
        'login',
        {
          'email': email,
          'password': password,
        },
      );

  /// Log out the user from the current device.
  /// (The user may still be logged in on other devices.)
  _i2.Future<void> logoutDevice() => caller.callServerEndpoint<void>(
        'auth',
        'logoutDevice',
        {},
      );

  /// Requests a password reset for [email].
  ///
  /// Throws [EmailAccountPasswordResetRequestTooManyAttemptsException] if the
  /// user has made too many requests.
  _i2.Future<void> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<void>(
        'auth',
        'startPasswordReset',
        {'email': email},
      );

  /// Completes a password reset request by setting a new password.
  ///
  /// If the reset was successful, a new session key is returned.
  ///
  /// If the reset failed, one of the following exceptions is thrown:
  /// - [EmailAccountPasswordPolicyViolationException]
  /// - [EmailAccountPasswordResetRequestExpiredException]
  /// - [EmailAccountPasswordResetRequestNotFoundException]
  /// - [EmailAccountPasswordResetRequestUnauthorizedException]
  /// - [EmailAccountPasswordResetTooManyAttemptsException]
  ///
  /// Destroys all the user's current sessions, and creates a new authenticated
  /// session for the user.
  _i2.Future<_i10.AuthSuccess> finishPasswordReset({
    required _i11.UuidValue passwordResetRequestId,
    required String verificationCode,
    required String newPassword,
  }) =>
      caller.callServerEndpoint<_i10.AuthSuccess>(
        'auth',
        'finishPasswordReset',
        {
          'passwordResetRequestId': passwordResetRequestId,
          'verificationCode': verificationCode,
          'newPassword': newPassword,
        },
      );
}

/// Endpoint for authentication.
/// {@category Endpoint}
class EndpointAuthWithAuth extends _i1.EndpointRef {
  EndpointAuthWithAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'authWithAuth';

  /// Creates a new authenticated session for the current user to use as CLI token.
  _i2.Future<_i10.AuthSuccess> createCliToken() =>
      caller.callServerEndpoint<_i10.AuthSuccess>(
        'authWithAuth',
        'createCliToken',
        {},
      );
}

/// {@category Endpoint}
class EndpointBilling extends _i1.EndpointRef {
  EndpointBilling(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'billing';

  /// Reads the owner's billing information.
  ///
  /// This endpoint reads the owner's billing information, including the
  /// billing address and email addresses.
  ///
  /// Returns the [Owner] object.
  _i2.Future<_i12.Owner> readOwner() => caller.callServerEndpoint<_i12.Owner>(
        'billing',
        'readOwner',
        {},
      );

  /// Updates the owner's billing information.
  ///
  /// This endpoint updates the owner's billing information, including the
  /// billing address and email addresses.
  ///
  /// The [billingEmails] parameter is a list of email addresses that will be
  /// used for billing purposes.
  ///
  /// The [billingInfo] parameter is the billing information to update.
  /// All data is overwritten.
  ///
  /// Returns the updated [Owner] object.
  _i2.Future<_i12.Owner> updateOwner({
    required List<String> billingEmails,
    required _i13.BillingInfo billingInfo,
  }) =>
      caller.callServerEndpoint<_i12.Owner>(
        'billing',
        'updateOwner',
        {
          'billingEmails': billingEmails,
          'billingInfo': billingInfo,
        },
      );

  /// Creates a setup intent for collecting payment methods.
  ///
  /// This endpoint creates a setup intent that can be used by the client
  /// to collect payment method details (e.g., card information) from the user.
  /// The setup intent is associated with the authenticated user's payment customer.
  ///
  /// The client can use the returned [PaymentSetupIntent] to:
  /// 1. Display a payment form to the user
  /// 2. Collect payment method details (card number, expiry, etc.)
  /// 3. Confirm the setup intent with the payment provider
  /// 4. Save the payment method for future use
  ///
  /// Returns a [PaymentSetupIntent] containing:
  /// - [id]: The setup intent ID
  /// - [clientSecret]: Secret for client-side confirmation
  /// - [status]: Current status of the setup intent
  ///
  /// Throws [NotFoundException] if the user is not found or has no payment customer.
  _i2.Future<_i14.PaymentSetupIntent> createSetupIntent() =>
      caller.callServerEndpoint<_i14.PaymentSetupIntent>(
        'billing',
        'createSetupIntent',
        {},
      );

  /// Lists all payment methods for the authenticated user.
  ///
  /// This endpoint retrieves all payment methods (currently cards) that have been
  /// saved by the user through the payment provider. Each payment method includes
  /// details such as card brand, last 4 digits, expiry date, etc.
  ///
  /// Returns a list of [PaymentMethod] objects, which may be empty if no payment
  /// methods have been set up.
  ///
  /// Throws [NotFoundException] if the user is not found or has no payment customer.
  _i2.Future<List<_i15.PaymentMethod>> listPaymentMethods() =>
      caller.callServerEndpoint<List<_i15.PaymentMethod>>(
        'billing',
        'listPaymentMethods',
        {},
      );
}

/// {@category Endpoint}
class EndpointCustomDomainName extends _i1.EndpointRef {
  EndpointCustomDomainName(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'customDomainName';

  _i2.Future<_i16.CustomDomainNameWithDefaultDomains> add({
    required String domainName,
    required _i17.DomainNameTarget target,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<_i16.CustomDomainNameWithDefaultDomains>(
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

  _i2.Future<_i18.CustomDomainNameList> list(
          {required String cloudCapsuleId}) =>
      caller.callServerEndpoint<_i18.CustomDomainNameList>(
        'customDomainName',
        'list',
        {'cloudCapsuleId': cloudCapsuleId},
      );

  _i2.Future<_i19.DomainNameStatus> refreshRecord({
    required String domainName,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<_i19.DomainNameStatus>(
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
  _i2.Future<_i20.EnvironmentVariable> create(
    String name,
    String value,
    String cloudCapsuleId,
  ) =>
      caller.callServerEndpoint<_i20.EnvironmentVariable>(
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
  _i2.Future<_i20.EnvironmentVariable> read({
    required String name,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<_i20.EnvironmentVariable>(
        'environmentVariables',
        'read',
        {
          'name': name,
          'cloudCapsuleId': cloudCapsuleId,
        },
      );

  /// Gets the list of environment variables for the given [cloudCapsuleId].
  _i2.Future<List<_i20.EnvironmentVariable>> list(String cloudCapsuleId) =>
      caller.callServerEndpoint<List<_i20.EnvironmentVariable>>(
        'environmentVariables',
        'list',
        {'cloudCapsuleId': cloudCapsuleId},
      );

  /// Creates a new [EnvironmentVariable] with the specified [name] and [value].
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i20.EnvironmentVariable> update({
    required String name,
    required String value,
    required String cloudCapsuleId,
  }) =>
      caller.callServerEndpoint<_i20.EnvironmentVariable>(
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
  _i2.Future<_i20.EnvironmentVariable> delete({
    required String cloudCapsuleId,
    required String name,
  }) =>
      caller.callServerEndpoint<_i20.EnvironmentVariable>(
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
  _i2.Stream<_i21.LogRecord> fetchRecords({
    String? cloudProjectId,
    String? cloudCapsuleId,
    DateTime? beforeTime,
    DateTime? afterTime,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i21.LogRecord>,
          _i21.LogRecord>(
        'logs',
        'fetchRecords',
        {
          'cloudProjectId': cloudProjectId,
          'cloudCapsuleId': cloudCapsuleId,
          'beforeTime': beforeTime,
          'afterTime': afterTime,
          'limit': limit,
        },
        {},
      );

  /// Tails log records from the specified project.
  /// Continues until the client unsubscribes, [limit] is reached,
  /// or the internal max limit is reached.
  _i2.Stream<_i21.LogRecord> tailRecords({
    String? cloudProjectId,
    String? cloudCapsuleId,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i21.LogRecord>,
          _i21.LogRecord>(
        'logs',
        'tailRecords',
        {
          'cloudProjectId': cloudProjectId,
          'cloudCapsuleId': cloudCapsuleId,
          'limit': limit,
        },
        {},
      );

  /// Fetches the build log records for the specified deploy attempt.
  _i2.Stream<_i21.LogRecord> fetchBuildLog({
    String? cloudProjectId,
    String? cloudCapsuleId,
    required String attemptId,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i21.LogRecord>,
          _i21.LogRecord>(
        'logs',
        'fetchBuildLog',
        {
          'cloudProjectId': cloudProjectId,
          'cloudCapsuleId': cloudCapsuleId,
          'attemptId': attemptId,
          'limit': limit,
        },
        {},
      );
}

/// Endpoint for managing subscription plans.
/// {@category Endpoint}
class EndpointPlans extends _i1.EndpointRef {
  EndpointPlans(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'plans';

  /// Procures a subscription plan.
  _i2.Future<void> procurePlan({required String planName}) =>
      caller.callServerEndpoint<void>(
        'plans',
        'procurePlan',
        {'planName': planName},
      );

  /// Fetches the names of the procured subscription plans.
  _i2.Future<List<String>> listProcuredPlanNames() =>
      caller.callServerEndpoint<List<String>>(
        'plans',
        'listProcuredPlanNames',
        {},
      );

  /// Checks if a plan is available for procurement.
  ///
  /// - Throws [NotFoundException] if the product is not found.
  /// - Throws [ProcurementDeniedException] if the product is not available.
  _i2.Future<void> checkPlanAvailability({required String planName}) =>
      caller.callServerEndpoint<void>(
        'plans',
        'checkPlanAvailability',
        {'planName': planName},
      );

  /// Fetches the names of the available subscription plans.
  _i2.Future<List<String>> listPlanNames() =>
      caller.callServerEndpoint<List<String>>(
        'plans',
        'listPlanNames',
        {},
      );
}

/// Endpoint for database management.
/// {@category Endpoint}
class EndpointDatabase extends _i1.EndpointRef {
  EndpointDatabase(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'database';

  _i2.Future<_i22.DatabaseConnection> getConnectionDetails(
          {required String cloudCapsuleId}) =>
      caller.callServerEndpoint<_i22.DatabaseConnection>(
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

  /// Validates a project ID by checking format rules and database existence.
  /// Throws [InvalidValueException] for format violations.
  /// Throws [DuplicateEntryException] if the project ID already exists.
  /// Returns true if the project ID is valid and available.
  _i2.Future<bool> validateProjectId(String projectId) =>
      caller.callServerEndpoint<bool>(
        'projects',
        'validateProjectId',
        {'projectId': projectId},
      );

  /// Creates a new project with basic setup.
  /// The [cloudProjectId] must be globally unique.
  /// [underSubscriptionId] optionally specify a subscription to procure the
  /// project under, or the user's primary subscription will be used.
  _i2.Future<_i3.Project> createProject({
    required String cloudProjectId,
    String? underSubscriptionId,
  }) =>
      caller.callServerEndpoint<_i3.Project>(
        'projects',
        'createProject',
        {
          'cloudProjectId': cloudProjectId,
          'underSubscriptionId': underSubscriptionId,
        },
      );

  /// Fetches the specified project.
  /// Its user roles are included in the response.
  _i2.Future<_i3.Project> fetchProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i3.Project>(
        'projects',
        'fetchProject',
        {'cloudProjectId': cloudProjectId},
      );

  /// Fetches the list of projects the current user has access to.
  @Deprecated('Use listProjectsInfo instead')
  _i2.Future<List<_i3.Project>> listProjects() =>
      caller.callServerEndpoint<List<_i3.Project>>(
        'projects',
        'listProjects',
        {},
      );

  /// Fetches the list of projects the current user has access to.
  /// If requested, the result includes the latest deploy attempt time
  /// (or null if undeployed).
  _i2.Future<List<_i4.ProjectInfo>> listProjectsInfo(
          {bool? includeLatestDeployAttemptTime}) =>
      caller.callServerEndpoint<List<_i4.ProjectInfo>>(
        'projects',
        'listProjectsInfo',
        {'includeLatestDeployAttemptTime': includeLatestDeployAttemptTime},
      );

  /// Deletes a project permanently.
  /// The id / name of the project is not immediately available for reuse.
  _i2.Future<_i3.Project> deleteProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i3.Project>(
        'projects',
        'deleteProject',
        {'cloudProjectId': cloudProjectId},
      );

  _i2.Future<_i23.ProjectConfig> fetchProjectConfig(
          {required String cloudProjectId}) =>
      caller.callServerEndpoint<_i23.ProjectConfig>(
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
  _i2.Future<List<_i24.Role>> fetchRolesForProject(
          {required String cloudProjectId}) =>
      caller.callServerEndpoint<List<_i24.Role>>(
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
  _i2.Future<List<_i5.DeployAttempt>> getDeployAttempts({
    required String cloudCapsuleId,
    int? limit,
  }) =>
      caller.callServerEndpoint<List<_i5.DeployAttempt>>(
        'status',
        'getDeployAttempts',
        {
          'cloudCapsuleId': cloudCapsuleId,
          'limit': limit,
        },
      );

  /// Gets the specified deploy attempt status of the a capsule.
  _i2.Future<List<_i25.DeployAttemptStage>> getDeployAttemptStatus({
    required String cloudCapsuleId,
    required String attemptId,
  }) =>
      caller.callServerEndpoint<List<_i25.DeployAttemptStage>>(
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
  _i2.Future<_i6.User> readUser() => caller.callServerEndpoint<_i6.User>(
        'users',
        'readUser',
        {},
      );

  /// Reads all users that have a role in the specified project.
  _i2.Future<List<_i6.User>> listUsersInProject(
          {required String cloudProjectId}) =>
      caller.callServerEndpoint<List<_i6.User>>(
        'users',
        'listUsersInProject',
        {'cloudProjectId': cloudProjectId},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i26.Caller(client);
    serverpod_auth_migration = _i27.Caller(client);
    serverpod_auth_bridge = _i28.Caller(client);
    auth = _i29.Caller(client);
    serverpod_auth_core = _i10.Caller(client);
  }

  late final _i26.Caller serverpod_auth_idp;

  late final _i27.Caller serverpod_auth_migration;

  late final _i28.Caller serverpod_auth_bridge;

  late final _i29.Caller auth;

  late final _i10.Caller serverpod_auth_core;
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
          _i30.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    adminProcurement = EndpointAdminProcurement(this);
    adminProjects = EndpointAdminProjects(this);
    adminUsers = EndpointAdminUsers(this);
    auth = EndpointAuth(this);
    authWithAuth = EndpointAuthWithAuth(this);
    billing = EndpointBilling(this);
    customDomainName = EndpointCustomDomainName(this);
    deploy = EndpointDeploy(this);
    environmentVariables = EndpointEnvironmentVariables(this);
    logs = EndpointLogs(this);
    plans = EndpointPlans(this);
    database = EndpointDatabase(this);
    infraResources = EndpointInfraResources(this);
    projects = EndpointProjects(this);
    roles = EndpointRoles(this);
    secrets = EndpointSecrets(this);
    status = EndpointStatus(this);
    users = EndpointUsers(this);
    modules = Modules(this);
  }

  late final EndpointAdminProcurement adminProcurement;

  late final EndpointAdminProjects adminProjects;

  late final EndpointAdminUsers adminUsers;

  late final EndpointAuth auth;

  late final EndpointAuthWithAuth authWithAuth;

  late final EndpointBilling billing;

  late final EndpointCustomDomainName customDomainName;

  late final EndpointDeploy deploy;

  late final EndpointEnvironmentVariables environmentVariables;

  late final EndpointLogs logs;

  late final EndpointPlans plans;

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
        'adminProcurement': adminProcurement,
        'adminProjects': adminProjects,
        'adminUsers': adminUsers,
        'auth': auth,
        'authWithAuth': authWithAuth,
        'billing': billing,
        'customDomainName': customDomainName,
        'deploy': deploy,
        'environmentVariables': environmentVariables,
        'logs': logs,
        'plans': plans,
        'database': database,
        'infraResources': infraResources,
        'projects': projects,
        'roles': roles,
        'secrets': secrets,
        'status': status,
        'users': users,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
        'serverpod_auth_idp': modules.serverpod_auth_idp,
        'serverpod_auth_migration': modules.serverpod_auth_migration,
        'serverpod_auth_bridge': modules.serverpod_auth_bridge,
        'auth': modules.auth,
        'serverpod_auth_core': modules.serverpod_auth_core,
      };
}

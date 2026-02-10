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
import 'package:ground_control_client/src/protocol/domains/projects/models/project.dart'
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
import 'package:ground_control_client/src/protocol/domains/billing/models/owner.dart'
    as _i11;
import 'package:ground_control_client/src/protocol/domains/billing/models/billing_info.dart'
    as _i12;
import 'package:ground_control_client/src/protocol/domains/billing/models/payment_setup_intent.dart'
    as _i13;
import 'package:ground_control_client/src/protocol/domains/billing/models/payment_method.dart'
    as _i14;
import 'package:ground_control_client/src/protocol/features/custom_domains/models/view_models/custom_domain_name_with_default_domains.dart'
    as _i15;
import 'package:ground_control_client/src/protocol/features/custom_domains/models/domain_name_target.dart'
    as _i16;
import 'package:ground_control_client/src/protocol/features/custom_domains/models/custom_domain_name_list.dart'
    as _i17;
import 'package:ground_control_client/src/protocol/features/custom_domains/models/domain_name_status.dart'
    as _i18;
import 'package:ground_control_client/src/protocol/features/databases/models/database_connection.dart'
    as _i19;
import 'package:ground_control_client/src/protocol/domains/environment_variables/models/variable.dart'
    as _i20;
import 'package:ground_control_client/src/protocol/features/insights/models/insights_connection_detail.dart'
    as _i21;
import 'package:ground_control_client/src/protocol/domains/logs/models/log_record.dart'
    as _i22;
import 'package:ground_control_client/src/protocol/domains/products/models/subscription_info.dart'
    as _i23;
import 'package:ground_control_client/src/protocol/domains/products/models/plan_info.dart'
    as _i24;
import 'package:ground_control_client/src/protocol/features/projects/models/project_config.dart'
    as _i25;
import 'package:ground_control_client/src/protocol/domains/projects/models/role.dart'
    as _i26;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _i27;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i28;
import 'protocol.dart' as _i29;

/// Endpoint for global administrator to handle procurement for users.
/// {@category Endpoint}
class EndpointAdminProcurement extends _i1.EndpointRef {
  EndpointAdminProcurement(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminProcurement';

  /// Procures a plan for a user.
  /// If [planProductVersion] is not provided, the latest version is used.
  /// If [trialPeriodOverride] is provided, it will override the trial period (number of days).
  /// If [overrideChecks] is true, the product availability checks are overridden.
  ///
  /// Throws a [NotFoundException] if the user or product is not found.
  /// Throws a [InvalidValueException] if the user has no owner (not fully registered).
  _i2.Future<void> procurePlan({
    required String userEmail,
    required String planProductName,
    int? planProductVersion,
    int? trialPeriodOverride,
    bool? overrideChecks,
  }) => caller.callServerEndpoint<void>('adminProcurement', 'procurePlan', {
    'userEmail': userEmail,
    'planProductName': planProductName,
    'planProductVersion': planProductVersion,
    'trialPeriodOverride': trialPeriodOverride,
    'overrideChecks': overrideChecks,
  });

  /// Fetches a user's procured products.
  /// Returns a list of `(String, String)` with the product ID and its type.
  ///
  /// Throws a [NotFoundException] if the user is not found.
  /// Throws a [InvalidValueException] if the user has no owner (not fully registered).
  _i2.Future<List<(String, String)>> listProcuredProducts({
    required String userEmail,
  }) => caller.callServerEndpoint<List<(String, String)>>(
    'adminProcurement',
    'listProcuredProducts',
    {'userEmail': userEmail},
  );

  /// Cancels the primary plan subscription of the user
  /// at the end of its current term.
  ///
  /// If [terminateImmediately] is true, the subscription is terminated
  /// immediately. If the user still has any active resource products,
  /// a [ProcurementCancellationException] will be thrown.
  ///
  /// Throws a [NoSubscriptionException] if the user has no subscription.
  /// Throws a [ProcurementCancellationException] if the subscription has
  /// already been cancelled or ended.
  _i2.Future<void> cancelPlan({
    required String userEmail,
    bool? terminateImmediately,
  }) => caller.callServerEndpoint<void>('adminProcurement', 'cancelPlan', {
    'userEmail': userEmail,
    'terminateImmediately': terminateImmediately,
  });

  @Deprecated(
    'This endpoint to migrate to hackathon plan is no longer supported.',
  )
  _i2.Future<void> moveToHackathonPlan({required String userEmail}) =>
      caller.callServerEndpoint<void>(
        'adminProcurement',
        'moveToHackathonPlan',
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
  }) => caller.callServerEndpoint<List<_i4.ProjectInfo>>(
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
  }) => caller.callServerEndpoint<List<_i5.DeployAttempt>>(
    'adminProjects',
    'getDeployAttempts',
    {'cloudCapsuleId': cloudCapsuleId, 'limit': limit},
  );

  /// Redeploys a capsule using its current image.
  /// Triggers a deploymentUpdated event to redeploy the infrastructure.
  _i2.Future<void> redeployCapsule(String cloudProjectId) =>
      caller.callServerEndpoint<void>('adminProjects', 'redeployCapsule', {
        'cloudProjectId': cloudProjectId,
      });
}

/// Endpoint for global administrator secrets migration.
/// {@category Endpoint}
class EndpointAdminSecrets extends _i1.EndpointRef {
  EndpointAdminSecrets(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminSecrets';

  /// Injects SERVERPOD_SESSION_PERSISTENT_LOG_ENABLED=true for managed secrets
  /// that already have SERVERPOD_DATABASE_HOST. Remove when migration is complete.
  _i2.Future<void> migrateManagedSecrets() => caller.callServerEndpoint<void>(
    'adminSecrets',
    'migrateManagedSecrets',
    {},
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
  }) => caller.callServerEndpoint<List<_i6.User>>('adminUsers', 'listUsers', {
    'cloudProjectId': cloudProjectId,
    'ofAccountStatus': ofAccountStatus,
    'includeArchived': includeArchived,
  });

  /// Invites a user to Serverpod Cloud.
  /// If the user does not exist, a user invitation email is sent.
  _i2.Future<void> inviteUser({required String email}) => caller
      .callServerEndpoint<void>('adminUsers', 'inviteUser', {'email': email});
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
  _i2.Future<void> startEmailAccountRegistration({
    required String email,
    required List<_i9.AcceptedTermsDTO> acceptedTerms,
  }) => caller.callServerEndpoint<void>(
    'auth',
    'startEmailAccountRegistration',
    {'email': email, 'acceptedTerms': acceptedTerms},
  );

  /// Verifies a registration code and returns the finish registration token.
  ///
  /// The token is used to finish the registration by calling
  /// [finishEmailAccountRegistration].
  _i2.Future<String> verifyRegistrationCode({
    required _i1.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>('auth', 'verifyRegistrationCode', {
    'accountRequestId': accountRequestId,
    'verificationCode': verificationCode,
  });

  /// Completes a new account registration, creating a new auth user with a
  /// profile, and creating a new authenticated session for the user.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [finishRegistrationToken]
  ///   is invalid.
  _i2.Future<_i10.AuthSuccess> finishEmailAccountRegistration({
    required String finishRegistrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i10.AuthSuccess>(
    'auth',
    'finishEmailAccountRegistration',
    {'finishRegistrationToken': finishRegistrationToken, 'password': password},
  );

  /// Logs in the user and returns a new session.
  ///
  /// In case an expected error occurs, this throws a
  /// `EmailAccountLoginException`.
  _i2.Future<_i10.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i10.AuthSuccess>('auth', 'login', {
    'email': email,
    'password': password,
  });

  /// Log out the user from the current device.
  /// (The user may still be logged in on other devices.)
  _i2.Future<void> logoutDevice() =>
      caller.callServerEndpoint<void>('auth', 'logoutDevice', {});

  /// Requests a password reset for [email].
  ///
  /// Throws [EmailAccountPasswordResetRequestTooManyAttemptsException] if the
  /// user has made too many requests.
  _i2.Future<void> startPasswordReset({required String email}) => caller
      .callServerEndpoint<void>('auth', 'startPasswordReset', {'email': email});

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
    required _i1.UuidValue passwordResetRequestId,
    required String verificationCode,
    required String newPassword,
  }) => caller
      .callServerEndpoint<_i10.AuthSuccess>('auth', 'finishPasswordReset', {
        'passwordResetRequestId': passwordResetRequestId,
        'verificationCode': verificationCode,
        'newPassword': newPassword,
      });
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

  /// Reads the owner information.
  ///
  /// Returns the [Owner] object,
  /// including the [User] object, and [BillingInfo] if it exists
  /// (including the billing address and email addresses).
  ///
  /// Throws a [NotFoundException] if the owner is not found.
  _i2.Future<_i11.Owner> readOwner() =>
      caller.callServerEndpoint<_i11.Owner>('billing', 'readOwner', {});

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
  _i2.Future<_i11.Owner> updateOwnerBilling({
    required List<String> billingEmails,
    required _i12.BillingInfo billingInfo,
  }) => caller.callServerEndpoint<_i11.Owner>('billing', 'updateOwnerBilling', {
    'billingEmails': billingEmails,
    'billingInfo': billingInfo,
  });

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
  _i2.Future<_i13.PaymentSetupIntent> createSetupIntent() =>
      caller.callServerEndpoint<_i13.PaymentSetupIntent>(
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
  _i2.Future<List<_i14.PaymentMethod>> listPaymentMethods() =>
      caller.callServerEndpoint<List<_i14.PaymentMethod>>(
        'billing',
        'listPaymentMethods',
        {},
      );

  /// Removes a payment method for the authenticated user.
  ///
  /// This endpoint removes a payment method from the user's payment customer.
  /// The endpoint validates that:
  /// - The payment method belongs to the user
  /// - If payment method is required (user has active projects), the user must
  ///   have at least one other payment method
  ///
  /// [paymentMethodId] The ID of the payment method to remove.
  ///
  /// Throws [NotFoundException] if the user is not found or has no payment customer.
  /// Throws [InvalidValueServerException] if the payment method doesn't belong to the user.
  /// Throws [InvalidValueServerException] if payment method is required and this is the last payment method.
  _i2.Future<void> removePaymentMethod({required String paymentMethodId}) =>
      caller.callServerEndpoint<void>('billing', 'removePaymentMethod', {
        'paymentMethodId': paymentMethodId,
      });

  /// Checks if a payment method is required for the authenticated user.
  ///
  /// This endpoint returns `true` if the user has active (non-archived) projects,
  /// meaning they cannot delete their last payment method. Returns `false` otherwise.
  ///
  /// Returns `true` if a payment method is required, `false` otherwise.
  _i2.Future<bool> isPaymentMethodRequired() =>
      caller.callServerEndpoint<bool>('billing', 'isPaymentMethodRequired', {});

  /// Sets the default payment method for the authenticated user.
  ///
  /// This endpoint sets the specified payment method as the default for the user's
  /// payment customer. The endpoint validates that:
  /// - The payment method belongs to the user
  ///
  /// [paymentMethodId] The ID of the payment method to set as default.
  ///
  /// Throws [NotFoundException] if the user is not found or has no payment customer.
  /// Throws [InvalidValueServerException] if the payment method doesn't belong to the user.
  _i2.Future<void> setDefaultPaymentMethod({required String paymentMethodId}) =>
      caller.callServerEndpoint<void>('billing', 'setDefaultPaymentMethod', {
        'paymentMethodId': paymentMethodId,
      });
}

/// {@category Endpoint}
class EndpointCustomDomainName extends _i1.EndpointRef {
  EndpointCustomDomainName(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'customDomainName';

  _i2.Future<_i15.CustomDomainNameWithDefaultDomains> add({
    required String domainName,
    required _i16.DomainNameTarget target,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i15.CustomDomainNameWithDefaultDomains>(
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
  }) => caller.callServerEndpoint<void>('customDomainName', 'remove', {
    'domainName': domainName,
    'cloudCapsuleId': cloudCapsuleId,
  });

  _i2.Future<_i17.CustomDomainNameList> list({
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i17.CustomDomainNameList>(
    'customDomainName',
    'list',
    {'cloudCapsuleId': cloudCapsuleId},
  );

  _i2.Future<_i18.DomainNameStatus> refreshRecord({
    required String domainName,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i18.DomainNameStatus>(
    'customDomainName',
    'refreshRecord',
    {'domainName': domainName, 'cloudCapsuleId': cloudCapsuleId},
  );
}

/// Endpoint for database management.
/// {@category Endpoint}
class EndpointDatabase extends _i1.EndpointRef {
  EndpointDatabase(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'database';

  /// Enables the database for a project.
  _i2.Future<void> enableDatabase({required String cloudCapsuleId}) =>
      caller.callServerEndpoint<void>('database', 'enableDatabase', {
        'cloudCapsuleId': cloudCapsuleId,
      });

  _i2.Future<_i19.DatabaseConnection> getConnectionDetails({
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i19.DatabaseConnection>(
    'database',
    'getConnectionDetails',
    {'cloudCapsuleId': cloudCapsuleId},
  );

  /// Creates a new super user in the database.
  /// Returns the password for the new user.
  _i2.Future<String> createSuperUser({
    required String cloudCapsuleId,
    required String username,
  }) => caller.callServerEndpoint<String>('database', 'createSuperUser', {
    'cloudCapsuleId': cloudCapsuleId,
    'username': username,
  });

  /// Resets the password for a user in the database.
  /// Returns the new password for the user.
  _i2.Future<String> resetDatabasePassword({
    required String cloudCapsuleId,
    required String username,
  }) => caller.callServerEndpoint<String>('database', 'resetDatabasePassword', {
    'cloudCapsuleId': cloudCapsuleId,
    'username': username,
  });

  /// Wipes the database by deleting and recreating it.
  /// This will drop all tables and data in the database.
  /// The deployment will error until a redeploy is performed.
  _i2.Future<void> wipeDatabase({required String cloudCapsuleId}) =>
      caller.callServerEndpoint<void>('database', 'wipeDatabase', {
        'cloudCapsuleId': cloudCapsuleId,
      });
}

/// Endpoint for infrastructure resource provisioning.
/// {@category Endpoint}
class EndpointInfraResources extends _i1.EndpointRef {
  EndpointInfraResources(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'infraResources';

  /// Enables the database for a project.
  @Deprecated('Use DatabaseEndpoint.enableDatabase instead')
  _i2.Future<void> enableDatabase({required String cloudCapsuleId}) =>
      caller.callServerEndpoint<void>('infraResources', 'enableDatabase', {
        'cloudCapsuleId': cloudCapsuleId,
      });
}

/// {@category Endpoint}
class EndpointDeploy extends _i1.EndpointRef {
  EndpointDeploy(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'deploy';

  _i2.Future<String> createUploadDescription(String cloudProjectId) =>
      caller.callServerEndpoint<String>('deploy', 'createUploadDescription', {
        'cloudProjectId': cloudProjectId,
      });
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
  ) => caller.callServerEndpoint<_i20.EnvironmentVariable>(
    'environmentVariables',
    'create',
    {'name': name, 'value': value, 'cloudCapsuleId': cloudCapsuleId},
  );

  /// Fetches the specified environment variable.
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i20.EnvironmentVariable> read({
    required String name,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i20.EnvironmentVariable>(
    'environmentVariables',
    'read',
    {'name': name, 'cloudCapsuleId': cloudCapsuleId},
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
  }) => caller.callServerEndpoint<_i20.EnvironmentVariable>(
    'environmentVariables',
    'update',
    {'name': name, 'value': value, 'cloudCapsuleId': cloudCapsuleId},
  );

  /// Permanently deletes an environment variable.
  /// Throws a [NotFoundException] if the environment variable is not found.
  _i2.Future<_i20.EnvironmentVariable> delete({
    required String cloudCapsuleId,
    required String name,
  }) => caller.callServerEndpoint<_i20.EnvironmentVariable>(
    'environmentVariables',
    'delete',
    {'cloudCapsuleId': cloudCapsuleId, 'name': name},
  );
}

/// {@category Endpoint}
class EndpointInsights extends _i1.EndpointRef {
  EndpointInsights(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'insights';

  /// Gets the connection details for the insights service.
  ///
  /// Requires project authorization with all scopes.
  ///
  /// Throws [UnauthorizedException] if the user is not authorized.
  /// Throws [NotFoundException] if insights service secret is not found.
  _i2.Future<_i21.InsightsConnectionDetail> getConnectionDetails({
    required String cloudProjectId,
  }) => caller.callServerEndpoint<_i21.InsightsConnectionDetail>(
    'insights',
    'getConnectionDetails',
    {'cloudProjectId': cloudProjectId},
  );
}

/// Endpoint for accessing cloud logs.
/// {@category Endpoint}
class EndpointLogs extends _i1.EndpointRef {
  EndpointLogs(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'logs';

  /// Fetches log records from the specified capsule.
  _i2.Stream<_i22.LogRecord> fetchRecords({
    String? cloudProjectId,
    String? cloudCapsuleId,
    DateTime? beforeTime,
    DateTime? afterTime,
    int? limit,
  }) => caller
      .callStreamingServerEndpoint<_i2.Stream<_i22.LogRecord>, _i22.LogRecord>(
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

  /// Fetches the N most recent records from the specified capsule,
  /// where N is the specified limit.
  /// Records are returned in ascending time order.
  ///
  /// This call will hold until all the records are fetched in order to sort them.
  _i2.Stream<_i22.LogRecord> fetchRecentRecords({
    required String cloudCapsuleId,
    int? limit,
  }) => caller
      .callStreamingServerEndpoint<_i2.Stream<_i22.LogRecord>, _i22.LogRecord>(
        'logs',
        'fetchRecentRecords',
        {'cloudCapsuleId': cloudCapsuleId, 'limit': limit},
        {},
      );

  /// Tails log records from the specified capsule.
  /// Continues until the client unsubscribes, [limit] is reached,
  /// or the internal max limit is reached.
  _i2.Stream<_i22.LogRecord> tailRecords({
    String? cloudProjectId,
    String? cloudCapsuleId,
    int? limit,
  }) => caller
      .callStreamingServerEndpoint<_i2.Stream<_i22.LogRecord>, _i22.LogRecord>(
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
  _i2.Stream<_i22.LogRecord> fetchBuildLog({
    String? cloudProjectId,
    String? cloudCapsuleId,
    required String attemptId,
    int? limit,
  }) => caller
      .callStreamingServerEndpoint<_i2.Stream<_i22.LogRecord>, _i22.LogRecord>(
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
  _i2.Future<void> procurePlan({String? planProductName, String? planName}) =>
      caller.callServerEndpoint<void>('plans', 'procurePlan', {
        'planProductName': planProductName,
        'planName': planName,
      });

  /// Cancels the primary plan subscription of the user.
  ///
  /// - Throws [ProcurementCancellationException] if the cancellation fails,
  /// e.g. if the subscription still has active resources or is already cancelled.
  /// - Throws [NoSubscriptionException] if the user has no subscription.
  _i2.Future<void> cancelPlan() =>
      caller.callServerEndpoint<void>('plans', 'cancelPlan', {});

  /// Fetches the names of the procured subscription plans.
  _i2.Future<List<String>> listProcuredPlanNames() => caller
      .callServerEndpoint<List<String>>('plans', 'listProcuredPlanNames', {});

  _i2.Future<_i23.SubscriptionInfo> getSubscriptionInfo() =>
      caller.callServerEndpoint<_i23.SubscriptionInfo>(
        'plans',
        'getSubscriptionInfo',
        {},
      );

  /// Checks if a plan is available for procurement.
  ///
  /// - Throws [NotFoundException] if the product is not found.
  /// - Throws [ProcurementDeniedException] if the product is not available.
  _i2.Future<void> checkPlanAvailability({
    String? planProductName,
    String? planName,
  }) => caller.callServerEndpoint<void>('plans', 'checkPlanAvailability', {
    'planProductName': planProductName,
    'planName': planName,
  });

  _i2.Future<_i24.PlanInfo> getPlanInfo({required String planProductName}) =>
      caller.callServerEndpoint<_i24.PlanInfo>('plans', 'getPlanInfo', {
        'planProductName': planProductName,
      });

  /// Fetches the names of all the subscription plans.
  _i2.Future<List<String>> listPlanNames() =>
      caller.callServerEndpoint<List<String>>('plans', 'listPlanNames', {});
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
      caller.callServerEndpoint<bool>('projects', 'validateProjectId', {
        'projectId': projectId,
      });

  /// Creates a new project with basic setup.
  /// The [cloudProjectId] must be globally unique.
  /// [underSubscriptionId] optionally specify a subscription to procure the
  /// project under, or the user's primary subscription will be used.
  _i2.Future<_i3.Project> createProject({
    required String cloudProjectId,
    String? underSubscriptionId,
  }) => caller.callServerEndpoint<_i3.Project>('projects', 'createProject', {
    'cloudProjectId': cloudProjectId,
    'underSubscriptionId': underSubscriptionId,
  });

  /// Fetches the specified project.
  /// Its user roles are included in the response.
  @Deprecated('Use fetchProjectInfo instead')
  _i2.Future<_i3.Project> fetchProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i3.Project>('projects', 'fetchProject', {
        'cloudProjectId': cloudProjectId,
      });

  /// Fetches the specified project.
  /// Its user roles are included in the response.
  _i2.Future<_i4.ProjectInfo> fetchProjectInfo({
    required String cloudProjectId,
    bool? includeLatestDeployAttemptTime,
  }) => caller
      .callServerEndpoint<_i4.ProjectInfo>('projects', 'fetchProjectInfo', {
        'cloudProjectId': cloudProjectId,
        'includeLatestDeployAttemptTime': includeLatestDeployAttemptTime,
      });

  /// Fetches the list of projects the current user has access to.
  @Deprecated('Use listProjectsInfo instead')
  _i2.Future<List<_i3.Project>> listProjects() => caller
      .callServerEndpoint<List<_i3.Project>>('projects', 'listProjects', {});

  /// Fetches the list of projects the current user has access to.
  /// If requested, the result includes the latest deploy attempt time
  /// (or null if undeployed).
  _i2.Future<List<_i4.ProjectInfo>> listProjectsInfo({
    bool? includeLatestDeployAttemptTime,
  }) => caller.callServerEndpoint<List<_i4.ProjectInfo>>(
    'projects',
    'listProjectsInfo',
    {'includeLatestDeployAttemptTime': includeLatestDeployAttemptTime},
  );

  /// Deletes a project permanently.
  /// The id / name of the project is not immediately available for reuse.
  _i2.Future<_i3.Project> deleteProject({required String cloudProjectId}) =>
      caller.callServerEndpoint<_i3.Project>('projects', 'deleteProject', {
        'cloudProjectId': cloudProjectId,
      });

  _i2.Future<_i25.ProjectConfig> fetchProjectConfig({
    required String cloudProjectId,
  }) => caller.callServerEndpoint<_i25.ProjectConfig>(
    'projects',
    'fetchProjectConfig',
    {'cloudProjectId': cloudProjectId},
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
  }) => caller.callServerEndpoint<void>('projects', 'inviteUser', {
    'cloudProjectId': cloudProjectId,
    'email': email,
    'assignRoleNames': assignRoleNames,
  });

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
  }) => caller.callServerEndpoint<List<String>>('projects', 'revokeUser', {
    'cloudProjectId': cloudProjectId,
    'email': email,
    'unassignRoleNames': unassignRoleNames,
    'unassignAllRoles': unassignAllRoles,
  });
}

/// Endpoint for managing access roles.
/// {@category Endpoint}
class EndpointRoles extends _i1.EndpointRef {
  EndpointRoles(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'roles';

  /// Fetches the user roles for a project.
  _i2.Future<List<_i26.Role>> fetchRolesForProject({
    required String cloudProjectId,
  }) => caller.callServerEndpoint<List<_i26.Role>>(
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
  }) => caller.callServerEndpoint<void>('secrets', 'create', {
    'secrets': secrets,
    'cloudCapsuleId': cloudCapsuleId,
  });

  /// Upserts secrets for a cloud capsule.
  ///
  /// Creates new secrets or updates existing ones. Unlike [create], this method
  /// allows updating existing secret keys without throwing an exception.
  ///
  /// Requires capsule authorization.
  ///
  /// Throws [NotFoundException] if the capsule is not found.
  /// Throws [InvalidValueException] if secret names are invalid.
  _i2.Future<void> upsert({
    required Map<String, String> secrets,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<void>('secrets', 'upsert', {
    'secrets': secrets,
    'cloudCapsuleId': cloudCapsuleId,
  });

  _i2.Future<void> delete({
    required String key,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<void>('secrets', 'delete', {
    'key': key,
    'cloudCapsuleId': cloudCapsuleId,
  });

  _i2.Future<List<String>> list(String cloudCapsuleId) =>
      caller.callServerEndpoint<List<String>>('secrets', 'list', {
        'cloudCapsuleId': cloudCapsuleId,
      });

  /// Lists platform-managed secret keys for a cloud capsule.
  ///
  /// Returns only the keys of managed secrets (no values). Unlike [list],
  /// this method filters to platform-managed secrets only, excluding
  /// user-created custom secrets.
  ///
  /// Requires capsule authorization.
  ///
  /// Throws [NotFoundException] if the capsule is not found.
  _i2.Future<List<String>> listManaged(String cloudCapsuleId) =>
      caller.callServerEndpoint<List<String>>('secrets', 'listManaged', {
        'cloudCapsuleId': cloudCapsuleId,
      });
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
  }) => caller.callServerEndpoint<List<_i5.DeployAttempt>>(
    'status',
    'getDeployAttempts',
    {'cloudCapsuleId': cloudCapsuleId, 'limit': limit},
  );

  /// Gets the specified deploy attempt status of the a capsule.
  _i2.Future<List<_i27.DeployAttemptStage>> getDeployAttemptStatus({
    required String cloudCapsuleId,
    required String attemptId,
  }) => caller.callServerEndpoint<List<_i27.DeployAttemptStage>>(
    'status',
    'getDeployAttemptStatus',
    {'cloudCapsuleId': cloudCapsuleId, 'attemptId': attemptId},
  );

  /// Gets the deploy attempt id for the specified attempt number of a capsule.
  /// This number enumerate the capsule's deploy attempts as latest first, starting from 0.
  _i2.Future<String> getDeployAttemptId({
    required String cloudCapsuleId,
    required int attemptNumber,
  }) => caller.callServerEndpoint<String>('status', 'getDeployAttemptId', {
    'cloudCapsuleId': cloudCapsuleId,
    'attemptNumber': attemptNumber,
  });
}

/// Bespoke endpoint for the 2025 Hackathon.
/// {@category Endpoint}
class EndpointHackathon extends _i1.EndpointRef {
  EndpointHackathon(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'hackathon';

  /// Invites a user to the 2025 Serverpod Hackathon.
  ///
  /// If the user email already exists, a [DuplicateEntryException] is thrown.
  _i2.Future<void> inviteUser({required String email}) => caller
      .callServerEndpoint<void>('hackathon', 'inviteUser', {'email': email});
}

/// Endpoint for managing users.
/// {@category Endpoint}
class EndpointUsers extends _i1.EndpointRef {
  EndpointUsers(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'users';

  /// Reads the current user's information.
  _i2.Future<_i6.User> readUser() =>
      caller.callServerEndpoint<_i6.User>('users', 'readUser', {});

  /// Reads all users that have a role in the specified project.
  _i2.Future<List<_i6.User>> listUsersInProject({
    required String cloudProjectId,
  }) => caller.callServerEndpoint<List<_i6.User>>(
    'users',
    'listUsersInProject',
    {'cloudProjectId': cloudProjectId},
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i28.Caller(client);
    serverpod_auth_core = _i10.Caller(client);
  }

  late final _i28.Caller serverpod_auth_idp;

  late final _i10.Caller serverpod_auth_core;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(_i1.MethodCallContext, Object, StackTrace)? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i29.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    adminProcurement = EndpointAdminProcurement(this);
    adminProjects = EndpointAdminProjects(this);
    adminSecrets = EndpointAdminSecrets(this);
    adminUsers = EndpointAdminUsers(this);
    auth = EndpointAuth(this);
    authWithAuth = EndpointAuthWithAuth(this);
    billing = EndpointBilling(this);
    customDomainName = EndpointCustomDomainName(this);
    database = EndpointDatabase(this);
    infraResources = EndpointInfraResources(this);
    deploy = EndpointDeploy(this);
    environmentVariables = EndpointEnvironmentVariables(this);
    insights = EndpointInsights(this);
    logs = EndpointLogs(this);
    plans = EndpointPlans(this);
    projects = EndpointProjects(this);
    roles = EndpointRoles(this);
    secrets = EndpointSecrets(this);
    status = EndpointStatus(this);
    hackathon = EndpointHackathon(this);
    users = EndpointUsers(this);
    modules = Modules(this);
  }

  late final EndpointAdminProcurement adminProcurement;

  late final EndpointAdminProjects adminProjects;

  late final EndpointAdminSecrets adminSecrets;

  late final EndpointAdminUsers adminUsers;

  late final EndpointAuth auth;

  late final EndpointAuthWithAuth authWithAuth;

  late final EndpointBilling billing;

  late final EndpointCustomDomainName customDomainName;

  late final EndpointDatabase database;

  late final EndpointInfraResources infraResources;

  late final EndpointDeploy deploy;

  late final EndpointEnvironmentVariables environmentVariables;

  late final EndpointInsights insights;

  late final EndpointLogs logs;

  late final EndpointPlans plans;

  late final EndpointProjects projects;

  late final EndpointRoles roles;

  late final EndpointSecrets secrets;

  late final EndpointStatus status;

  late final EndpointHackathon hackathon;

  late final EndpointUsers users;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'adminProcurement': adminProcurement,
    'adminProjects': adminProjects,
    'adminSecrets': adminSecrets,
    'adminUsers': adminUsers,
    'auth': auth,
    'authWithAuth': authWithAuth,
    'billing': billing,
    'customDomainName': customDomainName,
    'database': database,
    'infraResources': infraResources,
    'deploy': deploy,
    'environmentVariables': environmentVariables,
    'insights': insights,
    'logs': logs,
    'plans': plans,
    'projects': projects,
    'roles': roles,
    'secrets': secrets,
    'status': status,
    'hackathon': hackathon,
    'users': users,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}

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

import 'dart:async' as _ida;
import 'package:ground_control_client/src/protocol/domains/billing/models/billing_customer_type.dart'
    as _iqua0tdt;
import 'package:ground_control_client/src/protocol/domains/billing/models/billing_info.dart'
    as _iup39bna;
import 'package:ground_control_client/src/protocol/domains/billing/models/owner.dart'
    as _ijvsyu4l;
import 'package:ground_control_client/src/protocol/domains/billing/models/payment_method.dart'
    as _itisjjd4;
import 'package:ground_control_client/src/protocol/domains/billing/models/payment_setup_intent.dart'
    as _ia3irqvx;
import 'package:ground_control_client/src/protocol/domains/buckets/models/bucket_file_listing.dart'
    as _ikaw0g5r;
import 'package:ground_control_client/src/protocol/domains/buckets/models/bucket_resource.dart'
    as _itj7xmug;
import 'package:ground_control_client/src/protocol/domains/buckets/models/bucket_visibility.dart'
    as _inqugb0g;
import 'package:ground_control_client/src/protocol/domains/capsules/models/compute_info.dart'
    as _i9c8bf6t;
import 'package:ground_control_client/src/protocol/domains/capsules/models/compute_size_option.dart'
    as _ip9fvkzb;
import 'package:ground_control_client/src/protocol/domains/databases/models/backup_frequency.dart'
    as _igzjl4y6;
import 'package:ground_control_client/src/protocol/domains/databases/models/backup_schedule.dart'
    as _i2xil1ww;
import 'package:ground_control_client/src/protocol/domains/databases/models/database_connection.dart'
    as _i0jkhqr7;
import 'package:ground_control_client/src/protocol/domains/databases/models/database_info.dart'
    as _ihs8psvs;
import 'package:ground_control_client/src/protocol/domains/databases/models/database_resource.dart'
    as _ipowkh5v;
import 'package:ground_control_client/src/protocol/domains/databases/models/database_size.dart'
    as _iamz36cc;
import 'package:ground_control_client/src/protocol/domains/databases/models/database_snapshot.dart'
    as _ia6js50c;
import 'package:ground_control_client/src/protocol/domains/databases/models/database_user.dart'
    as _iztc790o;
import 'package:ground_control_client/src/protocol/domains/environment_variables/models/variable.dart'
    as _i82frs35;
import 'package:ground_control_client/src/protocol/domains/logs/models/log_record.dart'
    as _ig53v5t0;
import 'package:ground_control_client/src/protocol/domains/metrics/models/capsule_network_series.dart'
    as _itrp1ue5;
import 'package:ground_control_client/src/protocol/domains/metrics/models/database_metrics.dart'
    as _ii9nkdyl;
import 'package:ground_control_client/src/protocol/domains/metrics/models/metrics_range.dart'
    as _ioikgkhk;
import 'package:ground_control_client/src/protocol/domains/metrics/models/pod_resource_series.dart'
    as _ie2iiqds;
import 'package:ground_control_client/src/protocol/domains/products/models/plan_info.dart'
    as _ibsngdn1;
import 'package:ground_control_client/src/protocol/domains/products/models/subscription_info.dart'
    as _i2pv1k63;
import 'package:ground_control_client/src/protocol/domains/projects/models/project.dart'
    as _iavjecni;
import 'package:ground_control_client/src/protocol/domains/projects/models/role.dart'
    as _iavafiww;
import 'package:ground_control_client/src/protocol/domains/secrets/models/build_secret_type.dart'
    as _ifyrekdh;
import 'package:ground_control_client/src/protocol/domains/status/models/capsule_status.dart'
    as _i0c2pd3m;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i51mvi6s;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _iy77socp;
import 'package:ground_control_client/src/protocol/domains/users/models/user.dart'
    as _ibu0ogga;
import 'package:ground_control_client/src/protocol/domains/users/models/user_account_status.dart'
    as _ivvwo8y6;
import 'package:ground_control_client/src/protocol/features/auth/models/accepted_terms_dto.dart'
    as _irrma5ts;
import 'package:ground_control_client/src/protocol/features/auth/models/auth_token_info.dart'
    as _i9cx54ed;
import 'package:ground_control_client/src/protocol/features/auth/models/required_terms.dart'
    as _iu79vy7r;
import 'package:ground_control_client/src/protocol/features/custom_domains/models/custom_domain_name_list.dart'
    as _iv3w4cs7;
import 'package:ground_control_client/src/protocol/features/custom_domains/models/domain_name_status.dart'
    as _i83df8bo;
import 'package:ground_control_client/src/protocol/features/custom_domains/models/domain_name_target.dart'
    as _ifhcsb69;
import 'package:ground_control_client/src/protocol/features/custom_domains/models/view_models/custom_domain_name_with_default_domains.dart'
    as _i8g96tte;
import 'package:ground_control_client/src/protocol/features/insights/models/insights_connection_detail.dart'
    as _ikql43mq;
import 'package:ground_control_client/src/protocol/features/platform/models/dart_sdk_version_policy.dart'
    as _iw9inwiv;
import 'package:ground_control_client/src/protocol/features/projects/models/project_config.dart'
    as _i93ixjag;
import 'package:ground_control_client/src/protocol/features/projects/models/project_info/project_info.dart'
    as _ixukenxa;
import 'package:ground_control_client/src/protocol/features/projects/models/project_profile_update.dart'
    as _iag8nc5u;
import 'package:ground_control_client/src/protocol/features/status/models/capsule_runtime_status.dart'
    as _iw0bb95d;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// {@category Endpoint}
class EndpointAdminMigration extends _isc.EndpointRef {
  EndpointAdminMigration(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminMigration';
}

/// Endpoint for global administrator to handle procurement for users.
/// {@category Endpoint}
class EndpointAdminProcurement extends _isc.EndpointRef {
  EndpointAdminProcurement(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminProcurement';

  /// Procures a plan for a user.
  /// If [planProductVersion] is not provided, the latest version is used.
  /// If [trialPeriodOverride] is provided, it will override the trial period (number of days)
  /// in billing. The owner's trial end is synced from the new subscription afterward.
  /// If [overrideChecks] is true, the product availability checks are overridden.
  ///
  /// Returns the subscription ID of the created subscription.
  ///
  /// Throws a [NotFoundException] if the user or product is not found.
  /// Throws a [InvalidValueException] if the user has no owner (not fully registered).
  _ida.Future<_isc.UuidValue> procurePlan({
    required String userEmail,
    required String planProductName,
    int? planProductVersion,
    int? trialPeriodOverride,
    bool? overrideChecks,
  }) => caller
      .callServerEndpoint<_isc.UuidValue>('adminProcurement', 'procurePlan', {
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
  _ida.Future<List<(String, String)>> listProcuredProducts({
    required String userEmail,
  }) => caller.callServerEndpoint<List<(String, String)>>(
    'adminProcurement',
    'listProcuredProducts',
    {'userEmail': userEmail},
  );

  /// Cancels a subscription of the user at the end of its current term.
  /// Either [subscriptionId] or [cloudProjectId] must be provided.
  ///
  /// If [terminateImmediately] is true, the subscription is terminated
  /// immediately. If the user still has any active resource products,
  /// a [ProcurementCancellationException] will be thrown.
  ///
  /// Throws a [NoSubscriptionException] if the user has no subscription.
  /// Throws a [ProcurementCancellationException] if the subscription has
  /// already been cancelled or ended.
  _ida.Future<void> cancelPlan({
    required String userEmail,
    _isc.UuidValue? subscriptionId,
    String? cloudProjectId,
    bool? terminateImmediately,
  }) => caller.callServerEndpoint<void>('adminProcurement', 'cancelPlan', {
    'userEmail': userEmail,
    'subscriptionId': subscriptionId,
    'cloudProjectId': cloudProjectId,
    'terminateImmediately': terminateImmediately,
  });
}

/// Endpoint for global administrator projects access.
/// {@category Endpoint}
class EndpointAdminProjects extends _isc.EndpointRef {
  EndpointAdminProjects(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminProjects';

  /// Fetches the list of all projects.
  /// The result includes the owners for each project.
  @Deprecated('Use listProjectsInfo instead')
  _ida.Future<List<_iavjecni.Project>> listProjects({bool? includeArchived}) =>
      caller.callServerEndpoint<List<_iavjecni.Project>>(
        'adminProjects',
        'listProjects',
        {'includeArchived': includeArchived},
      );

  /// Fetches the list of all projects.
  /// The result includes the owners for each project
  /// and the latest deploy attempt time (or null if undeployed).
  _ida.Future<List<_ixukenxa.ProjectInfo>> listProjectsInfo({
    bool? includeArchived,
    bool? includeLatestDeployAttemptTime,
  }) => caller.callServerEndpoint<List<_ixukenxa.ProjectInfo>>(
    'adminProjects',
    'listProjectsInfo',
    {
      'includeArchived': includeArchived,
      'includeLatestDeployAttemptTime': includeLatestDeployAttemptTime,
    },
  );

  /// Gets deploy attempts of the specified capsule.
  /// Gets the recent-most attempts, up till [limit] if specified.
  _ida.Future<List<_i51mvi6s.DeployAttempt>> getDeployAttempts({
    required String cloudCapsuleId,
    int? limit,
  }) => caller.callServerEndpoint<List<_i51mvi6s.DeployAttempt>>(
    'adminProjects',
    'getDeployAttempts',
    {'cloudCapsuleId': cloudCapsuleId, 'limit': limit},
  );

  /// Archives a project and its capsule and permanently deletes its
  /// infrastructure on behalf of a user.
  /// Executes the same deletion code path as the regular deleteProject endpoint,
  /// but bypasses project-level authorization.
  ///
  /// If [keepEmptySubscription] is true, the project's subscription is not
  /// terminated even if it has no more resource products.
  _ida.Future<_iavjecni.Project> deleteProject({
    required String cloudProjectId,
    bool? keepEmptySubscription,
  }) => caller
      .callServerEndpoint<_iavjecni.Project>('adminProjects', 'deleteProject', {
        'cloudProjectId': cloudProjectId,
        'keepEmptySubscription': keepEmptySubscription,
      });

  /// Redeploys a capsule using its current image.
  /// Triggers a deploymentUpdated event to redeploy the infrastructure.
  ///
  /// Throws a [NoPriorDeploymentException] if the capsule has no prior deployment.
  _ida.Future<void> redeployCapsule(String cloudCapsuleId) =>
      caller.callServerEndpoint<void>('adminProjects', 'redeployCapsule', {
        'cloudCapsuleId': cloudCapsuleId,
      });
}

/// Endpoint for global administrator secrets migration.
/// {@category Endpoint}
class EndpointAdminSecrets extends _isc.EndpointRef {
  EndpointAdminSecrets(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminSecrets';

  /// Injects SERVERPOD_SESSION_PERSISTENT_LOG_ENABLED=true for managed secrets
  /// that already have SERVERPOD_DATABASE_HOST. Remove when migration is complete.
  _ida.Future<void> migrateManagedSecrets() => caller.callServerEndpoint<void>(
    'adminSecrets',
    'migrateManagedSecrets',
    {},
  );
}

/// Endpoint for the one-off storage-identity backfill.
/// {@category Endpoint}
class EndpointAdminStorageIdentity extends _isc.EndpointRef {
  EndpointAdminStorageIdentity(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminStorageIdentity';

  /// Provisions a storage identity and delivers its account key for every
  /// capsule whose managed secret predates the storage-identity feature.
  ///
  /// Capsules created after the feature shipped get their identity with the
  /// rest of the bootstrap secrets. Remove when the backfill is complete.
  _ida.Future<void> backfillStorageIdentities() =>
      caller.callServerEndpoint<void>(
        'adminStorageIdentity',
        'backfillStorageIdentities',
        {},
      );
}

/// {@category Endpoint}
class EndpointAdminUpdatePlan extends _isc.EndpointRef {
  EndpointAdminUpdatePlan(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminUpdatePlan';

  /// Lists all handled Orb plans by external plan id.
  _ida.Future<List<String>> listOrbPlans() => caller
      .callServerEndpoint<List<String>>('adminUpdatePlan', 'listOrbPlans', {});

  /// Pushes the current configuration for a plan to Orb.
  _ida.Future<Map<String, String>> updateOrbPlan({
    required String externalPlanId,
  }) => caller.callServerEndpoint<Map<String, String>>(
    'adminUpdatePlan',
    'updateOrbPlan',
    {'externalPlanId': externalPlanId},
  );
}

/// Endpoint for global administrator users access.
/// {@category Endpoint}
class EndpointAdminUsers extends _isc.EndpointRef {
  EndpointAdminUsers(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminUsers';

  /// Lists all users that match the specified criteria.
  _ida.Future<List<_ibu0ogga.User>> listUsers({
    String? cloudProjectId,
    _ivvwo8y6.UserAccountStatus? ofAccountStatus,
    bool? includeArchived,
  }) => caller
      .callServerEndpoint<List<_ibu0ogga.User>>('adminUsers', 'listUsers', {
        'cloudProjectId': cloudProjectId,
        'ofAccountStatus': ofAccountStatus,
        'includeArchived': includeArchived,
      });

  /// Invites a user to Serverpod Cloud.
  /// If the user does not exist, a user invitation email is sent.
  _ida.Future<void> inviteUser({required String email}) => caller
      .callServerEndpoint<void>('adminUsers', 'inviteUser', {'email': email});
}

/// Endpoint for authentication.
/// {@category Endpoint}
class EndpointAuth extends _isc.EndpointRef {
  EndpointAuth(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  _ida.Future<List<_iu79vy7r.RequiredTerms>> readRequiredTerms() =>
      caller.callServerEndpoint<List<_iu79vy7r.RequiredTerms>>(
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
  _ida.Future<void> startEmailAccountRegistration({
    required String email,
    String? name,
    required List<_irrma5ts.AcceptedTermsDTO> acceptedTerms,
  }) => caller.callServerEndpoint<void>(
    'auth',
    'startEmailAccountRegistration',
    {'email': email, 'name': name, 'acceptedTerms': acceptedTerms},
  );

  /// Verifies a registration code and returns the finish registration token.
  ///
  /// The token is used to finish the registration by calling
  /// [finishEmailAccountRegistration].
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
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
  _ida.Future<_iacc.AuthSuccess> finishEmailAccountRegistration({
    required String finishRegistrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'auth',
    'finishEmailAccountRegistration',
    {'finishRegistrationToken': finishRegistrationToken, 'password': password},
  );

  /// Logs in the user and returns a new session.
  ///
  /// In case an expected error occurs, this throws a
  /// `EmailAccountLoginException`.
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>('auth', 'login', {
    'email': email,
    'password': password,
  });

  @Deprecated('Use [authWithAuth.logoutDevice] instead')
  _ida.Future<void> logoutDevice() =>
      caller.callServerEndpoint<void>('auth', 'logoutDevice', {});

  /// Requests a password reset for [email].
  ///
  /// Throws [EmailAccountPasswordResetRequestTooManyAttemptsException] if the
  /// user has made too many requests.
  _ida.Future<void> startPasswordReset({required String email}) => caller
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
  _ida.Future<_iacc.AuthSuccess> finishPasswordReset({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
    required String newPassword,
  }) => caller
      .callServerEndpoint<_iacc.AuthSuccess>('auth', 'finishPasswordReset', {
        'passwordResetRequestId': passwordResetRequestId,
        'verificationCode': verificationCode,
        'newPassword': newPassword,
      });
}

/// Endpoint for authenticated-user session management.
/// {@category Endpoint}
class EndpointAuthWithAuth extends _isc.EndpointRef {
  EndpointAuthWithAuth(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'authWithAuth';

  /// Log out the current user from a login session or API token.
  /// If no [authTokenId] is provided, it will log out the current session.
  /// Only the targeted session is logged out; the user's other login sessions
  /// and API tokens will not be affected.
  ///
  /// Returns true if it was the current session that was logged out,
  /// false if it was a different session.
  _ida.Future<bool> logoutDevice({String? authTokenId}) =>
      caller.callServerEndpoint<bool>('authWithAuth', 'logoutDevice', {
        'authTokenId': authTokenId,
      });

  /// Log out the current user from all sessions including API tokens.
  _ida.Future<void> logoutAll() =>
      caller.callServerEndpoint<void>('authWithAuth', 'logoutAll', {});

  /// Creates a new authenticated session for the current user to use as
  /// CLI token / personal access token.
  ///
  /// If [expiresAt] is provided, the token will expire at the specified time.
  /// If [expiresAfter] is provided, the token will expire after being unused
  /// for the specified duration.
  _ida.Future<_iacc.AuthSuccess> createCliToken({
    DateTime? expiresAt,
    Duration? expiresAfter,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'authWithAuth',
    'createCliToken',
    {'expiresAt': expiresAt, 'expiresAfter': expiresAfter},
  );

  _ida.Future<List<_i9cx54ed.AuthTokenInfo>> listAuthSessions() =>
      caller.callServerEndpoint<List<_i9cx54ed.AuthTokenInfo>>(
        'authWithAuth',
        'listAuthSessions',
        {},
      );

  _ida.Future<String> getFeaturebaseSsoJwt() => caller
      .callServerEndpoint<String>('authWithAuth', 'getFeaturebaseSsoJwt', {});
}

/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Returns the list of terms that the user must accept when registering.
  _ida.Future<List<_iu79vy7r.RequiredTerms>> readRequiredTerms() =>
      caller.callServerEndpoint<List<_iu79vy7r.RequiredTerms>>(
        'emailIdp',
        'readRequiredTerms',
        {},
      );

  /// Starts the registration for a new user account.
  ///
  /// Accepts an optional [name] and required [acceptedTerms] in addition to
  /// [email]. Validates terms acceptance and stores the user's name before
  /// delegating to the email IDP.
  ///
  /// Throws [UserAccountRegistrationDeniedException] if the user has not
  /// accepted the required terms of service.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({
    required String email,
    String? name,
    List<_irrma5ts.AcceptedTermsDTO>? acceptedTerms,
  }) => caller.callServerEndpoint<_isc.UuidValue>(
    'emailIdp',
    'startRegistration',
    {'email': email, 'name': name, 'acceptedTerms': acceptedTerms},
  );

  /// Logs in the user and returns a new session.
  ///
  /// In case an expected error occurs, this throws an
  /// [EmailAccountLoginException]. If the user registered via a different
  /// identity provider, throws [EmailMethodBlockedException].
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>('emailIdp', 'login', {
    'email': email,
    'password': password,
  });

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
  _ida.Future<_iacc.AuthSuccess> resetPassword({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
    required String newPassword,
  }) => caller
      .callServerEndpoint<_iacc.AuthSuccess>('emailIdp', 'resetPassword', {
        'passwordResetRequestId': passwordResetRequestId,
        'verificationCode': verificationCode,
        'newPassword': newPassword,
      });

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) =>
      caller.callServerEndpoint<String>('emailIdp', 'verifyRegistrationCode', {
        'accountRequestId': accountRequestId,
        'verificationCode': verificationCode,
      });

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {'registrationToken': registrationToken, 'password': password},
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) =>
      caller.callServerEndpoint<String>('emailIdp', 'verifyPasswordResetCode', {
        'passwordResetRequestId': passwordResetRequestId,
        'verificationCode': verificationCode,
      });

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>('emailIdp', 'finishPasswordReset', {
    'finishPasswordResetToken': finishPasswordResetToken,
    'newPassword': newPassword,
  });

  @override
  _ida.Future<bool> hasAccount() =>
      caller.callServerEndpoint<bool>('emailIdp', 'hasAccount', {});
}

/// {@category Endpoint}
class EndpointGitHubIdp extends _iaic.EndpointGitHubIdpBase {
  EndpointGitHubIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'gitHubIdp';

  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>('gitHubIdp', 'login', {
    'code': code,
    'codeVerifier': codeVerifier,
    'redirectUri': redirectUri,
  });

  @override
  _ida.Future<bool> hasAccount() =>
      caller.callServerEndpoint<bool>('gitHubIdp', 'hasAccount', {});
}

/// {@category Endpoint}
class EndpointGoogleIdp extends _iaic.EndpointGoogleIdpBase {
  EndpointGoogleIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'googleIdp';

  @override
  _ida.Future<_iacc.AuthSuccess> loginWithCode({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'googleIdp',
    'loginWithCode',
    {'code': code, 'codeVerifier': codeVerifier, 'redirectUri': redirectUri},
  );

  /// Validates a Google ID token and either logs in the associated user or
  /// creates a new user account if the Google account ID is not yet known.
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String idToken,
    required String? accessToken,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>('googleIdp', 'login', {
    'idToken': idToken,
    'accessToken': accessToken,
  });

  @override
  _ida.Future<bool> hasAccount() =>
      caller.callServerEndpoint<bool>('googleIdp', 'hasAccount', {});
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// {@category Endpoint}
class EndpointBilling extends _isc.EndpointRef {
  EndpointBilling(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'billing';

  /// Reads the owner information.
  ///
  /// Returns the [Owner] object,
  /// including the [User] object, and [BillingInfo] if it exists
  /// (including the billing address and email addresses).
  ///
  /// Throws a [NotFoundException] if the owner is not found.
  _ida.Future<_ijvsyu4l.Owner> readOwner() =>
      caller.callServerEndpoint<_ijvsyu4l.Owner>('billing', 'readOwner', {});

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
  ///
  /// Throws [InvalidValueException] if required business billing fields are
  /// missing or invalid.
  _ida.Future<_ijvsyu4l.Owner> updateOwnerBilling({
    required List<String> billingEmails,
    required _iup39bna.BillingInfo billingInfo,
  }) => caller.callServerEndpoint<_ijvsyu4l.Owner>(
    'billing',
    'updateOwnerBilling',
    {'billingEmails': billingEmails, 'billingInfo': billingInfo},
  );

  /// Sets the owner's customer type (private or business) as a stop-gap until
  /// B2C/B2B migration is supported.
  ///
  /// Idempotent: calling this with the same value as already stored is a no-op.
  ///
  /// Throws [InvalidValueException] if the owner already has a different
  /// customer type set.
  _ida.Future<_ijvsyu4l.Owner> setOwnerCustomerType({
    required _iqua0tdt.BillingCustomerType customerType,
  }) => caller.callServerEndpoint<_ijvsyu4l.Owner>(
    'billing',
    'setOwnerCustomerType',
    {'customerType': customerType},
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
  _ida.Future<_ia3irqvx.PaymentSetupIntent> createSetupIntent() =>
      caller.callServerEndpoint<_ia3irqvx.PaymentSetupIntent>(
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
  _ida.Future<List<_itisjjd4.PaymentMethod>> listPaymentMethods() =>
      caller.callServerEndpoint<List<_itisjjd4.PaymentMethod>>(
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
  /// Throws [InvalidValueException] if the payment method doesn't belong to the user.
  /// Throws [InvalidValueException] if payment method is required and this is the last payment method.
  _ida.Future<void> removePaymentMethod({required String paymentMethodId}) =>
      caller.callServerEndpoint<void>('billing', 'removePaymentMethod', {
        'paymentMethodId': paymentMethodId,
      });

  /// Checks if a payment method is required for the authenticated user.
  ///
  /// This endpoint returns `true` if the user has active (non-archived) projects,
  /// meaning they cannot delete their last payment method. Returns `false` otherwise.
  ///
  /// Returns `true` if a payment method is required, `false` otherwise.
  _ida.Future<bool> isPaymentMethodRequired() =>
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
  /// Throws [InvalidValueException] if the payment method doesn't belong to the user.
  _ida.Future<void> setDefaultPaymentMethod({
    required String paymentMethodId,
  }) => caller.callServerEndpoint<void>('billing', 'setDefaultPaymentMethod', {
    'paymentMethodId': paymentMethodId,
  });

  /// Checks if the owner is in good standing.
  ///
  /// Verifies that the owner's billing account is active and has no outstanding
  /// issues that would prevent normal operation of the service.
  _ida.Future<bool> ownerIsInGoodStanding() =>
      caller.callServerEndpoint<bool>('billing', 'ownerIsInGoodStanding', {});
}

/// Endpoint for managing a capsule's storage buckets.
/// {@category Endpoint}
class EndpointBucket extends _isc.EndpointRef {
  EndpointBucket(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'bucket';

  /// Creates a bucket for a capsule under [storageId] with the given
  /// [visibility]. The capsule's storage identity is provisioned first
  /// (idempotent).
  ///
  /// Throws [NotFoundException] if the capsule is not found.
  /// Throws [DuplicateEntryException] if the storage id is already in use
  /// for this capsule.
  /// Throws [ProcurementDeniedException] if the capsule has no remaining bucket
  /// allowance.
  /// Throws [BucketStorageIdentityUnavailableException] if the storage identity
  /// is not ready yet (safe to retry).
  _ida.Future<_itj7xmug.BucketResource> createBucket({
    required String cloudCapsuleId,
    required String storageId,
    required _inqugb0g.BucketVisibility visibility,
  }) => caller
      .callServerEndpoint<_itj7xmug.BucketResource>('bucket', 'createBucket', {
        'cloudCapsuleId': cloudCapsuleId,
        'storageId': storageId,
        'visibility': visibility,
      });

  /// Deletes the bucket for a capsule under [storageId].
  ///
  /// Throws [NotFoundException] if the bucket is not found.
  _ida.Future<void> deleteBucket({
    required String cloudCapsuleId,
    required String storageId,
  }) => caller.callServerEndpoint<void>('bucket', 'deleteBucket', {
    'cloudCapsuleId': cloudCapsuleId,
    'storageId': storageId,
  });

  /// Lists the buckets for a capsule.
  _ida.Future<List<_itj7xmug.BucketResource>> listBuckets({
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<List<_itj7xmug.BucketResource>>(
    'bucket',
    'listBuckets',
    {'cloudCapsuleId': cloudCapsuleId},
  );
}

/// Endpoint for the object contents of a capsule's storage buckets.
/// {@category Endpoint}
class EndpointBucketObjects extends _isc.EndpointRef {
  EndpointBucketObjects(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'bucketObjects';

  /// Lists a page of files in a capsule's bucket, optionally filtered by
  /// [prefix] and continued from [pageToken].
  ///
  /// Throws [NotFoundException] if the bucket is not found.
  _ida.Future<_ikaw0g5r.BucketFileListing> listFiles({
    required String cloudCapsuleId,
    required String storageId,
    String? prefix,
    String? pageToken,
  }) => caller.callServerEndpoint<_ikaw0g5r.BucketFileListing>(
    'bucketObjects',
    'listFiles',
    {
      'cloudCapsuleId': cloudCapsuleId,
      'storageId': storageId,
      'prefix': prefix,
      'pageToken': pageToken,
    },
  );

  /// Deletes the file at [path] from a capsule's bucket.
  ///
  /// Throws [NotFoundException] if the bucket is not found.
  _ida.Future<void> deleteFile({
    required String cloudCapsuleId,
    required String storageId,
    required String path,
  }) => caller.callServerEndpoint<void>('bucketObjects', 'deleteFile', {
    'cloudCapsuleId': cloudCapsuleId,
    'storageId': storageId,
    'path': path,
  });

  /// Builds a signed direct-upload description (JSON) for [path] in a capsule's
  /// bucket.
  ///
  /// Throws [NotFoundException] if the bucket is not found.
  _ida.Future<String> createUploadDescription({
    required String cloudCapsuleId,
    required String storageId,
    required String path,
  }) => caller.callServerEndpoint<String>(
    'bucketObjects',
    'createUploadDescription',
    {'cloudCapsuleId': cloudCapsuleId, 'storageId': storageId, 'path': path},
  );

  /// Builds a signed download URL for [path] in a capsule's bucket.
  ///
  /// Throws [NotFoundException] if the bucket is not found.
  _ida.Future<String> getDownloadUrl({
    required String cloudCapsuleId,
    required String storageId,
    required String path,
  }) => caller.callServerEndpoint<String>('bucketObjects', 'getDownloadUrl', {
    'cloudCapsuleId': cloudCapsuleId,
    'storageId': storageId,
    'path': path,
  });
}

/// Endpoint for capsule operations.
/// {@category Endpoint}
class EndpointCapsules extends _isc.EndpointRef {
  EndpointCapsules(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'capsules';

  /// Redeploys a capsule using its current image.
  /// Triggers a deploymentUpdated event to redeploy the infrastructure.
  ///
  /// Throws a [NoPriorDeploymentException] if the capsule has no prior deployment.
  _ida.Future<void> redeployCapsule({required String cloudCapsuleId}) =>
      caller.callServerEndpoint<void>('capsules', 'redeployCapsule', {
        'cloudCapsuleId': cloudCapsuleId,
      });
}

/// Endpoint for reading and updating capsule compute configuration.
/// {@category Endpoint}
class EndpointCompute extends _isc.EndpointRef {
  EndpointCompute(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'compute';

  /// Reads the compute for a capsule.
  _ida.Future<_i9c8bf6t.ComputeInfo> readCompute({
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i9c8bf6t.ComputeInfo>(
    'compute',
    'readCompute',
    {'cloudCapsuleId': cloudCapsuleId},
  );

  /// Updates the compute configuration for a capsule.
  ///
  /// Validates the requested size and replica counts against the capsule's
  /// product constraints, persists the new configuration, and triggers an
  /// infrastructure update for any existing deployment.
  _ida.Future<_i9c8bf6t.ComputeInfo> updateCompute({
    required String cloudCapsuleId,
    required _ip9fvkzb.ComputeSizeOption size,
    required int minInstances,
    required int maxInstances,
  }) => caller
      .callServerEndpoint<_i9c8bf6t.ComputeInfo>('compute', 'updateCompute', {
        'cloudCapsuleId': cloudCapsuleId,
        'size': size,
        'minInstances': minInstances,
        'maxInstances': maxInstances,
      });
}

/// {@category Endpoint}
class EndpointCustomDomainName extends _isc.EndpointRef {
  EndpointCustomDomainName(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'customDomainName';

  _ida.Future<_i8g96tte.CustomDomainNameWithDefaultDomains> add({
    required String domainName,
    required _ifhcsb69.DomainNameTarget target,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i8g96tte.CustomDomainNameWithDefaultDomains>(
    'customDomainName',
    'add',
    {
      'domainName': domainName,
      'target': target,
      'cloudCapsuleId': cloudCapsuleId,
    },
  );

  _ida.Future<void> remove({
    required String domainName,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<void>('customDomainName', 'remove', {
    'domainName': domainName,
    'cloudCapsuleId': cloudCapsuleId,
  });

  _ida.Future<_iv3w4cs7.CustomDomainNameList> list({
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_iv3w4cs7.CustomDomainNameList>(
    'customDomainName',
    'list',
    {'cloudCapsuleId': cloudCapsuleId},
  );

  _ida.Future<_i83df8bo.DomainNameStatus> refreshRecord({
    required String domainName,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i83df8bo.DomainNameStatus>(
    'customDomainName',
    'refreshRecord',
    {'domainName': domainName, 'cloudCapsuleId': cloudCapsuleId},
  );
}

/// Endpoint for database management.
/// {@category Endpoint}
class EndpointDatabase extends _isc.EndpointRef {
  EndpointDatabase(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'database';

  /// Enables the database for a project.
  ///
  /// Throws [NotFoundException] if the capsule is not found.
  /// Throws [ProcurementDeniedException] if the database product is not available for the capsule.
  /// Throws [DatabaseResourceCreationFailed] if the database resource creation fails.
  _ida.Future<void> enableDatabase({required String cloudCapsuleId}) =>
      caller.callServerEndpoint<void>('database', 'enableDatabase', {
        'cloudCapsuleId': cloudCapsuleId,
      });

  /// Returns the connection details for a database resource.
  /// Throws [NotFoundException] if the database is not found.
  _ida.Future<_i0jkhqr7.DatabaseConnection> getConnectionDetails({
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i0jkhqr7.DatabaseConnection>(
    'database',
    'getConnectionDetails',
    {'cloudCapsuleId': cloudCapsuleId},
  );

  /// Returns persisted database capacity and quota for [cloudCapsuleId].
  ///
  /// Throws [NotFoundException] if the database is not found.
  _ida.Future<_ihs8psvs.DatabaseInfo> readDatabase({
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_ihs8psvs.DatabaseInfo>(
    'database',
    'readDatabase',
    {'cloudCapsuleId': cloudCapsuleId},
  );

  /// Creates a new super user in the database.
  /// Returns the password for the new user.
  ///
  /// Throws [NotFoundException] if the database is not found.
  /// Throws [DuplicateEntryException] if the [username] already exists.
  _ida.Future<String> createSuperUser({
    required String cloudCapsuleId,
    required String username,
  }) => caller.callServerEndpoint<String>('database', 'createSuperUser', {
    'cloudCapsuleId': cloudCapsuleId,
    'username': username,
  });

  /// Resets the password for a user in the database.
  /// Returns the new password for the user.
  ///
  /// Throws [NotFoundException] if the database is not found.
  /// Throws [InvalidValueException] if the [username] is the owner user.
  _ida.Future<String> resetDatabasePassword({
    required String cloudCapsuleId,
    required String username,
  }) => caller.callServerEndpoint<String>('database', 'resetDatabasePassword', {
    'cloudCapsuleId': cloudCapsuleId,
    'username': username,
  });

  /// Lists the user-created superusers of the database.
  ///
  /// Throws [NotFoundException] if the database is not found.
  _ida.Future<List<_iztc790o.DatabaseUser>> listDatabaseUsers({
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<List<_iztc790o.DatabaseUser>>(
    'database',
    'listDatabaseUsers',
    {'cloudCapsuleId': cloudCapsuleId},
  );

  /// Deletes a user from the database.
  ///
  /// Throws [NotFoundException] if the database is not found.
  /// Throws [InvalidValueException] if the [username] is the owner user.
  _ida.Future<void> deleteDatabaseUser({
    required String cloudCapsuleId,
    required String username,
  }) => caller.callServerEndpoint<void>('database', 'deleteDatabaseUser', {
    'cloudCapsuleId': cloudCapsuleId,
    'username': username,
  });

  /// Wipes the database by deleting and recreating it.
  /// This will drop all tables and data in the database.
  /// The deployment will error until a redeploy is performed.
  ///
  /// Throws [NotFoundException] if the database is not found.
  _ida.Future<void> wipeDatabase({required String cloudCapsuleId}) =>
      caller.callServerEndpoint<void>('database', 'wipeDatabase', {
        'cloudCapsuleId': cloudCapsuleId,
      });

  /// Updates the size and the autoscaling CU limits for a capsule's database,
  /// changing the procured database product if necessary.
  /// The size and limits are validated against the constraints of the capsule's
  /// product.
  ///
  /// [minCu] and [maxCu] must be provided together or both omitted.
  ///
  /// Throws [ProcurementDeniedException] if the size is not available for the capsule.
  /// Throws [InvalidValueException] if the size, minCu, and maxCu combination is invalid.
  /// Throws [NotFoundException] if no database is found for the capsule.
  _ida.Future<_ipowkh5v.DatabaseResource> updateDatabaseSize({
    required String cloudCapsuleId,
    required _iamz36cc.DatabaseSizeOption size,
    double? minCu,
    double? maxCu,
  }) => caller.callServerEndpoint<_ipowkh5v.DatabaseResource>(
    'database',
    'updateDatabaseSize',
    {
      'cloudCapsuleId': cloudCapsuleId,
      'size': size,
      'minCu': minCu,
      'maxCu': maxCu,
    },
  );

  /// Creates a manual snapshot of the capsule's database.
  ///
  /// Throws [ProcurementDeniedException] if the capsule's plan does not include
  /// the backup feature.
  /// Throws [NotFoundException] if the database is not found.
  /// Throws [DatabaseSnapshotLimitException] if the per-project snapshot limit
  /// has been reached.
  _ida.Future<_ia6js50c.DatabaseSnapshot> createSnapshot({
    required String cloudCapsuleId,
    String? name,
    DateTime? expiresAt,
  }) => caller.callServerEndpoint<_ia6js50c.DatabaseSnapshot>(
    'database',
    'createSnapshot',
    {'cloudCapsuleId': cloudCapsuleId, 'name': name, 'expiresAt': expiresAt},
  );

  /// Lists the snapshots of the capsule's database.
  ///
  /// Throws [NotFoundException] if the database is not found.
  _ida.Future<List<_ia6js50c.DatabaseSnapshot>> listSnapshots({
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<List<_ia6js50c.DatabaseSnapshot>>(
    'database',
    'listSnapshots',
    {'cloudCapsuleId': cloudCapsuleId},
  );

  /// Deletes a snapshot of the capsule's database.
  ///
  /// Throws [NotFoundException] if the database is not found.
  _ida.Future<void> deleteSnapshot({
    required String cloudCapsuleId,
    required String snapshotId,
  }) => caller.callServerEndpoint<void>('database', 'deleteSnapshot', {
    'cloudCapsuleId': cloudCapsuleId,
    'snapshotId': snapshotId,
  });

  /// Returns the automated backup schedule for the capsule's database, or null
  /// if none is configured.
  ///
  /// Throws [NotFoundException] if the database is not found.
  _ida.Future<_i2xil1ww.BackupSchedule?> getBackupSchedule({
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i2xil1ww.BackupSchedule?>(
    'database',
    'getBackupSchedule',
    {'cloudCapsuleId': cloudCapsuleId},
  );

  /// Sets the automated backup schedule for the capsule's database.
  ///
  /// Passing a null [frequency] disables automated backups.
  ///
  /// Throws [ProcurementDeniedException] if [frequency] is not null and the
  /// capsule's plan does not include the backup feature.
  /// Throws [NotFoundException] if the database is not found.
  /// Throws [InvalidValueException] if the schedule parameters are invalid for
  /// the given [frequency] (e.g. a weekly/monthly schedule without a day, or a
  /// schedule without an hour), or if the provider rejects a value such as a
  /// retention period that exceeds the maximum allowed.
  _ida.Future<void> setBackupSchedule({
    required String cloudCapsuleId,
    _igzjl4y6.BackupFrequency? frequency,
    int? day,
    int? hour,
    Duration? retention,
  }) => caller.callServerEndpoint<void>('database', 'setBackupSchedule', {
    'cloudCapsuleId': cloudCapsuleId,
    'frequency': frequency,
    'day': day,
    'hour': hour,
    'retention': retention,
  });

  /// Restores the capsule's live database to the given snapshot.
  ///
  /// The connection string is preserved; only the underlying branch changes.
  ///
  /// Throws [ProcurementDeniedException] if the capsule's plan does not include
  /// the backup feature.
  /// Throws [NotFoundException] if the database is not found.
  _ida.Future<void> restoreFromSnapshot({
    required String cloudCapsuleId,
    required String snapshotId,
  }) => caller.callServerEndpoint<void>('database', 'restoreFromSnapshot', {
    'cloudCapsuleId': cloudCapsuleId,
    'snapshotId': snapshotId,
  });
}

/// Endpoint for infrastructure resource provisioning.
/// {@category Endpoint}
class EndpointInfraResources extends _isc.EndpointRef {
  EndpointInfraResources(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'infraResources';

  /// Enables the database for a project.
  @Deprecated('Use DatabaseEndpoint.enableDatabase instead')
  _ida.Future<void> enableDatabase({required String cloudCapsuleId}) =>
      caller.callServerEndpoint<void>('infraResources', 'enableDatabase', {
        'cloudCapsuleId': cloudCapsuleId,
      });
}

/// {@category Endpoint}
class EndpointDeploy extends _isc.EndpointRef {
  EndpointDeploy(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'deploy';

  _ida.Future<String> createUploadDescription(
    String cloudProjectId, {
    String? serverpodVersion,
    String? dartVersion,
    String? commitHash,
    String? commitMessage,
    String? branch,
  }) => caller.callServerEndpoint<String>('deploy', 'createUploadDescription', {
    'cloudProjectId': cloudProjectId,
    'serverpodVersion': serverpodVersion,
    'dartVersion': dartVersion,
    'commitHash': commitHash,
    'commitMessage': commitMessage,
    'branch': branch,
  });
}

/// Endpoint for managing environment variables.
/// {@category Endpoint}
class EndpointEnvironmentVariables extends _isc.EndpointRef {
  EndpointEnvironmentVariables(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'environmentVariables';

  /// Creates a new [EnvironmentVariable] with the specified [name] and [value].
  /// Throws a [DuplicateEntryException] if an environment variable with the same name already exists.
  _ida.Future<_i82frs35.EnvironmentVariable> create(
    String name,
    String value,
    String cloudCapsuleId,
  ) => caller.callServerEndpoint<_i82frs35.EnvironmentVariable>(
    'environmentVariables',
    'create',
    {'name': name, 'value': value, 'cloudCapsuleId': cloudCapsuleId},
  );

  /// Fetches the specified environment variable.
  /// Throws a [NotFoundException] if the environment variable is not found.
  _ida.Future<_i82frs35.EnvironmentVariable> read({
    required String name,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i82frs35.EnvironmentVariable>(
    'environmentVariables',
    'read',
    {'name': name, 'cloudCapsuleId': cloudCapsuleId},
  );

  /// Gets the list of environment variables for the given [cloudCapsuleId].
  _ida.Future<List<_i82frs35.EnvironmentVariable>> list(
    String cloudCapsuleId,
  ) => caller.callServerEndpoint<List<_i82frs35.EnvironmentVariable>>(
    'environmentVariables',
    'list',
    {'cloudCapsuleId': cloudCapsuleId},
  );

  /// Creates a new [EnvironmentVariable] with the specified [name] and [value].
  /// Throws a [NotFoundException] if the environment variable is not found.
  _ida.Future<_i82frs35.EnvironmentVariable> update({
    required String name,
    required String value,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i82frs35.EnvironmentVariable>(
    'environmentVariables',
    'update',
    {'name': name, 'value': value, 'cloudCapsuleId': cloudCapsuleId},
  );

  /// Permanently deletes an environment variable.
  /// Throws a [NotFoundException] if the environment variable is not found.
  _ida.Future<_i82frs35.EnvironmentVariable> delete({
    required String cloudCapsuleId,
    required String name,
  }) => caller.callServerEndpoint<_i82frs35.EnvironmentVariable>(
    'environmentVariables',
    'delete',
    {'cloudCapsuleId': cloudCapsuleId, 'name': name},
  );
}

/// {@category Endpoint}
class EndpointInsights extends _isc.EndpointRef {
  EndpointInsights(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'insights';

  /// Gets the connection details for the insights service.
  ///
  /// Requires project authorization with all scopes.
  ///
  /// Throws [UnauthorizedException] if the user is not authorized.
  /// Throws [NotFoundException] if insights service secret is not found.
  _ida.Future<_ikql43mq.InsightsConnectionDetail> getConnectionDetails({
    required String cloudProjectId,
  }) => caller.callServerEndpoint<_ikql43mq.InsightsConnectionDetail>(
    'insights',
    'getConnectionDetails',
    {'cloudProjectId': cloudProjectId},
  );
}

/// Endpoint for accessing cloud logs.
/// {@category Endpoint}
class EndpointLogs extends _isc.EndpointRef {
  EndpointLogs(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'logs';

  /// Fetches log records from the specified capsule.
  _ida.Stream<_ig53v5t0.LogRecord> fetchRecords({
    @Deprecated('Use cloudCapsuleId instead') String? cloudProjectId,
    String? cloudCapsuleId,
    DateTime? beforeTime,
    DateTime? afterTime,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ig53v5t0.LogRecord>,
        _ig53v5t0.LogRecord
      >('logs', 'fetchRecords', {
        'cloudProjectId': cloudProjectId,
        'cloudCapsuleId': cloudCapsuleId,
        'beforeTime': beforeTime,
        'afterTime': afterTime,
        'limit': limit,
      }, {});

  /// Fetches the N most recent records from the specified capsule,
  /// where N is the specified limit.
  /// Records are returned in ascending time order.
  ///
  /// This call will hold until all the records are fetched in order to sort them.
  _ida.Stream<_ig53v5t0.LogRecord> fetchRecentRecords({
    required String cloudCapsuleId,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ig53v5t0.LogRecord>,
        _ig53v5t0.LogRecord
      >('logs', 'fetchRecentRecords', {
        'cloudCapsuleId': cloudCapsuleId,
        'limit': limit,
      }, {});

  /// Tails log records from the specified capsule.
  /// Continues until the client unsubscribes, [limit] is reached,
  /// or the internal max limit is reached.
  _ida.Stream<_ig53v5t0.LogRecord> tailRecords({
    @Deprecated('Use cloudCapsuleId instead') String? cloudProjectId,
    String? cloudCapsuleId,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ig53v5t0.LogRecord>,
        _ig53v5t0.LogRecord
      >('logs', 'tailRecords', {
        'cloudProjectId': cloudProjectId,
        'cloudCapsuleId': cloudCapsuleId,
        'limit': limit,
      }, {});

  /// Fetches the build log records for the specified deploy attempt.
  _ida.Stream<_ig53v5t0.LogRecord> fetchBuildLog({
    @Deprecated('Use cloudCapsuleId instead') String? cloudProjectId,
    String? cloudCapsuleId,
    required _isc.UuidValue attemptId,
    int? limit,
  }) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ig53v5t0.LogRecord>,
        _ig53v5t0.LogRecord
      >('logs', 'fetchBuildLog', {
        'cloudProjectId': cloudProjectId,
        'cloudCapsuleId': cloudCapsuleId,
        'attemptId': attemptId,
        'limit': limit,
      }, {});

  /// Tails the build log records for the specified deploy attempt.
  /// Continues until the client unsubscribes or the build stage is final.
  _ida.Stream<_ig53v5t0.LogRecord> tailBuildLog({
    required String cloudCapsuleId,
    required _isc.UuidValue attemptId,
  }) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ig53v5t0.LogRecord>,
        _ig53v5t0.LogRecord
      >('logs', 'tailBuildLog', {
        'cloudCapsuleId': cloudCapsuleId,
        'attemptId': attemptId,
      }, {});
}

/// Endpoint for reading capsule metrics.
/// {@category Endpoint}
class EndpointMetrics extends _isc.EndpointRef {
  EndpointMetrics(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'metrics';

  /// Returns per-pod CPU (cores) and memory (bytes) series for the capsule
  /// over a window of length [range] ending at [until] (defaults to now).
  ///
  /// Series are sparse: gaps are represented by absent samples, never
  /// interpolated, so a client can distinguish "no data" from a real zero.
  _ida.Future<List<_ie2iiqds.PodResourceSeries>> fetchPodResourceMetrics({
    required String cloudCapsuleId,
    required _ioikgkhk.MetricsRange range,
    DateTime? until,
  }) => caller.callServerEndpoint<List<_ie2iiqds.PodResourceSeries>>(
    'metrics',
    'fetchPodResourceMetrics',
    {'cloudCapsuleId': cloudCapsuleId, 'range': range, 'until': until},
  );

  /// Returns aggregate request and response-rate series for the capsule over
  /// a window of length [range] ending at [until] (defaults to now).
  ///
  /// Series are sparse: a namespace with no series over the window returns an
  /// empty result, which reads as "no data"; an idle-but-deployed capsule
  /// carries its own zeros, so a zero-rate sample is a real reading.
  _ida.Future<_itrp1ue5.CapsuleNetworkSeries> fetchNetworkMetrics({
    required String cloudCapsuleId,
    required _ioikgkhk.MetricsRange range,
    DateTime? until,
  }) => caller.callServerEndpoint<_itrp1ue5.CapsuleNetworkSeries>(
    'metrics',
    'fetchNetworkMetrics',
    {'cloudCapsuleId': cloudCapsuleId, 'range': range, 'until': until},
  );

  /// Returns the database signal set for the capsule's database over a window
  /// of length [range] ending at [until] (defaults to now).
  ///
  /// Series are sparse and share the window and step of the pod metrics for
  /// the same capsule. An empty result is not an error: a suspended database
  /// exports nothing, and the returned status says whether the database was
  /// idle or does not have metrics export enabled.
  _ida.Future<_ii9nkdyl.DatabaseMetrics> fetchDatabaseMetrics({
    required String cloudCapsuleId,
    required _ioikgkhk.MetricsRange range,
    DateTime? until,
  }) => caller.callServerEndpoint<_ii9nkdyl.DatabaseMetrics>(
    'metrics',
    'fetchDatabaseMetrics',
    {'cloudCapsuleId': cloudCapsuleId, 'range': range, 'until': until},
  );
}

/// Endpoint for reading platform information about Serverpod Cloud.
/// {@category Endpoint}
class EndpointPlatform extends _isc.EndpointRef {
  EndpointPlatform(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'platform';

  /// Gets the Dart SDK version policy for projects deployed to Serverpod Cloud.
  ///
  /// This method requires no authentication.
  _ida.Future<_iw9inwiv.DartSdkVersionPolicy> getDartSdkVersionPolicy() =>
      caller.callServerEndpoint<_iw9inwiv.DartSdkVersionPolicy>(
        'platform',
        'getDartSdkVersionPolicy',
        {},
      );
}

/// Endpoint for managing subscription plans.
///
/// - Throws [ProcurementDeniedException] if the procurement fails.
/// - Throws [NotFoundException] if the plan is not found.
/// {@category Endpoint}
class EndpointPlans extends _isc.EndpointRef {
  EndpointPlans(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'plans';

  /// Procures a subscription plan.
  ///
  /// Returns the ID of the created subscription.
  ///
  /// For plans that depend on the customer billing type (private / business),
  /// [BillingCustomerType.private] is used when no customer billing type is set.
  ///
  /// If the plan is not available to procure, a [ProcurementDeniedException] is thrown.
  _ida.Future<_isc.UuidValue> procurePlan({
    String? planProductName,
    @Deprecated('Use planProductName instead') String? planName,
  }) => caller.callServerEndpoint<_isc.UuidValue>('plans', 'procurePlan', {
    'planProductName': planProductName,
    'planName': planName,
  });

  /// Cancels a subscription owned by the user.
  ///
  /// - Throws [ProcurementCancellationException] if the cancellation fails,
  /// e.g. if the subscription still has active resources or is already cancelled.
  /// - Throws [NoSubscriptionException] if the user has no subscription.
  _ida.Future<void> cancelPlan({required _isc.UuidValue subscriptionId}) =>
      caller.callServerEndpoint<void>('plans', 'cancelPlan', {
        'subscriptionId': subscriptionId,
      });

  /// Fetches the names of the subscription plans owned by the user.
  _ida.Future<List<String>> listProcuredPlanNames() => caller
      .callServerEndpoint<List<String>>('plans', 'listProcuredPlanNames', {});

  /// Lists the subscriptions owned by the user.
  _ida.Future<List<_i2pv1k63.SubscriptionInfo>> listSubscriptions() =>
      caller.callServerEndpoint<List<_i2pv1k63.SubscriptionInfo>>(
        'plans',
        'listSubscriptions',
        {},
      );

  /// Gets the subscription info for the subscription of the given project id.
  ///
  /// Throws [NotFoundException] if the project's subscription is not found.
  _ida.Future<_i2pv1k63.SubscriptionInfo> getSubscriptionInfoOfProject({
    required String cloudProjectId,
  }) => caller.callServerEndpoint<_i2pv1k63.SubscriptionInfo>(
    'plans',
    'getSubscriptionInfoOfProject',
    {'cloudProjectId': cloudProjectId},
  );

  /// Gets a subscription info of a subscription owned by the user.
  ///
  /// Throws [NotFoundException] if the subscription is not found.
  _ida.Future<_i2pv1k63.SubscriptionInfo> getSubscriptionInfo({
    required _isc.UuidValue subscriptionId,
  }) => caller.callServerEndpoint<_i2pv1k63.SubscriptionInfo>(
    'plans',
    'getSubscriptionInfo',
    {'subscriptionId': subscriptionId},
  );

  /// Checks if a plan is available for procurement.
  ///
  /// - Throws [NotFoundException] if the product is not found.
  /// - Throws [ProcurementDeniedException] if the product is not available.
  _ida.Future<void> checkPlanAvailability({
    String? planProductName,
    @Deprecated('Use planProductName instead') String? planName,
  }) => caller.callServerEndpoint<void>('plans', 'checkPlanAvailability', {
    'planProductName': planProductName,
    'planName': planName,
  });

  /// Lists the public plans (`starter`, `growth`) for the private customer
  /// billing type. Each [PlanInfo] carries its bundled
  /// [PlanInfo.projectProduct].
  _ida.Future<List<_ibsngdn1.PlanInfo>> listPlans() => caller
      .callServerEndpoint<List<_ibsngdn1.PlanInfo>>('plans', 'listPlans', {});

  /// Gets the plan info for the named plan product.
  ///
  /// For plans that depend on the customer billing type (private / business),
  /// the plan product matching the user's customer billing type is resolved,
  /// with [BillingCustomerType.private] used when no customer billing type
  /// is set.
  ///
  /// Throws [NotFoundException] if the plan is not found.
  _ida.Future<_ibsngdn1.PlanInfo> getPlanInfo({
    required String planProductName,
  }) => caller.callServerEndpoint<_ibsngdn1.PlanInfo>('plans', 'getPlanInfo', {
    'planProductName': planProductName,
  });

  /// Fetches the names of all the subscription plans.
  _ida.Future<List<String>> listPlanNames() =>
      caller.callServerEndpoint<List<String>>('plans', 'listPlanNames', {});
}

/// Endpoint for managing projects.
/// {@category Endpoint}
class EndpointProjects extends _isc.EndpointRef {
  EndpointProjects(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'projects';

  /// Validates a project ID by checking format rules and database existence.
  /// Throws [InvalidValueException] for format violations.
  /// Throws [DuplicateEntryException] if the project ID already exists.
  /// Returns true if the project ID is valid and available.
  _ida.Future<bool> validateProjectId(String projectId) =>
      caller.callServerEndpoint<bool>('projects', 'validateProjectId', {
        'projectId': projectId,
      });

  /// Creates a new project with basic setup.
  ///
  /// Currently also creates its capsule.
  ///
  /// [cloudProjectId] is the id of the new project, it must be valid and globally unique.
  ///
  /// [underSubscriptionId] optionally specifies a subscription to procure the
  /// project under, or the user's first found subscription will be used.
  /// In future this parameter will be mandatory.
  ///
  /// [projectProductName] optionally specify the project product name to use,
  /// defaults to the first available bundled product for the subscription plan.
  ///
  /// Throws [ProcurementDeniedException] if the project procurement fails or the subscription is invalid.
  /// Throws [InvalidValueException] if the project name is invalid.
  /// Throws [DuplicateEntryException] if the project id already exists.
  /// Throws [NoSubscriptionException] if no subscription was provided and the user has no subscription.
  _ida.Future<_iavjecni.Project> createProject({
    required String cloudProjectId,
    _isc.UuidValue? underSubscriptionId,
    String? projectProductName,
  }) => caller
      .callServerEndpoint<_iavjecni.Project>('projects', 'createProject', {
        'cloudProjectId': cloudProjectId,
        'underSubscriptionId': underSubscriptionId,
        'projectProductName': projectProductName,
      });

  /// Creates a new complete project set up according to a project profile.
  /// This includes a plan subscription, project, capsule, and database (if specified).
  ///
  /// [cloudProjectId] is the id of the new project, it must be valid and globally unique.
  /// [profile] specifies the project profile to use. It must specify a plan type.
  /// The other fields are optional, and defaults will be used for any unspecified fields.
  ///
  /// Returns the id of the created subscription.
  ///
  /// Throws [InvalidValueException] if the profile does not specify a plan type.
  /// Throws [InvalidValueException] if the project id is invalid.
  /// Throws [DuplicateEntryException] if the project id already exists.
  /// Throws [ProcurementDeniedException] if a procurement fails.
  _ida.Future<_isc.UuidValue> createPlanProject({
    required String cloudProjectId,
    required _iag8nc5u.ProjectProfileUpdate profile,
  }) => caller.callServerEndpoint<_isc.UuidValue>(
    'projects',
    'createPlanProject',
    {'cloudProjectId': cloudProjectId, 'profile': profile},
  );

  /// Fetches the specified project.
  /// Its user roles are included in the response.
  @Deprecated('Use fetchProjectInfo instead')
  _ida.Future<_iavjecni.Project> fetchProject({
    required String cloudProjectId,
  }) => caller.callServerEndpoint<_iavjecni.Project>(
    'projects',
    'fetchProject',
    {'cloudProjectId': cloudProjectId},
  );

  /// Fetches the specified project.
  /// Its user roles are included in the response.
  _ida.Future<_ixukenxa.ProjectInfo> fetchProjectInfo({
    required String cloudProjectId,
    bool? includeLatestDeployAttemptTime,
  }) => caller.callServerEndpoint<_ixukenxa.ProjectInfo>(
    'projects',
    'fetchProjectInfo',
    {
      'cloudProjectId': cloudProjectId,
      'includeLatestDeployAttemptTime': includeLatestDeployAttemptTime,
    },
  );

  /// Fetches the list of projects the current user has access to.
  @Deprecated('Use listProjectsInfo instead')
  _ida.Future<List<_iavjecni.Project>> listProjects() =>
      caller.callServerEndpoint<List<_iavjecni.Project>>(
        'projects',
        'listProjects',
        {},
      );

  /// Fetches the list of projects the current user has access to.
  /// If requested, the result includes the latest deploy attempt time
  /// (or null if undeployed).
  _ida.Future<List<_ixukenxa.ProjectInfo>> listProjectsInfo({
    bool? includeLatestDeployAttemptTime,
  }) => caller.callServerEndpoint<List<_ixukenxa.ProjectInfo>>(
    'projects',
    'listProjectsInfo',
    {'includeLatestDeployAttemptTime': includeLatestDeployAttemptTime},
  );

  /// Archives a project and its capsule and permanently deletes its infrastructure.
  /// The id of the project is not available for reuse but the same string can
  /// be assigned as the "name" of another capsule.
  ///
  /// The project's subscription is terminated immediately if it has no more resource products.
  ///
  /// If the project does not exist or is archived, [NotFoundException] is thrown.
  _ida.Future<_iavjecni.Project> deleteProject({
    required String cloudProjectId,
  }) => caller.callServerEndpoint<_iavjecni.Project>(
    'projects',
    'deleteProject',
    {'cloudProjectId': cloudProjectId},
  );

  /// Applies a project profile change together with compute scaling and optional
  /// database sizing in one call.
  ///
  /// Intended to replace separate calls to [updateProjectProfile], compute
  /// `updateCompute`, and database `updateDatabaseSize` when all are updated
  /// together.
  ///
  /// [cloudProjectId] identifies the project for authorization and matches the
  /// capsule identifier used for compute and database operations.
  ///
  /// When [resources.databaseSize] is null, database sizing is not changed.
  ///
  /// Throws [NotFoundException] if the project is not found.
  /// Throws [UnauthorizedException] if the user is not the owner of the
  /// project's subscription.
  /// Throws [InvalidValueException] if the requested configuration violates the product constraints.
  /// Throws [PlanChangeDeniedException] if the plan change would strand a feature
  /// that is currently in use (e.g. removing backup support while backups exist).
  /// Throws [ProcurementDeniedException] if the requested new products are not available.
  /// Throws [ConcurrentSubscriptionUpdateException] if another update is in progress.
  _ida.Future<void> updateProjectProfile({
    required String cloudProjectId,
    required _iag8nc5u.ProjectProfileUpdate resources,
  }) => caller.callServerEndpoint<void>('projects', 'updateProjectProfile', {
    'cloudProjectId': cloudProjectId,
    'resources': resources,
  });

  _ida.Future<_i93ixjag.ProjectConfig> fetchProjectConfig({
    required String cloudProjectId,
  }) => caller.callServerEndpoint<_i93ixjag.ProjectConfig>(
    'projects',
    'fetchProjectConfig',
    {'cloudProjectId': cloudProjectId},
  );

  /// Invites a user to a project by assigning the specified project roles.
  /// If the user does not exist, a user invitation email is sent.
  ///
  /// Throws [NotFoundException] if the project or any of the roles
  /// do not exist.
  _ida.Future<void> inviteUser({
    required String cloudProjectId,
    required String email,
    required List<String> assignRoleNames,
  }) => caller.callServerEndpoint<void>('projects', 'inviteUser', {
    'cloudProjectId': cloudProjectId,
    'email': email,
    'assignRoleNames': assignRoleNames,
  });

  /// Resends the invitation email to a user that has been invited to the
  /// project but has not accepted the invitation yet.
  ///
  /// Throws [NotFoundException] if the project or the user does not exist.
  /// Throws [InvalidValueException] if the user has already accepted
  /// the invitation.
  _ida.Future<void> resendUserInvitation({
    required String cloudProjectId,
    required String email,
  }) => caller.callServerEndpoint<void>('projects', 'resendUserInvitation', {
    'cloudProjectId': cloudProjectId,
    'email': email,
  });

  /// Revokes a user from a project by unassigning the specified project roles.
  /// If any of the roles do not exist or are not previously assigned to the
  /// user, they are simply ignored.
  /// If [unassignAllRoles] is true, all roles on the project are unassigned
  /// from the user.
  ///
  /// Returns the list of role names that were actually unassigned.
  /// Throws [NotFoundException] if the project does not exist.
  _ida.Future<List<String>> revokeUser({
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
class EndpointRoles extends _isc.EndpointRef {
  EndpointRoles(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'roles';

  /// Fetches the user roles for a project.
  _ida.Future<List<_iavafiww.Role>> fetchRolesForProject({
    required String cloudProjectId,
  }) => caller.callServerEndpoint<List<_iavafiww.Role>>(
    'roles',
    'fetchRolesForProject',
    {'cloudProjectId': cloudProjectId},
  );
}

/// {@category Endpoint}
class EndpointSecrets extends _isc.EndpointRef {
  EndpointSecrets(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'secrets';

  /// Creates custom (user-defined) secrets for a cloud capsule.
  ///
  /// Secret value changes are applied at the next successful deployment.
  ///
  /// Throws [NotFoundException] if the capsule is not found.
  /// Throws [InvalidValueException] if secret names are invalid.
  _ida.Future<void> create({
    required Map<String, String> secrets,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<void>('secrets', 'create', {
    'secrets': secrets,
    'cloudCapsuleId': cloudCapsuleId,
  });

  /// Upserts custom (user-defined) secrets for a cloud capsule.
  ///
  /// Creates new secrets or updates existing ones. Unlike [create], this method
  /// allows updating existing secret keys without throwing an exception.
  ///
  /// Secret value changes are applied at the next successful deployment.
  ///
  /// Throws [NotFoundException] if the capsule is not found.
  /// Throws [InvalidValueException] if secret names are invalid.
  _ida.Future<void> upsert({
    required Map<String, String> secrets,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<void>('secrets', 'upsert', {
    'secrets': secrets,
    'cloudCapsuleId': cloudCapsuleId,
  });

  /// Upserts a build secret for a cloud capsule.
  /// Build secrets are used during the build process.
  /// They are not accessible at runtime.
  ///
  /// Secret value changes are applied at the next deployment.
  ///
  /// Throws [NotFoundException] if the capsule is not found.
  /// Throws [InvalidValueException] if secret names are invalid or the secret
  /// value exceeds the build-secret encryption size limit.
  _ida.Future<void> upsertBuildSecret({
    required String secretKey,
    required String secretValue,
    required _ifyrekdh.BuildSecretType buildSecretType,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<void>('secrets', 'upsertBuildSecret', {
    'secretKey': secretKey,
    'secretValue': secretValue,
    'buildSecretType': buildSecretType,
    'cloudCapsuleId': cloudCapsuleId,
  });

  /// Deletes a custom (user-defined) secret from a cloud capsule.
  ///
  /// Secret value changes are applied at the next successful deployment.
  ///
  /// Throws [NotFoundException] if the capsule or the secret is not found.
  _ida.Future<void> delete({
    required String key,
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<void>('secrets', 'delete', {
    'key': key,
    'cloudCapsuleId': cloudCapsuleId,
  });

  /// Deletes a build secret from a cloud capsule.
  ///
  /// Secret value changes are applied at the next deployment.
  ///
  /// Throws [NotFoundException] if the capsule or the secret is not found.
  _ida.Future<void> deleteBuild({
    required String cloudCapsuleId,
    required String key,
  }) => caller.callServerEndpoint<void>('secrets', 'deleteBuild', {
    'cloudCapsuleId': cloudCapsuleId,
    'key': key,
  });

  /// Lists custom (user-defined) secret keys for a cloud capsule.
  ///
  /// Returns only the keys of custom secrets (no values).
  ///
  /// The returned value reflects the secrets pending for the next deployment,
  /// which may differ from the currently active secrets.
  ///
  /// Throws [NotFoundException] if the capsule is not found.
  _ida.Future<List<String>> list(String cloudCapsuleId) =>
      caller.callServerEndpoint<List<String>>('secrets', 'list', {
        'cloudCapsuleId': cloudCapsuleId,
      });

  /// Lists platform-managed secret keys for a cloud capsule.
  ///
  /// Returns only the keys of managed secrets (no values). Unlike [list],
  /// this method filters to platform-managed secrets only, excluding
  /// user-created custom secrets.
  ///
  /// The returned value reflects the secrets pending for the next deployment,
  /// which may differ from the currently active secrets.
  ///
  /// Throws [NotFoundException] if the capsule is not found.
  _ida.Future<List<String>> listManaged(String cloudCapsuleId) =>
      caller.callServerEndpoint<List<String>>('secrets', 'listManaged', {
        'cloudCapsuleId': cloudCapsuleId,
      });

  /// Lists build secrets keys for a cloud capsule.
  ///
  /// Returns only the keys of build secrets (no values).
  ///
  /// The returned value reflects the secrets pending for the next deployment,
  /// which may differ from the currently active secrets.
  ///
  /// Throws [NotFoundException] if the capsule is not found.
  _ida.Future<List<String>> listBuild(String cloudCapsuleId) =>
      caller.callServerEndpoint<List<String>>('secrets', 'listBuild', {
        'cloudCapsuleId': cloudCapsuleId,
      });
}

/// Endpoint for accessing capsule deployment status.
/// {@category Endpoint}
class EndpointStatus extends _isc.EndpointRef {
  EndpointStatus(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'status';

  /// Gets the live runtime status of the specified capsule.
  /// An unhealthy capsule is still a successful result — the status is data.
  _ida.Future<_i0c2pd3m.CapsuleStatus> getCapsuleStatus({
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_i0c2pd3m.CapsuleStatus>(
    'status',
    'getCapsuleStatus',
    {'cloudCapsuleId': cloudCapsuleId},
  );

  /// Gets the live runtime status of the specified capsule, enriched with
  /// summaries of the deploy attempts behind the serving and incoming
  /// revisions.
  /// An unhealthy capsule is still a successful result — the status is data.
  _ida.Future<_iw0bb95d.CapsuleRuntimeStatus> getCapsuleRuntimeStatus({
    required String cloudCapsuleId,
  }) => caller.callServerEndpoint<_iw0bb95d.CapsuleRuntimeStatus>(
    'status',
    'getCapsuleRuntimeStatus',
    {'cloudCapsuleId': cloudCapsuleId},
  );

  /// Tails the live runtime status of the specified capsule.
  /// Emits the current status immediately, then an update whenever it
  /// changes. Continues until the client unsubscribes.
  _ida.Stream<_i0c2pd3m.CapsuleStatus> tailCapsuleStatus({
    required String cloudCapsuleId,
  }) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_i0c2pd3m.CapsuleStatus>,
        _i0c2pd3m.CapsuleStatus
      >('status', 'tailCapsuleStatus', {'cloudCapsuleId': cloudCapsuleId}, {});

  /// Gets deploy attempts of the specified capsule.
  /// Gets the recent-most attempts, up till [limit] if specified.
  _ida.Future<List<_i51mvi6s.DeployAttempt>> getDeployAttempts({
    required String cloudCapsuleId,
    int? limit,
  }) => caller.callServerEndpoint<List<_i51mvi6s.DeployAttempt>>(
    'status',
    'getDeployAttempts',
    {'cloudCapsuleId': cloudCapsuleId, 'limit': limit},
  );

  /// Gets the specified deploy attempt status of the a capsule.
  _ida.Future<List<_iy77socp.DeployAttemptStage>> getDeployAttemptStatus({
    required String cloudCapsuleId,
    required _isc.UuidValue attemptId,
  }) => caller.callServerEndpoint<List<_iy77socp.DeployAttemptStage>>(
    'status',
    'getDeployAttemptStatus',
    {'cloudCapsuleId': cloudCapsuleId, 'attemptId': attemptId},
  );

  /// Gets the deploy attempt id for the specified attempt number of a capsule.
  /// This number enumerate the capsule's deploy attempts as latest first, starting from 0.
  _ida.Future<_isc.UuidValue> getDeployAttemptId({
    required String cloudCapsuleId,
    required int attemptNumber,
  }) => caller.callServerEndpoint<_isc.UuidValue>(
    'status',
    'getDeployAttemptId',
    {'cloudCapsuleId': cloudCapsuleId, 'attemptNumber': attemptNumber},
  );

  /// Tails the status updates for a deploy attempt.
  /// Continues until the client unsubscribes or the status if final.
  _ida.Stream<_iy77socp.DeployAttemptStage> tailDeployAttemptStatus({
    required String cloudCapsuleId,
    required _isc.UuidValue attemptId,
  }) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_iy77socp.DeployAttemptStage>,
        _iy77socp.DeployAttemptStage
      >('status', 'tailDeployAttemptStatus', {
        'cloudCapsuleId': cloudCapsuleId,
        'attemptId': attemptId,
      }, {});
}

/// Endpoint for managing users.
/// {@category Endpoint}
class EndpointUsers extends _isc.EndpointRef {
  EndpointUsers(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'users';

  /// Reads the current user's information.
  _ida.Future<_ibu0ogga.User> readUser() =>
      caller.callServerEndpoint<_ibu0ogga.User>('users', 'readUser', {});

  /// Updates current user's [name].
  _ida.Future<_ibu0ogga.User> updateUserName(String name) =>
      caller.callServerEndpoint<_ibu0ogga.User>('users', 'updateUserName', {
        'name': name,
      });

  /// Reads all users that have a role in the specified project.
  _ida.Future<List<_ibu0ogga.User>> listUsersInProject({
    required String cloudProjectId,
  }) => caller.callServerEndpoint<List<_ibu0ogga.User>>(
    'users',
    'listUsersInProject',
    {'cloudProjectId': cloudProjectId},
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(_isc.MethodCallContext, Object, StackTrace)? onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    adminMigration = EndpointAdminMigration(this);
    adminProcurement = EndpointAdminProcurement(this);
    adminProjects = EndpointAdminProjects(this);
    adminSecrets = EndpointAdminSecrets(this);
    adminStorageIdentity = EndpointAdminStorageIdentity(this);
    adminUpdatePlan = EndpointAdminUpdatePlan(this);
    adminUsers = EndpointAdminUsers(this);
    auth = EndpointAuth(this);
    authWithAuth = EndpointAuthWithAuth(this);
    emailIdp = EndpointEmailIdp(this);
    gitHubIdp = EndpointGitHubIdp(this);
    googleIdp = EndpointGoogleIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    billing = EndpointBilling(this);
    bucket = EndpointBucket(this);
    bucketObjects = EndpointBucketObjects(this);
    capsules = EndpointCapsules(this);
    compute = EndpointCompute(this);
    customDomainName = EndpointCustomDomainName(this);
    database = EndpointDatabase(this);
    infraResources = EndpointInfraResources(this);
    deploy = EndpointDeploy(this);
    environmentVariables = EndpointEnvironmentVariables(this);
    insights = EndpointInsights(this);
    logs = EndpointLogs(this);
    metrics = EndpointMetrics(this);
    platform = EndpointPlatform(this);
    plans = EndpointPlans(this);
    projects = EndpointProjects(this);
    roles = EndpointRoles(this);
    secrets = EndpointSecrets(this);
    status = EndpointStatus(this);
    users = EndpointUsers(this);
    modules = Modules(this);
  }

  late final EndpointAdminMigration adminMigration;

  late final EndpointAdminProcurement adminProcurement;

  late final EndpointAdminProjects adminProjects;

  late final EndpointAdminSecrets adminSecrets;

  late final EndpointAdminStorageIdentity adminStorageIdentity;

  late final EndpointAdminUpdatePlan adminUpdatePlan;

  late final EndpointAdminUsers adminUsers;

  late final EndpointAuth auth;

  late final EndpointAuthWithAuth authWithAuth;

  late final EndpointEmailIdp emailIdp;

  late final EndpointGitHubIdp gitHubIdp;

  late final EndpointGoogleIdp googleIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointBilling billing;

  late final EndpointBucket bucket;

  late final EndpointBucketObjects bucketObjects;

  late final EndpointCapsules capsules;

  late final EndpointCompute compute;

  late final EndpointCustomDomainName customDomainName;

  late final EndpointDatabase database;

  late final EndpointInfraResources infraResources;

  late final EndpointDeploy deploy;

  late final EndpointEnvironmentVariables environmentVariables;

  late final EndpointInsights insights;

  late final EndpointLogs logs;

  late final EndpointMetrics metrics;

  late final EndpointPlatform platform;

  late final EndpointPlans plans;

  late final EndpointProjects projects;

  late final EndpointRoles roles;

  late final EndpointSecrets secrets;

  late final EndpointStatus status;

  late final EndpointUsers users;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'adminMigration': adminMigration,
    'adminProcurement': adminProcurement,
    'adminProjects': adminProjects,
    'adminSecrets': adminSecrets,
    'adminStorageIdentity': adminStorageIdentity,
    'adminUpdatePlan': adminUpdatePlan,
    'adminUsers': adminUsers,
    'auth': auth,
    'authWithAuth': authWithAuth,
    'emailIdp': emailIdp,
    'gitHubIdp': gitHubIdp,
    'googleIdp': googleIdp,
    'jwtRefresh': jwtRefresh,
    'billing': billing,
    'bucket': bucket,
    'bucketObjects': bucketObjects,
    'capsules': capsules,
    'compute': compute,
    'customDomainName': customDomainName,
    'database': database,
    'infraResources': infraResources,
    'deploy': deploy,
    'environmentVariables': environmentVariables,
    'insights': insights,
    'logs': logs,
    'metrics': metrics,
    'platform': platform,
    'plans': plans,
    'projects': projects,
    'roles': roles,
    'secrets': secrets,
    'status': status,
    'users': users,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}

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
import 'domains/users/models/user_account_status.dart' as _i2;
import 'domains/billing/models/billing_info.dart' as _i3;
import 'domains/billing/models/owner.dart' as _i4;
import 'domains/billing/models/payment_method.dart' as _i5;
import 'domains/billing/models/payment_method_card.dart' as _i6;
import 'domains/billing/models/payment_setup_intent.dart' as _i7;
import 'domains/billing/models/subscription.dart' as _i8;
import 'domains/capsules/models/capsule.dart' as _i9;
import 'domains/capsules/models/capsule_resource_config.dart' as _i10;
import 'domains/logs/models/log_record.dart' as _i11;
import 'domains/status/models/deploy_attempt.dart' as _i12;
import 'domains/status/models/deploy_attempt_stage.dart' as _i13;
import 'domains/status/models/deploy_progress_status.dart' as _i14;
import 'domains/status/models/deploy_stage_type.dart' as _i15;
import 'domains/users/models/account_authorization.dart' as _i16;
import 'domains/users/models/user.dart' as _i17;
import 'domains/billing/models/billing_customer_type.dart' as _i18;
import 'features/auth/exceptions/user_account_registration_denied_exception.dart'
    as _i19;
import 'features/auth/models/accepted_terms.dart' as _i20;
import 'features/auth/models/accepted_terms_dto.dart' as _i21;
import 'features/auth/models/required_terms.dart' as _i22;
import 'features/auth/models/terms.dart' as _i23;
import 'features/custom_domain_name/exceptions/dns_verification_failed_exception.dart'
    as _i24;
import 'features/custom_domain_name/models/custom_domain_name.dart' as _i25;
import 'features/custom_domain_name/models/custom_domain_name_list.dart'
    as _i26;
import 'features/custom_domain_name/models/dns_record_type.dart' as _i27;
import 'features/custom_domain_name/models/domain_name_status.dart' as _i28;
import 'features/custom_domain_name/models/domain_name_target.dart' as _i29;
import 'features/custom_domain_name/models/new_domain_names_event.dart' as _i30;
import 'features/custom_domain_name/models/view_models/custom_domain_name_with_default_domains.dart'
    as _i31;
import 'features/database/models/database_connection.dart' as _i32;
import 'features/database/models/database_provider.dart' as _i33;
import 'shared/services/pubsub/registry/pubsub_entry.dart' as _i34;
import 'features/environment_variables/models/environment_variable.dart'
    as _i35;
import 'features/project/models/address.dart' as _i36;
import 'features/project/models/project.dart' as _i37;
import 'features/project/models/project_config.dart' as _i38;
import 'features/project/models/project_delete_call_event.dart' as _i39;
import 'features/project/models/role.dart' as _i40;
import 'features/project/models/user_role_membership.dart' as _i41;
import 'features/secret_manager/models/secret_resource.dart' as _i42;
import 'features/secret_manager/models/secret_type.dart' as _i43;
import 'shared/exceptions/models/duplicate_entry_exception.dart' as _i44;
import 'shared/exceptions/models/invalid_value_exception.dart' as _i45;
import 'shared/exceptions/models/not_found_exception.dart' as _i46;
import 'shared/exceptions/models/resource_denied_exception.dart' as _i47;
import 'shared/exceptions/models/unauthenticated_exception.dart' as _i48;
import 'shared/exceptions/models/unauthorized_exception.dart' as _i49;
import 'shared/models/serverpod_region.dart' as _i50;
import 'features/database/models/database_resource.dart' as _i51;
import 'package:ground_control_client/src/protocol/features/project/models/project.dart'
    as _i52;
import 'package:ground_control_client/src/protocol/domains/users/models/user.dart'
    as _i53;
import 'package:ground_control_client/src/protocol/features/auth/models/required_terms.dart'
    as _i54;
import 'package:ground_control_client/src/protocol/features/auth/models/accepted_terms_dto.dart'
    as _i55;
import 'package:ground_control_client/src/protocol/domains/billing/models/payment_method.dart'
    as _i56;
import 'package:ground_control_client/src/protocol/features/environment_variables/models/environment_variable.dart'
    as _i57;
import 'package:ground_control_client/src/protocol/features/project/models/role.dart'
    as _i58;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i59;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _i60;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i61;
import 'package:serverpod_auth_migration_client/serverpod_auth_migration_client.dart'
    as _i62;
import 'package:serverpod_auth_bridge_client/serverpod_auth_bridge_client.dart'
    as _i63;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i64;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i65;
export 'domains/billing/models/billing_customer_type.dart';
export 'domains/billing/models/billing_info.dart';
export 'domains/billing/models/owner.dart';
export 'domains/billing/models/payment_method.dart';
export 'domains/billing/models/payment_method_card.dart';
export 'domains/billing/models/payment_setup_intent.dart';
export 'domains/billing/models/subscription.dart';
export 'domains/capsules/models/capsule.dart';
export 'domains/capsules/models/capsule_resource_config.dart';
export 'domains/logs/models/log_record.dart';
export 'domains/status/models/deploy_attempt.dart';
export 'domains/status/models/deploy_attempt_stage.dart';
export 'domains/status/models/deploy_progress_status.dart';
export 'domains/status/models/deploy_stage_type.dart';
export 'domains/users/models/account_authorization.dart';
export 'domains/users/models/user.dart';
export 'domains/users/models/user_account_status.dart';
export 'features/auth/exceptions/user_account_registration_denied_exception.dart';
export 'features/auth/models/accepted_terms.dart';
export 'features/auth/models/accepted_terms_dto.dart';
export 'features/auth/models/required_terms.dart';
export 'features/auth/models/terms.dart';
export 'features/custom_domain_name/exceptions/dns_verification_failed_exception.dart';
export 'features/custom_domain_name/models/custom_domain_name.dart';
export 'features/custom_domain_name/models/custom_domain_name_list.dart';
export 'features/custom_domain_name/models/dns_record_type.dart';
export 'features/custom_domain_name/models/domain_name_status.dart';
export 'features/custom_domain_name/models/domain_name_target.dart';
export 'features/custom_domain_name/models/new_domain_names_event.dart';
export 'features/custom_domain_name/models/view_models/custom_domain_name_with_default_domains.dart';
export 'features/database/models/database_connection.dart';
export 'features/database/models/database_provider.dart';
export 'features/database/models/database_resource.dart';
export 'features/environment_variables/models/environment_variable.dart';
export 'features/project/models/address.dart';
export 'features/project/models/project.dart';
export 'features/project/models/project_config.dart';
export 'features/project/models/project_delete_call_event.dart';
export 'features/project/models/role.dart';
export 'features/project/models/user_role_membership.dart';
export 'features/secret_manager/models/secret_resource.dart';
export 'features/secret_manager/models/secret_type.dart';
export 'shared/exceptions/models/duplicate_entry_exception.dart';
export 'shared/exceptions/models/invalid_value_exception.dart';
export 'shared/exceptions/models/not_found_exception.dart';
export 'shared/exceptions/models/resource_denied_exception.dart';
export 'shared/exceptions/models/unauthenticated_exception.dart';
export 'shared/exceptions/models/unauthorized_exception.dart';
export 'shared/models/serverpod_region.dart';
export 'shared/services/pubsub/registry/pubsub_entry.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.UserAccountStatus) {
      return _i2.UserAccountStatus.fromJson(data) as T;
    }
    if (t == _i3.BillingInfo) {
      return _i3.BillingInfo.fromJson(data) as T;
    }
    if (t == _i4.Owner) {
      return _i4.Owner.fromJson(data) as T;
    }
    if (t == _i5.PaymentMethod) {
      return _i5.PaymentMethod.fromJson(data) as T;
    }
    if (t == _i6.PaymentMethodCard) {
      return _i6.PaymentMethodCard.fromJson(data) as T;
    }
    if (t == _i7.PaymentSetupIntent) {
      return _i7.PaymentSetupIntent.fromJson(data) as T;
    }
    if (t == _i8.Subscription) {
      return _i8.Subscription.fromJson(data) as T;
    }
    if (t == _i9.Capsule) {
      return _i9.Capsule.fromJson(data) as T;
    }
    if (t == _i10.CapsuleResource) {
      return _i10.CapsuleResource.fromJson(data) as T;
    }
    if (t == _i11.LogRecord) {
      return _i11.LogRecord.fromJson(data) as T;
    }
    if (t == _i12.DeployAttempt) {
      return _i12.DeployAttempt.fromJson(data) as T;
    }
    if (t == _i13.DeployAttemptStage) {
      return _i13.DeployAttemptStage.fromJson(data) as T;
    }
    if (t == _i14.DeployProgressStatus) {
      return _i14.DeployProgressStatus.fromJson(data) as T;
    }
    if (t == _i15.DeployStageType) {
      return _i15.DeployStageType.fromJson(data) as T;
    }
    if (t == _i16.AccountAuthorization) {
      return _i16.AccountAuthorization.fromJson(data) as T;
    }
    if (t == _i17.User) {
      return _i17.User.fromJson(data) as T;
    }
    if (t == _i18.BillingCustomerType) {
      return _i18.BillingCustomerType.fromJson(data) as T;
    }
    if (t == _i19.UserAccountRegistrationDeniedException) {
      return _i19.UserAccountRegistrationDeniedException.fromJson(data) as T;
    }
    if (t == _i20.AcceptedTerms) {
      return _i20.AcceptedTerms.fromJson(data) as T;
    }
    if (t == _i21.AcceptedTermsDTO) {
      return _i21.AcceptedTermsDTO.fromJson(data) as T;
    }
    if (t == _i22.RequiredTerms) {
      return _i22.RequiredTerms.fromJson(data) as T;
    }
    if (t == _i23.Terms) {
      return _i23.Terms.fromJson(data) as T;
    }
    if (t == _i24.DNSVerificationFailedException) {
      return _i24.DNSVerificationFailedException.fromJson(data) as T;
    }
    if (t == _i25.CustomDomainName) {
      return _i25.CustomDomainName.fromJson(data) as T;
    }
    if (t == _i26.CustomDomainNameList) {
      return _i26.CustomDomainNameList.fromJson(data) as T;
    }
    if (t == _i27.DnsRecordType) {
      return _i27.DnsRecordType.fromJson(data) as T;
    }
    if (t == _i28.DomainNameStatus) {
      return _i28.DomainNameStatus.fromJson(data) as T;
    }
    if (t == _i29.DomainNameTarget) {
      return _i29.DomainNameTarget.fromJson(data) as T;
    }
    if (t == _i30.NewCustomDomainNamesEvent) {
      return _i30.NewCustomDomainNamesEvent.fromJson(data) as T;
    }
    if (t == _i31.CustomDomainNameWithDefaultDomains) {
      return _i31.CustomDomainNameWithDefaultDomains.fromJson(data) as T;
    }
    if (t == _i32.DatabaseConnection) {
      return _i32.DatabaseConnection.fromJson(data) as T;
    }
    if (t == _i33.DatabaseProvider) {
      return _i33.DatabaseProvider.fromJson(data) as T;
    }
    if (t == _i34.PubsubEntry) {
      return _i34.PubsubEntry.fromJson(data) as T;
    }
    if (t == _i35.EnvironmentVariable) {
      return _i35.EnvironmentVariable.fromJson(data) as T;
    }
    if (t == _i36.Address) {
      return _i36.Address.fromJson(data) as T;
    }
    if (t == _i37.Project) {
      return _i37.Project.fromJson(data) as T;
    }
    if (t == _i38.ProjectConfig) {
      return _i38.ProjectConfig.fromJson(data) as T;
    }
    if (t == _i39.ProjectDeleteCallEvent) {
      return _i39.ProjectDeleteCallEvent.fromJson(data) as T;
    }
    if (t == _i40.Role) {
      return _i40.Role.fromJson(data) as T;
    }
    if (t == _i41.UserRoleMembership) {
      return _i41.UserRoleMembership.fromJson(data) as T;
    }
    if (t == _i42.SecretResource) {
      return _i42.SecretResource.fromJson(data) as T;
    }
    if (t == _i43.SecretType) {
      return _i43.SecretType.fromJson(data) as T;
    }
    if (t == _i44.DuplicateEntryException) {
      return _i44.DuplicateEntryException.fromJson(data) as T;
    }
    if (t == _i45.InvalidValueException) {
      return _i45.InvalidValueException.fromJson(data) as T;
    }
    if (t == _i46.NotFoundException) {
      return _i46.NotFoundException.fromJson(data) as T;
    }
    if (t == _i47.ResourceDeniedException) {
      return _i47.ResourceDeniedException.fromJson(data) as T;
    }
    if (t == _i48.UnauthenticatedException) {
      return _i48.UnauthenticatedException.fromJson(data) as T;
    }
    if (t == _i49.UnauthorizedException) {
      return _i49.UnauthorizedException.fromJson(data) as T;
    }
    if (t == _i50.ServerpodRegion) {
      return _i50.ServerpodRegion.fromJson(data) as T;
    }
    if (t == _i51.DatabaseResource) {
      return _i51.DatabaseResource.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.UserAccountStatus?>()) {
      return (data != null ? _i2.UserAccountStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.BillingInfo?>()) {
      return (data != null ? _i3.BillingInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Owner?>()) {
      return (data != null ? _i4.Owner.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.PaymentMethod?>()) {
      return (data != null ? _i5.PaymentMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.PaymentMethodCard?>()) {
      return (data != null ? _i6.PaymentMethodCard.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.PaymentSetupIntent?>()) {
      return (data != null ? _i7.PaymentSetupIntent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Subscription?>()) {
      return (data != null ? _i8.Subscription.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Capsule?>()) {
      return (data != null ? _i9.Capsule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.CapsuleResource?>()) {
      return (data != null ? _i10.CapsuleResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.LogRecord?>()) {
      return (data != null ? _i11.LogRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.DeployAttempt?>()) {
      return (data != null ? _i12.DeployAttempt.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.DeployAttemptStage?>()) {
      return (data != null ? _i13.DeployAttemptStage.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.DeployProgressStatus?>()) {
      return (data != null ? _i14.DeployProgressStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.DeployStageType?>()) {
      return (data != null ? _i15.DeployStageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.AccountAuthorization?>()) {
      return (data != null ? _i16.AccountAuthorization.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.User?>()) {
      return (data != null ? _i17.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.BillingCustomerType?>()) {
      return (data != null ? _i18.BillingCustomerType.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.UserAccountRegistrationDeniedException?>()) {
      return (data != null
          ? _i19.UserAccountRegistrationDeniedException.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i20.AcceptedTerms?>()) {
      return (data != null ? _i20.AcceptedTerms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.AcceptedTermsDTO?>()) {
      return (data != null ? _i21.AcceptedTermsDTO.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.RequiredTerms?>()) {
      return (data != null ? _i22.RequiredTerms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.Terms?>()) {
      return (data != null ? _i23.Terms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.DNSVerificationFailedException?>()) {
      return (data != null
          ? _i24.DNSVerificationFailedException.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i25.CustomDomainName?>()) {
      return (data != null ? _i25.CustomDomainName.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.CustomDomainNameList?>()) {
      return (data != null ? _i26.CustomDomainNameList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i27.DnsRecordType?>()) {
      return (data != null ? _i27.DnsRecordType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.DomainNameStatus?>()) {
      return (data != null ? _i28.DomainNameStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.DomainNameTarget?>()) {
      return (data != null ? _i29.DomainNameTarget.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.NewCustomDomainNamesEvent?>()) {
      return (data != null
          ? _i30.NewCustomDomainNamesEvent.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i31.CustomDomainNameWithDefaultDomains?>()) {
      return (data != null
          ? _i31.CustomDomainNameWithDefaultDomains.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i32.DatabaseConnection?>()) {
      return (data != null ? _i32.DatabaseConnection.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i33.DatabaseProvider?>()) {
      return (data != null ? _i33.DatabaseProvider.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.PubsubEntry?>()) {
      return (data != null ? _i34.PubsubEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.EnvironmentVariable?>()) {
      return (data != null ? _i35.EnvironmentVariable.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i36.Address?>()) {
      return (data != null ? _i36.Address.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.Project?>()) {
      return (data != null ? _i37.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.ProjectConfig?>()) {
      return (data != null ? _i38.ProjectConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.ProjectDeleteCallEvent?>()) {
      return (data != null ? _i39.ProjectDeleteCallEvent.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i40.Role?>()) {
      return (data != null ? _i40.Role.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.UserRoleMembership?>()) {
      return (data != null ? _i41.UserRoleMembership.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i42.SecretResource?>()) {
      return (data != null ? _i42.SecretResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.SecretType?>()) {
      return (data != null ? _i43.SecretType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.DuplicateEntryException?>()) {
      return (data != null ? _i44.DuplicateEntryException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i45.InvalidValueException?>()) {
      return (data != null ? _i45.InvalidValueException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i46.NotFoundException?>()) {
      return (data != null ? _i46.NotFoundException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i47.ResourceDeniedException?>()) {
      return (data != null ? _i47.ResourceDeniedException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i48.UnauthenticatedException?>()) {
      return (data != null
          ? _i48.UnauthenticatedException.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i49.UnauthorizedException?>()) {
      return (data != null ? _i49.UnauthorizedException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i50.ServerpodRegion?>()) {
      return (data != null ? _i50.ServerpodRegion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i51.DatabaseResource?>()) {
      return (data != null ? _i51.DatabaseResource.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<_i37.Project>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i37.Project>(e)).toList()
          : null) as T;
    }
    if (t == _i1.getType<List<_i35.EnvironmentVariable>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i35.EnvironmentVariable>(e))
              .toList()
          : null) as T;
    }
    if (t == _i1.getType<List<_i25.CustomDomainName>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i25.CustomDomainName>(e))
              .toList()
          : null) as T;
    }
    if (t == _i1.getType<List<_i41.UserRoleMembership>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i41.UserRoleMembership>(e))
              .toList()
          : null) as T;
    }
    if (t == List<_i25.CustomDomainName>) {
      return (data as List)
          .map((e) => deserialize<_i25.CustomDomainName>(e))
          .toList() as T;
    }
    if (t == Map<_i29.DomainNameTarget, String>) {
      return Map.fromEntries((data as List).map((e) => MapEntry(
          deserialize<_i29.DomainNameTarget>(e['k']),
          deserialize<String>(e['v'])))) as T;
    }
    if (t == _i1.getType<List<_i40.Role>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i40.Role>(e)).toList()
          : null) as T;
    }
    if (t == _i1.getType<List<_i9.Capsule>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i9.Capsule>(e)).toList()
          : null) as T;
    }
    if (t == _i1.getType<List<_i41.UserRoleMembership>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i41.UserRoleMembership>(e))
              .toList()
          : null) as T;
    }
    if (t == List<(String, String)>) {
      return (data as List)
          .map((e) => deserialize<(String, String)>(e))
          .toList() as T;
    }
    if (t == _i1.getType<(String, String)>()) {
      return (
        deserialize<String>(((data as Map)['p'] as List)[0]),
        deserialize<String>(data['p'][1]),
      ) as T;
    }
    if (t == _i1.getType<(String, String)>()) {
      return (
        deserialize<String>(((data as Map)['p'] as List)[0]),
        deserialize<String>(data['p'][1]),
      ) as T;
    }
    if (t == List<_i52.Project>) {
      return (data as List).map((e) => deserialize<_i52.Project>(e)).toList()
          as T;
    }
    if (t == List<_i53.User>) {
      return (data as List).map((e) => deserialize<_i53.User>(e)).toList() as T;
    }
    if (t == List<_i54.RequiredTerms>) {
      return (data as List)
          .map((e) => deserialize<_i54.RequiredTerms>(e))
          .toList() as T;
    }
    if (t == List<_i55.AcceptedTermsDTO>) {
      return (data as List)
          .map((e) => deserialize<_i55.AcceptedTermsDTO>(e))
          .toList() as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i56.PaymentMethod>) {
      return (data as List)
          .map((e) => deserialize<_i56.PaymentMethod>(e))
          .toList() as T;
    }
    if (t == List<_i57.EnvironmentVariable>) {
      return (data as List)
          .map((e) => deserialize<_i57.EnvironmentVariable>(e))
          .toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<_i58.Role>) {
      return (data as List).map((e) => deserialize<_i58.Role>(e)).toList() as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map((k, v) =>
          MapEntry(deserialize<String>(k), deserialize<String>(v))) as T;
    }
    if (t == List<_i59.DeployAttempt>) {
      return (data as List)
          .map((e) => deserialize<_i59.DeployAttempt>(e))
          .toList() as T;
    }
    if (t == List<_i60.DeployAttemptStage>) {
      return (data as List)
          .map((e) => deserialize<_i60.DeployAttemptStage>(e))
          .toList() as T;
    }
    try {
      return _i61.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i62.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i63.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i64.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i65.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    switch (data) {
      case _i2.UserAccountStatus():
        return 'UserAccountStatus';
      case _i3.BillingInfo():
        return 'BillingInfo';
      case _i4.Owner():
        return 'Owner';
      case _i5.PaymentMethod():
        return 'PaymentMethod';
      case _i6.PaymentMethodCard():
        return 'PaymentMethodCard';
      case _i7.PaymentSetupIntent():
        return 'PaymentSetupIntent';
      case _i8.Subscription():
        return 'Subscription';
      case _i9.Capsule():
        return 'Capsule';
      case _i10.CapsuleResource():
        return 'CapsuleResource';
      case _i11.LogRecord():
        return 'LogRecord';
      case _i12.DeployAttempt():
        return 'DeployAttempt';
      case _i13.DeployAttemptStage():
        return 'DeployAttemptStage';
      case _i14.DeployProgressStatus():
        return 'DeployProgressStatus';
      case _i15.DeployStageType():
        return 'DeployStageType';
      case _i16.AccountAuthorization():
        return 'AccountAuthorization';
      case _i17.User():
        return 'User';
      case _i18.BillingCustomerType():
        return 'BillingCustomerType';
      case _i19.UserAccountRegistrationDeniedException():
        return 'UserAccountRegistrationDeniedException';
      case _i20.AcceptedTerms():
        return 'AcceptedTerms';
      case _i21.AcceptedTermsDTO():
        return 'AcceptedTermsDTO';
      case _i22.RequiredTerms():
        return 'RequiredTerms';
      case _i23.Terms():
        return 'Terms';
      case _i24.DNSVerificationFailedException():
        return 'DNSVerificationFailedException';
      case _i25.CustomDomainName():
        return 'CustomDomainName';
      case _i26.CustomDomainNameList():
        return 'CustomDomainNameList';
      case _i27.DnsRecordType():
        return 'DnsRecordType';
      case _i28.DomainNameStatus():
        return 'DomainNameStatus';
      case _i29.DomainNameTarget():
        return 'DomainNameTarget';
      case _i30.NewCustomDomainNamesEvent():
        return 'NewCustomDomainNamesEvent';
      case _i31.CustomDomainNameWithDefaultDomains():
        return 'CustomDomainNameWithDefaultDomains';
      case _i32.DatabaseConnection():
        return 'DatabaseConnection';
      case _i33.DatabaseProvider():
        return 'DatabaseProvider';
      case _i34.PubsubEntry():
        return 'PubsubEntry';
      case _i35.EnvironmentVariable():
        return 'EnvironmentVariable';
      case _i36.Address():
        return 'Address';
      case _i37.Project():
        return 'Project';
      case _i38.ProjectConfig():
        return 'ProjectConfig';
      case _i39.ProjectDeleteCallEvent():
        return 'ProjectDeleteCallEvent';
      case _i40.Role():
        return 'Role';
      case _i41.UserRoleMembership():
        return 'UserRoleMembership';
      case _i42.SecretResource():
        return 'SecretResource';
      case _i43.SecretType():
        return 'SecretType';
      case _i44.DuplicateEntryException():
        return 'DuplicateEntryException';
      case _i45.InvalidValueException():
        return 'InvalidValueException';
      case _i46.NotFoundException():
        return 'NotFoundException';
      case _i47.ResourceDeniedException():
        return 'ResourceDeniedException';
      case _i48.UnauthenticatedException():
        return 'UnauthenticatedException';
      case _i49.UnauthorizedException():
        return 'UnauthorizedException';
      case _i50.ServerpodRegion():
        return 'ServerpodRegion';
      case _i51.DatabaseResource():
        return 'DatabaseResource';
    }
    className = _i61.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i62.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_migration.$className';
    }
    className = _i63.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_bridge.$className';
    }
    className = _i64.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    className = _i65.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'UserAccountStatus') {
      return deserialize<_i2.UserAccountStatus>(data['data']);
    }
    if (dataClassName == 'BillingInfo') {
      return deserialize<_i3.BillingInfo>(data['data']);
    }
    if (dataClassName == 'Owner') {
      return deserialize<_i4.Owner>(data['data']);
    }
    if (dataClassName == 'PaymentMethod') {
      return deserialize<_i5.PaymentMethod>(data['data']);
    }
    if (dataClassName == 'PaymentMethodCard') {
      return deserialize<_i6.PaymentMethodCard>(data['data']);
    }
    if (dataClassName == 'PaymentSetupIntent') {
      return deserialize<_i7.PaymentSetupIntent>(data['data']);
    }
    if (dataClassName == 'Subscription') {
      return deserialize<_i8.Subscription>(data['data']);
    }
    if (dataClassName == 'Capsule') {
      return deserialize<_i9.Capsule>(data['data']);
    }
    if (dataClassName == 'CapsuleResource') {
      return deserialize<_i10.CapsuleResource>(data['data']);
    }
    if (dataClassName == 'LogRecord') {
      return deserialize<_i11.LogRecord>(data['data']);
    }
    if (dataClassName == 'DeployAttempt') {
      return deserialize<_i12.DeployAttempt>(data['data']);
    }
    if (dataClassName == 'DeployAttemptStage') {
      return deserialize<_i13.DeployAttemptStage>(data['data']);
    }
    if (dataClassName == 'DeployProgressStatus') {
      return deserialize<_i14.DeployProgressStatus>(data['data']);
    }
    if (dataClassName == 'DeployStageType') {
      return deserialize<_i15.DeployStageType>(data['data']);
    }
    if (dataClassName == 'AccountAuthorization') {
      return deserialize<_i16.AccountAuthorization>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i17.User>(data['data']);
    }
    if (dataClassName == 'BillingCustomerType') {
      return deserialize<_i18.BillingCustomerType>(data['data']);
    }
    if (dataClassName == 'UserAccountRegistrationDeniedException') {
      return deserialize<_i19.UserAccountRegistrationDeniedException>(
          data['data']);
    }
    if (dataClassName == 'AcceptedTerms') {
      return deserialize<_i20.AcceptedTerms>(data['data']);
    }
    if (dataClassName == 'AcceptedTermsDTO') {
      return deserialize<_i21.AcceptedTermsDTO>(data['data']);
    }
    if (dataClassName == 'RequiredTerms') {
      return deserialize<_i22.RequiredTerms>(data['data']);
    }
    if (dataClassName == 'Terms') {
      return deserialize<_i23.Terms>(data['data']);
    }
    if (dataClassName == 'DNSVerificationFailedException') {
      return deserialize<_i24.DNSVerificationFailedException>(data['data']);
    }
    if (dataClassName == 'CustomDomainName') {
      return deserialize<_i25.CustomDomainName>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameList') {
      return deserialize<_i26.CustomDomainNameList>(data['data']);
    }
    if (dataClassName == 'DnsRecordType') {
      return deserialize<_i27.DnsRecordType>(data['data']);
    }
    if (dataClassName == 'DomainNameStatus') {
      return deserialize<_i28.DomainNameStatus>(data['data']);
    }
    if (dataClassName == 'DomainNameTarget') {
      return deserialize<_i29.DomainNameTarget>(data['data']);
    }
    if (dataClassName == 'NewCustomDomainNamesEvent') {
      return deserialize<_i30.NewCustomDomainNamesEvent>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameWithDefaultDomains') {
      return deserialize<_i31.CustomDomainNameWithDefaultDomains>(data['data']);
    }
    if (dataClassName == 'DatabaseConnection') {
      return deserialize<_i32.DatabaseConnection>(data['data']);
    }
    if (dataClassName == 'DatabaseProvider') {
      return deserialize<_i33.DatabaseProvider>(data['data']);
    }
    if (dataClassName == 'PubsubEntry') {
      return deserialize<_i34.PubsubEntry>(data['data']);
    }
    if (dataClassName == 'EnvironmentVariable') {
      return deserialize<_i35.EnvironmentVariable>(data['data']);
    }
    if (dataClassName == 'Address') {
      return deserialize<_i36.Address>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i37.Project>(data['data']);
    }
    if (dataClassName == 'ProjectConfig') {
      return deserialize<_i38.ProjectConfig>(data['data']);
    }
    if (dataClassName == 'ProjectDeleteCallEvent') {
      return deserialize<_i39.ProjectDeleteCallEvent>(data['data']);
    }
    if (dataClassName == 'Role') {
      return deserialize<_i40.Role>(data['data']);
    }
    if (dataClassName == 'UserRoleMembership') {
      return deserialize<_i41.UserRoleMembership>(data['data']);
    }
    if (dataClassName == 'SecretResource') {
      return deserialize<_i42.SecretResource>(data['data']);
    }
    if (dataClassName == 'SecretType') {
      return deserialize<_i43.SecretType>(data['data']);
    }
    if (dataClassName == 'DuplicateEntryException') {
      return deserialize<_i44.DuplicateEntryException>(data['data']);
    }
    if (dataClassName == 'InvalidValueException') {
      return deserialize<_i45.InvalidValueException>(data['data']);
    }
    if (dataClassName == 'NotFoundException') {
      return deserialize<_i46.NotFoundException>(data['data']);
    }
    if (dataClassName == 'ResourceDeniedException') {
      return deserialize<_i47.ResourceDeniedException>(data['data']);
    }
    if (dataClassName == 'UnauthenticatedException') {
      return deserialize<_i48.UnauthenticatedException>(data['data']);
    }
    if (dataClassName == 'UnauthorizedException') {
      return deserialize<_i49.UnauthorizedException>(data['data']);
    }
    if (dataClassName == 'ServerpodRegion') {
      return deserialize<_i50.ServerpodRegion>(data['data']);
    }
    if (dataClassName == 'DatabaseResource') {
      return deserialize<_i51.DatabaseResource>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i61.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_migration.')) {
      data['className'] = dataClassName.substring(25);
      return _i62.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_bridge.')) {
      data['className'] = dataClassName.substring(22);
      return _i63.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i64.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i65.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}

/// Maps any `Record`s known to this [Protocol] to their JSON representation
///
/// Throws in case the record type is not known.
///
/// This method will return `null` (only) for `null` inputs.
Map<String, dynamic>? mapRecordToJson(Record? record) {
  if (record == null) {
    return null;
  }
  if (record is (String, String)) {
    return {
      "p": [
        record.$1,
        record.$2,
      ],
    };
  }
  throw Exception('Unsupported record type ${record.runtimeType}');
}

/// Maps container types (like [List], [Map], [Set]) containing
/// [Record]s or non-String-keyed [Map]s to their JSON representation.
///
/// It should not be called for [SerializableModel] types. These
/// handle the "[Record] in container" mapping internally already.
///
/// It is only supposed to be called from generated protocol code.
///
/// Returns either a `List<dynamic>` (for List, Sets, and Maps with
/// non-String keys) or a `Map<String, dynamic>` in case the input was
/// a `Map<String, …>`.
Object? mapContainerToJson(Object obj) {
  if (obj is! Iterable && obj is! Map) {
    throw ArgumentError.value(
      obj,
      'obj',
      'The object to serialize should be of type List, Map, or Set',
    );
  }

  dynamic mapIfNeeded(Object? obj) {
    return switch (obj) {
      Record record => mapRecordToJson(record),
      Iterable iterable => mapContainerToJson(iterable),
      Map map => mapContainerToJson(map),
      Object? value => value,
    };
  }

  switch (obj) {
    case Map<String, dynamic>():
      return {
        for (var entry in obj.entries) entry.key: mapIfNeeded(entry.value),
      };
    case Map():
      return [
        for (var entry in obj.entries)
          {
            'k': mapIfNeeded(entry.key),
            'v': mapIfNeeded(entry.value),
          }
      ];

    case Iterable():
      return [
        for (var e in obj) mapIfNeeded(e),
      ];
  }

  return obj;
}

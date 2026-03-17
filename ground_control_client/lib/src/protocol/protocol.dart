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
import 'domains/billing/models/billing_customer_type.dart' as _i2;
import 'domains/billing/models/billing_info.dart' as _i3;
import 'domains/billing/models/billing_mapping_type.dart' as _i4;
import 'domains/billing/models/owner.dart' as _i5;
import 'domains/billing/models/payment_method.dart' as _i6;
import 'domains/billing/models/payment_method_card.dart' as _i7;
import 'domains/billing/models/payment_setup_intent.dart' as _i8;
import 'domains/capsules/models/capsule.dart' as _i9;
import 'domains/capsules/models/capsule_resource_config.dart' as _i10;
import 'domains/capsules/models/compute_size_option.dart' as _i11;
import 'domains/environment_variables/models/variable.dart' as _i12;
import 'domains/logs/models/log_record.dart' as _i13;
import 'domains/products/models/compute_product_info.dart' as _i14;
import 'domains/products/models/database_product_info.dart' as _i15;
import 'domains/products/models/database_scaling_info.dart' as _i16;
import 'domains/products/models/database_size_info.dart' as _i17;
import 'domains/products/models/plan_info.dart' as _i18;
import 'domains/products/models/product_type.dart' as _i19;
import 'domains/products/models/project_product_info.dart' as _i20;
import 'domains/products/models/subscription_info.dart' as _i21;
import 'domains/projects/models/project.dart' as _i22;
import 'domains/projects/models/role.dart' as _i23;
import 'domains/projects/models/user_role_membership.dart' as _i24;
import 'domains/secrets/models/secret_resource.dart' as _i25;
import 'domains/secrets/models/secret_type.dart' as _i26;
import 'domains/status/models/deploy_attempt.dart' as _i27;
import 'domains/status/models/deploy_attempt_stage.dart' as _i28;
import 'domains/status/models/deploy_progress_status.dart' as _i29;
import 'domains/status/models/deploy_stage_type.dart' as _i30;
import 'domains/users/models/account_authorization.dart' as _i31;
import 'domains/users/models/user.dart' as _i32;
import 'domains/users/models/user_account_status.dart' as _i33;
import 'domains/users/models/user_label.dart' as _i34;
import 'domains/users/models/user_label_mapping.dart' as _i35;
import 'features/auth/exceptions/user_account_registration_denied_exception.dart'
    as _i36;
import 'features/auth/models/accepted_terms.dart' as _i37;
import 'features/auth/models/accepted_terms_dto.dart' as _i38;
import 'features/auth/models/auth_token_info.dart' as _i39;
import 'features/auth/models/required_terms.dart' as _i40;
import 'features/auth/models/terms.dart' as _i41;
import 'features/capsules/models/compute_info.dart' as _i42;
import 'features/custom_domains/exceptions/dns_verification_failed_exception.dart'
    as _i43;
import 'features/custom_domains/models/custom_domain_name.dart' as _i44;
import 'features/custom_domains/models/custom_domain_name_list.dart' as _i45;
import 'features/custom_domains/models/dns_record_type.dart' as _i46;
import 'features/custom_domains/models/domain_name_status.dart' as _i47;
import 'features/custom_domains/models/domain_name_target.dart' as _i48;
import 'features/custom_domains/models/new_domain_names_event.dart' as _i49;
import 'features/custom_domains/models/view_models/custom_domain_name_with_default_domains.dart'
    as _i50;
import 'features/databases/models/database_connection.dart' as _i51;
import 'features/databases/models/database_info.dart' as _i52;
import 'features/databases/models/database_provider.dart' as _i53;
import 'features/databases/models/database_quota.dart' as _i54;
import 'features/databases/models/database_resource.dart' as _i55;
import 'features/databases/models/database_scaling.dart' as _i56;
import 'features/databases/models/database_size.dart' as _i57;
import 'features/insights/models/insights_connection_detail.dart' as _i58;
import 'features/projects/models/project_config.dart' as _i59;
import 'features/projects/models/project_delete_call_event.dart' as _i60;
import 'features/projects/models/project_info/project_info.dart' as _i61;
import 'features/projects/models/project_info/timestamp.dart' as _i62;
import 'shared/exceptions/models/duplicate_entry_exception.dart' as _i63;
import 'shared/exceptions/models/invalid_value_exception.dart' as _i64;
import 'shared/exceptions/models/no_subscription_exception.dart' as _i65;
import 'shared/exceptions/models/not_found_exception.dart' as _i66;
import 'shared/exceptions/models/procurement_cancellation_exception.dart'
    as _i67;
import 'shared/exceptions/models/procurement_denied_exception.dart' as _i68;
import 'shared/exceptions/models/unauthenticated_exception.dart' as _i69;
import 'shared/exceptions/models/unauthorized_exception.dart' as _i70;
import 'shared/models/serverpod_region.dart' as _i71;
import 'shared/services/pubsub/registry/pubsub_entry.dart' as _i72;
import 'package:ground_control_client/src/protocol/domains/projects/models/project.dart'
    as _i73;
import 'package:ground_control_client/src/protocol/features/projects/models/project_info/project_info.dart'
    as _i74;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i75;
import 'package:ground_control_client/src/protocol/domains/users/models/user.dart'
    as _i76;
import 'package:ground_control_client/src/protocol/features/auth/models/required_terms.dart'
    as _i77;
import 'package:ground_control_client/src/protocol/features/auth/models/accepted_terms_dto.dart'
    as _i78;
import 'package:ground_control_client/src/protocol/features/auth/models/auth_token_info.dart'
    as _i79;
import 'package:ground_control_client/src/protocol/domains/billing/models/payment_method.dart'
    as _i80;
import 'package:ground_control_client/src/protocol/domains/environment_variables/models/variable.dart'
    as _i81;
import 'package:ground_control_client/src/protocol/domains/projects/models/role.dart'
    as _i82;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _i83;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i84;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i85;
export 'domains/billing/models/billing_customer_type.dart';
export 'domains/billing/models/billing_info.dart';
export 'domains/billing/models/billing_mapping_type.dart';
export 'domains/billing/models/owner.dart';
export 'domains/billing/models/payment_method.dart';
export 'domains/billing/models/payment_method_card.dart';
export 'domains/billing/models/payment_setup_intent.dart';
export 'domains/capsules/models/capsule.dart';
export 'domains/capsules/models/capsule_resource_config.dart';
export 'domains/capsules/models/compute_size_option.dart';
export 'domains/environment_variables/models/variable.dart';
export 'domains/logs/models/log_record.dart';
export 'domains/products/models/compute_product_info.dart';
export 'domains/products/models/database_product_info.dart';
export 'domains/products/models/database_scaling_info.dart';
export 'domains/products/models/database_size_info.dart';
export 'domains/products/models/plan_info.dart';
export 'domains/products/models/product_type.dart';
export 'domains/products/models/project_product_info.dart';
export 'domains/products/models/subscription_info.dart';
export 'domains/projects/models/project.dart';
export 'domains/projects/models/role.dart';
export 'domains/projects/models/user_role_membership.dart';
export 'domains/secrets/models/secret_resource.dart';
export 'domains/secrets/models/secret_type.dart';
export 'domains/status/models/deploy_attempt.dart';
export 'domains/status/models/deploy_attempt_stage.dart';
export 'domains/status/models/deploy_progress_status.dart';
export 'domains/status/models/deploy_stage_type.dart';
export 'domains/users/models/account_authorization.dart';
export 'domains/users/models/user.dart';
export 'domains/users/models/user_account_status.dart';
export 'domains/users/models/user_label.dart';
export 'domains/users/models/user_label_mapping.dart';
export 'features/auth/exceptions/user_account_registration_denied_exception.dart';
export 'features/auth/models/accepted_terms.dart';
export 'features/auth/models/accepted_terms_dto.dart';
export 'features/auth/models/auth_token_info.dart';
export 'features/auth/models/required_terms.dart';
export 'features/auth/models/terms.dart';
export 'features/capsules/models/compute_info.dart';
export 'features/custom_domains/exceptions/dns_verification_failed_exception.dart';
export 'features/custom_domains/models/custom_domain_name.dart';
export 'features/custom_domains/models/custom_domain_name_list.dart';
export 'features/custom_domains/models/dns_record_type.dart';
export 'features/custom_domains/models/domain_name_status.dart';
export 'features/custom_domains/models/domain_name_target.dart';
export 'features/custom_domains/models/new_domain_names_event.dart';
export 'features/custom_domains/models/view_models/custom_domain_name_with_default_domains.dart';
export 'features/databases/models/database_connection.dart';
export 'features/databases/models/database_info.dart';
export 'features/databases/models/database_provider.dart';
export 'features/databases/models/database_quota.dart';
export 'features/databases/models/database_resource.dart';
export 'features/databases/models/database_scaling.dart';
export 'features/databases/models/database_size.dart';
export 'features/insights/models/insights_connection_detail.dart';
export 'features/projects/models/project_config.dart';
export 'features/projects/models/project_delete_call_event.dart';
export 'features/projects/models/project_info/project_info.dart';
export 'features/projects/models/project_info/timestamp.dart';
export 'shared/exceptions/models/duplicate_entry_exception.dart';
export 'shared/exceptions/models/invalid_value_exception.dart';
export 'shared/exceptions/models/no_subscription_exception.dart';
export 'shared/exceptions/models/not_found_exception.dart';
export 'shared/exceptions/models/procurement_cancellation_exception.dart';
export 'shared/exceptions/models/procurement_denied_exception.dart';
export 'shared/exceptions/models/unauthenticated_exception.dart';
export 'shared/exceptions/models/unauthorized_exception.dart';
export 'shared/models/serverpod_region.dart';
export 'shared/services/pubsub/registry/pubsub_entry.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(dynamic data, [Type? t]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.BillingCustomerType) {
      return _i2.BillingCustomerType.fromJson(data) as T;
    }
    if (t == _i3.BillingInfo) {
      return _i3.BillingInfo.fromJson(data) as T;
    }
    if (t == _i4.BillingMappingType) {
      return _i4.BillingMappingType.fromJson(data) as T;
    }
    if (t == _i5.Owner) {
      return _i5.Owner.fromJson(data) as T;
    }
    if (t == _i6.PaymentMethod) {
      return _i6.PaymentMethod.fromJson(data) as T;
    }
    if (t == _i7.PaymentMethodCard) {
      return _i7.PaymentMethodCard.fromJson(data) as T;
    }
    if (t == _i8.PaymentSetupIntent) {
      return _i8.PaymentSetupIntent.fromJson(data) as T;
    }
    if (t == _i9.Capsule) {
      return _i9.Capsule.fromJson(data) as T;
    }
    if (t == _i10.CapsuleResource) {
      return _i10.CapsuleResource.fromJson(data) as T;
    }
    if (t == _i11.ComputeSizeOption) {
      return _i11.ComputeSizeOption.fromJson(data) as T;
    }
    if (t == _i12.EnvironmentVariable) {
      return _i12.EnvironmentVariable.fromJson(data) as T;
    }
    if (t == _i13.LogRecord) {
      return _i13.LogRecord.fromJson(data) as T;
    }
    if (t == _i14.ComputeProductInfo) {
      return _i14.ComputeProductInfo.fromJson(data) as T;
    }
    if (t == _i15.DatabaseProductInfo) {
      return _i15.DatabaseProductInfo.fromJson(data) as T;
    }
    if (t == _i16.DatabaseScalingInfo) {
      return _i16.DatabaseScalingInfo.fromJson(data) as T;
    }
    if (t == _i17.DatabaseSizeInfo) {
      return _i17.DatabaseSizeInfo.fromJson(data) as T;
    }
    if (t == _i18.PlanInfo) {
      return _i18.PlanInfo.fromJson(data) as T;
    }
    if (t == _i19.ProductType) {
      return _i19.ProductType.fromJson(data) as T;
    }
    if (t == _i20.ProjectProductInfo) {
      return _i20.ProjectProductInfo.fromJson(data) as T;
    }
    if (t == _i21.SubscriptionInfo) {
      return _i21.SubscriptionInfo.fromJson(data) as T;
    }
    if (t == _i22.Project) {
      return _i22.Project.fromJson(data) as T;
    }
    if (t == _i23.Role) {
      return _i23.Role.fromJson(data) as T;
    }
    if (t == _i24.UserRoleMembership) {
      return _i24.UserRoleMembership.fromJson(data) as T;
    }
    if (t == _i25.SecretResource) {
      return _i25.SecretResource.fromJson(data) as T;
    }
    if (t == _i26.SecretType) {
      return _i26.SecretType.fromJson(data) as T;
    }
    if (t == _i27.DeployAttempt) {
      return _i27.DeployAttempt.fromJson(data) as T;
    }
    if (t == _i28.DeployAttemptStage) {
      return _i28.DeployAttemptStage.fromJson(data) as T;
    }
    if (t == _i29.DeployProgressStatus) {
      return _i29.DeployProgressStatus.fromJson(data) as T;
    }
    if (t == _i30.DeployStageType) {
      return _i30.DeployStageType.fromJson(data) as T;
    }
    if (t == _i31.AccountAuthorization) {
      return _i31.AccountAuthorization.fromJson(data) as T;
    }
    if (t == _i32.User) {
      return _i32.User.fromJson(data) as T;
    }
    if (t == _i33.UserAccountStatus) {
      return _i33.UserAccountStatus.fromJson(data) as T;
    }
    if (t == _i34.UserLabel) {
      return _i34.UserLabel.fromJson(data) as T;
    }
    if (t == _i35.UserLabelMapping) {
      return _i35.UserLabelMapping.fromJson(data) as T;
    }
    if (t == _i36.UserAccountRegistrationDeniedException) {
      return _i36.UserAccountRegistrationDeniedException.fromJson(data) as T;
    }
    if (t == _i37.AcceptedTerms) {
      return _i37.AcceptedTerms.fromJson(data) as T;
    }
    if (t == _i38.AcceptedTermsDTO) {
      return _i38.AcceptedTermsDTO.fromJson(data) as T;
    }
    if (t == _i39.AuthTokenInfo) {
      return _i39.AuthTokenInfo.fromJson(data) as T;
    }
    if (t == _i40.RequiredTerms) {
      return _i40.RequiredTerms.fromJson(data) as T;
    }
    if (t == _i41.Terms) {
      return _i41.Terms.fromJson(data) as T;
    }
    if (t == _i42.ComputeInfo) {
      return _i42.ComputeInfo.fromJson(data) as T;
    }
    if (t == _i43.DNSVerificationFailedException) {
      return _i43.DNSVerificationFailedException.fromJson(data) as T;
    }
    if (t == _i44.CustomDomainName) {
      return _i44.CustomDomainName.fromJson(data) as T;
    }
    if (t == _i45.CustomDomainNameList) {
      return _i45.CustomDomainNameList.fromJson(data) as T;
    }
    if (t == _i46.DnsRecordType) {
      return _i46.DnsRecordType.fromJson(data) as T;
    }
    if (t == _i47.DomainNameStatus) {
      return _i47.DomainNameStatus.fromJson(data) as T;
    }
    if (t == _i48.DomainNameTarget) {
      return _i48.DomainNameTarget.fromJson(data) as T;
    }
    if (t == _i49.NewCustomDomainNamesEvent) {
      return _i49.NewCustomDomainNamesEvent.fromJson(data) as T;
    }
    if (t == _i50.CustomDomainNameWithDefaultDomains) {
      return _i50.CustomDomainNameWithDefaultDomains.fromJson(data) as T;
    }
    if (t == _i51.DatabaseConnection) {
      return _i51.DatabaseConnection.fromJson(data) as T;
    }
    if (t == _i52.DatabaseInfo) {
      return _i52.DatabaseInfo.fromJson(data) as T;
    }
    if (t == _i53.DatabaseProvider) {
      return _i53.DatabaseProvider.fromJson(data) as T;
    }
    if (t == _i54.DatabaseQuota) {
      return _i54.DatabaseQuota.fromJson(data) as T;
    }
    if (t == _i55.DatabaseResource) {
      return _i55.DatabaseResource.fromJson(data) as T;
    }
    if (t == _i56.DatabaseScaling) {
      return _i56.DatabaseScaling.fromJson(data) as T;
    }
    if (t == _i57.DatabaseSizeOption) {
      return _i57.DatabaseSizeOption.fromJson(data) as T;
    }
    if (t == _i58.InsightsConnectionDetail) {
      return _i58.InsightsConnectionDetail.fromJson(data) as T;
    }
    if (t == _i59.ProjectConfig) {
      return _i59.ProjectConfig.fromJson(data) as T;
    }
    if (t == _i60.ProjectDeleteCallEvent) {
      return _i60.ProjectDeleteCallEvent.fromJson(data) as T;
    }
    if (t == _i61.ProjectInfo) {
      return _i61.ProjectInfo.fromJson(data) as T;
    }
    if (t == _i62.Timestamp) {
      return _i62.Timestamp.fromJson(data) as T;
    }
    if (t == _i63.DuplicateEntryException) {
      return _i63.DuplicateEntryException.fromJson(data) as T;
    }
    if (t == _i64.InvalidValueException) {
      return _i64.InvalidValueException.fromJson(data) as T;
    }
    if (t == _i65.NoSubscriptionException) {
      return _i65.NoSubscriptionException.fromJson(data) as T;
    }
    if (t == _i66.NotFoundException) {
      return _i66.NotFoundException.fromJson(data) as T;
    }
    if (t == _i67.ProcurementCancellationException) {
      return _i67.ProcurementCancellationException.fromJson(data) as T;
    }
    if (t == _i68.ProcurementDeniedException) {
      return _i68.ProcurementDeniedException.fromJson(data) as T;
    }
    if (t == _i69.UnauthenticatedException) {
      return _i69.UnauthenticatedException.fromJson(data) as T;
    }
    if (t == _i70.UnauthorizedException) {
      return _i70.UnauthorizedException.fromJson(data) as T;
    }
    if (t == _i71.ServerpodRegion) {
      return _i71.ServerpodRegion.fromJson(data) as T;
    }
    if (t == _i72.PubsubEntry) {
      return _i72.PubsubEntry.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.BillingCustomerType?>()) {
      return (data != null ? _i2.BillingCustomerType.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i3.BillingInfo?>()) {
      return (data != null ? _i3.BillingInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.BillingMappingType?>()) {
      return (data != null ? _i4.BillingMappingType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Owner?>()) {
      return (data != null ? _i5.Owner.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.PaymentMethod?>()) {
      return (data != null ? _i6.PaymentMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.PaymentMethodCard?>()) {
      return (data != null ? _i7.PaymentMethodCard.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.PaymentSetupIntent?>()) {
      return (data != null ? _i8.PaymentSetupIntent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Capsule?>()) {
      return (data != null ? _i9.Capsule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.CapsuleResource?>()) {
      return (data != null ? _i10.CapsuleResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.ComputeSizeOption?>()) {
      return (data != null ? _i11.ComputeSizeOption.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.EnvironmentVariable?>()) {
      return (data != null ? _i12.EnvironmentVariable.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.LogRecord?>()) {
      return (data != null ? _i13.LogRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.ComputeProductInfo?>()) {
      return (data != null ? _i14.ComputeProductInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.DatabaseProductInfo?>()) {
      return (data != null ? _i15.DatabaseProductInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.DatabaseScalingInfo?>()) {
      return (data != null ? _i16.DatabaseScalingInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.DatabaseSizeInfo?>()) {
      return (data != null ? _i17.DatabaseSizeInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.PlanInfo?>()) {
      return (data != null ? _i18.PlanInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.ProductType?>()) {
      return (data != null ? _i19.ProductType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.ProjectProductInfo?>()) {
      return (data != null ? _i20.ProjectProductInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i21.SubscriptionInfo?>()) {
      return (data != null ? _i21.SubscriptionInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.Project?>()) {
      return (data != null ? _i22.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.Role?>()) {
      return (data != null ? _i23.Role.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.UserRoleMembership?>()) {
      return (data != null ? _i24.UserRoleMembership.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i25.SecretResource?>()) {
      return (data != null ? _i25.SecretResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.SecretType?>()) {
      return (data != null ? _i26.SecretType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.DeployAttempt?>()) {
      return (data != null ? _i27.DeployAttempt.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.DeployAttemptStage?>()) {
      return (data != null ? _i28.DeployAttemptStage.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i29.DeployProgressStatus?>()) {
      return (data != null ? _i29.DeployProgressStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i30.DeployStageType?>()) {
      return (data != null ? _i30.DeployStageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.AccountAuthorization?>()) {
      return (data != null ? _i31.AccountAuthorization.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i32.User?>()) {
      return (data != null ? _i32.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.UserAccountStatus?>()) {
      return (data != null ? _i33.UserAccountStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.UserLabel?>()) {
      return (data != null ? _i34.UserLabel.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.UserLabelMapping?>()) {
      return (data != null ? _i35.UserLabelMapping.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.UserAccountRegistrationDeniedException?>()) {
      return (data != null
              ? _i36.UserAccountRegistrationDeniedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i37.AcceptedTerms?>()) {
      return (data != null ? _i37.AcceptedTerms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.AcceptedTermsDTO?>()) {
      return (data != null ? _i38.AcceptedTermsDTO.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.AuthTokenInfo?>()) {
      return (data != null ? _i39.AuthTokenInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.RequiredTerms?>()) {
      return (data != null ? _i40.RequiredTerms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.Terms?>()) {
      return (data != null ? _i41.Terms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i42.ComputeInfo?>()) {
      return (data != null ? _i42.ComputeInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.DNSVerificationFailedException?>()) {
      return (data != null
              ? _i43.DNSVerificationFailedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i44.CustomDomainName?>()) {
      return (data != null ? _i44.CustomDomainName.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.CustomDomainNameList?>()) {
      return (data != null ? _i45.CustomDomainNameList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i46.DnsRecordType?>()) {
      return (data != null ? _i46.DnsRecordType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i47.DomainNameStatus?>()) {
      return (data != null ? _i47.DomainNameStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i48.DomainNameTarget?>()) {
      return (data != null ? _i48.DomainNameTarget.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i49.NewCustomDomainNamesEvent?>()) {
      return (data != null
              ? _i49.NewCustomDomainNamesEvent.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i50.CustomDomainNameWithDefaultDomains?>()) {
      return (data != null
              ? _i50.CustomDomainNameWithDefaultDomains.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i51.DatabaseConnection?>()) {
      return (data != null ? _i51.DatabaseConnection.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i52.DatabaseInfo?>()) {
      return (data != null ? _i52.DatabaseInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i53.DatabaseProvider?>()) {
      return (data != null ? _i53.DatabaseProvider.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i54.DatabaseQuota?>()) {
      return (data != null ? _i54.DatabaseQuota.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i55.DatabaseResource?>()) {
      return (data != null ? _i55.DatabaseResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i56.DatabaseScaling?>()) {
      return (data != null ? _i56.DatabaseScaling.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i57.DatabaseSizeOption?>()) {
      return (data != null ? _i57.DatabaseSizeOption.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i58.InsightsConnectionDetail?>()) {
      return (data != null
              ? _i58.InsightsConnectionDetail.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i59.ProjectConfig?>()) {
      return (data != null ? _i59.ProjectConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i60.ProjectDeleteCallEvent?>()) {
      return (data != null ? _i60.ProjectDeleteCallEvent.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i61.ProjectInfo?>()) {
      return (data != null ? _i61.ProjectInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i62.Timestamp?>()) {
      return (data != null ? _i62.Timestamp.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i63.DuplicateEntryException?>()) {
      return (data != null ? _i63.DuplicateEntryException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i64.InvalidValueException?>()) {
      return (data != null ? _i64.InvalidValueException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i65.NoSubscriptionException?>()) {
      return (data != null ? _i65.NoSubscriptionException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i66.NotFoundException?>()) {
      return (data != null ? _i66.NotFoundException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i67.ProcurementCancellationException?>()) {
      return (data != null
              ? _i67.ProcurementCancellationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i68.ProcurementDeniedException?>()) {
      return (data != null
              ? _i68.ProcurementDeniedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i69.UnauthenticatedException?>()) {
      return (data != null
              ? _i69.UnauthenticatedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i70.UnauthorizedException?>()) {
      return (data != null ? _i70.UnauthorizedException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i71.ServerpodRegion?>()) {
      return (data != null ? _i71.ServerpodRegion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i72.PubsubEntry?>()) {
      return (data != null ? _i72.PubsubEntry.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i22.Project>) {
      return (data as List).map((e) => deserialize<_i22.Project>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i22.Project>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i22.Project>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i12.EnvironmentVariable>) {
      return (data as List)
              .map((e) => deserialize<_i12.EnvironmentVariable>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i12.EnvironmentVariable>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i12.EnvironmentVariable>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i44.CustomDomainName>) {
      return (data as List)
              .map((e) => deserialize<_i44.CustomDomainName>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i44.CustomDomainName>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i44.CustomDomainName>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i17.DatabaseSizeInfo>) {
      return (data as List)
              .map((e) => deserialize<_i17.DatabaseSizeInfo>(e))
              .toList()
          as T;
    }
    if (t == List<double>) {
      return (data as List).map((e) => deserialize<double>(e)).toList() as T;
    }
    if (t == List<_i20.ProjectProductInfo>) {
      return (data as List)
              .map((e) => deserialize<_i20.ProjectProductInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i23.Role>) {
      return (data as List).map((e) => deserialize<_i23.Role>(e)).toList() as T;
    }
    if (t == _i1.getType<List<_i23.Role>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i23.Role>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i9.Capsule>) {
      return (data as List).map((e) => deserialize<_i9.Capsule>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i9.Capsule>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i9.Capsule>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i24.UserRoleMembership>) {
      return (data as List)
              .map((e) => deserialize<_i24.UserRoleMembership>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i24.UserRoleMembership>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i24.UserRoleMembership>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i35.UserLabelMapping>) {
      return (data as List)
              .map((e) => deserialize<_i35.UserLabelMapping>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i35.UserLabelMapping>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i35.UserLabelMapping>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == Map<_i48.DomainNameTarget, String>) {
      return Map.fromEntries(
            (data as List).map(
              (e) => MapEntry(
                deserialize<_i48.DomainNameTarget>(e['k']),
                deserialize<String>(e['v']),
              ),
            ),
          )
          as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<dynamic>(v)),
          )
          as T;
    }
    if (t == List<(String, String)>) {
      return (data as List)
              .map((e) => deserialize<(String, String)>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<(String, String)>()) {
      return (
            deserialize<String>(((data as Map)['p'] as List)[0]),
            deserialize<String>(data['p'][1]),
          )
          as T;
    }
    if (t == _i1.getType<(String, String)>()) {
      return (
            deserialize<String>(((data as Map)['p'] as List)[0]),
            deserialize<String>(data['p'][1]),
          )
          as T;
    }
    if (t == List<_i73.Project>) {
      return (data as List).map((e) => deserialize<_i73.Project>(e)).toList()
          as T;
    }
    if (t == List<_i74.ProjectInfo>) {
      return (data as List)
              .map((e) => deserialize<_i74.ProjectInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i75.DeployAttempt>) {
      return (data as List)
              .map((e) => deserialize<_i75.DeployAttempt>(e))
              .toList()
          as T;
    }
    if (t == List<_i76.User>) {
      return (data as List).map((e) => deserialize<_i76.User>(e)).toList() as T;
    }
    if (t == List<_i77.RequiredTerms>) {
      return (data as List)
              .map((e) => deserialize<_i77.RequiredTerms>(e))
              .toList()
          as T;
    }
    if (t == List<_i78.AcceptedTermsDTO>) {
      return (data as List)
              .map((e) => deserialize<_i78.AcceptedTermsDTO>(e))
              .toList()
          as T;
    }
    if (t == List<_i79.AuthTokenInfo>) {
      return (data as List)
              .map((e) => deserialize<_i79.AuthTokenInfo>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i80.PaymentMethod>) {
      return (data as List)
              .map((e) => deserialize<_i80.PaymentMethod>(e))
              .toList()
          as T;
    }
    if (t == List<_i81.EnvironmentVariable>) {
      return (data as List)
              .map((e) => deserialize<_i81.EnvironmentVariable>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i82.Role>) {
      return (data as List).map((e) => deserialize<_i82.Role>(e)).toList() as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == List<_i83.DeployAttemptStage>) {
      return (data as List)
              .map((e) => deserialize<_i83.DeployAttemptStage>(e))
              .toList()
          as T;
    }
    try {
      return _i84.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i85.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.BillingCustomerType => 'BillingCustomerType',
      _i3.BillingInfo => 'BillingInfo',
      _i4.BillingMappingType => 'BillingMappingType',
      _i5.Owner => 'Owner',
      _i6.PaymentMethod => 'PaymentMethod',
      _i7.PaymentMethodCard => 'PaymentMethodCard',
      _i8.PaymentSetupIntent => 'PaymentSetupIntent',
      _i9.Capsule => 'Capsule',
      _i10.CapsuleResource => 'CapsuleResource',
      _i11.ComputeSizeOption => 'ComputeSizeOption',
      _i12.EnvironmentVariable => 'EnvironmentVariable',
      _i13.LogRecord => 'LogRecord',
      _i14.ComputeProductInfo => 'ComputeProductInfo',
      _i15.DatabaseProductInfo => 'DatabaseProductInfo',
      _i16.DatabaseScalingInfo => 'DatabaseScalingInfo',
      _i17.DatabaseSizeInfo => 'DatabaseSizeInfo',
      _i18.PlanInfo => 'PlanInfo',
      _i19.ProductType => 'ProductType',
      _i20.ProjectProductInfo => 'ProjectProductInfo',
      _i21.SubscriptionInfo => 'SubscriptionInfo',
      _i22.Project => 'Project',
      _i23.Role => 'Role',
      _i24.UserRoleMembership => 'UserRoleMembership',
      _i25.SecretResource => 'SecretResource',
      _i26.SecretType => 'SecretType',
      _i27.DeployAttempt => 'DeployAttempt',
      _i28.DeployAttemptStage => 'DeployAttemptStage',
      _i29.DeployProgressStatus => 'DeployProgressStatus',
      _i30.DeployStageType => 'DeployStageType',
      _i31.AccountAuthorization => 'AccountAuthorization',
      _i32.User => 'User',
      _i33.UserAccountStatus => 'UserAccountStatus',
      _i34.UserLabel => 'UserLabel',
      _i35.UserLabelMapping => 'UserLabelMapping',
      _i36.UserAccountRegistrationDeniedException =>
        'UserAccountRegistrationDeniedException',
      _i37.AcceptedTerms => 'AcceptedTerms',
      _i38.AcceptedTermsDTO => 'AcceptedTermsDTO',
      _i39.AuthTokenInfo => 'AuthTokenInfo',
      _i40.RequiredTerms => 'RequiredTerms',
      _i41.Terms => 'Terms',
      _i42.ComputeInfo => 'ComputeInfo',
      _i43.DNSVerificationFailedException => 'DNSVerificationFailedException',
      _i44.CustomDomainName => 'CustomDomainName',
      _i45.CustomDomainNameList => 'CustomDomainNameList',
      _i46.DnsRecordType => 'DnsRecordType',
      _i47.DomainNameStatus => 'DomainNameStatus',
      _i48.DomainNameTarget => 'DomainNameTarget',
      _i49.NewCustomDomainNamesEvent => 'NewCustomDomainNamesEvent',
      _i50.CustomDomainNameWithDefaultDomains =>
        'CustomDomainNameWithDefaultDomains',
      _i51.DatabaseConnection => 'DatabaseConnection',
      _i52.DatabaseInfo => 'DatabaseInfo',
      _i53.DatabaseProvider => 'DatabaseProvider',
      _i54.DatabaseQuota => 'DatabaseQuota',
      _i55.DatabaseResource => 'DatabaseResource',
      _i56.DatabaseScaling => 'DatabaseScaling',
      _i57.DatabaseSizeOption => 'DatabaseSizeOption',
      _i58.InsightsConnectionDetail => 'InsightsConnectionDetail',
      _i59.ProjectConfig => 'ProjectConfig',
      _i60.ProjectDeleteCallEvent => 'ProjectDeleteCallEvent',
      _i61.ProjectInfo => 'ProjectInfo',
      _i62.Timestamp => 'Timestamp',
      _i63.DuplicateEntryException => 'DuplicateEntryException',
      _i64.InvalidValueException => 'InvalidValueException',
      _i65.NoSubscriptionException => 'NoSubscriptionException',
      _i66.NotFoundException => 'NotFoundException',
      _i67.ProcurementCancellationException =>
        'ProcurementCancellationException',
      _i68.ProcurementDeniedException => 'ProcurementDeniedException',
      _i69.UnauthenticatedException => 'UnauthenticatedException',
      _i70.UnauthorizedException => 'UnauthorizedException',
      _i71.ServerpodRegion => 'ServerpodRegion',
      _i72.PubsubEntry => 'PubsubEntry',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'ground_control.',
        '',
      );
    }

    switch (data) {
      case _i2.BillingCustomerType():
        return 'BillingCustomerType';
      case _i3.BillingInfo():
        return 'BillingInfo';
      case _i4.BillingMappingType():
        return 'BillingMappingType';
      case _i5.Owner():
        return 'Owner';
      case _i6.PaymentMethod():
        return 'PaymentMethod';
      case _i7.PaymentMethodCard():
        return 'PaymentMethodCard';
      case _i8.PaymentSetupIntent():
        return 'PaymentSetupIntent';
      case _i9.Capsule():
        return 'Capsule';
      case _i10.CapsuleResource():
        return 'CapsuleResource';
      case _i11.ComputeSizeOption():
        return 'ComputeSizeOption';
      case _i12.EnvironmentVariable():
        return 'EnvironmentVariable';
      case _i13.LogRecord():
        return 'LogRecord';
      case _i14.ComputeProductInfo():
        return 'ComputeProductInfo';
      case _i15.DatabaseProductInfo():
        return 'DatabaseProductInfo';
      case _i16.DatabaseScalingInfo():
        return 'DatabaseScalingInfo';
      case _i17.DatabaseSizeInfo():
        return 'DatabaseSizeInfo';
      case _i18.PlanInfo():
        return 'PlanInfo';
      case _i19.ProductType():
        return 'ProductType';
      case _i20.ProjectProductInfo():
        return 'ProjectProductInfo';
      case _i21.SubscriptionInfo():
        return 'SubscriptionInfo';
      case _i22.Project():
        return 'Project';
      case _i23.Role():
        return 'Role';
      case _i24.UserRoleMembership():
        return 'UserRoleMembership';
      case _i25.SecretResource():
        return 'SecretResource';
      case _i26.SecretType():
        return 'SecretType';
      case _i27.DeployAttempt():
        return 'DeployAttempt';
      case _i28.DeployAttemptStage():
        return 'DeployAttemptStage';
      case _i29.DeployProgressStatus():
        return 'DeployProgressStatus';
      case _i30.DeployStageType():
        return 'DeployStageType';
      case _i31.AccountAuthorization():
        return 'AccountAuthorization';
      case _i32.User():
        return 'User';
      case _i33.UserAccountStatus():
        return 'UserAccountStatus';
      case _i34.UserLabel():
        return 'UserLabel';
      case _i35.UserLabelMapping():
        return 'UserLabelMapping';
      case _i36.UserAccountRegistrationDeniedException():
        return 'UserAccountRegistrationDeniedException';
      case _i37.AcceptedTerms():
        return 'AcceptedTerms';
      case _i38.AcceptedTermsDTO():
        return 'AcceptedTermsDTO';
      case _i39.AuthTokenInfo():
        return 'AuthTokenInfo';
      case _i40.RequiredTerms():
        return 'RequiredTerms';
      case _i41.Terms():
        return 'Terms';
      case _i42.ComputeInfo():
        return 'ComputeInfo';
      case _i43.DNSVerificationFailedException():
        return 'DNSVerificationFailedException';
      case _i44.CustomDomainName():
        return 'CustomDomainName';
      case _i45.CustomDomainNameList():
        return 'CustomDomainNameList';
      case _i46.DnsRecordType():
        return 'DnsRecordType';
      case _i47.DomainNameStatus():
        return 'DomainNameStatus';
      case _i48.DomainNameTarget():
        return 'DomainNameTarget';
      case _i49.NewCustomDomainNamesEvent():
        return 'NewCustomDomainNamesEvent';
      case _i50.CustomDomainNameWithDefaultDomains():
        return 'CustomDomainNameWithDefaultDomains';
      case _i51.DatabaseConnection():
        return 'DatabaseConnection';
      case _i52.DatabaseInfo():
        return 'DatabaseInfo';
      case _i53.DatabaseProvider():
        return 'DatabaseProvider';
      case _i54.DatabaseQuota():
        return 'DatabaseQuota';
      case _i55.DatabaseResource():
        return 'DatabaseResource';
      case _i56.DatabaseScaling():
        return 'DatabaseScaling';
      case _i57.DatabaseSizeOption():
        return 'DatabaseSizeOption';
      case _i58.InsightsConnectionDetail():
        return 'InsightsConnectionDetail';
      case _i59.ProjectConfig():
        return 'ProjectConfig';
      case _i60.ProjectDeleteCallEvent():
        return 'ProjectDeleteCallEvent';
      case _i61.ProjectInfo():
        return 'ProjectInfo';
      case _i62.Timestamp():
        return 'Timestamp';
      case _i63.DuplicateEntryException():
        return 'DuplicateEntryException';
      case _i64.InvalidValueException():
        return 'InvalidValueException';
      case _i65.NoSubscriptionException():
        return 'NoSubscriptionException';
      case _i66.NotFoundException():
        return 'NotFoundException';
      case _i67.ProcurementCancellationException():
        return 'ProcurementCancellationException';
      case _i68.ProcurementDeniedException():
        return 'ProcurementDeniedException';
      case _i69.UnauthenticatedException():
        return 'UnauthenticatedException';
      case _i70.UnauthorizedException():
        return 'UnauthorizedException';
      case _i71.ServerpodRegion():
        return 'ServerpodRegion';
      case _i72.PubsubEntry():
        return 'PubsubEntry';
    }
    className = _i84.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i85.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'BillingCustomerType') {
      return deserialize<_i2.BillingCustomerType>(data['data']);
    }
    if (dataClassName == 'BillingInfo') {
      return deserialize<_i3.BillingInfo>(data['data']);
    }
    if (dataClassName == 'BillingMappingType') {
      return deserialize<_i4.BillingMappingType>(data['data']);
    }
    if (dataClassName == 'Owner') {
      return deserialize<_i5.Owner>(data['data']);
    }
    if (dataClassName == 'PaymentMethod') {
      return deserialize<_i6.PaymentMethod>(data['data']);
    }
    if (dataClassName == 'PaymentMethodCard') {
      return deserialize<_i7.PaymentMethodCard>(data['data']);
    }
    if (dataClassName == 'PaymentSetupIntent') {
      return deserialize<_i8.PaymentSetupIntent>(data['data']);
    }
    if (dataClassName == 'Capsule') {
      return deserialize<_i9.Capsule>(data['data']);
    }
    if (dataClassName == 'CapsuleResource') {
      return deserialize<_i10.CapsuleResource>(data['data']);
    }
    if (dataClassName == 'ComputeSizeOption') {
      return deserialize<_i11.ComputeSizeOption>(data['data']);
    }
    if (dataClassName == 'EnvironmentVariable') {
      return deserialize<_i12.EnvironmentVariable>(data['data']);
    }
    if (dataClassName == 'LogRecord') {
      return deserialize<_i13.LogRecord>(data['data']);
    }
    if (dataClassName == 'ComputeProductInfo') {
      return deserialize<_i14.ComputeProductInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseProductInfo') {
      return deserialize<_i15.DatabaseProductInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseScalingInfo') {
      return deserialize<_i16.DatabaseScalingInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseSizeInfo') {
      return deserialize<_i17.DatabaseSizeInfo>(data['data']);
    }
    if (dataClassName == 'PlanInfo') {
      return deserialize<_i18.PlanInfo>(data['data']);
    }
    if (dataClassName == 'ProductType') {
      return deserialize<_i19.ProductType>(data['data']);
    }
    if (dataClassName == 'ProjectProductInfo') {
      return deserialize<_i20.ProjectProductInfo>(data['data']);
    }
    if (dataClassName == 'SubscriptionInfo') {
      return deserialize<_i21.SubscriptionInfo>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i22.Project>(data['data']);
    }
    if (dataClassName == 'Role') {
      return deserialize<_i23.Role>(data['data']);
    }
    if (dataClassName == 'UserRoleMembership') {
      return deserialize<_i24.UserRoleMembership>(data['data']);
    }
    if (dataClassName == 'SecretResource') {
      return deserialize<_i25.SecretResource>(data['data']);
    }
    if (dataClassName == 'SecretType') {
      return deserialize<_i26.SecretType>(data['data']);
    }
    if (dataClassName == 'DeployAttempt') {
      return deserialize<_i27.DeployAttempt>(data['data']);
    }
    if (dataClassName == 'DeployAttemptStage') {
      return deserialize<_i28.DeployAttemptStage>(data['data']);
    }
    if (dataClassName == 'DeployProgressStatus') {
      return deserialize<_i29.DeployProgressStatus>(data['data']);
    }
    if (dataClassName == 'DeployStageType') {
      return deserialize<_i30.DeployStageType>(data['data']);
    }
    if (dataClassName == 'AccountAuthorization') {
      return deserialize<_i31.AccountAuthorization>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i32.User>(data['data']);
    }
    if (dataClassName == 'UserAccountStatus') {
      return deserialize<_i33.UserAccountStatus>(data['data']);
    }
    if (dataClassName == 'UserLabel') {
      return deserialize<_i34.UserLabel>(data['data']);
    }
    if (dataClassName == 'UserLabelMapping') {
      return deserialize<_i35.UserLabelMapping>(data['data']);
    }
    if (dataClassName == 'UserAccountRegistrationDeniedException') {
      return deserialize<_i36.UserAccountRegistrationDeniedException>(
        data['data'],
      );
    }
    if (dataClassName == 'AcceptedTerms') {
      return deserialize<_i37.AcceptedTerms>(data['data']);
    }
    if (dataClassName == 'AcceptedTermsDTO') {
      return deserialize<_i38.AcceptedTermsDTO>(data['data']);
    }
    if (dataClassName == 'AuthTokenInfo') {
      return deserialize<_i39.AuthTokenInfo>(data['data']);
    }
    if (dataClassName == 'RequiredTerms') {
      return deserialize<_i40.RequiredTerms>(data['data']);
    }
    if (dataClassName == 'Terms') {
      return deserialize<_i41.Terms>(data['data']);
    }
    if (dataClassName == 'ComputeInfo') {
      return deserialize<_i42.ComputeInfo>(data['data']);
    }
    if (dataClassName == 'DNSVerificationFailedException') {
      return deserialize<_i43.DNSVerificationFailedException>(data['data']);
    }
    if (dataClassName == 'CustomDomainName') {
      return deserialize<_i44.CustomDomainName>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameList') {
      return deserialize<_i45.CustomDomainNameList>(data['data']);
    }
    if (dataClassName == 'DnsRecordType') {
      return deserialize<_i46.DnsRecordType>(data['data']);
    }
    if (dataClassName == 'DomainNameStatus') {
      return deserialize<_i47.DomainNameStatus>(data['data']);
    }
    if (dataClassName == 'DomainNameTarget') {
      return deserialize<_i48.DomainNameTarget>(data['data']);
    }
    if (dataClassName == 'NewCustomDomainNamesEvent') {
      return deserialize<_i49.NewCustomDomainNamesEvent>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameWithDefaultDomains') {
      return deserialize<_i50.CustomDomainNameWithDefaultDomains>(data['data']);
    }
    if (dataClassName == 'DatabaseConnection') {
      return deserialize<_i51.DatabaseConnection>(data['data']);
    }
    if (dataClassName == 'DatabaseInfo') {
      return deserialize<_i52.DatabaseInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseProvider') {
      return deserialize<_i53.DatabaseProvider>(data['data']);
    }
    if (dataClassName == 'DatabaseQuota') {
      return deserialize<_i54.DatabaseQuota>(data['data']);
    }
    if (dataClassName == 'DatabaseResource') {
      return deserialize<_i55.DatabaseResource>(data['data']);
    }
    if (dataClassName == 'DatabaseScaling') {
      return deserialize<_i56.DatabaseScaling>(data['data']);
    }
    if (dataClassName == 'DatabaseSizeOption') {
      return deserialize<_i57.DatabaseSizeOption>(data['data']);
    }
    if (dataClassName == 'InsightsConnectionDetail') {
      return deserialize<_i58.InsightsConnectionDetail>(data['data']);
    }
    if (dataClassName == 'ProjectConfig') {
      return deserialize<_i59.ProjectConfig>(data['data']);
    }
    if (dataClassName == 'ProjectDeleteCallEvent') {
      return deserialize<_i60.ProjectDeleteCallEvent>(data['data']);
    }
    if (dataClassName == 'ProjectInfo') {
      return deserialize<_i61.ProjectInfo>(data['data']);
    }
    if (dataClassName == 'Timestamp') {
      return deserialize<_i62.Timestamp>(data['data']);
    }
    if (dataClassName == 'DuplicateEntryException') {
      return deserialize<_i63.DuplicateEntryException>(data['data']);
    }
    if (dataClassName == 'InvalidValueException') {
      return deserialize<_i64.InvalidValueException>(data['data']);
    }
    if (dataClassName == 'NoSubscriptionException') {
      return deserialize<_i65.NoSubscriptionException>(data['data']);
    }
    if (dataClassName == 'NotFoundException') {
      return deserialize<_i66.NotFoundException>(data['data']);
    }
    if (dataClassName == 'ProcurementCancellationException') {
      return deserialize<_i67.ProcurementCancellationException>(data['data']);
    }
    if (dataClassName == 'ProcurementDeniedException') {
      return deserialize<_i68.ProcurementDeniedException>(data['data']);
    }
    if (dataClassName == 'UnauthenticatedException') {
      return deserialize<_i69.UnauthenticatedException>(data['data']);
    }
    if (dataClassName == 'UnauthorizedException') {
      return deserialize<_i70.UnauthorizedException>(data['data']);
    }
    if (dataClassName == 'ServerpodRegion') {
      return deserialize<_i71.ServerpodRegion>(data['data']);
    }
    if (dataClassName == 'PubsubEntry') {
      return deserialize<_i72.PubsubEntry>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i84.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i85.Protocol().deserializeByClassName(data);
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
      "p": [record.$1, record.$2],
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
          {'k': mapIfNeeded(entry.key), 'v': mapIfNeeded(entry.value)},
      ];

    case Iterable():
      return [for (var e in obj) mapIfNeeded(e)];
  }

  return obj;
}

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
import 'domains/buckets/models/bucket_file.dart' as _i9;
import 'domains/buckets/models/bucket_file_listing.dart' as _i10;
import 'domains/buckets/models/bucket_provider.dart' as _i11;
import 'domains/buckets/models/bucket_resource.dart' as _i12;
import 'domains/buckets/models/bucket_service_account.dart' as _i13;
import 'domains/buckets/models/bucket_service_account_status.dart' as _i14;
import 'domains/buckets/models/bucket_status.dart' as _i15;
import 'domains/buckets/models/bucket_visibility.dart' as _i16;
import 'domains/capsules/models/capsule.dart' as _i17;
import 'domains/capsules/models/capsule_resource_config.dart' as _i18;
import 'domains/capsules/models/compute_size_option.dart' as _i19;
import 'domains/databases/exceptions/database_snapshot_limit_exception.dart'
    as _i20;
import 'domains/databases/models/backup_frequency.dart' as _i21;
import 'domains/databases/models/backup_schedule.dart' as _i22;
import 'domains/databases/models/database_connection.dart' as _i23;
import 'domains/databases/models/database_info.dart' as _i24;
import 'domains/databases/models/database_provider.dart' as _i25;
import 'domains/databases/models/database_quota.dart' as _i26;
import 'domains/databases/models/database_resource.dart' as _i27;
import 'domains/databases/models/database_scaling.dart' as _i28;
import 'domains/databases/models/database_size.dart' as _i29;
import 'domains/databases/models/database_snapshot.dart' as _i30;
import 'domains/databases/models/database_user.dart' as _i31;
import 'domains/environment_variables/models/variable.dart' as _i32;
import 'domains/logs/models/log_record.dart' as _i33;
import 'domains/metrics/models/metrics_range.dart' as _i34;
import 'domains/metrics/models/pod_metric_sample.dart' as _i35;
import 'domains/metrics/models/pod_resource_series.dart' as _i36;
import 'domains/products/models/compute_catalog_info.dart' as _i37;
import 'domains/products/models/compute_product_info.dart' as _i38;
import 'domains/products/models/compute_scaling_info.dart' as _i39;
import 'domains/products/models/database_catalog_info.dart' as _i40;
import 'domains/products/models/database_product_info.dart' as _i41;
import 'domains/products/models/database_scaling_info.dart' as _i42;
import 'domains/products/models/plan_info.dart' as _i43;
import 'domains/products/models/plan_type.dart' as _i44;
import 'domains/products/models/product_type.dart' as _i45;
import 'domains/products/models/project_product_info.dart' as _i46;
import 'domains/products/models/subscription_info.dart' as _i47;
import 'domains/projects/models/project.dart' as _i48;
import 'domains/projects/models/role.dart' as _i49;
import 'domains/projects/models/user_role_membership.dart' as _i50;
import 'domains/secrets/models/build_secret_type.dart' as _i51;
import 'domains/secrets/models/secret_resource.dart' as _i52;
import 'domains/secrets/models/secret_type.dart' as _i53;
import 'domains/secrets/models/stored_secret_version.dart' as _i54;
import 'domains/status/models/capsule_deployment_status.dart' as _i55;
import 'domains/status/models/capsule_revision.dart' as _i56;
import 'domains/status/models/capsule_state.dart' as _i57;
import 'domains/status/models/capsule_status.dart' as _i58;
import 'domains/status/models/deploy_attempt.dart' as _i59;
import 'domains/status/models/deploy_attempt_stage.dart' as _i60;
import 'domains/status/models/deploy_progress_status.dart' as _i61;
import 'domains/status/models/deploy_stage_type.dart' as _i62;
import 'domains/users/models/user.dart' as _i63;
import 'domains/users/models/user_account_status.dart' as _i64;
import 'domains/users/models/user_label.dart' as _i65;
import 'domains/users/models/user_label_mapping.dart' as _i66;
import 'features/auth/exceptions/email_method_blocked_exception.dart' as _i67;
import 'features/auth/exceptions/user_account_registration_denied_exception.dart'
    as _i68;
import 'features/auth/models/accepted_terms.dart' as _i69;
import 'features/auth/models/accepted_terms_dto.dart' as _i70;
import 'features/auth/models/auth_token_info.dart' as _i71;
import 'features/auth/models/required_terms.dart' as _i72;
import 'features/auth/models/terms.dart' as _i73;
import 'features/capsules/models/compute_info.dart' as _i74;
import 'features/custom_domains/exceptions/dns_verification_failed_exception.dart'
    as _i75;
import 'features/custom_domains/models/custom_domain_name.dart' as _i76;
import 'features/custom_domains/models/custom_domain_name_list.dart' as _i77;
import 'features/custom_domains/models/dns_record_type.dart' as _i78;
import 'features/custom_domains/models/domain_name_status.dart' as _i79;
import 'features/custom_domains/models/domain_name_target.dart' as _i80;
import 'features/custom_domains/models/view_models/custom_domain_name_with_default_domains.dart'
    as _i81;
import 'features/insights/models/insights_connection_detail.dart' as _i82;
import 'features/projects/models/project_config.dart' as _i83;
import 'features/projects/models/project_info/project_info.dart' as _i84;
import 'features/projects/models/project_info/timestamp.dart' as _i85;
import 'features/projects/models/project_profile_update.dart' as _i86;
import 'features/status/exceptions/capsule_status_unavailable_exception.dart'
    as _i87;
import 'shared/exceptions/models/dart_sdk_unsupported_constraint_exception.dart'
    as _i88;
import 'shared/exceptions/models/duplicate_entry_exception.dart' as _i89;
import 'shared/exceptions/models/invalid_value_exception.dart' as _i90;
import 'shared/exceptions/models/no_customer_billing_type_exception.dart'
    as _i91;
import 'shared/exceptions/models/no_subscription_exception.dart' as _i92;
import 'shared/exceptions/models/not_found_exception.dart' as _i93;
import 'shared/exceptions/models/procurement_cancellation_exception.dart'
    as _i94;
import 'shared/exceptions/models/procurement_denied_exception.dart' as _i95;
import 'shared/exceptions/models/procurement_denied_reason.dart' as _i96;
import 'shared/exceptions/models/unauthenticated_exception.dart' as _i97;
import 'shared/exceptions/models/unauthorized_exception.dart' as _i98;
import 'shared/models/serverpod_region.dart' as _i99;
import 'shared/services/pubsub/registry/pubsub_entry.dart' as _i100;
import 'package:ground_control_client/src/protocol/domains/projects/models/project.dart'
    as _i101;
import 'package:ground_control_client/src/protocol/features/projects/models/project_info/project_info.dart'
    as _i102;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i103;
import 'package:ground_control_client/src/protocol/domains/users/models/user.dart'
    as _i104;
import 'package:ground_control_client/src/protocol/features/auth/models/required_terms.dart'
    as _i105;
import 'package:ground_control_client/src/protocol/features/auth/models/accepted_terms_dto.dart'
    as _i106;
import 'package:ground_control_client/src/protocol/features/auth/models/auth_token_info.dart'
    as _i107;
import 'package:ground_control_client/src/protocol/domains/billing/models/payment_method.dart'
    as _i108;
import 'package:ground_control_client/src/protocol/domains/databases/models/database_user.dart'
    as _i109;
import 'package:ground_control_client/src/protocol/domains/databases/models/database_snapshot.dart'
    as _i110;
import 'package:ground_control_client/src/protocol/domains/environment_variables/models/variable.dart'
    as _i111;
import 'package:ground_control_client/src/protocol/domains/metrics/models/pod_resource_series.dart'
    as _i112;
import 'package:ground_control_client/src/protocol/domains/products/models/subscription_info.dart'
    as _i113;
import 'package:ground_control_client/src/protocol/domains/products/models/plan_info.dart'
    as _i114;
import 'package:ground_control_client/src/protocol/domains/projects/models/role.dart'
    as _i115;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _i116;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i117;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i118;
export 'domains/billing/models/billing_customer_type.dart';
export 'domains/billing/models/billing_info.dart';
export 'domains/billing/models/billing_mapping_type.dart';
export 'domains/billing/models/owner.dart';
export 'domains/billing/models/payment_method.dart';
export 'domains/billing/models/payment_method_card.dart';
export 'domains/billing/models/payment_setup_intent.dart';
export 'domains/buckets/models/bucket_file.dart';
export 'domains/buckets/models/bucket_file_listing.dart';
export 'domains/buckets/models/bucket_provider.dart';
export 'domains/buckets/models/bucket_resource.dart';
export 'domains/buckets/models/bucket_service_account.dart';
export 'domains/buckets/models/bucket_service_account_status.dart';
export 'domains/buckets/models/bucket_status.dart';
export 'domains/buckets/models/bucket_visibility.dart';
export 'domains/capsules/models/capsule.dart';
export 'domains/capsules/models/capsule_resource_config.dart';
export 'domains/capsules/models/compute_size_option.dart';
export 'domains/databases/exceptions/database_snapshot_limit_exception.dart';
export 'domains/databases/models/backup_frequency.dart';
export 'domains/databases/models/backup_schedule.dart';
export 'domains/databases/models/database_connection.dart';
export 'domains/databases/models/database_info.dart';
export 'domains/databases/models/database_provider.dart';
export 'domains/databases/models/database_quota.dart';
export 'domains/databases/models/database_resource.dart';
export 'domains/databases/models/database_scaling.dart';
export 'domains/databases/models/database_size.dart';
export 'domains/databases/models/database_snapshot.dart';
export 'domains/databases/models/database_user.dart';
export 'domains/environment_variables/models/variable.dart';
export 'domains/logs/models/log_record.dart';
export 'domains/metrics/models/metrics_range.dart';
export 'domains/metrics/models/pod_metric_sample.dart';
export 'domains/metrics/models/pod_resource_series.dart';
export 'domains/products/models/compute_catalog_info.dart';
export 'domains/products/models/compute_product_info.dart';
export 'domains/products/models/compute_scaling_info.dart';
export 'domains/products/models/database_catalog_info.dart';
export 'domains/products/models/database_product_info.dart';
export 'domains/products/models/database_scaling_info.dart';
export 'domains/products/models/plan_info.dart';
export 'domains/products/models/plan_type.dart';
export 'domains/products/models/product_type.dart';
export 'domains/products/models/project_product_info.dart';
export 'domains/products/models/subscription_info.dart';
export 'domains/projects/models/project.dart';
export 'domains/projects/models/role.dart';
export 'domains/projects/models/user_role_membership.dart';
export 'domains/secrets/models/build_secret_type.dart';
export 'domains/secrets/models/secret_resource.dart';
export 'domains/secrets/models/secret_type.dart';
export 'domains/secrets/models/stored_secret_version.dart';
export 'domains/status/models/capsule_deployment_status.dart';
export 'domains/status/models/capsule_revision.dart';
export 'domains/status/models/capsule_state.dart';
export 'domains/status/models/capsule_status.dart';
export 'domains/status/models/deploy_attempt.dart';
export 'domains/status/models/deploy_attempt_stage.dart';
export 'domains/status/models/deploy_progress_status.dart';
export 'domains/status/models/deploy_stage_type.dart';
export 'domains/users/models/user.dart';
export 'domains/users/models/user_account_status.dart';
export 'domains/users/models/user_label.dart';
export 'domains/users/models/user_label_mapping.dart';
export 'features/auth/exceptions/email_method_blocked_exception.dart';
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
export 'features/custom_domains/models/view_models/custom_domain_name_with_default_domains.dart';
export 'features/insights/models/insights_connection_detail.dart';
export 'features/projects/models/project_config.dart';
export 'features/projects/models/project_info/project_info.dart';
export 'features/projects/models/project_info/timestamp.dart';
export 'features/projects/models/project_profile_update.dart';
export 'features/status/exceptions/capsule_status_unavailable_exception.dart';
export 'shared/exceptions/models/dart_sdk_unsupported_constraint_exception.dart';
export 'shared/exceptions/models/duplicate_entry_exception.dart';
export 'shared/exceptions/models/invalid_value_exception.dart';
export 'shared/exceptions/models/no_customer_billing_type_exception.dart';
export 'shared/exceptions/models/no_subscription_exception.dart';
export 'shared/exceptions/models/not_found_exception.dart';
export 'shared/exceptions/models/procurement_cancellation_exception.dart';
export 'shared/exceptions/models/procurement_denied_exception.dart';
export 'shared/exceptions/models/procurement_denied_reason.dart';
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
    if (t == _i9.BucketFile) {
      return _i9.BucketFile.fromJson(data) as T;
    }
    if (t == _i10.BucketFileListing) {
      return _i10.BucketFileListing.fromJson(data) as T;
    }
    if (t == _i11.BucketProvider) {
      return _i11.BucketProvider.fromJson(data) as T;
    }
    if (t == _i12.BucketResource) {
      return _i12.BucketResource.fromJson(data) as T;
    }
    if (t == _i13.BucketServiceAccount) {
      return _i13.BucketServiceAccount.fromJson(data) as T;
    }
    if (t == _i14.BucketServiceAccountStatus) {
      return _i14.BucketServiceAccountStatus.fromJson(data) as T;
    }
    if (t == _i15.BucketStatus) {
      return _i15.BucketStatus.fromJson(data) as T;
    }
    if (t == _i16.BucketVisibility) {
      return _i16.BucketVisibility.fromJson(data) as T;
    }
    if (t == _i17.Capsule) {
      return _i17.Capsule.fromJson(data) as T;
    }
    if (t == _i18.CapsuleResource) {
      return _i18.CapsuleResource.fromJson(data) as T;
    }
    if (t == _i19.ComputeSizeOption) {
      return _i19.ComputeSizeOption.fromJson(data) as T;
    }
    if (t == _i20.DatabaseSnapshotLimitException) {
      return _i20.DatabaseSnapshotLimitException.fromJson(data) as T;
    }
    if (t == _i21.BackupFrequency) {
      return _i21.BackupFrequency.fromJson(data) as T;
    }
    if (t == _i22.BackupSchedule) {
      return _i22.BackupSchedule.fromJson(data) as T;
    }
    if (t == _i23.DatabaseConnection) {
      return _i23.DatabaseConnection.fromJson(data) as T;
    }
    if (t == _i24.DatabaseInfo) {
      return _i24.DatabaseInfo.fromJson(data) as T;
    }
    if (t == _i25.DatabaseProvider) {
      return _i25.DatabaseProvider.fromJson(data) as T;
    }
    if (t == _i26.DatabaseQuota) {
      return _i26.DatabaseQuota.fromJson(data) as T;
    }
    if (t == _i27.DatabaseResource) {
      return _i27.DatabaseResource.fromJson(data) as T;
    }
    if (t == _i28.DatabaseScaling) {
      return _i28.DatabaseScaling.fromJson(data) as T;
    }
    if (t == _i29.DatabaseSizeOption) {
      return _i29.DatabaseSizeOption.fromJson(data) as T;
    }
    if (t == _i30.DatabaseSnapshot) {
      return _i30.DatabaseSnapshot.fromJson(data) as T;
    }
    if (t == _i31.DatabaseUser) {
      return _i31.DatabaseUser.fromJson(data) as T;
    }
    if (t == _i32.EnvironmentVariable) {
      return _i32.EnvironmentVariable.fromJson(data) as T;
    }
    if (t == _i33.LogRecord) {
      return _i33.LogRecord.fromJson(data) as T;
    }
    if (t == _i34.MetricsRange) {
      return _i34.MetricsRange.fromJson(data) as T;
    }
    if (t == _i35.PodMetricSample) {
      return _i35.PodMetricSample.fromJson(data) as T;
    }
    if (t == _i36.PodResourceSeries) {
      return _i36.PodResourceSeries.fromJson(data) as T;
    }
    if (t == _i37.ComputeCatalogInfo) {
      return _i37.ComputeCatalogInfo.fromJson(data) as T;
    }
    if (t == _i38.ComputeProductInfo) {
      return _i38.ComputeProductInfo.fromJson(data) as T;
    }
    if (t == _i39.ComputeScalingInfo) {
      return _i39.ComputeScalingInfo.fromJson(data) as T;
    }
    if (t == _i40.DatabaseCatalogInfo) {
      return _i40.DatabaseCatalogInfo.fromJson(data) as T;
    }
    if (t == _i41.DatabaseProductInfo) {
      return _i41.DatabaseProductInfo.fromJson(data) as T;
    }
    if (t == _i42.DatabaseScalingInfo) {
      return _i42.DatabaseScalingInfo.fromJson(data) as T;
    }
    if (t == _i43.PlanInfo) {
      return _i43.PlanInfo.fromJson(data) as T;
    }
    if (t == _i44.PlanType) {
      return _i44.PlanType.fromJson(data) as T;
    }
    if (t == _i45.ProductType) {
      return _i45.ProductType.fromJson(data) as T;
    }
    if (t == _i46.ProjectProductInfo) {
      return _i46.ProjectProductInfo.fromJson(data) as T;
    }
    if (t == _i47.SubscriptionInfo) {
      return _i47.SubscriptionInfo.fromJson(data) as T;
    }
    if (t == _i48.Project) {
      return _i48.Project.fromJson(data) as T;
    }
    if (t == _i49.Role) {
      return _i49.Role.fromJson(data) as T;
    }
    if (t == _i50.UserRoleMembership) {
      return _i50.UserRoleMembership.fromJson(data) as T;
    }
    if (t == _i51.BuildSecretType) {
      return _i51.BuildSecretType.fromJson(data) as T;
    }
    if (t == _i52.SecretResource) {
      return _i52.SecretResource.fromJson(data) as T;
    }
    if (t == _i53.SecretType) {
      return _i53.SecretType.fromJson(data) as T;
    }
    if (t == _i54.StoredSecretVersion) {
      return _i54.StoredSecretVersion.fromJson(data) as T;
    }
    if (t == _i55.CapsuleDeploymentStatus) {
      return _i55.CapsuleDeploymentStatus.fromJson(data) as T;
    }
    if (t == _i56.CapsuleRevision) {
      return _i56.CapsuleRevision.fromJson(data) as T;
    }
    if (t == _i57.CapsuleState) {
      return _i57.CapsuleState.fromJson(data) as T;
    }
    if (t == _i58.CapsuleStatus) {
      return _i58.CapsuleStatus.fromJson(data) as T;
    }
    if (t == _i59.DeployAttempt) {
      return _i59.DeployAttempt.fromJson(data) as T;
    }
    if (t == _i60.DeployAttemptStage) {
      return _i60.DeployAttemptStage.fromJson(data) as T;
    }
    if (t == _i61.DeployProgressStatus) {
      return _i61.DeployProgressStatus.fromJson(data) as T;
    }
    if (t == _i62.DeployStageType) {
      return _i62.DeployStageType.fromJson(data) as T;
    }
    if (t == _i63.User) {
      return _i63.User.fromJson(data) as T;
    }
    if (t == _i64.UserAccountStatus) {
      return _i64.UserAccountStatus.fromJson(data) as T;
    }
    if (t == _i65.UserLabel) {
      return _i65.UserLabel.fromJson(data) as T;
    }
    if (t == _i66.UserLabelMapping) {
      return _i66.UserLabelMapping.fromJson(data) as T;
    }
    if (t == _i67.EmailMethodBlockedException) {
      return _i67.EmailMethodBlockedException.fromJson(data) as T;
    }
    if (t == _i68.UserAccountRegistrationDeniedException) {
      return _i68.UserAccountRegistrationDeniedException.fromJson(data) as T;
    }
    if (t == _i69.AcceptedTerms) {
      return _i69.AcceptedTerms.fromJson(data) as T;
    }
    if (t == _i70.AcceptedTermsDTO) {
      return _i70.AcceptedTermsDTO.fromJson(data) as T;
    }
    if (t == _i71.AuthTokenInfo) {
      return _i71.AuthTokenInfo.fromJson(data) as T;
    }
    if (t == _i72.RequiredTerms) {
      return _i72.RequiredTerms.fromJson(data) as T;
    }
    if (t == _i73.Terms) {
      return _i73.Terms.fromJson(data) as T;
    }
    if (t == _i74.ComputeInfo) {
      return _i74.ComputeInfo.fromJson(data) as T;
    }
    if (t == _i75.DNSVerificationFailedException) {
      return _i75.DNSVerificationFailedException.fromJson(data) as T;
    }
    if (t == _i76.CustomDomainName) {
      return _i76.CustomDomainName.fromJson(data) as T;
    }
    if (t == _i77.CustomDomainNameList) {
      return _i77.CustomDomainNameList.fromJson(data) as T;
    }
    if (t == _i78.DnsRecordType) {
      return _i78.DnsRecordType.fromJson(data) as T;
    }
    if (t == _i79.DomainNameStatus) {
      return _i79.DomainNameStatus.fromJson(data) as T;
    }
    if (t == _i80.DomainNameTarget) {
      return _i80.DomainNameTarget.fromJson(data) as T;
    }
    if (t == _i81.CustomDomainNameWithDefaultDomains) {
      return _i81.CustomDomainNameWithDefaultDomains.fromJson(data) as T;
    }
    if (t == _i82.InsightsConnectionDetail) {
      return _i82.InsightsConnectionDetail.fromJson(data) as T;
    }
    if (t == _i83.ProjectConfig) {
      return _i83.ProjectConfig.fromJson(data) as T;
    }
    if (t == _i84.ProjectInfo) {
      return _i84.ProjectInfo.fromJson(data) as T;
    }
    if (t == _i85.Timestamp) {
      return _i85.Timestamp.fromJson(data) as T;
    }
    if (t == _i86.ProjectProfileUpdate) {
      return _i86.ProjectProfileUpdate.fromJson(data) as T;
    }
    if (t == _i87.CapsuleStatusUnavailableException) {
      return _i87.CapsuleStatusUnavailableException.fromJson(data) as T;
    }
    if (t == _i88.DartSdkUnsupportedConstraintException) {
      return _i88.DartSdkUnsupportedConstraintException.fromJson(data) as T;
    }
    if (t == _i89.DuplicateEntryException) {
      return _i89.DuplicateEntryException.fromJson(data) as T;
    }
    if (t == _i90.InvalidValueException) {
      return _i90.InvalidValueException.fromJson(data) as T;
    }
    if (t == _i91.NoCustomerBillingTypeException) {
      return _i91.NoCustomerBillingTypeException.fromJson(data) as T;
    }
    if (t == _i92.NoSubscriptionException) {
      return _i92.NoSubscriptionException.fromJson(data) as T;
    }
    if (t == _i93.NotFoundException) {
      return _i93.NotFoundException.fromJson(data) as T;
    }
    if (t == _i94.ProcurementCancellationException) {
      return _i94.ProcurementCancellationException.fromJson(data) as T;
    }
    if (t == _i95.ProcurementDeniedException) {
      return _i95.ProcurementDeniedException.fromJson(data) as T;
    }
    if (t == _i96.ProcurementDeniedReason) {
      return _i96.ProcurementDeniedReason.fromJson(data) as T;
    }
    if (t == _i97.UnauthenticatedException) {
      return _i97.UnauthenticatedException.fromJson(data) as T;
    }
    if (t == _i98.UnauthorizedException) {
      return _i98.UnauthorizedException.fromJson(data) as T;
    }
    if (t == _i99.ServerpodRegion) {
      return _i99.ServerpodRegion.fromJson(data) as T;
    }
    if (t == _i100.PubsubEntry) {
      return _i100.PubsubEntry.fromJson(data) as T;
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
    if (t == _i1.getType<_i9.BucketFile?>()) {
      return (data != null ? _i9.BucketFile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.BucketFileListing?>()) {
      return (data != null ? _i10.BucketFileListing.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.BucketProvider?>()) {
      return (data != null ? _i11.BucketProvider.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.BucketResource?>()) {
      return (data != null ? _i12.BucketResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.BucketServiceAccount?>()) {
      return (data != null ? _i13.BucketServiceAccount.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.BucketServiceAccountStatus?>()) {
      return (data != null
              ? _i14.BucketServiceAccountStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i15.BucketStatus?>()) {
      return (data != null ? _i15.BucketStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.BucketVisibility?>()) {
      return (data != null ? _i16.BucketVisibility.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.Capsule?>()) {
      return (data != null ? _i17.Capsule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.CapsuleResource?>()) {
      return (data != null ? _i18.CapsuleResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.ComputeSizeOption?>()) {
      return (data != null ? _i19.ComputeSizeOption.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.DatabaseSnapshotLimitException?>()) {
      return (data != null
              ? _i20.DatabaseSnapshotLimitException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i21.BackupFrequency?>()) {
      return (data != null ? _i21.BackupFrequency.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.BackupSchedule?>()) {
      return (data != null ? _i22.BackupSchedule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.DatabaseConnection?>()) {
      return (data != null ? _i23.DatabaseConnection.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i24.DatabaseInfo?>()) {
      return (data != null ? _i24.DatabaseInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.DatabaseProvider?>()) {
      return (data != null ? _i25.DatabaseProvider.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.DatabaseQuota?>()) {
      return (data != null ? _i26.DatabaseQuota.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.DatabaseResource?>()) {
      return (data != null ? _i27.DatabaseResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.DatabaseScaling?>()) {
      return (data != null ? _i28.DatabaseScaling.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.DatabaseSizeOption?>()) {
      return (data != null ? _i29.DatabaseSizeOption.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i30.DatabaseSnapshot?>()) {
      return (data != null ? _i30.DatabaseSnapshot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.DatabaseUser?>()) {
      return (data != null ? _i31.DatabaseUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.EnvironmentVariable?>()) {
      return (data != null ? _i32.EnvironmentVariable.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i33.LogRecord?>()) {
      return (data != null ? _i33.LogRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.MetricsRange?>()) {
      return (data != null ? _i34.MetricsRange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.PodMetricSample?>()) {
      return (data != null ? _i35.PodMetricSample.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.PodResourceSeries?>()) {
      return (data != null ? _i36.PodResourceSeries.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.ComputeCatalogInfo?>()) {
      return (data != null ? _i37.ComputeCatalogInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i38.ComputeProductInfo?>()) {
      return (data != null ? _i38.ComputeProductInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i39.ComputeScalingInfo?>()) {
      return (data != null ? _i39.ComputeScalingInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i40.DatabaseCatalogInfo?>()) {
      return (data != null ? _i40.DatabaseCatalogInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i41.DatabaseProductInfo?>()) {
      return (data != null ? _i41.DatabaseProductInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i42.DatabaseScalingInfo?>()) {
      return (data != null ? _i42.DatabaseScalingInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i43.PlanInfo?>()) {
      return (data != null ? _i43.PlanInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.PlanType?>()) {
      return (data != null ? _i44.PlanType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.ProductType?>()) {
      return (data != null ? _i45.ProductType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.ProjectProductInfo?>()) {
      return (data != null ? _i46.ProjectProductInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i47.SubscriptionInfo?>()) {
      return (data != null ? _i47.SubscriptionInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i48.Project?>()) {
      return (data != null ? _i48.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i49.Role?>()) {
      return (data != null ? _i49.Role.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i50.UserRoleMembership?>()) {
      return (data != null ? _i50.UserRoleMembership.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i51.BuildSecretType?>()) {
      return (data != null ? _i51.BuildSecretType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i52.SecretResource?>()) {
      return (data != null ? _i52.SecretResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i53.SecretType?>()) {
      return (data != null ? _i53.SecretType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i54.StoredSecretVersion?>()) {
      return (data != null ? _i54.StoredSecretVersion.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i55.CapsuleDeploymentStatus?>()) {
      return (data != null ? _i55.CapsuleDeploymentStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i56.CapsuleRevision?>()) {
      return (data != null ? _i56.CapsuleRevision.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i57.CapsuleState?>()) {
      return (data != null ? _i57.CapsuleState.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i58.CapsuleStatus?>()) {
      return (data != null ? _i58.CapsuleStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i59.DeployAttempt?>()) {
      return (data != null ? _i59.DeployAttempt.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i60.DeployAttemptStage?>()) {
      return (data != null ? _i60.DeployAttemptStage.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i61.DeployProgressStatus?>()) {
      return (data != null ? _i61.DeployProgressStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i62.DeployStageType?>()) {
      return (data != null ? _i62.DeployStageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i63.User?>()) {
      return (data != null ? _i63.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i64.UserAccountStatus?>()) {
      return (data != null ? _i64.UserAccountStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i65.UserLabel?>()) {
      return (data != null ? _i65.UserLabel.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i66.UserLabelMapping?>()) {
      return (data != null ? _i66.UserLabelMapping.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i67.EmailMethodBlockedException?>()) {
      return (data != null
              ? _i67.EmailMethodBlockedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i68.UserAccountRegistrationDeniedException?>()) {
      return (data != null
              ? _i68.UserAccountRegistrationDeniedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i69.AcceptedTerms?>()) {
      return (data != null ? _i69.AcceptedTerms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i70.AcceptedTermsDTO?>()) {
      return (data != null ? _i70.AcceptedTermsDTO.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i71.AuthTokenInfo?>()) {
      return (data != null ? _i71.AuthTokenInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i72.RequiredTerms?>()) {
      return (data != null ? _i72.RequiredTerms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i73.Terms?>()) {
      return (data != null ? _i73.Terms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i74.ComputeInfo?>()) {
      return (data != null ? _i74.ComputeInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i75.DNSVerificationFailedException?>()) {
      return (data != null
              ? _i75.DNSVerificationFailedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i76.CustomDomainName?>()) {
      return (data != null ? _i76.CustomDomainName.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i77.CustomDomainNameList?>()) {
      return (data != null ? _i77.CustomDomainNameList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i78.DnsRecordType?>()) {
      return (data != null ? _i78.DnsRecordType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i79.DomainNameStatus?>()) {
      return (data != null ? _i79.DomainNameStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i80.DomainNameTarget?>()) {
      return (data != null ? _i80.DomainNameTarget.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i81.CustomDomainNameWithDefaultDomains?>()) {
      return (data != null
              ? _i81.CustomDomainNameWithDefaultDomains.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i82.InsightsConnectionDetail?>()) {
      return (data != null
              ? _i82.InsightsConnectionDetail.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i83.ProjectConfig?>()) {
      return (data != null ? _i83.ProjectConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i84.ProjectInfo?>()) {
      return (data != null ? _i84.ProjectInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i85.Timestamp?>()) {
      return (data != null ? _i85.Timestamp.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i86.ProjectProfileUpdate?>()) {
      return (data != null ? _i86.ProjectProfileUpdate.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i87.CapsuleStatusUnavailableException?>()) {
      return (data != null
              ? _i87.CapsuleStatusUnavailableException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i88.DartSdkUnsupportedConstraintException?>()) {
      return (data != null
              ? _i88.DartSdkUnsupportedConstraintException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i89.DuplicateEntryException?>()) {
      return (data != null ? _i89.DuplicateEntryException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i90.InvalidValueException?>()) {
      return (data != null ? _i90.InvalidValueException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i91.NoCustomerBillingTypeException?>()) {
      return (data != null
              ? _i91.NoCustomerBillingTypeException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i92.NoSubscriptionException?>()) {
      return (data != null ? _i92.NoSubscriptionException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i93.NotFoundException?>()) {
      return (data != null ? _i93.NotFoundException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i94.ProcurementCancellationException?>()) {
      return (data != null
              ? _i94.ProcurementCancellationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i95.ProcurementDeniedException?>()) {
      return (data != null
              ? _i95.ProcurementDeniedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i96.ProcurementDeniedReason?>()) {
      return (data != null ? _i96.ProcurementDeniedReason.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i97.UnauthenticatedException?>()) {
      return (data != null
              ? _i97.UnauthenticatedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i98.UnauthorizedException?>()) {
      return (data != null ? _i98.UnauthorizedException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i99.ServerpodRegion?>()) {
      return (data != null ? _i99.ServerpodRegion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i100.PubsubEntry?>()) {
      return (data != null ? _i100.PubsubEntry.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i48.Project>) {
      return (data as List).map((e) => deserialize<_i48.Project>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i48.Project>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i48.Project>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i9.BucketFile>) {
      return (data as List).map((e) => deserialize<_i9.BucketFile>(e)).toList()
          as T;
    }
    if (t == List<_i32.EnvironmentVariable>) {
      return (data as List)
              .map((e) => deserialize<_i32.EnvironmentVariable>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i32.EnvironmentVariable>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i32.EnvironmentVariable>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i76.CustomDomainName>) {
      return (data as List)
              .map((e) => deserialize<_i76.CustomDomainName>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i76.CustomDomainName>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i76.CustomDomainName>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i35.PodMetricSample>) {
      return (data as List)
              .map((e) => deserialize<_i35.PodMetricSample>(e))
              .toList()
          as T;
    }
    if (t == List<_i38.ComputeProductInfo>) {
      return (data as List)
              .map((e) => deserialize<_i38.ComputeProductInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i41.DatabaseProductInfo>) {
      return (data as List)
              .map((e) => deserialize<_i41.DatabaseProductInfo>(e))
              .toList()
          as T;
    }
    if (t == List<double>) {
      return (data as List).map((e) => deserialize<double>(e)).toList() as T;
    }
    if (t == List<_i46.ProjectProductInfo>) {
      return (data as List)
              .map((e) => deserialize<_i46.ProjectProductInfo>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i46.ProjectProductInfo>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i46.ProjectProductInfo>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i49.Role>) {
      return (data as List).map((e) => deserialize<_i49.Role>(e)).toList() as T;
    }
    if (t == _i1.getType<List<_i49.Role>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i49.Role>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i17.Capsule>) {
      return (data as List).map((e) => deserialize<_i17.Capsule>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i17.Capsule>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i17.Capsule>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i50.UserRoleMembership>) {
      return (data as List)
              .map((e) => deserialize<_i50.UserRoleMembership>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i50.UserRoleMembership>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i50.UserRoleMembership>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i54.StoredSecretVersion>) {
      return (data as List)
              .map((e) => deserialize<_i54.StoredSecretVersion>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i54.StoredSecretVersion>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i54.StoredSecretVersion>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == List<_i60.DeployAttemptStage>) {
      return (data as List)
              .map((e) => deserialize<_i60.DeployAttemptStage>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i60.DeployAttemptStage>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i60.DeployAttemptStage>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i66.UserLabelMapping>) {
      return (data as List)
              .map((e) => deserialize<_i66.UserLabelMapping>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i66.UserLabelMapping>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i66.UserLabelMapping>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == Map<_i80.DomainNameTarget, String>) {
      return Map.fromEntries(
            (data as List).map(
              (e) => MapEntry(
                deserialize<_i80.DomainNameTarget>(e['k']),
                deserialize<String>(e['v']),
              ),
            ),
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
    if (t == List<_i101.Project>) {
      return (data as List).map((e) => deserialize<_i101.Project>(e)).toList()
          as T;
    }
    if (t == List<_i102.ProjectInfo>) {
      return (data as List)
              .map((e) => deserialize<_i102.ProjectInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i103.DeployAttempt>) {
      return (data as List)
              .map((e) => deserialize<_i103.DeployAttempt>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == List<_i104.User>) {
      return (data as List).map((e) => deserialize<_i104.User>(e)).toList()
          as T;
    }
    if (t == List<_i105.RequiredTerms>) {
      return (data as List)
              .map((e) => deserialize<_i105.RequiredTerms>(e))
              .toList()
          as T;
    }
    if (t == List<_i106.AcceptedTermsDTO>) {
      return (data as List)
              .map((e) => deserialize<_i106.AcceptedTermsDTO>(e))
              .toList()
          as T;
    }
    if (t == List<_i107.AuthTokenInfo>) {
      return (data as List)
              .map((e) => deserialize<_i107.AuthTokenInfo>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i106.AcceptedTermsDTO>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i106.AcceptedTermsDTO>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i108.PaymentMethod>) {
      return (data as List)
              .map((e) => deserialize<_i108.PaymentMethod>(e))
              .toList()
          as T;
    }
    if (t == List<_i109.DatabaseUser>) {
      return (data as List)
              .map((e) => deserialize<_i109.DatabaseUser>(e))
              .toList()
          as T;
    }
    if (t == List<_i110.DatabaseSnapshot>) {
      return (data as List)
              .map((e) => deserialize<_i110.DatabaseSnapshot>(e))
              .toList()
          as T;
    }
    if (t == List<_i111.EnvironmentVariable>) {
      return (data as List)
              .map((e) => deserialize<_i111.EnvironmentVariable>(e))
              .toList()
          as T;
    }
    if (t == List<_i112.PodResourceSeries>) {
      return (data as List)
              .map((e) => deserialize<_i112.PodResourceSeries>(e))
              .toList()
          as T;
    }
    if (t == List<_i113.SubscriptionInfo>) {
      return (data as List)
              .map((e) => deserialize<_i113.SubscriptionInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i114.PlanInfo>) {
      return (data as List).map((e) => deserialize<_i114.PlanInfo>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i115.Role>) {
      return (data as List).map((e) => deserialize<_i115.Role>(e)).toList()
          as T;
    }
    if (t == List<_i116.DeployAttemptStage>) {
      return (data as List)
              .map((e) => deserialize<_i116.DeployAttemptStage>(e))
              .toList()
          as T;
    }
    try {
      return _i117.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i118.Protocol().deserialize<T>(data, t);
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
      _i9.BucketFile => 'BucketFile',
      _i10.BucketFileListing => 'BucketFileListing',
      _i11.BucketProvider => 'BucketProvider',
      _i12.BucketResource => 'BucketResource',
      _i13.BucketServiceAccount => 'BucketServiceAccount',
      _i14.BucketServiceAccountStatus => 'BucketServiceAccountStatus',
      _i15.BucketStatus => 'BucketStatus',
      _i16.BucketVisibility => 'BucketVisibility',
      _i17.Capsule => 'Capsule',
      _i18.CapsuleResource => 'CapsuleResource',
      _i19.ComputeSizeOption => 'ComputeSizeOption',
      _i20.DatabaseSnapshotLimitException => 'DatabaseSnapshotLimitException',
      _i21.BackupFrequency => 'BackupFrequency',
      _i22.BackupSchedule => 'BackupSchedule',
      _i23.DatabaseConnection => 'DatabaseConnection',
      _i24.DatabaseInfo => 'DatabaseInfo',
      _i25.DatabaseProvider => 'DatabaseProvider',
      _i26.DatabaseQuota => 'DatabaseQuota',
      _i27.DatabaseResource => 'DatabaseResource',
      _i28.DatabaseScaling => 'DatabaseScaling',
      _i29.DatabaseSizeOption => 'DatabaseSizeOption',
      _i30.DatabaseSnapshot => 'DatabaseSnapshot',
      _i31.DatabaseUser => 'DatabaseUser',
      _i32.EnvironmentVariable => 'EnvironmentVariable',
      _i33.LogRecord => 'LogRecord',
      _i34.MetricsRange => 'MetricsRange',
      _i35.PodMetricSample => 'PodMetricSample',
      _i36.PodResourceSeries => 'PodResourceSeries',
      _i37.ComputeCatalogInfo => 'ComputeCatalogInfo',
      _i38.ComputeProductInfo => 'ComputeProductInfo',
      _i39.ComputeScalingInfo => 'ComputeScalingInfo',
      _i40.DatabaseCatalogInfo => 'DatabaseCatalogInfo',
      _i41.DatabaseProductInfo => 'DatabaseProductInfo',
      _i42.DatabaseScalingInfo => 'DatabaseScalingInfo',
      _i43.PlanInfo => 'PlanInfo',
      _i44.PlanType => 'PlanType',
      _i45.ProductType => 'ProductType',
      _i46.ProjectProductInfo => 'ProjectProductInfo',
      _i47.SubscriptionInfo => 'SubscriptionInfo',
      _i48.Project => 'Project',
      _i49.Role => 'Role',
      _i50.UserRoleMembership => 'UserRoleMembership',
      _i51.BuildSecretType => 'BuildSecretType',
      _i52.SecretResource => 'SecretResource',
      _i53.SecretType => 'SecretType',
      _i54.StoredSecretVersion => 'StoredSecretVersion',
      _i55.CapsuleDeploymentStatus => 'CapsuleDeploymentStatus',
      _i56.CapsuleRevision => 'CapsuleRevision',
      _i57.CapsuleState => 'CapsuleState',
      _i58.CapsuleStatus => 'CapsuleStatus',
      _i59.DeployAttempt => 'DeployAttempt',
      _i60.DeployAttemptStage => 'DeployAttemptStage',
      _i61.DeployProgressStatus => 'DeployProgressStatus',
      _i62.DeployStageType => 'DeployStageType',
      _i63.User => 'User',
      _i64.UserAccountStatus => 'UserAccountStatus',
      _i65.UserLabel => 'UserLabel',
      _i66.UserLabelMapping => 'UserLabelMapping',
      _i67.EmailMethodBlockedException => 'EmailMethodBlockedException',
      _i68.UserAccountRegistrationDeniedException =>
        'UserAccountRegistrationDeniedException',
      _i69.AcceptedTerms => 'AcceptedTerms',
      _i70.AcceptedTermsDTO => 'AcceptedTermsDTO',
      _i71.AuthTokenInfo => 'AuthTokenInfo',
      _i72.RequiredTerms => 'RequiredTerms',
      _i73.Terms => 'Terms',
      _i74.ComputeInfo => 'ComputeInfo',
      _i75.DNSVerificationFailedException => 'DNSVerificationFailedException',
      _i76.CustomDomainName => 'CustomDomainName',
      _i77.CustomDomainNameList => 'CustomDomainNameList',
      _i78.DnsRecordType => 'DnsRecordType',
      _i79.DomainNameStatus => 'DomainNameStatus',
      _i80.DomainNameTarget => 'DomainNameTarget',
      _i81.CustomDomainNameWithDefaultDomains =>
        'CustomDomainNameWithDefaultDomains',
      _i82.InsightsConnectionDetail => 'InsightsConnectionDetail',
      _i83.ProjectConfig => 'ProjectConfig',
      _i84.ProjectInfo => 'ProjectInfo',
      _i85.Timestamp => 'Timestamp',
      _i86.ProjectProfileUpdate => 'ProjectProfileUpdate',
      _i87.CapsuleStatusUnavailableException =>
        'CapsuleStatusUnavailableException',
      _i88.DartSdkUnsupportedConstraintException =>
        'DartSdkUnsupportedConstraintException',
      _i89.DuplicateEntryException => 'DuplicateEntryException',
      _i90.InvalidValueException => 'InvalidValueException',
      _i91.NoCustomerBillingTypeException => 'NoCustomerBillingTypeException',
      _i92.NoSubscriptionException => 'NoSubscriptionException',
      _i93.NotFoundException => 'NotFoundException',
      _i94.ProcurementCancellationException =>
        'ProcurementCancellationException',
      _i95.ProcurementDeniedException => 'ProcurementDeniedException',
      _i96.ProcurementDeniedReason => 'ProcurementDeniedReason',
      _i97.UnauthenticatedException => 'UnauthenticatedException',
      _i98.UnauthorizedException => 'UnauthorizedException',
      _i99.ServerpodRegion => 'ServerpodRegion',
      _i100.PubsubEntry => 'PubsubEntry',
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
      case _i9.BucketFile():
        return 'BucketFile';
      case _i10.BucketFileListing():
        return 'BucketFileListing';
      case _i11.BucketProvider():
        return 'BucketProvider';
      case _i12.BucketResource():
        return 'BucketResource';
      case _i13.BucketServiceAccount():
        return 'BucketServiceAccount';
      case _i14.BucketServiceAccountStatus():
        return 'BucketServiceAccountStatus';
      case _i15.BucketStatus():
        return 'BucketStatus';
      case _i16.BucketVisibility():
        return 'BucketVisibility';
      case _i17.Capsule():
        return 'Capsule';
      case _i18.CapsuleResource():
        return 'CapsuleResource';
      case _i19.ComputeSizeOption():
        return 'ComputeSizeOption';
      case _i20.DatabaseSnapshotLimitException():
        return 'DatabaseSnapshotLimitException';
      case _i21.BackupFrequency():
        return 'BackupFrequency';
      case _i22.BackupSchedule():
        return 'BackupSchedule';
      case _i23.DatabaseConnection():
        return 'DatabaseConnection';
      case _i24.DatabaseInfo():
        return 'DatabaseInfo';
      case _i25.DatabaseProvider():
        return 'DatabaseProvider';
      case _i26.DatabaseQuota():
        return 'DatabaseQuota';
      case _i27.DatabaseResource():
        return 'DatabaseResource';
      case _i28.DatabaseScaling():
        return 'DatabaseScaling';
      case _i29.DatabaseSizeOption():
        return 'DatabaseSizeOption';
      case _i30.DatabaseSnapshot():
        return 'DatabaseSnapshot';
      case _i31.DatabaseUser():
        return 'DatabaseUser';
      case _i32.EnvironmentVariable():
        return 'EnvironmentVariable';
      case _i33.LogRecord():
        return 'LogRecord';
      case _i34.MetricsRange():
        return 'MetricsRange';
      case _i35.PodMetricSample():
        return 'PodMetricSample';
      case _i36.PodResourceSeries():
        return 'PodResourceSeries';
      case _i37.ComputeCatalogInfo():
        return 'ComputeCatalogInfo';
      case _i38.ComputeProductInfo():
        return 'ComputeProductInfo';
      case _i39.ComputeScalingInfo():
        return 'ComputeScalingInfo';
      case _i40.DatabaseCatalogInfo():
        return 'DatabaseCatalogInfo';
      case _i41.DatabaseProductInfo():
        return 'DatabaseProductInfo';
      case _i42.DatabaseScalingInfo():
        return 'DatabaseScalingInfo';
      case _i43.PlanInfo():
        return 'PlanInfo';
      case _i44.PlanType():
        return 'PlanType';
      case _i45.ProductType():
        return 'ProductType';
      case _i46.ProjectProductInfo():
        return 'ProjectProductInfo';
      case _i47.SubscriptionInfo():
        return 'SubscriptionInfo';
      case _i48.Project():
        return 'Project';
      case _i49.Role():
        return 'Role';
      case _i50.UserRoleMembership():
        return 'UserRoleMembership';
      case _i51.BuildSecretType():
        return 'BuildSecretType';
      case _i52.SecretResource():
        return 'SecretResource';
      case _i53.SecretType():
        return 'SecretType';
      case _i54.StoredSecretVersion():
        return 'StoredSecretVersion';
      case _i55.CapsuleDeploymentStatus():
        return 'CapsuleDeploymentStatus';
      case _i56.CapsuleRevision():
        return 'CapsuleRevision';
      case _i57.CapsuleState():
        return 'CapsuleState';
      case _i58.CapsuleStatus():
        return 'CapsuleStatus';
      case _i59.DeployAttempt():
        return 'DeployAttempt';
      case _i60.DeployAttemptStage():
        return 'DeployAttemptStage';
      case _i61.DeployProgressStatus():
        return 'DeployProgressStatus';
      case _i62.DeployStageType():
        return 'DeployStageType';
      case _i63.User():
        return 'User';
      case _i64.UserAccountStatus():
        return 'UserAccountStatus';
      case _i65.UserLabel():
        return 'UserLabel';
      case _i66.UserLabelMapping():
        return 'UserLabelMapping';
      case _i67.EmailMethodBlockedException():
        return 'EmailMethodBlockedException';
      case _i68.UserAccountRegistrationDeniedException():
        return 'UserAccountRegistrationDeniedException';
      case _i69.AcceptedTerms():
        return 'AcceptedTerms';
      case _i70.AcceptedTermsDTO():
        return 'AcceptedTermsDTO';
      case _i71.AuthTokenInfo():
        return 'AuthTokenInfo';
      case _i72.RequiredTerms():
        return 'RequiredTerms';
      case _i73.Terms():
        return 'Terms';
      case _i74.ComputeInfo():
        return 'ComputeInfo';
      case _i75.DNSVerificationFailedException():
        return 'DNSVerificationFailedException';
      case _i76.CustomDomainName():
        return 'CustomDomainName';
      case _i77.CustomDomainNameList():
        return 'CustomDomainNameList';
      case _i78.DnsRecordType():
        return 'DnsRecordType';
      case _i79.DomainNameStatus():
        return 'DomainNameStatus';
      case _i80.DomainNameTarget():
        return 'DomainNameTarget';
      case _i81.CustomDomainNameWithDefaultDomains():
        return 'CustomDomainNameWithDefaultDomains';
      case _i82.InsightsConnectionDetail():
        return 'InsightsConnectionDetail';
      case _i83.ProjectConfig():
        return 'ProjectConfig';
      case _i84.ProjectInfo():
        return 'ProjectInfo';
      case _i85.Timestamp():
        return 'Timestamp';
      case _i86.ProjectProfileUpdate():
        return 'ProjectProfileUpdate';
      case _i87.CapsuleStatusUnavailableException():
        return 'CapsuleStatusUnavailableException';
      case _i88.DartSdkUnsupportedConstraintException():
        return 'DartSdkUnsupportedConstraintException';
      case _i89.DuplicateEntryException():
        return 'DuplicateEntryException';
      case _i90.InvalidValueException():
        return 'InvalidValueException';
      case _i91.NoCustomerBillingTypeException():
        return 'NoCustomerBillingTypeException';
      case _i92.NoSubscriptionException():
        return 'NoSubscriptionException';
      case _i93.NotFoundException():
        return 'NotFoundException';
      case _i94.ProcurementCancellationException():
        return 'ProcurementCancellationException';
      case _i95.ProcurementDeniedException():
        return 'ProcurementDeniedException';
      case _i96.ProcurementDeniedReason():
        return 'ProcurementDeniedReason';
      case _i97.UnauthenticatedException():
        return 'UnauthenticatedException';
      case _i98.UnauthorizedException():
        return 'UnauthorizedException';
      case _i99.ServerpodRegion():
        return 'ServerpodRegion';
      case _i100.PubsubEntry():
        return 'PubsubEntry';
    }
    className = _i117.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i118.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'BucketFile') {
      return deserialize<_i9.BucketFile>(data['data']);
    }
    if (dataClassName == 'BucketFileListing') {
      return deserialize<_i10.BucketFileListing>(data['data']);
    }
    if (dataClassName == 'BucketProvider') {
      return deserialize<_i11.BucketProvider>(data['data']);
    }
    if (dataClassName == 'BucketResource') {
      return deserialize<_i12.BucketResource>(data['data']);
    }
    if (dataClassName == 'BucketServiceAccount') {
      return deserialize<_i13.BucketServiceAccount>(data['data']);
    }
    if (dataClassName == 'BucketServiceAccountStatus') {
      return deserialize<_i14.BucketServiceAccountStatus>(data['data']);
    }
    if (dataClassName == 'BucketStatus') {
      return deserialize<_i15.BucketStatus>(data['data']);
    }
    if (dataClassName == 'BucketVisibility') {
      return deserialize<_i16.BucketVisibility>(data['data']);
    }
    if (dataClassName == 'Capsule') {
      return deserialize<_i17.Capsule>(data['data']);
    }
    if (dataClassName == 'CapsuleResource') {
      return deserialize<_i18.CapsuleResource>(data['data']);
    }
    if (dataClassName == 'ComputeSizeOption') {
      return deserialize<_i19.ComputeSizeOption>(data['data']);
    }
    if (dataClassName == 'DatabaseSnapshotLimitException') {
      return deserialize<_i20.DatabaseSnapshotLimitException>(data['data']);
    }
    if (dataClassName == 'BackupFrequency') {
      return deserialize<_i21.BackupFrequency>(data['data']);
    }
    if (dataClassName == 'BackupSchedule') {
      return deserialize<_i22.BackupSchedule>(data['data']);
    }
    if (dataClassName == 'DatabaseConnection') {
      return deserialize<_i23.DatabaseConnection>(data['data']);
    }
    if (dataClassName == 'DatabaseInfo') {
      return deserialize<_i24.DatabaseInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseProvider') {
      return deserialize<_i25.DatabaseProvider>(data['data']);
    }
    if (dataClassName == 'DatabaseQuota') {
      return deserialize<_i26.DatabaseQuota>(data['data']);
    }
    if (dataClassName == 'DatabaseResource') {
      return deserialize<_i27.DatabaseResource>(data['data']);
    }
    if (dataClassName == 'DatabaseScaling') {
      return deserialize<_i28.DatabaseScaling>(data['data']);
    }
    if (dataClassName == 'DatabaseSizeOption') {
      return deserialize<_i29.DatabaseSizeOption>(data['data']);
    }
    if (dataClassName == 'DatabaseSnapshot') {
      return deserialize<_i30.DatabaseSnapshot>(data['data']);
    }
    if (dataClassName == 'DatabaseUser') {
      return deserialize<_i31.DatabaseUser>(data['data']);
    }
    if (dataClassName == 'EnvironmentVariable') {
      return deserialize<_i32.EnvironmentVariable>(data['data']);
    }
    if (dataClassName == 'LogRecord') {
      return deserialize<_i33.LogRecord>(data['data']);
    }
    if (dataClassName == 'MetricsRange') {
      return deserialize<_i34.MetricsRange>(data['data']);
    }
    if (dataClassName == 'PodMetricSample') {
      return deserialize<_i35.PodMetricSample>(data['data']);
    }
    if (dataClassName == 'PodResourceSeries') {
      return deserialize<_i36.PodResourceSeries>(data['data']);
    }
    if (dataClassName == 'ComputeCatalogInfo') {
      return deserialize<_i37.ComputeCatalogInfo>(data['data']);
    }
    if (dataClassName == 'ComputeProductInfo') {
      return deserialize<_i38.ComputeProductInfo>(data['data']);
    }
    if (dataClassName == 'ComputeScalingInfo') {
      return deserialize<_i39.ComputeScalingInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseCatalogInfo') {
      return deserialize<_i40.DatabaseCatalogInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseProductInfo') {
      return deserialize<_i41.DatabaseProductInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseScalingInfo') {
      return deserialize<_i42.DatabaseScalingInfo>(data['data']);
    }
    if (dataClassName == 'PlanInfo') {
      return deserialize<_i43.PlanInfo>(data['data']);
    }
    if (dataClassName == 'PlanType') {
      return deserialize<_i44.PlanType>(data['data']);
    }
    if (dataClassName == 'ProductType') {
      return deserialize<_i45.ProductType>(data['data']);
    }
    if (dataClassName == 'ProjectProductInfo') {
      return deserialize<_i46.ProjectProductInfo>(data['data']);
    }
    if (dataClassName == 'SubscriptionInfo') {
      return deserialize<_i47.SubscriptionInfo>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i48.Project>(data['data']);
    }
    if (dataClassName == 'Role') {
      return deserialize<_i49.Role>(data['data']);
    }
    if (dataClassName == 'UserRoleMembership') {
      return deserialize<_i50.UserRoleMembership>(data['data']);
    }
    if (dataClassName == 'BuildSecretType') {
      return deserialize<_i51.BuildSecretType>(data['data']);
    }
    if (dataClassName == 'SecretResource') {
      return deserialize<_i52.SecretResource>(data['data']);
    }
    if (dataClassName == 'SecretType') {
      return deserialize<_i53.SecretType>(data['data']);
    }
    if (dataClassName == 'StoredSecretVersion') {
      return deserialize<_i54.StoredSecretVersion>(data['data']);
    }
    if (dataClassName == 'CapsuleDeploymentStatus') {
      return deserialize<_i55.CapsuleDeploymentStatus>(data['data']);
    }
    if (dataClassName == 'CapsuleRevision') {
      return deserialize<_i56.CapsuleRevision>(data['data']);
    }
    if (dataClassName == 'CapsuleState') {
      return deserialize<_i57.CapsuleState>(data['data']);
    }
    if (dataClassName == 'CapsuleStatus') {
      return deserialize<_i58.CapsuleStatus>(data['data']);
    }
    if (dataClassName == 'DeployAttempt') {
      return deserialize<_i59.DeployAttempt>(data['data']);
    }
    if (dataClassName == 'DeployAttemptStage') {
      return deserialize<_i60.DeployAttemptStage>(data['data']);
    }
    if (dataClassName == 'DeployProgressStatus') {
      return deserialize<_i61.DeployProgressStatus>(data['data']);
    }
    if (dataClassName == 'DeployStageType') {
      return deserialize<_i62.DeployStageType>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i63.User>(data['data']);
    }
    if (dataClassName == 'UserAccountStatus') {
      return deserialize<_i64.UserAccountStatus>(data['data']);
    }
    if (dataClassName == 'UserLabel') {
      return deserialize<_i65.UserLabel>(data['data']);
    }
    if (dataClassName == 'UserLabelMapping') {
      return deserialize<_i66.UserLabelMapping>(data['data']);
    }
    if (dataClassName == 'EmailMethodBlockedException') {
      return deserialize<_i67.EmailMethodBlockedException>(data['data']);
    }
    if (dataClassName == 'UserAccountRegistrationDeniedException') {
      return deserialize<_i68.UserAccountRegistrationDeniedException>(
        data['data'],
      );
    }
    if (dataClassName == 'AcceptedTerms') {
      return deserialize<_i69.AcceptedTerms>(data['data']);
    }
    if (dataClassName == 'AcceptedTermsDTO') {
      return deserialize<_i70.AcceptedTermsDTO>(data['data']);
    }
    if (dataClassName == 'AuthTokenInfo') {
      return deserialize<_i71.AuthTokenInfo>(data['data']);
    }
    if (dataClassName == 'RequiredTerms') {
      return deserialize<_i72.RequiredTerms>(data['data']);
    }
    if (dataClassName == 'Terms') {
      return deserialize<_i73.Terms>(data['data']);
    }
    if (dataClassName == 'ComputeInfo') {
      return deserialize<_i74.ComputeInfo>(data['data']);
    }
    if (dataClassName == 'DNSVerificationFailedException') {
      return deserialize<_i75.DNSVerificationFailedException>(data['data']);
    }
    if (dataClassName == 'CustomDomainName') {
      return deserialize<_i76.CustomDomainName>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameList') {
      return deserialize<_i77.CustomDomainNameList>(data['data']);
    }
    if (dataClassName == 'DnsRecordType') {
      return deserialize<_i78.DnsRecordType>(data['data']);
    }
    if (dataClassName == 'DomainNameStatus') {
      return deserialize<_i79.DomainNameStatus>(data['data']);
    }
    if (dataClassName == 'DomainNameTarget') {
      return deserialize<_i80.DomainNameTarget>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameWithDefaultDomains') {
      return deserialize<_i81.CustomDomainNameWithDefaultDomains>(data['data']);
    }
    if (dataClassName == 'InsightsConnectionDetail') {
      return deserialize<_i82.InsightsConnectionDetail>(data['data']);
    }
    if (dataClassName == 'ProjectConfig') {
      return deserialize<_i83.ProjectConfig>(data['data']);
    }
    if (dataClassName == 'ProjectInfo') {
      return deserialize<_i84.ProjectInfo>(data['data']);
    }
    if (dataClassName == 'Timestamp') {
      return deserialize<_i85.Timestamp>(data['data']);
    }
    if (dataClassName == 'ProjectProfileUpdate') {
      return deserialize<_i86.ProjectProfileUpdate>(data['data']);
    }
    if (dataClassName == 'CapsuleStatusUnavailableException') {
      return deserialize<_i87.CapsuleStatusUnavailableException>(data['data']);
    }
    if (dataClassName == 'DartSdkUnsupportedConstraintException') {
      return deserialize<_i88.DartSdkUnsupportedConstraintException>(
        data['data'],
      );
    }
    if (dataClassName == 'DuplicateEntryException') {
      return deserialize<_i89.DuplicateEntryException>(data['data']);
    }
    if (dataClassName == 'InvalidValueException') {
      return deserialize<_i90.InvalidValueException>(data['data']);
    }
    if (dataClassName == 'NoCustomerBillingTypeException') {
      return deserialize<_i91.NoCustomerBillingTypeException>(data['data']);
    }
    if (dataClassName == 'NoSubscriptionException') {
      return deserialize<_i92.NoSubscriptionException>(data['data']);
    }
    if (dataClassName == 'NotFoundException') {
      return deserialize<_i93.NotFoundException>(data['data']);
    }
    if (dataClassName == 'ProcurementCancellationException') {
      return deserialize<_i94.ProcurementCancellationException>(data['data']);
    }
    if (dataClassName == 'ProcurementDeniedException') {
      return deserialize<_i95.ProcurementDeniedException>(data['data']);
    }
    if (dataClassName == 'ProcurementDeniedReason') {
      return deserialize<_i96.ProcurementDeniedReason>(data['data']);
    }
    if (dataClassName == 'UnauthenticatedException') {
      return deserialize<_i97.UnauthenticatedException>(data['data']);
    }
    if (dataClassName == 'UnauthorizedException') {
      return deserialize<_i98.UnauthorizedException>(data['data']);
    }
    if (dataClassName == 'ServerpodRegion') {
      return deserialize<_i99.ServerpodRegion>(data['data']);
    }
    if (dataClassName == 'PubsubEntry') {
      return deserialize<_i100.PubsubEntry>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i117.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i118.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
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
    try {
      return _i117.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i118.Protocol().mapRecordToJson(record);
    } catch (_) {}
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
}

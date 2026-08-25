/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

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
import 'domains/capsules/exceptions/no_prior_deployment_exception.dart' as _i17;
import 'domains/capsules/models/capsule.dart' as _i18;
import 'domains/capsules/models/capsule_resource_config.dart' as _i19;
import 'domains/capsules/models/compute_info.dart' as _i20;
import 'domains/capsules/models/compute_size_option.dart' as _i21;
import 'domains/databases/exceptions/database_snapshot_limit_exception.dart'
    as _i22;
import 'domains/databases/models/backup_frequency.dart' as _i23;
import 'domains/databases/models/backup_schedule.dart' as _i24;
import 'domains/databases/models/database_connection.dart' as _i25;
import 'domains/databases/models/database_info.dart' as _i26;
import 'domains/databases/models/database_provider.dart' as _i27;
import 'domains/databases/models/database_provisioning.dart' as _i28;
import 'domains/databases/models/database_provisioning_status.dart' as _i29;
import 'domains/databases/models/database_quota.dart' as _i30;
import 'domains/databases/models/database_resource.dart' as _i31;
import 'domains/databases/models/database_scaling.dart' as _i32;
import 'domains/databases/models/database_size.dart' as _i33;
import 'domains/databases/models/database_snapshot.dart' as _i34;
import 'domains/databases/models/database_status.dart' as _i35;
import 'domains/databases/models/database_user.dart' as _i36;
import 'domains/environment_variables/models/variable.dart' as _i37;
import 'domains/logs/models/log_record.dart' as _i38;
import 'domains/metrics/models/capsule_network_series.dart' as _i39;
import 'domains/metrics/models/database_metrics.dart' as _i40;
import 'domains/metrics/models/database_metrics_status.dart' as _i41;
import 'domains/metrics/models/metric_sample.dart' as _i42;
import 'domains/metrics/models/metrics_range.dart' as _i43;
import 'domains/metrics/models/pod_resource_series.dart' as _i44;
import 'domains/metrics/models/response_class_series.dart' as _i45;
import 'domains/products/models/compute_catalog_info.dart' as _i46;
import 'domains/products/models/compute_product_info.dart' as _i47;
import 'domains/products/models/compute_scaling_info.dart' as _i48;
import 'domains/products/models/concurrent_subscription_update_exception.dart'
    as _i49;
import 'domains/products/models/database_catalog_info.dart' as _i50;
import 'domains/products/models/database_product_info.dart' as _i51;
import 'domains/products/models/database_scaling_info.dart' as _i52;
import 'domains/products/models/plan_info.dart' as _i53;
import 'domains/products/models/plan_type.dart' as _i54;
import 'domains/products/models/product_type.dart' as _i55;
import 'domains/products/models/project_product_info.dart' as _i56;
import 'domains/products/models/subscription_info.dart' as _i57;
import 'domains/projects/models/project.dart' as _i58;
import 'domains/projects/models/role.dart' as _i59;
import 'domains/projects/models/user_role_membership.dart' as _i60;
import 'domains/secrets/models/build_secret_type.dart' as _i61;
import 'domains/secrets/models/secret_resource.dart' as _i62;
import 'domains/secrets/models/secret_type.dart' as _i63;
import 'domains/secrets/models/stored_secret_version.dart' as _i64;
import 'domains/status/models/capsule_deployment_status.dart' as _i65;
import 'domains/status/models/capsule_revision.dart' as _i66;
import 'domains/status/models/capsule_state.dart' as _i67;
import 'domains/status/models/capsule_status.dart' as _i68;
import 'domains/status/models/deploy_attempt.dart' as _i69;
import 'domains/status/models/deploy_attempt_stage.dart' as _i70;
import 'domains/status/models/deploy_progress_status.dart' as _i71;
import 'domains/status/models/deploy_stage_type.dart' as _i72;
import 'domains/users/models/user.dart' as _i73;
import 'domains/users/models/user_account_status.dart' as _i74;
import 'domains/users/models/user_label.dart' as _i75;
import 'domains/users/models/user_label_mapping.dart' as _i76;
import 'features/auth/exceptions/email_method_blocked_exception.dart' as _i77;
import 'features/auth/exceptions/user_account_registration_denied_exception.dart'
    as _i78;
import 'features/auth/models/accepted_terms.dart' as _i79;
import 'features/auth/models/accepted_terms_dto.dart' as _i80;
import 'features/auth/models/auth_token_info.dart' as _i81;
import 'features/auth/models/required_terms.dart' as _i82;
import 'features/auth/models/terms.dart' as _i83;
import 'features/buckets/exceptions/bucket_storage_identity_unavailable_exception.dart'
    as _i84;
import 'features/custom_domains/exceptions/dns_verification_failed_exception.dart'
    as _i85;
import 'features/custom_domains/models/custom_domain_name.dart' as _i86;
import 'features/custom_domains/models/custom_domain_name_list.dart' as _i87;
import 'features/custom_domains/models/dns_record_type.dart' as _i88;
import 'features/custom_domains/models/domain_name_status.dart' as _i89;
import 'features/custom_domains/models/domain_name_target.dart' as _i90;
import 'features/custom_domains/models/view_models/custom_domain_name_with_default_domains.dart'
    as _i91;
import 'features/insights/models/insights_connection_detail.dart' as _i92;
import 'features/platform/models/dart_sdk_version.dart' as _i93;
import 'features/platform/models/dart_sdk_version_policy.dart' as _i94;
import 'features/projects/models/project_config.dart' as _i95;
import 'features/projects/models/project_info/project_info.dart' as _i96;
import 'features/projects/models/project_info/timestamp.dart' as _i97;
import 'features/projects/models/project_profile_update.dart' as _i98;
import 'features/status/exceptions/capsule_status_unavailable_exception.dart'
    as _i99;
import 'features/status/models/capsule_runtime_status.dart' as _i100;
import 'features/status/models/deploy_attempt_summary.dart' as _i101;
import 'shared/exceptions/models/dart_sdk_unsupported_constraint_exception.dart'
    as _i102;
import 'shared/exceptions/models/database_not_ready_exception.dart' as _i103;
import 'shared/exceptions/models/duplicate_entry_exception.dart' as _i104;
import 'shared/exceptions/models/invalid_value_exception.dart' as _i105;
import 'shared/exceptions/models/no_customer_billing_type_exception.dart'
    as _i106;
import 'shared/exceptions/models/no_subscription_exception.dart' as _i107;
import 'shared/exceptions/models/not_found_exception.dart' as _i108;
import 'shared/exceptions/models/plan_change_denied_exception.dart' as _i109;
import 'shared/exceptions/models/plan_change_denied_reason.dart' as _i110;
import 'shared/exceptions/models/procurement_cancellation_exception.dart'
    as _i111;
import 'shared/exceptions/models/procurement_denied_exception.dart' as _i112;
import 'shared/exceptions/models/procurement_denied_reason.dart' as _i113;
import 'shared/exceptions/models/unauthenticated_exception.dart' as _i114;
import 'shared/exceptions/models/unauthorized_exception.dart' as _i115;
import 'shared/models/http_response_class.dart' as _i116;
import 'shared/models/serverpod_region.dart' as _i117;
import 'shared/pubsub/registry/pubsub_entry.dart' as _i118;
import 'package:ground_control_client/src/protocol/domains/projects/models/project.dart'
    as _i119;
import 'package:ground_control_client/src/protocol/features/projects/models/project_info/project_info.dart'
    as _i120;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i121;
import 'package:ground_control_client/src/protocol/domains/users/models/user.dart'
    as _i122;
import 'package:ground_control_client/src/protocol/features/auth/models/required_terms.dart'
    as _i123;
import 'package:ground_control_client/src/protocol/features/auth/models/accepted_terms_dto.dart'
    as _i124;
import 'package:ground_control_client/src/protocol/features/auth/models/auth_token_info.dart'
    as _i125;
import 'package:ground_control_client/src/protocol/domains/billing/models/payment_method.dart'
    as _i126;
import 'package:ground_control_client/src/protocol/domains/buckets/models/bucket_resource.dart'
    as _i127;
import 'package:ground_control_client/src/protocol/domains/databases/models/database_user.dart'
    as _i128;
import 'package:ground_control_client/src/protocol/domains/databases/models/database_snapshot.dart'
    as _i129;
import 'package:ground_control_client/src/protocol/domains/environment_variables/models/variable.dart'
    as _i130;
import 'package:ground_control_client/src/protocol/domains/metrics/models/pod_resource_series.dart'
    as _i131;
import 'package:ground_control_client/src/protocol/domains/products/models/subscription_info.dart'
    as _i132;
import 'package:ground_control_client/src/protocol/domains/products/models/plan_info.dart'
    as _i133;
import 'package:ground_control_client/src/protocol/domains/projects/models/role.dart'
    as _i134;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _i135;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i136;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i137;
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
export 'domains/capsules/exceptions/no_prior_deployment_exception.dart';
export 'domains/capsules/models/capsule.dart';
export 'domains/capsules/models/capsule_resource_config.dart';
export 'domains/capsules/models/compute_info.dart';
export 'domains/capsules/models/compute_size_option.dart';
export 'domains/databases/exceptions/database_snapshot_limit_exception.dart';
export 'domains/databases/models/backup_frequency.dart';
export 'domains/databases/models/backup_schedule.dart';
export 'domains/databases/models/database_connection.dart';
export 'domains/databases/models/database_info.dart';
export 'domains/databases/models/database_provider.dart';
export 'domains/databases/models/database_provisioning.dart';
export 'domains/databases/models/database_provisioning_status.dart';
export 'domains/databases/models/database_quota.dart';
export 'domains/databases/models/database_resource.dart';
export 'domains/databases/models/database_scaling.dart';
export 'domains/databases/models/database_size.dart';
export 'domains/databases/models/database_snapshot.dart';
export 'domains/databases/models/database_status.dart';
export 'domains/databases/models/database_user.dart';
export 'domains/environment_variables/models/variable.dart';
export 'domains/logs/models/log_record.dart';
export 'domains/metrics/models/capsule_network_series.dart';
export 'domains/metrics/models/database_metrics.dart';
export 'domains/metrics/models/database_metrics_status.dart';
export 'domains/metrics/models/metric_sample.dart';
export 'domains/metrics/models/metrics_range.dart';
export 'domains/metrics/models/pod_resource_series.dart';
export 'domains/metrics/models/response_class_series.dart';
export 'domains/products/models/compute_catalog_info.dart';
export 'domains/products/models/compute_product_info.dart';
export 'domains/products/models/compute_scaling_info.dart';
export 'domains/products/models/concurrent_subscription_update_exception.dart';
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
export 'features/buckets/exceptions/bucket_storage_identity_unavailable_exception.dart';
export 'features/custom_domains/exceptions/dns_verification_failed_exception.dart';
export 'features/custom_domains/models/custom_domain_name.dart';
export 'features/custom_domains/models/custom_domain_name_list.dart';
export 'features/custom_domains/models/dns_record_type.dart';
export 'features/custom_domains/models/domain_name_status.dart';
export 'features/custom_domains/models/domain_name_target.dart';
export 'features/custom_domains/models/view_models/custom_domain_name_with_default_domains.dart';
export 'features/insights/models/insights_connection_detail.dart';
export 'features/platform/models/dart_sdk_version.dart';
export 'features/platform/models/dart_sdk_version_policy.dart';
export 'features/projects/models/project_config.dart';
export 'features/projects/models/project_info/project_info.dart';
export 'features/projects/models/project_info/timestamp.dart';
export 'features/projects/models/project_profile_update.dart';
export 'features/status/exceptions/capsule_status_unavailable_exception.dart';
export 'features/status/models/capsule_runtime_status.dart';
export 'features/status/models/deploy_attempt_summary.dart';
export 'shared/exceptions/models/dart_sdk_unsupported_constraint_exception.dart';
export 'shared/exceptions/models/database_not_ready_exception.dart';
export 'shared/exceptions/models/duplicate_entry_exception.dart';
export 'shared/exceptions/models/invalid_value_exception.dart';
export 'shared/exceptions/models/no_customer_billing_type_exception.dart';
export 'shared/exceptions/models/no_subscription_exception.dart';
export 'shared/exceptions/models/not_found_exception.dart';
export 'shared/exceptions/models/plan_change_denied_exception.dart';
export 'shared/exceptions/models/plan_change_denied_reason.dart';
export 'shared/exceptions/models/procurement_cancellation_exception.dart';
export 'shared/exceptions/models/procurement_denied_exception.dart';
export 'shared/exceptions/models/procurement_denied_reason.dart';
export 'shared/exceptions/models/unauthenticated_exception.dart';
export 'shared/exceptions/models/unauthorized_exception.dart';
export 'shared/models/http_response_class.dart';
export 'shared/models/serverpod_region.dart';
export 'shared/pubsub/registry/pubsub_entry.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

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
    if (t == _i17.NoPriorDeploymentException) {
      return _i17.NoPriorDeploymentException.fromJson(data) as T;
    }
    if (t == _i18.Capsule) {
      return _i18.Capsule.fromJson(data) as T;
    }
    if (t == _i19.CapsuleResource) {
      return _i19.CapsuleResource.fromJson(data) as T;
    }
    if (t == _i20.ComputeInfo) {
      return _i20.ComputeInfo.fromJson(data) as T;
    }
    if (t == _i21.ComputeSizeOption) {
      return _i21.ComputeSizeOption.fromJson(data) as T;
    }
    if (t == _i22.DatabaseSnapshotLimitException) {
      return _i22.DatabaseSnapshotLimitException.fromJson(data) as T;
    }
    if (t == _i23.BackupFrequency) {
      return _i23.BackupFrequency.fromJson(data) as T;
    }
    if (t == _i24.BackupSchedule) {
      return _i24.BackupSchedule.fromJson(data) as T;
    }
    if (t == _i25.DatabaseConnection) {
      return _i25.DatabaseConnection.fromJson(data) as T;
    }
    if (t == _i26.DatabaseInfo) {
      return _i26.DatabaseInfo.fromJson(data) as T;
    }
    if (t == _i27.DatabaseProvider) {
      return _i27.DatabaseProvider.fromJson(data) as T;
    }
    if (t == _i28.DatabaseProvisioning) {
      return _i28.DatabaseProvisioning.fromJson(data) as T;
    }
    if (t == _i29.DatabaseProvisioningStatus) {
      return _i29.DatabaseProvisioningStatus.fromJson(data) as T;
    }
    if (t == _i30.DatabaseQuota) {
      return _i30.DatabaseQuota.fromJson(data) as T;
    }
    if (t == _i31.DatabaseResource) {
      return _i31.DatabaseResource.fromJson(data) as T;
    }
    if (t == _i32.DatabaseScaling) {
      return _i32.DatabaseScaling.fromJson(data) as T;
    }
    if (t == _i33.DatabaseSizeOption) {
      return _i33.DatabaseSizeOption.fromJson(data) as T;
    }
    if (t == _i34.DatabaseSnapshot) {
      return _i34.DatabaseSnapshot.fromJson(data) as T;
    }
    if (t == _i35.DatabaseStatus) {
      return _i35.DatabaseStatus.fromJson(data) as T;
    }
    if (t == _i36.DatabaseUser) {
      return _i36.DatabaseUser.fromJson(data) as T;
    }
    if (t == _i37.EnvironmentVariable) {
      return _i37.EnvironmentVariable.fromJson(data) as T;
    }
    if (t == _i38.LogRecord) {
      return _i38.LogRecord.fromJson(data) as T;
    }
    if (t == _i39.CapsuleNetworkSeries) {
      return _i39.CapsuleNetworkSeries.fromJson(data) as T;
    }
    if (t == _i40.DatabaseMetrics) {
      return _i40.DatabaseMetrics.fromJson(data) as T;
    }
    if (t == _i41.DatabaseMetricsStatus) {
      return _i41.DatabaseMetricsStatus.fromJson(data) as T;
    }
    if (t == _i42.MetricSample) {
      return _i42.MetricSample.fromJson(data) as T;
    }
    if (t == _i43.MetricsRange) {
      return _i43.MetricsRange.fromJson(data) as T;
    }
    if (t == _i44.PodResourceSeries) {
      return _i44.PodResourceSeries.fromJson(data) as T;
    }
    if (t == _i45.ResponseClassSeries) {
      return _i45.ResponseClassSeries.fromJson(data) as T;
    }
    if (t == _i46.ComputeCatalogInfo) {
      return _i46.ComputeCatalogInfo.fromJson(data) as T;
    }
    if (t == _i47.ComputeProductInfo) {
      return _i47.ComputeProductInfo.fromJson(data) as T;
    }
    if (t == _i48.ComputeScalingInfo) {
      return _i48.ComputeScalingInfo.fromJson(data) as T;
    }
    if (t == _i49.ConcurrentSubscriptionUpdateException) {
      return _i49.ConcurrentSubscriptionUpdateException.fromJson(data) as T;
    }
    if (t == _i50.DatabaseCatalogInfo) {
      return _i50.DatabaseCatalogInfo.fromJson(data) as T;
    }
    if (t == _i51.DatabaseProductInfo) {
      return _i51.DatabaseProductInfo.fromJson(data) as T;
    }
    if (t == _i52.DatabaseScalingInfo) {
      return _i52.DatabaseScalingInfo.fromJson(data) as T;
    }
    if (t == _i53.PlanInfo) {
      return _i53.PlanInfo.fromJson(data) as T;
    }
    if (t == _i54.PlanType) {
      return _i54.PlanType.fromJson(data) as T;
    }
    if (t == _i55.ProductType) {
      return _i55.ProductType.fromJson(data) as T;
    }
    if (t == _i56.ProjectProductInfo) {
      return _i56.ProjectProductInfo.fromJson(data) as T;
    }
    if (t == _i57.SubscriptionInfo) {
      return _i57.SubscriptionInfo.fromJson(data) as T;
    }
    if (t == _i58.Project) {
      return _i58.Project.fromJson(data) as T;
    }
    if (t == _i59.Role) {
      return _i59.Role.fromJson(data) as T;
    }
    if (t == _i60.UserRoleMembership) {
      return _i60.UserRoleMembership.fromJson(data) as T;
    }
    if (t == _i61.BuildSecretType) {
      return _i61.BuildSecretType.fromJson(data) as T;
    }
    if (t == _i62.SecretResource) {
      return _i62.SecretResource.fromJson(data) as T;
    }
    if (t == _i63.SecretType) {
      return _i63.SecretType.fromJson(data) as T;
    }
    if (t == _i64.StoredSecretVersion) {
      return _i64.StoredSecretVersion.fromJson(data) as T;
    }
    if (t == _i65.CapsuleDeploymentStatus) {
      return _i65.CapsuleDeploymentStatus.fromJson(data) as T;
    }
    if (t == _i66.CapsuleRevision) {
      return _i66.CapsuleRevision.fromJson(data) as T;
    }
    if (t == _i67.CapsuleState) {
      return _i67.CapsuleState.fromJson(data) as T;
    }
    if (t == _i68.CapsuleStatus) {
      return _i68.CapsuleStatus.fromJson(data) as T;
    }
    if (t == _i69.DeployAttempt) {
      return _i69.DeployAttempt.fromJson(data) as T;
    }
    if (t == _i70.DeployAttemptStage) {
      return _i70.DeployAttemptStage.fromJson(data) as T;
    }
    if (t == _i71.DeployProgressStatus) {
      return _i71.DeployProgressStatus.fromJson(data) as T;
    }
    if (t == _i72.DeployStageType) {
      return _i72.DeployStageType.fromJson(data) as T;
    }
    if (t == _i73.User) {
      return _i73.User.fromJson(data) as T;
    }
    if (t == _i74.UserAccountStatus) {
      return _i74.UserAccountStatus.fromJson(data) as T;
    }
    if (t == _i75.UserLabel) {
      return _i75.UserLabel.fromJson(data) as T;
    }
    if (t == _i76.UserLabelMapping) {
      return _i76.UserLabelMapping.fromJson(data) as T;
    }
    if (t == _i77.EmailMethodBlockedException) {
      return _i77.EmailMethodBlockedException.fromJson(data) as T;
    }
    if (t == _i78.UserAccountRegistrationDeniedException) {
      return _i78.UserAccountRegistrationDeniedException.fromJson(data) as T;
    }
    if (t == _i79.AcceptedTerms) {
      return _i79.AcceptedTerms.fromJson(data) as T;
    }
    if (t == _i80.AcceptedTermsDTO) {
      return _i80.AcceptedTermsDTO.fromJson(data) as T;
    }
    if (t == _i81.AuthTokenInfo) {
      return _i81.AuthTokenInfo.fromJson(data) as T;
    }
    if (t == _i82.RequiredTerms) {
      return _i82.RequiredTerms.fromJson(data) as T;
    }
    if (t == _i83.Terms) {
      return _i83.Terms.fromJson(data) as T;
    }
    if (t == _i84.BucketStorageIdentityUnavailableException) {
      return _i84.BucketStorageIdentityUnavailableException.fromJson(data) as T;
    }
    if (t == _i85.DNSVerificationFailedException) {
      return _i85.DNSVerificationFailedException.fromJson(data) as T;
    }
    if (t == _i86.CustomDomainName) {
      return _i86.CustomDomainName.fromJson(data) as T;
    }
    if (t == _i87.CustomDomainNameList) {
      return _i87.CustomDomainNameList.fromJson(data) as T;
    }
    if (t == _i88.DnsRecordType) {
      return _i88.DnsRecordType.fromJson(data) as T;
    }
    if (t == _i89.DomainNameStatus) {
      return _i89.DomainNameStatus.fromJson(data) as T;
    }
    if (t == _i90.DomainNameTarget) {
      return _i90.DomainNameTarget.fromJson(data) as T;
    }
    if (t == _i91.CustomDomainNameWithDefaultDomains) {
      return _i91.CustomDomainNameWithDefaultDomains.fromJson(data) as T;
    }
    if (t == _i92.InsightsConnectionDetail) {
      return _i92.InsightsConnectionDetail.fromJson(data) as T;
    }
    if (t == _i93.DartSdkVersion) {
      return _i93.DartSdkVersion.fromJson(data) as T;
    }
    if (t == _i94.DartSdkVersionPolicy) {
      return _i94.DartSdkVersionPolicy.fromJson(data) as T;
    }
    if (t == _i95.ProjectConfig) {
      return _i95.ProjectConfig.fromJson(data) as T;
    }
    if (t == _i96.ProjectInfo) {
      return _i96.ProjectInfo.fromJson(data) as T;
    }
    if (t == _i97.Timestamp) {
      return _i97.Timestamp.fromJson(data) as T;
    }
    if (t == _i98.ProjectProfileUpdate) {
      return _i98.ProjectProfileUpdate.fromJson(data) as T;
    }
    if (t == _i99.CapsuleStatusUnavailableException) {
      return _i99.CapsuleStatusUnavailableException.fromJson(data) as T;
    }
    if (t == _i100.CapsuleRuntimeStatus) {
      return _i100.CapsuleRuntimeStatus.fromJson(data) as T;
    }
    if (t == _i101.DeployAttemptSummary) {
      return _i101.DeployAttemptSummary.fromJson(data) as T;
    }
    if (t == _i102.DartSdkUnsupportedConstraintException) {
      return _i102.DartSdkUnsupportedConstraintException.fromJson(data) as T;
    }
    if (t == _i103.DatabaseNotReadyException) {
      return _i103.DatabaseNotReadyException.fromJson(data) as T;
    }
    if (t == _i104.DuplicateEntryException) {
      return _i104.DuplicateEntryException.fromJson(data) as T;
    }
    if (t == _i105.InvalidValueException) {
      return _i105.InvalidValueException.fromJson(data) as T;
    }
    if (t == _i106.NoCustomerBillingTypeException) {
      return _i106.NoCustomerBillingTypeException.fromJson(data) as T;
    }
    if (t == _i107.NoSubscriptionException) {
      return _i107.NoSubscriptionException.fromJson(data) as T;
    }
    if (t == _i108.NotFoundException) {
      return _i108.NotFoundException.fromJson(data) as T;
    }
    if (t == _i109.PlanChangeDeniedException) {
      return _i109.PlanChangeDeniedException.fromJson(data) as T;
    }
    if (t == _i110.PlanChangeDeniedReason) {
      return _i110.PlanChangeDeniedReason.fromJson(data) as T;
    }
    if (t == _i111.ProcurementCancellationException) {
      return _i111.ProcurementCancellationException.fromJson(data) as T;
    }
    if (t == _i112.ProcurementDeniedException) {
      return _i112.ProcurementDeniedException.fromJson(data) as T;
    }
    if (t == _i113.ProcurementDeniedReason) {
      return _i113.ProcurementDeniedReason.fromJson(data) as T;
    }
    if (t == _i114.UnauthenticatedException) {
      return _i114.UnauthenticatedException.fromJson(data) as T;
    }
    if (t == _i115.UnauthorizedException) {
      return _i115.UnauthorizedException.fromJson(data) as T;
    }
    if (t == _i116.HttpResponseClass) {
      return _i116.HttpResponseClass.fromJson(data) as T;
    }
    if (t == _i117.ServerpodRegion) {
      return _i117.ServerpodRegion.fromJson(data) as T;
    }
    if (t == _i118.PubsubEntry) {
      return _i118.PubsubEntry.fromJson(data) as T;
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
    if (t == _i1.getType<_i17.NoPriorDeploymentException?>()) {
      return (data != null
              ? _i17.NoPriorDeploymentException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i18.Capsule?>()) {
      return (data != null ? _i18.Capsule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.CapsuleResource?>()) {
      return (data != null ? _i19.CapsuleResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.ComputeInfo?>()) {
      return (data != null ? _i20.ComputeInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.ComputeSizeOption?>()) {
      return (data != null ? _i21.ComputeSizeOption.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.DatabaseSnapshotLimitException?>()) {
      return (data != null
              ? _i22.DatabaseSnapshotLimitException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i23.BackupFrequency?>()) {
      return (data != null ? _i23.BackupFrequency.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.BackupSchedule?>()) {
      return (data != null ? _i24.BackupSchedule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.DatabaseConnection?>()) {
      return (data != null ? _i25.DatabaseConnection.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i26.DatabaseInfo?>()) {
      return (data != null ? _i26.DatabaseInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.DatabaseProvider?>()) {
      return (data != null ? _i27.DatabaseProvider.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.DatabaseProvisioning?>()) {
      return (data != null ? _i28.DatabaseProvisioning.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i29.DatabaseProvisioningStatus?>()) {
      return (data != null
              ? _i29.DatabaseProvisioningStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i30.DatabaseQuota?>()) {
      return (data != null ? _i30.DatabaseQuota.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.DatabaseResource?>()) {
      return (data != null ? _i31.DatabaseResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.DatabaseScaling?>()) {
      return (data != null ? _i32.DatabaseScaling.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.DatabaseSizeOption?>()) {
      return (data != null ? _i33.DatabaseSizeOption.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i34.DatabaseSnapshot?>()) {
      return (data != null ? _i34.DatabaseSnapshot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.DatabaseStatus?>()) {
      return (data != null ? _i35.DatabaseStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.DatabaseUser?>()) {
      return (data != null ? _i36.DatabaseUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.EnvironmentVariable?>()) {
      return (data != null ? _i37.EnvironmentVariable.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i38.LogRecord?>()) {
      return (data != null ? _i38.LogRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.CapsuleNetworkSeries?>()) {
      return (data != null ? _i39.CapsuleNetworkSeries.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i40.DatabaseMetrics?>()) {
      return (data != null ? _i40.DatabaseMetrics.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.DatabaseMetricsStatus?>()) {
      return (data != null ? _i41.DatabaseMetricsStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i42.MetricSample?>()) {
      return (data != null ? _i42.MetricSample.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.MetricsRange?>()) {
      return (data != null ? _i43.MetricsRange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.PodResourceSeries?>()) {
      return (data != null ? _i44.PodResourceSeries.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.ResponseClassSeries?>()) {
      return (data != null ? _i45.ResponseClassSeries.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i46.ComputeCatalogInfo?>()) {
      return (data != null ? _i46.ComputeCatalogInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i47.ComputeProductInfo?>()) {
      return (data != null ? _i47.ComputeProductInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i48.ComputeScalingInfo?>()) {
      return (data != null ? _i48.ComputeScalingInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i49.ConcurrentSubscriptionUpdateException?>()) {
      return (data != null
              ? _i49.ConcurrentSubscriptionUpdateException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i50.DatabaseCatalogInfo?>()) {
      return (data != null ? _i50.DatabaseCatalogInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i51.DatabaseProductInfo?>()) {
      return (data != null ? _i51.DatabaseProductInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i52.DatabaseScalingInfo?>()) {
      return (data != null ? _i52.DatabaseScalingInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i53.PlanInfo?>()) {
      return (data != null ? _i53.PlanInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i54.PlanType?>()) {
      return (data != null ? _i54.PlanType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i55.ProductType?>()) {
      return (data != null ? _i55.ProductType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i56.ProjectProductInfo?>()) {
      return (data != null ? _i56.ProjectProductInfo.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i57.SubscriptionInfo?>()) {
      return (data != null ? _i57.SubscriptionInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i58.Project?>()) {
      return (data != null ? _i58.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i59.Role?>()) {
      return (data != null ? _i59.Role.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i60.UserRoleMembership?>()) {
      return (data != null ? _i60.UserRoleMembership.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i61.BuildSecretType?>()) {
      return (data != null ? _i61.BuildSecretType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i62.SecretResource?>()) {
      return (data != null ? _i62.SecretResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i63.SecretType?>()) {
      return (data != null ? _i63.SecretType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i64.StoredSecretVersion?>()) {
      return (data != null ? _i64.StoredSecretVersion.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i65.CapsuleDeploymentStatus?>()) {
      return (data != null ? _i65.CapsuleDeploymentStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i66.CapsuleRevision?>()) {
      return (data != null ? _i66.CapsuleRevision.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i67.CapsuleState?>()) {
      return (data != null ? _i67.CapsuleState.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i68.CapsuleStatus?>()) {
      return (data != null ? _i68.CapsuleStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i69.DeployAttempt?>()) {
      return (data != null ? _i69.DeployAttempt.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i70.DeployAttemptStage?>()) {
      return (data != null ? _i70.DeployAttemptStage.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i71.DeployProgressStatus?>()) {
      return (data != null ? _i71.DeployProgressStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i72.DeployStageType?>()) {
      return (data != null ? _i72.DeployStageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i73.User?>()) {
      return (data != null ? _i73.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i74.UserAccountStatus?>()) {
      return (data != null ? _i74.UserAccountStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i75.UserLabel?>()) {
      return (data != null ? _i75.UserLabel.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i76.UserLabelMapping?>()) {
      return (data != null ? _i76.UserLabelMapping.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i77.EmailMethodBlockedException?>()) {
      return (data != null
              ? _i77.EmailMethodBlockedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i78.UserAccountRegistrationDeniedException?>()) {
      return (data != null
              ? _i78.UserAccountRegistrationDeniedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i79.AcceptedTerms?>()) {
      return (data != null ? _i79.AcceptedTerms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i80.AcceptedTermsDTO?>()) {
      return (data != null ? _i80.AcceptedTermsDTO.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i81.AuthTokenInfo?>()) {
      return (data != null ? _i81.AuthTokenInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i82.RequiredTerms?>()) {
      return (data != null ? _i82.RequiredTerms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i83.Terms?>()) {
      return (data != null ? _i83.Terms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i84.BucketStorageIdentityUnavailableException?>()) {
      return (data != null
              ? _i84.BucketStorageIdentityUnavailableException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i85.DNSVerificationFailedException?>()) {
      return (data != null
              ? _i85.DNSVerificationFailedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i86.CustomDomainName?>()) {
      return (data != null ? _i86.CustomDomainName.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i87.CustomDomainNameList?>()) {
      return (data != null ? _i87.CustomDomainNameList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i88.DnsRecordType?>()) {
      return (data != null ? _i88.DnsRecordType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i89.DomainNameStatus?>()) {
      return (data != null ? _i89.DomainNameStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i90.DomainNameTarget?>()) {
      return (data != null ? _i90.DomainNameTarget.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i91.CustomDomainNameWithDefaultDomains?>()) {
      return (data != null
              ? _i91.CustomDomainNameWithDefaultDomains.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i92.InsightsConnectionDetail?>()) {
      return (data != null
              ? _i92.InsightsConnectionDetail.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i93.DartSdkVersion?>()) {
      return (data != null ? _i93.DartSdkVersion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i94.DartSdkVersionPolicy?>()) {
      return (data != null ? _i94.DartSdkVersionPolicy.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i95.ProjectConfig?>()) {
      return (data != null ? _i95.ProjectConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i96.ProjectInfo?>()) {
      return (data != null ? _i96.ProjectInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i97.Timestamp?>()) {
      return (data != null ? _i97.Timestamp.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i98.ProjectProfileUpdate?>()) {
      return (data != null ? _i98.ProjectProfileUpdate.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i99.CapsuleStatusUnavailableException?>()) {
      return (data != null
              ? _i99.CapsuleStatusUnavailableException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i100.CapsuleRuntimeStatus?>()) {
      return (data != null ? _i100.CapsuleRuntimeStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i101.DeployAttemptSummary?>()) {
      return (data != null ? _i101.DeployAttemptSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i102.DartSdkUnsupportedConstraintException?>()) {
      return (data != null
              ? _i102.DartSdkUnsupportedConstraintException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i103.DatabaseNotReadyException?>()) {
      return (data != null
              ? _i103.DatabaseNotReadyException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i104.DuplicateEntryException?>()) {
      return (data != null
              ? _i104.DuplicateEntryException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i105.InvalidValueException?>()) {
      return (data != null ? _i105.InvalidValueException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i106.NoCustomerBillingTypeException?>()) {
      return (data != null
              ? _i106.NoCustomerBillingTypeException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i107.NoSubscriptionException?>()) {
      return (data != null
              ? _i107.NoSubscriptionException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i108.NotFoundException?>()) {
      return (data != null ? _i108.NotFoundException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i109.PlanChangeDeniedException?>()) {
      return (data != null
              ? _i109.PlanChangeDeniedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i110.PlanChangeDeniedReason?>()) {
      return (data != null ? _i110.PlanChangeDeniedReason.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i111.ProcurementCancellationException?>()) {
      return (data != null
              ? _i111.ProcurementCancellationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i112.ProcurementDeniedException?>()) {
      return (data != null
              ? _i112.ProcurementDeniedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i113.ProcurementDeniedReason?>()) {
      return (data != null
              ? _i113.ProcurementDeniedReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i114.UnauthenticatedException?>()) {
      return (data != null
              ? _i114.UnauthenticatedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i115.UnauthorizedException?>()) {
      return (data != null ? _i115.UnauthorizedException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i116.HttpResponseClass?>()) {
      return (data != null ? _i116.HttpResponseClass.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i117.ServerpodRegion?>()) {
      return (data != null ? _i117.ServerpodRegion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i118.PubsubEntry?>()) {
      return (data != null ? _i118.PubsubEntry.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i58.Project>) {
      return (data as List).map((e) => deserialize<_i58.Project>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i58.Project>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i58.Project>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i9.BucketFile>) {
      return (data as List).map((e) => deserialize<_i9.BucketFile>(e)).toList()
          as T;
    }
    if (t == List<_i37.EnvironmentVariable>) {
      return (data as List)
              .map((e) => deserialize<_i37.EnvironmentVariable>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i37.EnvironmentVariable>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i37.EnvironmentVariable>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i86.CustomDomainName>) {
      return (data as List)
              .map((e) => deserialize<_i86.CustomDomainName>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i86.CustomDomainName>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i86.CustomDomainName>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i42.MetricSample>) {
      return (data as List)
              .map((e) => deserialize<_i42.MetricSample>(e))
              .toList()
          as T;
    }
    if (t == List<_i45.ResponseClassSeries>) {
      return (data as List)
              .map((e) => deserialize<_i45.ResponseClassSeries>(e))
              .toList()
          as T;
    }
    if (t == List<_i47.ComputeProductInfo>) {
      return (data as List)
              .map((e) => deserialize<_i47.ComputeProductInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i51.DatabaseProductInfo>) {
      return (data as List)
              .map((e) => deserialize<_i51.DatabaseProductInfo>(e))
              .toList()
          as T;
    }
    if (t == List<double>) {
      return (data as List).map((e) => deserialize<double>(e)).toList() as T;
    }
    if (t == List<_i56.ProjectProductInfo>) {
      return (data as List)
              .map((e) => deserialize<_i56.ProjectProductInfo>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i56.ProjectProductInfo>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i56.ProjectProductInfo>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i59.Role>) {
      return (data as List).map((e) => deserialize<_i59.Role>(e)).toList() as T;
    }
    if (t == _i1.getType<List<_i59.Role>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i59.Role>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i18.Capsule>) {
      return (data as List).map((e) => deserialize<_i18.Capsule>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i18.Capsule>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i18.Capsule>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i60.UserRoleMembership>) {
      return (data as List)
              .map((e) => deserialize<_i60.UserRoleMembership>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i60.UserRoleMembership>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i60.UserRoleMembership>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i64.StoredSecretVersion>) {
      return (data as List)
              .map((e) => deserialize<_i64.StoredSecretVersion>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i64.StoredSecretVersion>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i64.StoredSecretVersion>(e))
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
    if (t == List<_i70.DeployAttemptStage>) {
      return (data as List)
              .map((e) => deserialize<_i70.DeployAttemptStage>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i70.DeployAttemptStage>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i70.DeployAttemptStage>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i76.UserLabelMapping>) {
      return (data as List)
              .map((e) => deserialize<_i76.UserLabelMapping>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i76.UserLabelMapping>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i76.UserLabelMapping>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == Map<_i90.DomainNameTarget, String>) {
      return Map.fromEntries(
            (data as List).map(
              (e) => MapEntry(
                deserialize<_i90.DomainNameTarget>(e['k']),
                deserialize<String>(e['v']),
              ),
            ),
          )
          as T;
    }
    if (t == List<_i93.DartSdkVersion>) {
      return (data as List)
              .map((e) => deserialize<_i93.DartSdkVersion>(e))
              .toList()
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
    if (t == List<_i119.Project>) {
      return (data as List).map((e) => deserialize<_i119.Project>(e)).toList()
          as T;
    }
    if (t == List<_i120.ProjectInfo>) {
      return (data as List)
              .map((e) => deserialize<_i120.ProjectInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i121.DeployAttempt>) {
      return (data as List)
              .map((e) => deserialize<_i121.DeployAttempt>(e))
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
    if (t == List<_i122.User>) {
      return (data as List).map((e) => deserialize<_i122.User>(e)).toList()
          as T;
    }
    if (t == List<_i123.RequiredTerms>) {
      return (data as List)
              .map((e) => deserialize<_i123.RequiredTerms>(e))
              .toList()
          as T;
    }
    if (t == List<_i124.AcceptedTermsDTO>) {
      return (data as List)
              .map((e) => deserialize<_i124.AcceptedTermsDTO>(e))
              .toList()
          as T;
    }
    if (t == List<_i125.AuthTokenInfo>) {
      return (data as List)
              .map((e) => deserialize<_i125.AuthTokenInfo>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i124.AcceptedTermsDTO>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i124.AcceptedTermsDTO>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i126.PaymentMethod>) {
      return (data as List)
              .map((e) => deserialize<_i126.PaymentMethod>(e))
              .toList()
          as T;
    }
    if (t == List<_i127.BucketResource>) {
      return (data as List)
              .map((e) => deserialize<_i127.BucketResource>(e))
              .toList()
          as T;
    }
    if (t == List<_i128.DatabaseUser>) {
      return (data as List)
              .map((e) => deserialize<_i128.DatabaseUser>(e))
              .toList()
          as T;
    }
    if (t == List<_i129.DatabaseSnapshot>) {
      return (data as List)
              .map((e) => deserialize<_i129.DatabaseSnapshot>(e))
              .toList()
          as T;
    }
    if (t == List<_i130.EnvironmentVariable>) {
      return (data as List)
              .map((e) => deserialize<_i130.EnvironmentVariable>(e))
              .toList()
          as T;
    }
    if (t == List<_i131.PodResourceSeries>) {
      return (data as List)
              .map((e) => deserialize<_i131.PodResourceSeries>(e))
              .toList()
          as T;
    }
    if (t == List<_i132.SubscriptionInfo>) {
      return (data as List)
              .map((e) => deserialize<_i132.SubscriptionInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i133.PlanInfo>) {
      return (data as List).map((e) => deserialize<_i133.PlanInfo>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i134.Role>) {
      return (data as List).map((e) => deserialize<_i134.Role>(e)).toList()
          as T;
    }
    if (t == List<_i135.DeployAttemptStage>) {
      return (data as List)
              .map((e) => deserialize<_i135.DeployAttemptStage>(e))
              .toList()
          as T;
    }
    try {
      return _i136.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i137.Protocol().deserialize<T>(data, t);
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
      _i17.NoPriorDeploymentException => 'NoPriorDeploymentException',
      _i18.Capsule => 'Capsule',
      _i19.CapsuleResource => 'CapsuleResource',
      _i20.ComputeInfo => 'ComputeInfo',
      _i21.ComputeSizeOption => 'ComputeSizeOption',
      _i22.DatabaseSnapshotLimitException => 'DatabaseSnapshotLimitException',
      _i23.BackupFrequency => 'BackupFrequency',
      _i24.BackupSchedule => 'BackupSchedule',
      _i25.DatabaseConnection => 'DatabaseConnection',
      _i26.DatabaseInfo => 'DatabaseInfo',
      _i27.DatabaseProvider => 'DatabaseProvider',
      _i28.DatabaseProvisioning => 'DatabaseProvisioning',
      _i29.DatabaseProvisioningStatus => 'DatabaseProvisioningStatus',
      _i30.DatabaseQuota => 'DatabaseQuota',
      _i31.DatabaseResource => 'DatabaseResource',
      _i32.DatabaseScaling => 'DatabaseScaling',
      _i33.DatabaseSizeOption => 'DatabaseSizeOption',
      _i34.DatabaseSnapshot => 'DatabaseSnapshot',
      _i35.DatabaseStatus => 'DatabaseStatus',
      _i36.DatabaseUser => 'DatabaseUser',
      _i37.EnvironmentVariable => 'EnvironmentVariable',
      _i38.LogRecord => 'LogRecord',
      _i39.CapsuleNetworkSeries => 'CapsuleNetworkSeries',
      _i40.DatabaseMetrics => 'DatabaseMetrics',
      _i41.DatabaseMetricsStatus => 'DatabaseMetricsStatus',
      _i42.MetricSample => 'MetricSample',
      _i43.MetricsRange => 'MetricsRange',
      _i44.PodResourceSeries => 'PodResourceSeries',
      _i45.ResponseClassSeries => 'ResponseClassSeries',
      _i46.ComputeCatalogInfo => 'ComputeCatalogInfo',
      _i47.ComputeProductInfo => 'ComputeProductInfo',
      _i48.ComputeScalingInfo => 'ComputeScalingInfo',
      _i49.ConcurrentSubscriptionUpdateException =>
        'ConcurrentSubscriptionUpdateException',
      _i50.DatabaseCatalogInfo => 'DatabaseCatalogInfo',
      _i51.DatabaseProductInfo => 'DatabaseProductInfo',
      _i52.DatabaseScalingInfo => 'DatabaseScalingInfo',
      _i53.PlanInfo => 'PlanInfo',
      _i54.PlanType => 'PlanType',
      _i55.ProductType => 'ProductType',
      _i56.ProjectProductInfo => 'ProjectProductInfo',
      _i57.SubscriptionInfo => 'SubscriptionInfo',
      _i58.Project => 'Project',
      _i59.Role => 'Role',
      _i60.UserRoleMembership => 'UserRoleMembership',
      _i61.BuildSecretType => 'BuildSecretType',
      _i62.SecretResource => 'SecretResource',
      _i63.SecretType => 'SecretType',
      _i64.StoredSecretVersion => 'StoredSecretVersion',
      _i65.CapsuleDeploymentStatus => 'CapsuleDeploymentStatus',
      _i66.CapsuleRevision => 'CapsuleRevision',
      _i67.CapsuleState => 'CapsuleState',
      _i68.CapsuleStatus => 'CapsuleStatus',
      _i69.DeployAttempt => 'DeployAttempt',
      _i70.DeployAttemptStage => 'DeployAttemptStage',
      _i71.DeployProgressStatus => 'DeployProgressStatus',
      _i72.DeployStageType => 'DeployStageType',
      _i73.User => 'User',
      _i74.UserAccountStatus => 'UserAccountStatus',
      _i75.UserLabel => 'UserLabel',
      _i76.UserLabelMapping => 'UserLabelMapping',
      _i77.EmailMethodBlockedException => 'EmailMethodBlockedException',
      _i78.UserAccountRegistrationDeniedException =>
        'UserAccountRegistrationDeniedException',
      _i79.AcceptedTerms => 'AcceptedTerms',
      _i80.AcceptedTermsDTO => 'AcceptedTermsDTO',
      _i81.AuthTokenInfo => 'AuthTokenInfo',
      _i82.RequiredTerms => 'RequiredTerms',
      _i83.Terms => 'Terms',
      _i84.BucketStorageIdentityUnavailableException =>
        'BucketStorageIdentityUnavailableException',
      _i85.DNSVerificationFailedException => 'DNSVerificationFailedException',
      _i86.CustomDomainName => 'CustomDomainName',
      _i87.CustomDomainNameList => 'CustomDomainNameList',
      _i88.DnsRecordType => 'DnsRecordType',
      _i89.DomainNameStatus => 'DomainNameStatus',
      _i90.DomainNameTarget => 'DomainNameTarget',
      _i91.CustomDomainNameWithDefaultDomains =>
        'CustomDomainNameWithDefaultDomains',
      _i92.InsightsConnectionDetail => 'InsightsConnectionDetail',
      _i93.DartSdkVersion => 'DartSdkVersion',
      _i94.DartSdkVersionPolicy => 'DartSdkVersionPolicy',
      _i95.ProjectConfig => 'ProjectConfig',
      _i96.ProjectInfo => 'ProjectInfo',
      _i97.Timestamp => 'Timestamp',
      _i98.ProjectProfileUpdate => 'ProjectProfileUpdate',
      _i99.CapsuleStatusUnavailableException =>
        'CapsuleStatusUnavailableException',
      _i100.CapsuleRuntimeStatus => 'CapsuleRuntimeStatus',
      _i101.DeployAttemptSummary => 'DeployAttemptSummary',
      _i102.DartSdkUnsupportedConstraintException =>
        'DartSdkUnsupportedConstraintException',
      _i103.DatabaseNotReadyException => 'DatabaseNotReadyException',
      _i104.DuplicateEntryException => 'DuplicateEntryException',
      _i105.InvalidValueException => 'InvalidValueException',
      _i106.NoCustomerBillingTypeException => 'NoCustomerBillingTypeException',
      _i107.NoSubscriptionException => 'NoSubscriptionException',
      _i108.NotFoundException => 'NotFoundException',
      _i109.PlanChangeDeniedException => 'PlanChangeDeniedException',
      _i110.PlanChangeDeniedReason => 'PlanChangeDeniedReason',
      _i111.ProcurementCancellationException =>
        'ProcurementCancellationException',
      _i112.ProcurementDeniedException => 'ProcurementDeniedException',
      _i113.ProcurementDeniedReason => 'ProcurementDeniedReason',
      _i114.UnauthenticatedException => 'UnauthenticatedException',
      _i115.UnauthorizedException => 'UnauthorizedException',
      _i116.HttpResponseClass => 'HttpResponseClass',
      _i117.ServerpodRegion => 'ServerpodRegion',
      _i118.PubsubEntry => 'PubsubEntry',
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
      case _i17.NoPriorDeploymentException():
        return 'NoPriorDeploymentException';
      case _i18.Capsule():
        return 'Capsule';
      case _i19.CapsuleResource():
        return 'CapsuleResource';
      case _i20.ComputeInfo():
        return 'ComputeInfo';
      case _i21.ComputeSizeOption():
        return 'ComputeSizeOption';
      case _i22.DatabaseSnapshotLimitException():
        return 'DatabaseSnapshotLimitException';
      case _i23.BackupFrequency():
        return 'BackupFrequency';
      case _i24.BackupSchedule():
        return 'BackupSchedule';
      case _i25.DatabaseConnection():
        return 'DatabaseConnection';
      case _i26.DatabaseInfo():
        return 'DatabaseInfo';
      case _i27.DatabaseProvider():
        return 'DatabaseProvider';
      case _i28.DatabaseProvisioning():
        return 'DatabaseProvisioning';
      case _i29.DatabaseProvisioningStatus():
        return 'DatabaseProvisioningStatus';
      case _i30.DatabaseQuota():
        return 'DatabaseQuota';
      case _i31.DatabaseResource():
        return 'DatabaseResource';
      case _i32.DatabaseScaling():
        return 'DatabaseScaling';
      case _i33.DatabaseSizeOption():
        return 'DatabaseSizeOption';
      case _i34.DatabaseSnapshot():
        return 'DatabaseSnapshot';
      case _i35.DatabaseStatus():
        return 'DatabaseStatus';
      case _i36.DatabaseUser():
        return 'DatabaseUser';
      case _i37.EnvironmentVariable():
        return 'EnvironmentVariable';
      case _i38.LogRecord():
        return 'LogRecord';
      case _i39.CapsuleNetworkSeries():
        return 'CapsuleNetworkSeries';
      case _i40.DatabaseMetrics():
        return 'DatabaseMetrics';
      case _i41.DatabaseMetricsStatus():
        return 'DatabaseMetricsStatus';
      case _i42.MetricSample():
        return 'MetricSample';
      case _i43.MetricsRange():
        return 'MetricsRange';
      case _i44.PodResourceSeries():
        return 'PodResourceSeries';
      case _i45.ResponseClassSeries():
        return 'ResponseClassSeries';
      case _i46.ComputeCatalogInfo():
        return 'ComputeCatalogInfo';
      case _i47.ComputeProductInfo():
        return 'ComputeProductInfo';
      case _i48.ComputeScalingInfo():
        return 'ComputeScalingInfo';
      case _i49.ConcurrentSubscriptionUpdateException():
        return 'ConcurrentSubscriptionUpdateException';
      case _i50.DatabaseCatalogInfo():
        return 'DatabaseCatalogInfo';
      case _i51.DatabaseProductInfo():
        return 'DatabaseProductInfo';
      case _i52.DatabaseScalingInfo():
        return 'DatabaseScalingInfo';
      case _i53.PlanInfo():
        return 'PlanInfo';
      case _i54.PlanType():
        return 'PlanType';
      case _i55.ProductType():
        return 'ProductType';
      case _i56.ProjectProductInfo():
        return 'ProjectProductInfo';
      case _i57.SubscriptionInfo():
        return 'SubscriptionInfo';
      case _i58.Project():
        return 'Project';
      case _i59.Role():
        return 'Role';
      case _i60.UserRoleMembership():
        return 'UserRoleMembership';
      case _i61.BuildSecretType():
        return 'BuildSecretType';
      case _i62.SecretResource():
        return 'SecretResource';
      case _i63.SecretType():
        return 'SecretType';
      case _i64.StoredSecretVersion():
        return 'StoredSecretVersion';
      case _i65.CapsuleDeploymentStatus():
        return 'CapsuleDeploymentStatus';
      case _i66.CapsuleRevision():
        return 'CapsuleRevision';
      case _i67.CapsuleState():
        return 'CapsuleState';
      case _i68.CapsuleStatus():
        return 'CapsuleStatus';
      case _i69.DeployAttempt():
        return 'DeployAttempt';
      case _i70.DeployAttemptStage():
        return 'DeployAttemptStage';
      case _i71.DeployProgressStatus():
        return 'DeployProgressStatus';
      case _i72.DeployStageType():
        return 'DeployStageType';
      case _i73.User():
        return 'User';
      case _i74.UserAccountStatus():
        return 'UserAccountStatus';
      case _i75.UserLabel():
        return 'UserLabel';
      case _i76.UserLabelMapping():
        return 'UserLabelMapping';
      case _i77.EmailMethodBlockedException():
        return 'EmailMethodBlockedException';
      case _i78.UserAccountRegistrationDeniedException():
        return 'UserAccountRegistrationDeniedException';
      case _i79.AcceptedTerms():
        return 'AcceptedTerms';
      case _i80.AcceptedTermsDTO():
        return 'AcceptedTermsDTO';
      case _i81.AuthTokenInfo():
        return 'AuthTokenInfo';
      case _i82.RequiredTerms():
        return 'RequiredTerms';
      case _i83.Terms():
        return 'Terms';
      case _i84.BucketStorageIdentityUnavailableException():
        return 'BucketStorageIdentityUnavailableException';
      case _i85.DNSVerificationFailedException():
        return 'DNSVerificationFailedException';
      case _i86.CustomDomainName():
        return 'CustomDomainName';
      case _i87.CustomDomainNameList():
        return 'CustomDomainNameList';
      case _i88.DnsRecordType():
        return 'DnsRecordType';
      case _i89.DomainNameStatus():
        return 'DomainNameStatus';
      case _i90.DomainNameTarget():
        return 'DomainNameTarget';
      case _i91.CustomDomainNameWithDefaultDomains():
        return 'CustomDomainNameWithDefaultDomains';
      case _i92.InsightsConnectionDetail():
        return 'InsightsConnectionDetail';
      case _i93.DartSdkVersion():
        return 'DartSdkVersion';
      case _i94.DartSdkVersionPolicy():
        return 'DartSdkVersionPolicy';
      case _i95.ProjectConfig():
        return 'ProjectConfig';
      case _i96.ProjectInfo():
        return 'ProjectInfo';
      case _i97.Timestamp():
        return 'Timestamp';
      case _i98.ProjectProfileUpdate():
        return 'ProjectProfileUpdate';
      case _i99.CapsuleStatusUnavailableException():
        return 'CapsuleStatusUnavailableException';
      case _i100.CapsuleRuntimeStatus():
        return 'CapsuleRuntimeStatus';
      case _i101.DeployAttemptSummary():
        return 'DeployAttemptSummary';
      case _i102.DartSdkUnsupportedConstraintException():
        return 'DartSdkUnsupportedConstraintException';
      case _i103.DatabaseNotReadyException():
        return 'DatabaseNotReadyException';
      case _i104.DuplicateEntryException():
        return 'DuplicateEntryException';
      case _i105.InvalidValueException():
        return 'InvalidValueException';
      case _i106.NoCustomerBillingTypeException():
        return 'NoCustomerBillingTypeException';
      case _i107.NoSubscriptionException():
        return 'NoSubscriptionException';
      case _i108.NotFoundException():
        return 'NotFoundException';
      case _i109.PlanChangeDeniedException():
        return 'PlanChangeDeniedException';
      case _i110.PlanChangeDeniedReason():
        return 'PlanChangeDeniedReason';
      case _i111.ProcurementCancellationException():
        return 'ProcurementCancellationException';
      case _i112.ProcurementDeniedException():
        return 'ProcurementDeniedException';
      case _i113.ProcurementDeniedReason():
        return 'ProcurementDeniedReason';
      case _i114.UnauthenticatedException():
        return 'UnauthenticatedException';
      case _i115.UnauthorizedException():
        return 'UnauthorizedException';
      case _i116.HttpResponseClass():
        return 'HttpResponseClass';
      case _i117.ServerpodRegion():
        return 'ServerpodRegion';
      case _i118.PubsubEntry():
        return 'PubsubEntry';
    }
    className = _i136.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _i137.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
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
    if (dataClassName == 'NoPriorDeploymentException') {
      return deserialize<_i17.NoPriorDeploymentException>(data['data']);
    }
    if (dataClassName == 'Capsule') {
      return deserialize<_i18.Capsule>(data['data']);
    }
    if (dataClassName == 'CapsuleResource') {
      return deserialize<_i19.CapsuleResource>(data['data']);
    }
    if (dataClassName == 'ComputeInfo') {
      return deserialize<_i20.ComputeInfo>(data['data']);
    }
    if (dataClassName == 'ComputeSizeOption') {
      return deserialize<_i21.ComputeSizeOption>(data['data']);
    }
    if (dataClassName == 'DatabaseSnapshotLimitException') {
      return deserialize<_i22.DatabaseSnapshotLimitException>(data['data']);
    }
    if (dataClassName == 'BackupFrequency') {
      return deserialize<_i23.BackupFrequency>(data['data']);
    }
    if (dataClassName == 'BackupSchedule') {
      return deserialize<_i24.BackupSchedule>(data['data']);
    }
    if (dataClassName == 'DatabaseConnection') {
      return deserialize<_i25.DatabaseConnection>(data['data']);
    }
    if (dataClassName == 'DatabaseInfo') {
      return deserialize<_i26.DatabaseInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseProvider') {
      return deserialize<_i27.DatabaseProvider>(data['data']);
    }
    if (dataClassName == 'DatabaseProvisioning') {
      return deserialize<_i28.DatabaseProvisioning>(data['data']);
    }
    if (dataClassName == 'DatabaseProvisioningStatus') {
      return deserialize<_i29.DatabaseProvisioningStatus>(data['data']);
    }
    if (dataClassName == 'DatabaseQuota') {
      return deserialize<_i30.DatabaseQuota>(data['data']);
    }
    if (dataClassName == 'DatabaseResource') {
      return deserialize<_i31.DatabaseResource>(data['data']);
    }
    if (dataClassName == 'DatabaseScaling') {
      return deserialize<_i32.DatabaseScaling>(data['data']);
    }
    if (dataClassName == 'DatabaseSizeOption') {
      return deserialize<_i33.DatabaseSizeOption>(data['data']);
    }
    if (dataClassName == 'DatabaseSnapshot') {
      return deserialize<_i34.DatabaseSnapshot>(data['data']);
    }
    if (dataClassName == 'DatabaseStatus') {
      return deserialize<_i35.DatabaseStatus>(data['data']);
    }
    if (dataClassName == 'DatabaseUser') {
      return deserialize<_i36.DatabaseUser>(data['data']);
    }
    if (dataClassName == 'EnvironmentVariable') {
      return deserialize<_i37.EnvironmentVariable>(data['data']);
    }
    if (dataClassName == 'LogRecord') {
      return deserialize<_i38.LogRecord>(data['data']);
    }
    if (dataClassName == 'CapsuleNetworkSeries') {
      return deserialize<_i39.CapsuleNetworkSeries>(data['data']);
    }
    if (dataClassName == 'DatabaseMetrics') {
      return deserialize<_i40.DatabaseMetrics>(data['data']);
    }
    if (dataClassName == 'DatabaseMetricsStatus') {
      return deserialize<_i41.DatabaseMetricsStatus>(data['data']);
    }
    if (dataClassName == 'MetricSample') {
      return deserialize<_i42.MetricSample>(data['data']);
    }
    if (dataClassName == 'MetricsRange') {
      return deserialize<_i43.MetricsRange>(data['data']);
    }
    if (dataClassName == 'PodResourceSeries') {
      return deserialize<_i44.PodResourceSeries>(data['data']);
    }
    if (dataClassName == 'ResponseClassSeries') {
      return deserialize<_i45.ResponseClassSeries>(data['data']);
    }
    if (dataClassName == 'ComputeCatalogInfo') {
      return deserialize<_i46.ComputeCatalogInfo>(data['data']);
    }
    if (dataClassName == 'ComputeProductInfo') {
      return deserialize<_i47.ComputeProductInfo>(data['data']);
    }
    if (dataClassName == 'ComputeScalingInfo') {
      return deserialize<_i48.ComputeScalingInfo>(data['data']);
    }
    if (dataClassName == 'ConcurrentSubscriptionUpdateException') {
      return deserialize<_i49.ConcurrentSubscriptionUpdateException>(
        data['data'],
      );
    }
    if (dataClassName == 'DatabaseCatalogInfo') {
      return deserialize<_i50.DatabaseCatalogInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseProductInfo') {
      return deserialize<_i51.DatabaseProductInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseScalingInfo') {
      return deserialize<_i52.DatabaseScalingInfo>(data['data']);
    }
    if (dataClassName == 'PlanInfo') {
      return deserialize<_i53.PlanInfo>(data['data']);
    }
    if (dataClassName == 'PlanType') {
      return deserialize<_i54.PlanType>(data['data']);
    }
    if (dataClassName == 'ProductType') {
      return deserialize<_i55.ProductType>(data['data']);
    }
    if (dataClassName == 'ProjectProductInfo') {
      return deserialize<_i56.ProjectProductInfo>(data['data']);
    }
    if (dataClassName == 'SubscriptionInfo') {
      return deserialize<_i57.SubscriptionInfo>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i58.Project>(data['data']);
    }
    if (dataClassName == 'Role') {
      return deserialize<_i59.Role>(data['data']);
    }
    if (dataClassName == 'UserRoleMembership') {
      return deserialize<_i60.UserRoleMembership>(data['data']);
    }
    if (dataClassName == 'BuildSecretType') {
      return deserialize<_i61.BuildSecretType>(data['data']);
    }
    if (dataClassName == 'SecretResource') {
      return deserialize<_i62.SecretResource>(data['data']);
    }
    if (dataClassName == 'SecretType') {
      return deserialize<_i63.SecretType>(data['data']);
    }
    if (dataClassName == 'StoredSecretVersion') {
      return deserialize<_i64.StoredSecretVersion>(data['data']);
    }
    if (dataClassName == 'CapsuleDeploymentStatus') {
      return deserialize<_i65.CapsuleDeploymentStatus>(data['data']);
    }
    if (dataClassName == 'CapsuleRevision') {
      return deserialize<_i66.CapsuleRevision>(data['data']);
    }
    if (dataClassName == 'CapsuleState') {
      return deserialize<_i67.CapsuleState>(data['data']);
    }
    if (dataClassName == 'CapsuleStatus') {
      return deserialize<_i68.CapsuleStatus>(data['data']);
    }
    if (dataClassName == 'DeployAttempt') {
      return deserialize<_i69.DeployAttempt>(data['data']);
    }
    if (dataClassName == 'DeployAttemptStage') {
      return deserialize<_i70.DeployAttemptStage>(data['data']);
    }
    if (dataClassName == 'DeployProgressStatus') {
      return deserialize<_i71.DeployProgressStatus>(data['data']);
    }
    if (dataClassName == 'DeployStageType') {
      return deserialize<_i72.DeployStageType>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i73.User>(data['data']);
    }
    if (dataClassName == 'UserAccountStatus') {
      return deserialize<_i74.UserAccountStatus>(data['data']);
    }
    if (dataClassName == 'UserLabel') {
      return deserialize<_i75.UserLabel>(data['data']);
    }
    if (dataClassName == 'UserLabelMapping') {
      return deserialize<_i76.UserLabelMapping>(data['data']);
    }
    if (dataClassName == 'EmailMethodBlockedException') {
      return deserialize<_i77.EmailMethodBlockedException>(data['data']);
    }
    if (dataClassName == 'UserAccountRegistrationDeniedException') {
      return deserialize<_i78.UserAccountRegistrationDeniedException>(
        data['data'],
      );
    }
    if (dataClassName == 'AcceptedTerms') {
      return deserialize<_i79.AcceptedTerms>(data['data']);
    }
    if (dataClassName == 'AcceptedTermsDTO') {
      return deserialize<_i80.AcceptedTermsDTO>(data['data']);
    }
    if (dataClassName == 'AuthTokenInfo') {
      return deserialize<_i81.AuthTokenInfo>(data['data']);
    }
    if (dataClassName == 'RequiredTerms') {
      return deserialize<_i82.RequiredTerms>(data['data']);
    }
    if (dataClassName == 'Terms') {
      return deserialize<_i83.Terms>(data['data']);
    }
    if (dataClassName == 'BucketStorageIdentityUnavailableException') {
      return deserialize<_i84.BucketStorageIdentityUnavailableException>(
        data['data'],
      );
    }
    if (dataClassName == 'DNSVerificationFailedException') {
      return deserialize<_i85.DNSVerificationFailedException>(data['data']);
    }
    if (dataClassName == 'CustomDomainName') {
      return deserialize<_i86.CustomDomainName>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameList') {
      return deserialize<_i87.CustomDomainNameList>(data['data']);
    }
    if (dataClassName == 'DnsRecordType') {
      return deserialize<_i88.DnsRecordType>(data['data']);
    }
    if (dataClassName == 'DomainNameStatus') {
      return deserialize<_i89.DomainNameStatus>(data['data']);
    }
    if (dataClassName == 'DomainNameTarget') {
      return deserialize<_i90.DomainNameTarget>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameWithDefaultDomains') {
      return deserialize<_i91.CustomDomainNameWithDefaultDomains>(data['data']);
    }
    if (dataClassName == 'InsightsConnectionDetail') {
      return deserialize<_i92.InsightsConnectionDetail>(data['data']);
    }
    if (dataClassName == 'DartSdkVersion') {
      return deserialize<_i93.DartSdkVersion>(data['data']);
    }
    if (dataClassName == 'DartSdkVersionPolicy') {
      return deserialize<_i94.DartSdkVersionPolicy>(data['data']);
    }
    if (dataClassName == 'ProjectConfig') {
      return deserialize<_i95.ProjectConfig>(data['data']);
    }
    if (dataClassName == 'ProjectInfo') {
      return deserialize<_i96.ProjectInfo>(data['data']);
    }
    if (dataClassName == 'Timestamp') {
      return deserialize<_i97.Timestamp>(data['data']);
    }
    if (dataClassName == 'ProjectProfileUpdate') {
      return deserialize<_i98.ProjectProfileUpdate>(data['data']);
    }
    if (dataClassName == 'CapsuleStatusUnavailableException') {
      return deserialize<_i99.CapsuleStatusUnavailableException>(data['data']);
    }
    if (dataClassName == 'CapsuleRuntimeStatus') {
      return deserialize<_i100.CapsuleRuntimeStatus>(data['data']);
    }
    if (dataClassName == 'DeployAttemptSummary') {
      return deserialize<_i101.DeployAttemptSummary>(data['data']);
    }
    if (dataClassName == 'DartSdkUnsupportedConstraintException') {
      return deserialize<_i102.DartSdkUnsupportedConstraintException>(
        data['data'],
      );
    }
    if (dataClassName == 'DatabaseNotReadyException') {
      return deserialize<_i103.DatabaseNotReadyException>(data['data']);
    }
    if (dataClassName == 'DuplicateEntryException') {
      return deserialize<_i104.DuplicateEntryException>(data['data']);
    }
    if (dataClassName == 'InvalidValueException') {
      return deserialize<_i105.InvalidValueException>(data['data']);
    }
    if (dataClassName == 'NoCustomerBillingTypeException') {
      return deserialize<_i106.NoCustomerBillingTypeException>(data['data']);
    }
    if (dataClassName == 'NoSubscriptionException') {
      return deserialize<_i107.NoSubscriptionException>(data['data']);
    }
    if (dataClassName == 'NotFoundException') {
      return deserialize<_i108.NotFoundException>(data['data']);
    }
    if (dataClassName == 'PlanChangeDeniedException') {
      return deserialize<_i109.PlanChangeDeniedException>(data['data']);
    }
    if (dataClassName == 'PlanChangeDeniedReason') {
      return deserialize<_i110.PlanChangeDeniedReason>(data['data']);
    }
    if (dataClassName == 'ProcurementCancellationException') {
      return deserialize<_i111.ProcurementCancellationException>(data['data']);
    }
    if (dataClassName == 'ProcurementDeniedException') {
      return deserialize<_i112.ProcurementDeniedException>(data['data']);
    }
    if (dataClassName == 'ProcurementDeniedReason') {
      return deserialize<_i113.ProcurementDeniedReason>(data['data']);
    }
    if (dataClassName == 'UnauthenticatedException') {
      return deserialize<_i114.UnauthenticatedException>(data['data']);
    }
    if (dataClassName == 'UnauthorizedException') {
      return deserialize<_i115.UnauthorizedException>(data['data']);
    }
    if (dataClassName == 'HttpResponseClass') {
      return deserialize<_i116.HttpResponseClass>(data['data']);
    }
    if (dataClassName == 'ServerpodRegion') {
      return deserialize<_i117.ServerpodRegion>(data['data']);
    }
    if (dataClassName == 'PubsubEntry') {
      return deserialize<_i118.PubsubEntry>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i136.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i137.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _i136.Protocol().registerHostProtocol('ground_control', this);
    _i137.Protocol().registerHostProtocol('ground_control', this);
  }

  @override
  String getModuleName() => 'ground_control';

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
      return _i136.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i137.Protocol().mapRecordToJson(record);
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

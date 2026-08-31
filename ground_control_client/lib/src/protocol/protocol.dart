/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, no_leading_underscores_for_library_prefixes
// ignore_for_file: unnecessary_type_check

import 'package:ground_control_client/src/protocol/domains/billing/models/payment_method.dart'
    as _itisjjd4;
import 'package:ground_control_client/src/protocol/domains/buckets/models/bucket_resource.dart'
    as _itj7xmug;
import 'package:ground_control_client/src/protocol/domains/databases/models/database_snapshot.dart'
    as _ia6js50c;
import 'package:ground_control_client/src/protocol/domains/databases/models/database_user.dart'
    as _iztc790o;
import 'package:ground_control_client/src/protocol/domains/environment_variables/models/variable.dart'
    as _i82frs35;
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
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i51mvi6s;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _iy77socp;
import 'package:ground_control_client/src/protocol/domains/users/models/user.dart'
    as _ibu0ogga;
import 'package:ground_control_client/src/protocol/features/auth/models/accepted_terms_dto.dart'
    as _irrma5ts;
import 'package:ground_control_client/src/protocol/features/auth/models/auth_token_info.dart'
    as _i9cx54ed;
import 'package:ground_control_client/src/protocol/features/auth/models/required_terms.dart'
    as _iu79vy7r;
import 'package:ground_control_client/src/protocol/features/projects/models/project_info/project_info.dart'
    as _ixukenxa;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'domains/billing/models/billing_customer_type.dart' as _i4m2a6uw;
import 'domains/billing/models/billing_info.dart' as _i7vhubyw;
import 'domains/billing/models/billing_mapping_type.dart' as _i0j2fm74;
import 'domains/billing/models/owner.dart' as _i7df4v4i;
import 'domains/billing/models/payment_method.dart' as _ikeafg5a;
import 'domains/billing/models/payment_method_card.dart' as _i4cauyzh;
import 'domains/billing/models/payment_setup_intent.dart' as _iq0xsybs;
import 'domains/buckets/models/bucket_access_revocation_reason.dart'
    as _i2gsen8i;
import 'domains/buckets/models/bucket_file.dart' as _i8dv9s28;
import 'domains/buckets/models/bucket_file_listing.dart' as _ixt62bhu;
import 'domains/buckets/models/bucket_provider.dart' as _i8eu07u2;
import 'domains/buckets/models/bucket_resource.dart' as _ikzjts3s;
import 'domains/buckets/models/bucket_service_account.dart' as _it8lkrr1;
import 'domains/buckets/models/bucket_service_account_status.dart' as _i3vivpe2;
import 'domains/buckets/models/bucket_status.dart' as _isqha6b2;
import 'domains/buckets/models/bucket_visibility.dart' as _in5j38rp;
import 'domains/capsules/exceptions/no_prior_deployment_exception.dart'
    as _ixm27pxa;
import 'domains/capsules/models/capsule.dart' as _ibqxrsez;
import 'domains/capsules/models/capsule_resource_config.dart' as _ilh5zv14;
import 'domains/capsules/models/compute_info.dart' as _i2jsgnwd;
import 'domains/capsules/models/compute_size_option.dart' as _isncq5hp;
import 'domains/databases/exceptions/database_snapshot_limit_exception.dart'
    as _io3hi6yc;
import 'domains/databases/models/backup_frequency.dart' as _ifv8l1c3;
import 'domains/databases/models/backup_schedule.dart' as _iy6lcw8y;
import 'domains/databases/models/database_connection.dart' as _ipqxgh3i;
import 'domains/databases/models/database_info.dart' as _islskkwv;
import 'domains/databases/models/database_provider.dart' as _iptvro4o;
import 'domains/databases/models/database_quota.dart' as _inz8j88p;
import 'domains/databases/models/database_resource.dart' as _i49mcfnh;
import 'domains/databases/models/database_scaling.dart' as _i6xy85up;
import 'domains/databases/models/database_size.dart' as _ifxd5ia6;
import 'domains/databases/models/database_snapshot.dart' as _i1q8jyc7;
import 'domains/databases/models/database_user.dart' as _iiqkhpys;
import 'domains/environment_variables/models/variable.dart' as _i7s8kwes;
import 'domains/logs/models/log_record.dart' as _iwt7hqgw;
import 'domains/metrics/models/capsule_network_series.dart' as _izgm68si;
import 'domains/metrics/models/database_metrics.dart' as _ifq3txzx;
import 'domains/metrics/models/database_metrics_status.dart' as _ihqubfzc;
import 'domains/metrics/models/metric_sample.dart' as _ixjvnalq;
import 'domains/metrics/models/metrics_range.dart' as _igwmelc6;
import 'domains/metrics/models/pod_resource_series.dart' as _ia30stxm;
import 'domains/metrics/models/response_class_series.dart' as _i9u2had9;
import 'domains/products/models/compute_catalog_info.dart' as _i6f96f3s;
import 'domains/products/models/compute_product_info.dart' as _ixsx3y2g;
import 'domains/products/models/compute_scaling_info.dart' as _ijiweskq;
import 'domains/products/models/concurrent_subscription_update_exception.dart'
    as _ik99pp4r;
import 'domains/products/models/database_catalog_info.dart' as _i1kxda18;
import 'domains/products/models/database_product_info.dart' as _ie5edybc;
import 'domains/products/models/database_scaling_info.dart' as _i7kd6f8h;
import 'domains/products/models/plan_info.dart' as _ioxhthdl;
import 'domains/products/models/plan_type.dart' as _iagjhgs9;
import 'domains/products/models/product_type.dart' as _is6epy3v;
import 'domains/products/models/project_product_info.dart' as _iwmabm4s;
import 'domains/products/models/subscription_info.dart' as _iera5yzg;
import 'domains/projects/models/project.dart' as _immj5l46;
import 'domains/projects/models/role.dart' as _iw41fb37;
import 'domains/projects/models/user_role_membership.dart' as _icd2sct1;
import 'domains/secrets/models/build_secret_type.dart' as _ikwy8e1b;
import 'domains/secrets/models/secret_resource.dart' as _i3g0ekuz;
import 'domains/secrets/models/secret_type.dart' as _immhj4v3;
import 'domains/secrets/models/stored_secret_version.dart' as _i7kzg109;
import 'domains/status/models/capsule_deployment_status.dart' as _im62j85v;
import 'domains/status/models/capsule_revision.dart' as _i3wrl47t;
import 'domains/status/models/capsule_state.dart' as _in4d44nu;
import 'domains/status/models/capsule_status.dart' as _icnre768;
import 'domains/status/models/deploy_attempt.dart' as _iov43xof;
import 'domains/status/models/deploy_attempt_stage.dart' as _iwfg38ma;
import 'domains/status/models/deploy_progress_status.dart' as _i7neienr;
import 'domains/status/models/deploy_stage_type.dart' as _imfv08in;
import 'domains/users/models/user.dart' as _iz26r0wp;
import 'domains/users/models/user_account_status.dart' as _iu2mqg52;
import 'domains/users/models/user_label.dart' as _iptirt7i;
import 'domains/users/models/user_label_mapping.dart' as _im281b2u;
import 'features/auth/exceptions/email_method_blocked_exception.dart'
    as _ihqdfodo;
import 'features/auth/exceptions/user_account_registration_denied_exception.dart'
    as _ilk02hh2;
import 'features/auth/models/accepted_terms.dart' as _iq25bick;
import 'features/auth/models/accepted_terms_dto.dart' as _i8z78m78;
import 'features/auth/models/auth_token_info.dart' as _ic6o6jk9;
import 'features/auth/models/required_terms.dart' as _il367b51;
import 'features/auth/models/terms.dart' as _i5k61oox;
import 'features/buckets/exceptions/bucket_storage_identity_unavailable_exception.dart'
    as _ih9vxrpp;
import 'features/custom_domains/exceptions/dns_verification_failed_exception.dart'
    as _in5svsiw;
import 'features/custom_domains/models/custom_domain_name.dart' as _ia7ohsf2;
import 'features/custom_domains/models/custom_domain_name_list.dart'
    as _iw8cnhxy;
import 'features/custom_domains/models/dns_record_type.dart' as _ii5jxrig;
import 'features/custom_domains/models/domain_name_status.dart' as _i95e195t;
import 'features/custom_domains/models/domain_name_target.dart' as _idr3lfj1;
import 'features/custom_domains/models/view_models/custom_domain_name_with_default_domains.dart'
    as _ivf1sqm0;
import 'features/insights/models/insights_connection_detail.dart' as _irxldgjy;
import 'features/platform/models/dart_sdk_version.dart' as _ixr2s32y;
import 'features/platform/models/dart_sdk_version_policy.dart' as _iv0kay60;
import 'features/projects/models/project_config.dart' as _ib7pq1fg;
import 'features/projects/models/project_info/project_info.dart' as _i0cd290p;
import 'features/projects/models/project_info/timestamp.dart' as _iaa2toio;
import 'features/projects/models/project_profile_update.dart' as _id87teh5;
import 'features/status/exceptions/capsule_status_unavailable_exception.dart'
    as _iglg9o3u;
import 'features/status/models/capsule_runtime_status.dart' as _ivmk5dq6;
import 'features/status/models/deploy_attempt_summary.dart' as _iewvz7zd;
import 'shared/exceptions/models/dart_sdk_unsupported_constraint_exception.dart'
    as _iv8o207k;
import 'shared/exceptions/models/duplicate_entry_exception.dart' as _inn0ooo2;
import 'shared/exceptions/models/invalid_value_exception.dart' as _i8kl75v5;
import 'shared/exceptions/models/no_customer_billing_type_exception.dart'
    as _ijqib2z2;
import 'shared/exceptions/models/no_subscription_exception.dart' as _i8k8a030;
import 'shared/exceptions/models/not_found_exception.dart' as _iffy9d8d;
import 'shared/exceptions/models/plan_change_denied_exception.dart'
    as _iawp7ytp;
import 'shared/exceptions/models/plan_change_denied_reason.dart' as _iwnitgrm;
import 'shared/exceptions/models/procurement_cancellation_exception.dart'
    as _ijkhxmuq;
import 'shared/exceptions/models/procurement_denied_exception.dart'
    as _iw0gwwvc;
import 'shared/exceptions/models/procurement_denied_reason.dart' as _iibx2ckv;
import 'shared/exceptions/models/unauthenticated_exception.dart' as _i8itwzl1;
import 'shared/exceptions/models/unauthorized_exception.dart' as _is3nd795;
import 'shared/models/http_response_class.dart' as _is21hzeq;
import 'shared/models/serverpod_region.dart' as _i3qziuyp;
import 'shared/pubsub/registry/pubsub_entry.dart' as _i1i04ivn;
export 'domains/billing/models/billing_customer_type.dart';
export 'domains/billing/models/billing_info.dart';
export 'domains/billing/models/billing_mapping_type.dart';
export 'domains/billing/models/owner.dart';
export 'domains/billing/models/payment_method.dart';
export 'domains/billing/models/payment_method_card.dart';
export 'domains/billing/models/payment_setup_intent.dart';
export 'domains/buckets/models/bucket_access_revocation_reason.dart';
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
export 'domains/databases/models/database_quota.dart';
export 'domains/databases/models/database_resource.dart';
export 'domains/databases/models/database_scaling.dart';
export 'domains/databases/models/database_size.dart';
export 'domains/databases/models/database_snapshot.dart';
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

class Protocol extends _isc.SerializationManager {
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

    if (t == _i4m2a6uw.BillingCustomerType) {
      return _i4m2a6uw.BillingCustomerType.fromJson(data) as T;
    }
    if (t == _i7vhubyw.BillingInfo) {
      return _i7vhubyw.BillingInfo.fromJson(data) as T;
    }
    if (t == _i0j2fm74.BillingMappingType) {
      return _i0j2fm74.BillingMappingType.fromJson(data) as T;
    }
    if (t == _i7df4v4i.Owner) {
      return _i7df4v4i.Owner.fromJson(data) as T;
    }
    if (t == _ikeafg5a.PaymentMethod) {
      return _ikeafg5a.PaymentMethod.fromJson(data) as T;
    }
    if (t == _i4cauyzh.PaymentMethodCard) {
      return _i4cauyzh.PaymentMethodCard.fromJson(data) as T;
    }
    if (t == _iq0xsybs.PaymentSetupIntent) {
      return _iq0xsybs.PaymentSetupIntent.fromJson(data) as T;
    }
    if (t == _i2gsen8i.BucketAccessRevocationReason) {
      return _i2gsen8i.BucketAccessRevocationReason.fromJson(data) as T;
    }
    if (t == _i8dv9s28.BucketFile) {
      return _i8dv9s28.BucketFile.fromJson(data) as T;
    }
    if (t == _ixt62bhu.BucketFileListing) {
      return _ixt62bhu.BucketFileListing.fromJson(data) as T;
    }
    if (t == _i8eu07u2.BucketProvider) {
      return _i8eu07u2.BucketProvider.fromJson(data) as T;
    }
    if (t == _ikzjts3s.BucketResource) {
      return _ikzjts3s.BucketResource.fromJson(data) as T;
    }
    if (t == _it8lkrr1.BucketServiceAccount) {
      return _it8lkrr1.BucketServiceAccount.fromJson(data) as T;
    }
    if (t == _i3vivpe2.BucketServiceAccountStatus) {
      return _i3vivpe2.BucketServiceAccountStatus.fromJson(data) as T;
    }
    if (t == _isqha6b2.BucketStatus) {
      return _isqha6b2.BucketStatus.fromJson(data) as T;
    }
    if (t == _in5j38rp.BucketVisibility) {
      return _in5j38rp.BucketVisibility.fromJson(data) as T;
    }
    if (t == _ixm27pxa.NoPriorDeploymentException) {
      return _ixm27pxa.NoPriorDeploymentException.fromJson(data) as T;
    }
    if (t == _ibqxrsez.Capsule) {
      return _ibqxrsez.Capsule.fromJson(data) as T;
    }
    if (t == _ilh5zv14.CapsuleResource) {
      return _ilh5zv14.CapsuleResource.fromJson(data) as T;
    }
    if (t == _i2jsgnwd.ComputeInfo) {
      return _i2jsgnwd.ComputeInfo.fromJson(data) as T;
    }
    if (t == _isncq5hp.ComputeSizeOption) {
      return _isncq5hp.ComputeSizeOption.fromJson(data) as T;
    }
    if (t == _io3hi6yc.DatabaseSnapshotLimitException) {
      return _io3hi6yc.DatabaseSnapshotLimitException.fromJson(data) as T;
    }
    if (t == _ifv8l1c3.BackupFrequency) {
      return _ifv8l1c3.BackupFrequency.fromJson(data) as T;
    }
    if (t == _iy6lcw8y.BackupSchedule) {
      return _iy6lcw8y.BackupSchedule.fromJson(data) as T;
    }
    if (t == _ipqxgh3i.DatabaseConnection) {
      return _ipqxgh3i.DatabaseConnection.fromJson(data) as T;
    }
    if (t == _islskkwv.DatabaseInfo) {
      return _islskkwv.DatabaseInfo.fromJson(data) as T;
    }
    if (t == _iptvro4o.DatabaseProvider) {
      return _iptvro4o.DatabaseProvider.fromJson(data) as T;
    }
    if (t == _inz8j88p.DatabaseQuota) {
      return _inz8j88p.DatabaseQuota.fromJson(data) as T;
    }
    if (t == _i49mcfnh.DatabaseResource) {
      return _i49mcfnh.DatabaseResource.fromJson(data) as T;
    }
    if (t == _i6xy85up.DatabaseScaling) {
      return _i6xy85up.DatabaseScaling.fromJson(data) as T;
    }
    if (t == _ifxd5ia6.DatabaseSizeOption) {
      return _ifxd5ia6.DatabaseSizeOption.fromJson(data) as T;
    }
    if (t == _i1q8jyc7.DatabaseSnapshot) {
      return _i1q8jyc7.DatabaseSnapshot.fromJson(data) as T;
    }
    if (t == _iiqkhpys.DatabaseUser) {
      return _iiqkhpys.DatabaseUser.fromJson(data) as T;
    }
    if (t == _i7s8kwes.EnvironmentVariable) {
      return _i7s8kwes.EnvironmentVariable.fromJson(data) as T;
    }
    if (t == _iwt7hqgw.LogRecord) {
      return _iwt7hqgw.LogRecord.fromJson(data) as T;
    }
    if (t == _izgm68si.CapsuleNetworkSeries) {
      return _izgm68si.CapsuleNetworkSeries.fromJson(data) as T;
    }
    if (t == _ifq3txzx.DatabaseMetrics) {
      return _ifq3txzx.DatabaseMetrics.fromJson(data) as T;
    }
    if (t == _ihqubfzc.DatabaseMetricsStatus) {
      return _ihqubfzc.DatabaseMetricsStatus.fromJson(data) as T;
    }
    if (t == _ixjvnalq.MetricSample) {
      return _ixjvnalq.MetricSample.fromJson(data) as T;
    }
    if (t == _igwmelc6.MetricsRange) {
      return _igwmelc6.MetricsRange.fromJson(data) as T;
    }
    if (t == _ia30stxm.PodResourceSeries) {
      return _ia30stxm.PodResourceSeries.fromJson(data) as T;
    }
    if (t == _i9u2had9.ResponseClassSeries) {
      return _i9u2had9.ResponseClassSeries.fromJson(data) as T;
    }
    if (t == _i6f96f3s.ComputeCatalogInfo) {
      return _i6f96f3s.ComputeCatalogInfo.fromJson(data) as T;
    }
    if (t == _ixsx3y2g.ComputeProductInfo) {
      return _ixsx3y2g.ComputeProductInfo.fromJson(data) as T;
    }
    if (t == _ijiweskq.ComputeScalingInfo) {
      return _ijiweskq.ComputeScalingInfo.fromJson(data) as T;
    }
    if (t == _ik99pp4r.ConcurrentSubscriptionUpdateException) {
      return _ik99pp4r.ConcurrentSubscriptionUpdateException.fromJson(data)
          as T;
    }
    if (t == _i1kxda18.DatabaseCatalogInfo) {
      return _i1kxda18.DatabaseCatalogInfo.fromJson(data) as T;
    }
    if (t == _ie5edybc.DatabaseProductInfo) {
      return _ie5edybc.DatabaseProductInfo.fromJson(data) as T;
    }
    if (t == _i7kd6f8h.DatabaseScalingInfo) {
      return _i7kd6f8h.DatabaseScalingInfo.fromJson(data) as T;
    }
    if (t == _ioxhthdl.PlanInfo) {
      return _ioxhthdl.PlanInfo.fromJson(data) as T;
    }
    if (t == _iagjhgs9.PlanType) {
      return _iagjhgs9.PlanType.fromJson(data) as T;
    }
    if (t == _is6epy3v.ProductType) {
      return _is6epy3v.ProductType.fromJson(data) as T;
    }
    if (t == _iwmabm4s.ProjectProductInfo) {
      return _iwmabm4s.ProjectProductInfo.fromJson(data) as T;
    }
    if (t == _iera5yzg.SubscriptionInfo) {
      return _iera5yzg.SubscriptionInfo.fromJson(data) as T;
    }
    if (t == _immj5l46.Project) {
      return _immj5l46.Project.fromJson(data) as T;
    }
    if (t == _iw41fb37.Role) {
      return _iw41fb37.Role.fromJson(data) as T;
    }
    if (t == _icd2sct1.UserRoleMembership) {
      return _icd2sct1.UserRoleMembership.fromJson(data) as T;
    }
    if (t == _ikwy8e1b.BuildSecretType) {
      return _ikwy8e1b.BuildSecretType.fromJson(data) as T;
    }
    if (t == _i3g0ekuz.SecretResource) {
      return _i3g0ekuz.SecretResource.fromJson(data) as T;
    }
    if (t == _immhj4v3.SecretType) {
      return _immhj4v3.SecretType.fromJson(data) as T;
    }
    if (t == _i7kzg109.StoredSecretVersion) {
      return _i7kzg109.StoredSecretVersion.fromJson(data) as T;
    }
    if (t == _im62j85v.CapsuleDeploymentStatus) {
      return _im62j85v.CapsuleDeploymentStatus.fromJson(data) as T;
    }
    if (t == _i3wrl47t.CapsuleRevision) {
      return _i3wrl47t.CapsuleRevision.fromJson(data) as T;
    }
    if (t == _in4d44nu.CapsuleState) {
      return _in4d44nu.CapsuleState.fromJson(data) as T;
    }
    if (t == _icnre768.CapsuleStatus) {
      return _icnre768.CapsuleStatus.fromJson(data) as T;
    }
    if (t == _iov43xof.DeployAttempt) {
      return _iov43xof.DeployAttempt.fromJson(data) as T;
    }
    if (t == _iwfg38ma.DeployAttemptStage) {
      return _iwfg38ma.DeployAttemptStage.fromJson(data) as T;
    }
    if (t == _i7neienr.DeployProgressStatus) {
      return _i7neienr.DeployProgressStatus.fromJson(data) as T;
    }
    if (t == _imfv08in.DeployStageType) {
      return _imfv08in.DeployStageType.fromJson(data) as T;
    }
    if (t == _iz26r0wp.User) {
      return _iz26r0wp.User.fromJson(data) as T;
    }
    if (t == _iu2mqg52.UserAccountStatus) {
      return _iu2mqg52.UserAccountStatus.fromJson(data) as T;
    }
    if (t == _iptirt7i.UserLabel) {
      return _iptirt7i.UserLabel.fromJson(data) as T;
    }
    if (t == _im281b2u.UserLabelMapping) {
      return _im281b2u.UserLabelMapping.fromJson(data) as T;
    }
    if (t == _ihqdfodo.EmailMethodBlockedException) {
      return _ihqdfodo.EmailMethodBlockedException.fromJson(data) as T;
    }
    if (t == _ilk02hh2.UserAccountRegistrationDeniedException) {
      return _ilk02hh2.UserAccountRegistrationDeniedException.fromJson(data)
          as T;
    }
    if (t == _iq25bick.AcceptedTerms) {
      return _iq25bick.AcceptedTerms.fromJson(data) as T;
    }
    if (t == _i8z78m78.AcceptedTermsDTO) {
      return _i8z78m78.AcceptedTermsDTO.fromJson(data) as T;
    }
    if (t == _ic6o6jk9.AuthTokenInfo) {
      return _ic6o6jk9.AuthTokenInfo.fromJson(data) as T;
    }
    if (t == _il367b51.RequiredTerms) {
      return _il367b51.RequiredTerms.fromJson(data) as T;
    }
    if (t == _i5k61oox.Terms) {
      return _i5k61oox.Terms.fromJson(data) as T;
    }
    if (t == _ih9vxrpp.BucketStorageIdentityUnavailableException) {
      return _ih9vxrpp.BucketStorageIdentityUnavailableException.fromJson(data)
          as T;
    }
    if (t == _in5svsiw.DNSVerificationFailedException) {
      return _in5svsiw.DNSVerificationFailedException.fromJson(data) as T;
    }
    if (t == _ia7ohsf2.CustomDomainName) {
      return _ia7ohsf2.CustomDomainName.fromJson(data) as T;
    }
    if (t == _iw8cnhxy.CustomDomainNameList) {
      return _iw8cnhxy.CustomDomainNameList.fromJson(data) as T;
    }
    if (t == _ii5jxrig.DnsRecordType) {
      return _ii5jxrig.DnsRecordType.fromJson(data) as T;
    }
    if (t == _i95e195t.DomainNameStatus) {
      return _i95e195t.DomainNameStatus.fromJson(data) as T;
    }
    if (t == _idr3lfj1.DomainNameTarget) {
      return _idr3lfj1.DomainNameTarget.fromJson(data) as T;
    }
    if (t == _ivf1sqm0.CustomDomainNameWithDefaultDomains) {
      return _ivf1sqm0.CustomDomainNameWithDefaultDomains.fromJson(data) as T;
    }
    if (t == _irxldgjy.InsightsConnectionDetail) {
      return _irxldgjy.InsightsConnectionDetail.fromJson(data) as T;
    }
    if (t == _ixr2s32y.DartSdkVersion) {
      return _ixr2s32y.DartSdkVersion.fromJson(data) as T;
    }
    if (t == _iv0kay60.DartSdkVersionPolicy) {
      return _iv0kay60.DartSdkVersionPolicy.fromJson(data) as T;
    }
    if (t == _ib7pq1fg.ProjectConfig) {
      return _ib7pq1fg.ProjectConfig.fromJson(data) as T;
    }
    if (t == _i0cd290p.ProjectInfo) {
      return _i0cd290p.ProjectInfo.fromJson(data) as T;
    }
    if (t == _iaa2toio.Timestamp) {
      return _iaa2toio.Timestamp.fromJson(data) as T;
    }
    if (t == _id87teh5.ProjectProfileUpdate) {
      return _id87teh5.ProjectProfileUpdate.fromJson(data) as T;
    }
    if (t == _iglg9o3u.CapsuleStatusUnavailableException) {
      return _iglg9o3u.CapsuleStatusUnavailableException.fromJson(data) as T;
    }
    if (t == _ivmk5dq6.CapsuleRuntimeStatus) {
      return _ivmk5dq6.CapsuleRuntimeStatus.fromJson(data) as T;
    }
    if (t == _iewvz7zd.DeployAttemptSummary) {
      return _iewvz7zd.DeployAttemptSummary.fromJson(data) as T;
    }
    if (t == _iv8o207k.DartSdkUnsupportedConstraintException) {
      return _iv8o207k.DartSdkUnsupportedConstraintException.fromJson(data)
          as T;
    }
    if (t == _inn0ooo2.DuplicateEntryException) {
      return _inn0ooo2.DuplicateEntryException.fromJson(data) as T;
    }
    if (t == _i8kl75v5.InvalidValueException) {
      return _i8kl75v5.InvalidValueException.fromJson(data) as T;
    }
    if (t == _ijqib2z2.NoCustomerBillingTypeException) {
      return _ijqib2z2.NoCustomerBillingTypeException.fromJson(data) as T;
    }
    if (t == _i8k8a030.NoSubscriptionException) {
      return _i8k8a030.NoSubscriptionException.fromJson(data) as T;
    }
    if (t == _iffy9d8d.NotFoundException) {
      return _iffy9d8d.NotFoundException.fromJson(data) as T;
    }
    if (t == _iawp7ytp.PlanChangeDeniedException) {
      return _iawp7ytp.PlanChangeDeniedException.fromJson(data) as T;
    }
    if (t == _iwnitgrm.PlanChangeDeniedReason) {
      return _iwnitgrm.PlanChangeDeniedReason.fromJson(data) as T;
    }
    if (t == _ijkhxmuq.ProcurementCancellationException) {
      return _ijkhxmuq.ProcurementCancellationException.fromJson(data) as T;
    }
    if (t == _iw0gwwvc.ProcurementDeniedException) {
      return _iw0gwwvc.ProcurementDeniedException.fromJson(data) as T;
    }
    if (t == _iibx2ckv.ProcurementDeniedReason) {
      return _iibx2ckv.ProcurementDeniedReason.fromJson(data) as T;
    }
    if (t == _i8itwzl1.UnauthenticatedException) {
      return _i8itwzl1.UnauthenticatedException.fromJson(data) as T;
    }
    if (t == _is3nd795.UnauthorizedException) {
      return _is3nd795.UnauthorizedException.fromJson(data) as T;
    }
    if (t == _is21hzeq.HttpResponseClass) {
      return _is21hzeq.HttpResponseClass.fromJson(data) as T;
    }
    if (t == _i3qziuyp.ServerpodRegion) {
      return _i3qziuyp.ServerpodRegion.fromJson(data) as T;
    }
    if (t == _i1i04ivn.PubsubEntry) {
      return _i1i04ivn.PubsubEntry.fromJson(data) as T;
    }
    if (t == _isc.getType<_i4m2a6uw.BillingCustomerType?>()) {
      return (data != null
              ? _i4m2a6uw.BillingCustomerType.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i7vhubyw.BillingInfo?>()) {
      return (data != null ? _i7vhubyw.BillingInfo.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i0j2fm74.BillingMappingType?>()) {
      return (data != null ? _i0j2fm74.BillingMappingType.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i7df4v4i.Owner?>()) {
      return (data != null ? _i7df4v4i.Owner.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ikeafg5a.PaymentMethod?>()) {
      return (data != null ? _ikeafg5a.PaymentMethod.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i4cauyzh.PaymentMethodCard?>()) {
      return (data != null ? _i4cauyzh.PaymentMethodCard.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iq0xsybs.PaymentSetupIntent?>()) {
      return (data != null ? _iq0xsybs.PaymentSetupIntent.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i2gsen8i.BucketAccessRevocationReason?>()) {
      return (data != null
              ? _i2gsen8i.BucketAccessRevocationReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i8dv9s28.BucketFile?>()) {
      return (data != null ? _i8dv9s28.BucketFile.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ixt62bhu.BucketFileListing?>()) {
      return (data != null ? _ixt62bhu.BucketFileListing.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i8eu07u2.BucketProvider?>()) {
      return (data != null ? _i8eu07u2.BucketProvider.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ikzjts3s.BucketResource?>()) {
      return (data != null ? _ikzjts3s.BucketResource.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_it8lkrr1.BucketServiceAccount?>()) {
      return (data != null
              ? _it8lkrr1.BucketServiceAccount.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i3vivpe2.BucketServiceAccountStatus?>()) {
      return (data != null
              ? _i3vivpe2.BucketServiceAccountStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_isqha6b2.BucketStatus?>()) {
      return (data != null ? _isqha6b2.BucketStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_in5j38rp.BucketVisibility?>()) {
      return (data != null ? _in5j38rp.BucketVisibility.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ixm27pxa.NoPriorDeploymentException?>()) {
      return (data != null
              ? _ixm27pxa.NoPriorDeploymentException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ibqxrsez.Capsule?>()) {
      return (data != null ? _ibqxrsez.Capsule.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ilh5zv14.CapsuleResource?>()) {
      return (data != null ? _ilh5zv14.CapsuleResource.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i2jsgnwd.ComputeInfo?>()) {
      return (data != null ? _i2jsgnwd.ComputeInfo.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_isncq5hp.ComputeSizeOption?>()) {
      return (data != null ? _isncq5hp.ComputeSizeOption.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_io3hi6yc.DatabaseSnapshotLimitException?>()) {
      return (data != null
              ? _io3hi6yc.DatabaseSnapshotLimitException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ifv8l1c3.BackupFrequency?>()) {
      return (data != null ? _ifv8l1c3.BackupFrequency.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iy6lcw8y.BackupSchedule?>()) {
      return (data != null ? _iy6lcw8y.BackupSchedule.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ipqxgh3i.DatabaseConnection?>()) {
      return (data != null ? _ipqxgh3i.DatabaseConnection.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_islskkwv.DatabaseInfo?>()) {
      return (data != null ? _islskkwv.DatabaseInfo.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iptvro4o.DatabaseProvider?>()) {
      return (data != null ? _iptvro4o.DatabaseProvider.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_inz8j88p.DatabaseQuota?>()) {
      return (data != null ? _inz8j88p.DatabaseQuota.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i49mcfnh.DatabaseResource?>()) {
      return (data != null ? _i49mcfnh.DatabaseResource.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i6xy85up.DatabaseScaling?>()) {
      return (data != null ? _i6xy85up.DatabaseScaling.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ifxd5ia6.DatabaseSizeOption?>()) {
      return (data != null ? _ifxd5ia6.DatabaseSizeOption.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i1q8jyc7.DatabaseSnapshot?>()) {
      return (data != null ? _i1q8jyc7.DatabaseSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iiqkhpys.DatabaseUser?>()) {
      return (data != null ? _iiqkhpys.DatabaseUser.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i7s8kwes.EnvironmentVariable?>()) {
      return (data != null
              ? _i7s8kwes.EnvironmentVariable.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iwt7hqgw.LogRecord?>()) {
      return (data != null ? _iwt7hqgw.LogRecord.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izgm68si.CapsuleNetworkSeries?>()) {
      return (data != null
              ? _izgm68si.CapsuleNetworkSeries.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ifq3txzx.DatabaseMetrics?>()) {
      return (data != null ? _ifq3txzx.DatabaseMetrics.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ihqubfzc.DatabaseMetricsStatus?>()) {
      return (data != null
              ? _ihqubfzc.DatabaseMetricsStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ixjvnalq.MetricSample?>()) {
      return (data != null ? _ixjvnalq.MetricSample.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_igwmelc6.MetricsRange?>()) {
      return (data != null ? _igwmelc6.MetricsRange.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ia30stxm.PodResourceSeries?>()) {
      return (data != null ? _ia30stxm.PodResourceSeries.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i9u2had9.ResponseClassSeries?>()) {
      return (data != null
              ? _i9u2had9.ResponseClassSeries.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i6f96f3s.ComputeCatalogInfo?>()) {
      return (data != null ? _i6f96f3s.ComputeCatalogInfo.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ixsx3y2g.ComputeProductInfo?>()) {
      return (data != null ? _ixsx3y2g.ComputeProductInfo.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ijiweskq.ComputeScalingInfo?>()) {
      return (data != null ? _ijiweskq.ComputeScalingInfo.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ik99pp4r.ConcurrentSubscriptionUpdateException?>()) {
      return (data != null
              ? _ik99pp4r.ConcurrentSubscriptionUpdateException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i1kxda18.DatabaseCatalogInfo?>()) {
      return (data != null
              ? _i1kxda18.DatabaseCatalogInfo.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ie5edybc.DatabaseProductInfo?>()) {
      return (data != null
              ? _ie5edybc.DatabaseProductInfo.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i7kd6f8h.DatabaseScalingInfo?>()) {
      return (data != null
              ? _i7kd6f8h.DatabaseScalingInfo.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ioxhthdl.PlanInfo?>()) {
      return (data != null ? _ioxhthdl.PlanInfo.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iagjhgs9.PlanType?>()) {
      return (data != null ? _iagjhgs9.PlanType.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_is6epy3v.ProductType?>()) {
      return (data != null ? _is6epy3v.ProductType.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iwmabm4s.ProjectProductInfo?>()) {
      return (data != null ? _iwmabm4s.ProjectProductInfo.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iera5yzg.SubscriptionInfo?>()) {
      return (data != null ? _iera5yzg.SubscriptionInfo.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_immj5l46.Project?>()) {
      return (data != null ? _immj5l46.Project.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iw41fb37.Role?>()) {
      return (data != null ? _iw41fb37.Role.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_icd2sct1.UserRoleMembership?>()) {
      return (data != null ? _icd2sct1.UserRoleMembership.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ikwy8e1b.BuildSecretType?>()) {
      return (data != null ? _ikwy8e1b.BuildSecretType.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i3g0ekuz.SecretResource?>()) {
      return (data != null ? _i3g0ekuz.SecretResource.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_immhj4v3.SecretType?>()) {
      return (data != null ? _immhj4v3.SecretType.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i7kzg109.StoredSecretVersion?>()) {
      return (data != null
              ? _i7kzg109.StoredSecretVersion.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_im62j85v.CapsuleDeploymentStatus?>()) {
      return (data != null
              ? _im62j85v.CapsuleDeploymentStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i3wrl47t.CapsuleRevision?>()) {
      return (data != null ? _i3wrl47t.CapsuleRevision.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_in4d44nu.CapsuleState?>()) {
      return (data != null ? _in4d44nu.CapsuleState.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_icnre768.CapsuleStatus?>()) {
      return (data != null ? _icnre768.CapsuleStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iov43xof.DeployAttempt?>()) {
      return (data != null ? _iov43xof.DeployAttempt.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iwfg38ma.DeployAttemptStage?>()) {
      return (data != null ? _iwfg38ma.DeployAttemptStage.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i7neienr.DeployProgressStatus?>()) {
      return (data != null
              ? _i7neienr.DeployProgressStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_imfv08in.DeployStageType?>()) {
      return (data != null ? _imfv08in.DeployStageType.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iz26r0wp.User?>()) {
      return (data != null ? _iz26r0wp.User.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iu2mqg52.UserAccountStatus?>()) {
      return (data != null ? _iu2mqg52.UserAccountStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iptirt7i.UserLabel?>()) {
      return (data != null ? _iptirt7i.UserLabel.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_im281b2u.UserLabelMapping?>()) {
      return (data != null ? _im281b2u.UserLabelMapping.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ihqdfodo.EmailMethodBlockedException?>()) {
      return (data != null
              ? _ihqdfodo.EmailMethodBlockedException.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _isc.getType<_ilk02hh2.UserAccountRegistrationDeniedException?>()) {
      return (data != null
              ? _ilk02hh2.UserAccountRegistrationDeniedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iq25bick.AcceptedTerms?>()) {
      return (data != null ? _iq25bick.AcceptedTerms.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i8z78m78.AcceptedTermsDTO?>()) {
      return (data != null ? _i8z78m78.AcceptedTermsDTO.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ic6o6jk9.AuthTokenInfo?>()) {
      return (data != null ? _ic6o6jk9.AuthTokenInfo.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_il367b51.RequiredTerms?>()) {
      return (data != null ? _il367b51.RequiredTerms.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i5k61oox.Terms?>()) {
      return (data != null ? _i5k61oox.Terms.fromJson(data) : null) as T;
    }
    if (t ==
        _isc.getType<_ih9vxrpp.BucketStorageIdentityUnavailableException?>()) {
      return (data != null
              ? _ih9vxrpp.BucketStorageIdentityUnavailableException.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _isc.getType<_in5svsiw.DNSVerificationFailedException?>()) {
      return (data != null
              ? _in5svsiw.DNSVerificationFailedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ia7ohsf2.CustomDomainName?>()) {
      return (data != null ? _ia7ohsf2.CustomDomainName.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iw8cnhxy.CustomDomainNameList?>()) {
      return (data != null
              ? _iw8cnhxy.CustomDomainNameList.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ii5jxrig.DnsRecordType?>()) {
      return (data != null ? _ii5jxrig.DnsRecordType.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i95e195t.DomainNameStatus?>()) {
      return (data != null ? _i95e195t.DomainNameStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_idr3lfj1.DomainNameTarget?>()) {
      return (data != null ? _idr3lfj1.DomainNameTarget.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ivf1sqm0.CustomDomainNameWithDefaultDomains?>()) {
      return (data != null
              ? _ivf1sqm0.CustomDomainNameWithDefaultDomains.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_irxldgjy.InsightsConnectionDetail?>()) {
      return (data != null
              ? _irxldgjy.InsightsConnectionDetail.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ixr2s32y.DartSdkVersion?>()) {
      return (data != null ? _ixr2s32y.DartSdkVersion.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iv0kay60.DartSdkVersionPolicy?>()) {
      return (data != null
              ? _iv0kay60.DartSdkVersionPolicy.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ib7pq1fg.ProjectConfig?>()) {
      return (data != null ? _ib7pq1fg.ProjectConfig.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i0cd290p.ProjectInfo?>()) {
      return (data != null ? _i0cd290p.ProjectInfo.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iaa2toio.Timestamp?>()) {
      return (data != null ? _iaa2toio.Timestamp.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_id87teh5.ProjectProfileUpdate?>()) {
      return (data != null
              ? _id87teh5.ProjectProfileUpdate.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iglg9o3u.CapsuleStatusUnavailableException?>()) {
      return (data != null
              ? _iglg9o3u.CapsuleStatusUnavailableException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ivmk5dq6.CapsuleRuntimeStatus?>()) {
      return (data != null
              ? _ivmk5dq6.CapsuleRuntimeStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iewvz7zd.DeployAttemptSummary?>()) {
      return (data != null
              ? _iewvz7zd.DeployAttemptSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iv8o207k.DartSdkUnsupportedConstraintException?>()) {
      return (data != null
              ? _iv8o207k.DartSdkUnsupportedConstraintException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_inn0ooo2.DuplicateEntryException?>()) {
      return (data != null
              ? _inn0ooo2.DuplicateEntryException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i8kl75v5.InvalidValueException?>()) {
      return (data != null
              ? _i8kl75v5.InvalidValueException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ijqib2z2.NoCustomerBillingTypeException?>()) {
      return (data != null
              ? _ijqib2z2.NoCustomerBillingTypeException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i8k8a030.NoSubscriptionException?>()) {
      return (data != null
              ? _i8k8a030.NoSubscriptionException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iffy9d8d.NotFoundException?>()) {
      return (data != null ? _iffy9d8d.NotFoundException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iawp7ytp.PlanChangeDeniedException?>()) {
      return (data != null
              ? _iawp7ytp.PlanChangeDeniedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iwnitgrm.PlanChangeDeniedReason?>()) {
      return (data != null
              ? _iwnitgrm.PlanChangeDeniedReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ijkhxmuq.ProcurementCancellationException?>()) {
      return (data != null
              ? _ijkhxmuq.ProcurementCancellationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iw0gwwvc.ProcurementDeniedException?>()) {
      return (data != null
              ? _iw0gwwvc.ProcurementDeniedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iibx2ckv.ProcurementDeniedReason?>()) {
      return (data != null
              ? _iibx2ckv.ProcurementDeniedReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i8itwzl1.UnauthenticatedException?>()) {
      return (data != null
              ? _i8itwzl1.UnauthenticatedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_is3nd795.UnauthorizedException?>()) {
      return (data != null
              ? _is3nd795.UnauthorizedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_is21hzeq.HttpResponseClass?>()) {
      return (data != null ? _is21hzeq.HttpResponseClass.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i3qziuyp.ServerpodRegion?>()) {
      return (data != null ? _i3qziuyp.ServerpodRegion.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i1i04ivn.PubsubEntry?>()) {
      return (data != null ? _i1i04ivn.PubsubEntry.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_immj5l46.Project>) {
      return (data as List)
              .map((e) => deserialize<_immj5l46.Project>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_immj5l46.Project>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_immj5l46.Project>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i8dv9s28.BucketFile>) {
      return (data as List)
              .map((e) => deserialize<_i8dv9s28.BucketFile>(e))
              .toList()
          as T;
    }
    if (t == List<_i7s8kwes.EnvironmentVariable>) {
      return (data as List)
              .map((e) => deserialize<_i7s8kwes.EnvironmentVariable>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_i7s8kwes.EnvironmentVariable>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i7s8kwes.EnvironmentVariable>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ia7ohsf2.CustomDomainName>) {
      return (data as List)
              .map((e) => deserialize<_ia7ohsf2.CustomDomainName>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_ia7ohsf2.CustomDomainName>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ia7ohsf2.CustomDomainName>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ixjvnalq.MetricSample>) {
      return (data as List)
              .map((e) => deserialize<_ixjvnalq.MetricSample>(e))
              .toList()
          as T;
    }
    if (t == List<_i9u2had9.ResponseClassSeries>) {
      return (data as List)
              .map((e) => deserialize<_i9u2had9.ResponseClassSeries>(e))
              .toList()
          as T;
    }
    if (t == List<_ixsx3y2g.ComputeProductInfo>) {
      return (data as List)
              .map((e) => deserialize<_ixsx3y2g.ComputeProductInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_ie5edybc.DatabaseProductInfo>) {
      return (data as List)
              .map((e) => deserialize<_ie5edybc.DatabaseProductInfo>(e))
              .toList()
          as T;
    }
    if (t == List<double>) {
      return (data as List).map((e) => deserialize<double>(e)).toList() as T;
    }
    if (t == List<_iwmabm4s.ProjectProductInfo>) {
      return (data as List)
              .map((e) => deserialize<_iwmabm4s.ProjectProductInfo>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_iwmabm4s.ProjectProductInfo>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_iwmabm4s.ProjectProductInfo>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_iw41fb37.Role>) {
      return (data as List).map((e) => deserialize<_iw41fb37.Role>(e)).toList()
          as T;
    }
    if (t == _isc.getType<List<_iw41fb37.Role>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_iw41fb37.Role>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ibqxrsez.Capsule>) {
      return (data as List)
              .map((e) => deserialize<_ibqxrsez.Capsule>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_ibqxrsez.Capsule>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ibqxrsez.Capsule>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_icd2sct1.UserRoleMembership>) {
      return (data as List)
              .map((e) => deserialize<_icd2sct1.UserRoleMembership>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_icd2sct1.UserRoleMembership>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_icd2sct1.UserRoleMembership>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i7kzg109.StoredSecretVersion>) {
      return (data as List)
              .map((e) => deserialize<_i7kzg109.StoredSecretVersion>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_i7kzg109.StoredSecretVersion>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i7kzg109.StoredSecretVersion>(e))
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
    if (t == List<_iwfg38ma.DeployAttemptStage>) {
      return (data as List)
              .map((e) => deserialize<_iwfg38ma.DeployAttemptStage>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_iwfg38ma.DeployAttemptStage>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_iwfg38ma.DeployAttemptStage>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_im281b2u.UserLabelMapping>) {
      return (data as List)
              .map((e) => deserialize<_im281b2u.UserLabelMapping>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_im281b2u.UserLabelMapping>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_im281b2u.UserLabelMapping>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == Map<_idr3lfj1.DomainNameTarget, String>) {
      return Map.fromEntries(
            (data as List).map(
              (e) => MapEntry(
                deserialize<_idr3lfj1.DomainNameTarget>(e['k']),
                deserialize<String>(e['v']),
              ),
            ),
          )
          as T;
    }
    if (t == List<_ixr2s32y.DartSdkVersion>) {
      return (data as List)
              .map((e) => deserialize<_ixr2s32y.DartSdkVersion>(e))
              .toList()
          as T;
    }
    if (t == List<(String, String)>) {
      return (data as List)
              .map((e) => deserialize<(String, String)>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<(String, String)>()) {
      return (
            deserialize<String>(((data as Map)['p'] as List)[0]),
            deserialize<String>(data['p'][1]),
          )
          as T;
    }
    if (t == _isc.getType<(String, String)>()) {
      return (
            deserialize<String>(((data as Map)['p'] as List)[0]),
            deserialize<String>(data['p'][1]),
          )
          as T;
    }
    if (t == List<_iavjecni.Project>) {
      return (data as List)
              .map((e) => deserialize<_iavjecni.Project>(e))
              .toList()
          as T;
    }
    if (t == List<_ixukenxa.ProjectInfo>) {
      return (data as List)
              .map((e) => deserialize<_ixukenxa.ProjectInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_i51mvi6s.DeployAttempt>) {
      return (data as List)
              .map((e) => deserialize<_i51mvi6s.DeployAttempt>(e))
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
    if (t == List<_ibu0ogga.User>) {
      return (data as List).map((e) => deserialize<_ibu0ogga.User>(e)).toList()
          as T;
    }
    if (t == List<_iu79vy7r.RequiredTerms>) {
      return (data as List)
              .map((e) => deserialize<_iu79vy7r.RequiredTerms>(e))
              .toList()
          as T;
    }
    if (t == List<_irrma5ts.AcceptedTermsDTO>) {
      return (data as List)
              .map((e) => deserialize<_irrma5ts.AcceptedTermsDTO>(e))
              .toList()
          as T;
    }
    if (t == List<_i9cx54ed.AuthTokenInfo>) {
      return (data as List)
              .map((e) => deserialize<_i9cx54ed.AuthTokenInfo>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<_irrma5ts.AcceptedTermsDTO>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_irrma5ts.AcceptedTermsDTO>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_itisjjd4.PaymentMethod>) {
      return (data as List)
              .map((e) => deserialize<_itisjjd4.PaymentMethod>(e))
              .toList()
          as T;
    }
    if (t == List<_itj7xmug.BucketResource>) {
      return (data as List)
              .map((e) => deserialize<_itj7xmug.BucketResource>(e))
              .toList()
          as T;
    }
    if (t == List<_iztc790o.DatabaseUser>) {
      return (data as List)
              .map((e) => deserialize<_iztc790o.DatabaseUser>(e))
              .toList()
          as T;
    }
    if (t == List<_ia6js50c.DatabaseSnapshot>) {
      return (data as List)
              .map((e) => deserialize<_ia6js50c.DatabaseSnapshot>(e))
              .toList()
          as T;
    }
    if (t == List<_i82frs35.EnvironmentVariable>) {
      return (data as List)
              .map((e) => deserialize<_i82frs35.EnvironmentVariable>(e))
              .toList()
          as T;
    }
    if (t == List<_ie2iiqds.PodResourceSeries>) {
      return (data as List)
              .map((e) => deserialize<_ie2iiqds.PodResourceSeries>(e))
              .toList()
          as T;
    }
    if (t == List<_i2pv1k63.SubscriptionInfo>) {
      return (data as List)
              .map((e) => deserialize<_i2pv1k63.SubscriptionInfo>(e))
              .toList()
          as T;
    }
    if (t == List<_ibsngdn1.PlanInfo>) {
      return (data as List)
              .map((e) => deserialize<_ibsngdn1.PlanInfo>(e))
              .toList()
          as T;
    }
    if (t == _isc.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_iavafiww.Role>) {
      return (data as List).map((e) => deserialize<_iavafiww.Role>(e)).toList()
          as T;
    }
    if (t == List<_iy77socp.DeployAttemptStage>) {
      return (data as List)
              .map((e) => deserialize<_iy77socp.DeployAttemptStage>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i4m2a6uw.BillingCustomerType => 'BillingCustomerType',
      _i7vhubyw.BillingInfo => 'BillingInfo',
      _i0j2fm74.BillingMappingType => 'BillingMappingType',
      _i7df4v4i.Owner => 'Owner',
      _ikeafg5a.PaymentMethod => 'PaymentMethod',
      _i4cauyzh.PaymentMethodCard => 'PaymentMethodCard',
      _iq0xsybs.PaymentSetupIntent => 'PaymentSetupIntent',
      _i2gsen8i.BucketAccessRevocationReason => 'BucketAccessRevocationReason',
      _i8dv9s28.BucketFile => 'BucketFile',
      _ixt62bhu.BucketFileListing => 'BucketFileListing',
      _i8eu07u2.BucketProvider => 'BucketProvider',
      _ikzjts3s.BucketResource => 'BucketResource',
      _it8lkrr1.BucketServiceAccount => 'BucketServiceAccount',
      _i3vivpe2.BucketServiceAccountStatus => 'BucketServiceAccountStatus',
      _isqha6b2.BucketStatus => 'BucketStatus',
      _in5j38rp.BucketVisibility => 'BucketVisibility',
      _ixm27pxa.NoPriorDeploymentException => 'NoPriorDeploymentException',
      _ibqxrsez.Capsule => 'Capsule',
      _ilh5zv14.CapsuleResource => 'CapsuleResource',
      _i2jsgnwd.ComputeInfo => 'ComputeInfo',
      _isncq5hp.ComputeSizeOption => 'ComputeSizeOption',
      _io3hi6yc.DatabaseSnapshotLimitException =>
        'DatabaseSnapshotLimitException',
      _ifv8l1c3.BackupFrequency => 'BackupFrequency',
      _iy6lcw8y.BackupSchedule => 'BackupSchedule',
      _ipqxgh3i.DatabaseConnection => 'DatabaseConnection',
      _islskkwv.DatabaseInfo => 'DatabaseInfo',
      _iptvro4o.DatabaseProvider => 'DatabaseProvider',
      _inz8j88p.DatabaseQuota => 'DatabaseQuota',
      _i49mcfnh.DatabaseResource => 'DatabaseResource',
      _i6xy85up.DatabaseScaling => 'DatabaseScaling',
      _ifxd5ia6.DatabaseSizeOption => 'DatabaseSizeOption',
      _i1q8jyc7.DatabaseSnapshot => 'DatabaseSnapshot',
      _iiqkhpys.DatabaseUser => 'DatabaseUser',
      _i7s8kwes.EnvironmentVariable => 'EnvironmentVariable',
      _iwt7hqgw.LogRecord => 'LogRecord',
      _izgm68si.CapsuleNetworkSeries => 'CapsuleNetworkSeries',
      _ifq3txzx.DatabaseMetrics => 'DatabaseMetrics',
      _ihqubfzc.DatabaseMetricsStatus => 'DatabaseMetricsStatus',
      _ixjvnalq.MetricSample => 'MetricSample',
      _igwmelc6.MetricsRange => 'MetricsRange',
      _ia30stxm.PodResourceSeries => 'PodResourceSeries',
      _i9u2had9.ResponseClassSeries => 'ResponseClassSeries',
      _i6f96f3s.ComputeCatalogInfo => 'ComputeCatalogInfo',
      _ixsx3y2g.ComputeProductInfo => 'ComputeProductInfo',
      _ijiweskq.ComputeScalingInfo => 'ComputeScalingInfo',
      _ik99pp4r.ConcurrentSubscriptionUpdateException =>
        'ConcurrentSubscriptionUpdateException',
      _i1kxda18.DatabaseCatalogInfo => 'DatabaseCatalogInfo',
      _ie5edybc.DatabaseProductInfo => 'DatabaseProductInfo',
      _i7kd6f8h.DatabaseScalingInfo => 'DatabaseScalingInfo',
      _ioxhthdl.PlanInfo => 'PlanInfo',
      _iagjhgs9.PlanType => 'PlanType',
      _is6epy3v.ProductType => 'ProductType',
      _iwmabm4s.ProjectProductInfo => 'ProjectProductInfo',
      _iera5yzg.SubscriptionInfo => 'SubscriptionInfo',
      _immj5l46.Project => 'Project',
      _iw41fb37.Role => 'Role',
      _icd2sct1.UserRoleMembership => 'UserRoleMembership',
      _ikwy8e1b.BuildSecretType => 'BuildSecretType',
      _i3g0ekuz.SecretResource => 'SecretResource',
      _immhj4v3.SecretType => 'SecretType',
      _i7kzg109.StoredSecretVersion => 'StoredSecretVersion',
      _im62j85v.CapsuleDeploymentStatus => 'CapsuleDeploymentStatus',
      _i3wrl47t.CapsuleRevision => 'CapsuleRevision',
      _in4d44nu.CapsuleState => 'CapsuleState',
      _icnre768.CapsuleStatus => 'CapsuleStatus',
      _iov43xof.DeployAttempt => 'DeployAttempt',
      _iwfg38ma.DeployAttemptStage => 'DeployAttemptStage',
      _i7neienr.DeployProgressStatus => 'DeployProgressStatus',
      _imfv08in.DeployStageType => 'DeployStageType',
      _iz26r0wp.User => 'User',
      _iu2mqg52.UserAccountStatus => 'UserAccountStatus',
      _iptirt7i.UserLabel => 'UserLabel',
      _im281b2u.UserLabelMapping => 'UserLabelMapping',
      _ihqdfodo.EmailMethodBlockedException => 'EmailMethodBlockedException',
      _ilk02hh2.UserAccountRegistrationDeniedException =>
        'UserAccountRegistrationDeniedException',
      _iq25bick.AcceptedTerms => 'AcceptedTerms',
      _i8z78m78.AcceptedTermsDTO => 'AcceptedTermsDTO',
      _ic6o6jk9.AuthTokenInfo => 'AuthTokenInfo',
      _il367b51.RequiredTerms => 'RequiredTerms',
      _i5k61oox.Terms => 'Terms',
      _ih9vxrpp.BucketStorageIdentityUnavailableException =>
        'BucketStorageIdentityUnavailableException',
      _in5svsiw.DNSVerificationFailedException =>
        'DNSVerificationFailedException',
      _ia7ohsf2.CustomDomainName => 'CustomDomainName',
      _iw8cnhxy.CustomDomainNameList => 'CustomDomainNameList',
      _ii5jxrig.DnsRecordType => 'DnsRecordType',
      _i95e195t.DomainNameStatus => 'DomainNameStatus',
      _idr3lfj1.DomainNameTarget => 'DomainNameTarget',
      _ivf1sqm0.CustomDomainNameWithDefaultDomains =>
        'CustomDomainNameWithDefaultDomains',
      _irxldgjy.InsightsConnectionDetail => 'InsightsConnectionDetail',
      _ixr2s32y.DartSdkVersion => 'DartSdkVersion',
      _iv0kay60.DartSdkVersionPolicy => 'DartSdkVersionPolicy',
      _ib7pq1fg.ProjectConfig => 'ProjectConfig',
      _i0cd290p.ProjectInfo => 'ProjectInfo',
      _iaa2toio.Timestamp => 'Timestamp',
      _id87teh5.ProjectProfileUpdate => 'ProjectProfileUpdate',
      _iglg9o3u.CapsuleStatusUnavailableException =>
        'CapsuleStatusUnavailableException',
      _ivmk5dq6.CapsuleRuntimeStatus => 'CapsuleRuntimeStatus',
      _iewvz7zd.DeployAttemptSummary => 'DeployAttemptSummary',
      _iv8o207k.DartSdkUnsupportedConstraintException =>
        'DartSdkUnsupportedConstraintException',
      _inn0ooo2.DuplicateEntryException => 'DuplicateEntryException',
      _i8kl75v5.InvalidValueException => 'InvalidValueException',
      _ijqib2z2.NoCustomerBillingTypeException =>
        'NoCustomerBillingTypeException',
      _i8k8a030.NoSubscriptionException => 'NoSubscriptionException',
      _iffy9d8d.NotFoundException => 'NotFoundException',
      _iawp7ytp.PlanChangeDeniedException => 'PlanChangeDeniedException',
      _iwnitgrm.PlanChangeDeniedReason => 'PlanChangeDeniedReason',
      _ijkhxmuq.ProcurementCancellationException =>
        'ProcurementCancellationException',
      _iw0gwwvc.ProcurementDeniedException => 'ProcurementDeniedException',
      _iibx2ckv.ProcurementDeniedReason => 'ProcurementDeniedReason',
      _i8itwzl1.UnauthenticatedException => 'UnauthenticatedException',
      _is3nd795.UnauthorizedException => 'UnauthorizedException',
      _is21hzeq.HttpResponseClass => 'HttpResponseClass',
      _i3qziuyp.ServerpodRegion => 'ServerpodRegion',
      _i1i04ivn.PubsubEntry => 'PubsubEntry',
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
      case _i4m2a6uw.BillingCustomerType():
        return 'BillingCustomerType';
      case _i7vhubyw.BillingInfo():
        return 'BillingInfo';
      case _i0j2fm74.BillingMappingType():
        return 'BillingMappingType';
      case _i7df4v4i.Owner():
        return 'Owner';
      case _ikeafg5a.PaymentMethod():
        return 'PaymentMethod';
      case _i4cauyzh.PaymentMethodCard():
        return 'PaymentMethodCard';
      case _iq0xsybs.PaymentSetupIntent():
        return 'PaymentSetupIntent';
      case _i2gsen8i.BucketAccessRevocationReason():
        return 'BucketAccessRevocationReason';
      case _i8dv9s28.BucketFile():
        return 'BucketFile';
      case _ixt62bhu.BucketFileListing():
        return 'BucketFileListing';
      case _i8eu07u2.BucketProvider():
        return 'BucketProvider';
      case _ikzjts3s.BucketResource():
        return 'BucketResource';
      case _it8lkrr1.BucketServiceAccount():
        return 'BucketServiceAccount';
      case _i3vivpe2.BucketServiceAccountStatus():
        return 'BucketServiceAccountStatus';
      case _isqha6b2.BucketStatus():
        return 'BucketStatus';
      case _in5j38rp.BucketVisibility():
        return 'BucketVisibility';
      case _ixm27pxa.NoPriorDeploymentException():
        return 'NoPriorDeploymentException';
      case _ibqxrsez.Capsule():
        return 'Capsule';
      case _ilh5zv14.CapsuleResource():
        return 'CapsuleResource';
      case _i2jsgnwd.ComputeInfo():
        return 'ComputeInfo';
      case _isncq5hp.ComputeSizeOption():
        return 'ComputeSizeOption';
      case _io3hi6yc.DatabaseSnapshotLimitException():
        return 'DatabaseSnapshotLimitException';
      case _ifv8l1c3.BackupFrequency():
        return 'BackupFrequency';
      case _iy6lcw8y.BackupSchedule():
        return 'BackupSchedule';
      case _ipqxgh3i.DatabaseConnection():
        return 'DatabaseConnection';
      case _islskkwv.DatabaseInfo():
        return 'DatabaseInfo';
      case _iptvro4o.DatabaseProvider():
        return 'DatabaseProvider';
      case _inz8j88p.DatabaseQuota():
        return 'DatabaseQuota';
      case _i49mcfnh.DatabaseResource():
        return 'DatabaseResource';
      case _i6xy85up.DatabaseScaling():
        return 'DatabaseScaling';
      case _ifxd5ia6.DatabaseSizeOption():
        return 'DatabaseSizeOption';
      case _i1q8jyc7.DatabaseSnapshot():
        return 'DatabaseSnapshot';
      case _iiqkhpys.DatabaseUser():
        return 'DatabaseUser';
      case _i7s8kwes.EnvironmentVariable():
        return 'EnvironmentVariable';
      case _iwt7hqgw.LogRecord():
        return 'LogRecord';
      case _izgm68si.CapsuleNetworkSeries():
        return 'CapsuleNetworkSeries';
      case _ifq3txzx.DatabaseMetrics():
        return 'DatabaseMetrics';
      case _ihqubfzc.DatabaseMetricsStatus():
        return 'DatabaseMetricsStatus';
      case _ixjvnalq.MetricSample():
        return 'MetricSample';
      case _igwmelc6.MetricsRange():
        return 'MetricsRange';
      case _ia30stxm.PodResourceSeries():
        return 'PodResourceSeries';
      case _i9u2had9.ResponseClassSeries():
        return 'ResponseClassSeries';
      case _i6f96f3s.ComputeCatalogInfo():
        return 'ComputeCatalogInfo';
      case _ixsx3y2g.ComputeProductInfo():
        return 'ComputeProductInfo';
      case _ijiweskq.ComputeScalingInfo():
        return 'ComputeScalingInfo';
      case _ik99pp4r.ConcurrentSubscriptionUpdateException():
        return 'ConcurrentSubscriptionUpdateException';
      case _i1kxda18.DatabaseCatalogInfo():
        return 'DatabaseCatalogInfo';
      case _ie5edybc.DatabaseProductInfo():
        return 'DatabaseProductInfo';
      case _i7kd6f8h.DatabaseScalingInfo():
        return 'DatabaseScalingInfo';
      case _ioxhthdl.PlanInfo():
        return 'PlanInfo';
      case _iagjhgs9.PlanType():
        return 'PlanType';
      case _is6epy3v.ProductType():
        return 'ProductType';
      case _iwmabm4s.ProjectProductInfo():
        return 'ProjectProductInfo';
      case _iera5yzg.SubscriptionInfo():
        return 'SubscriptionInfo';
      case _immj5l46.Project():
        return 'Project';
      case _iw41fb37.Role():
        return 'Role';
      case _icd2sct1.UserRoleMembership():
        return 'UserRoleMembership';
      case _ikwy8e1b.BuildSecretType():
        return 'BuildSecretType';
      case _i3g0ekuz.SecretResource():
        return 'SecretResource';
      case _immhj4v3.SecretType():
        return 'SecretType';
      case _i7kzg109.StoredSecretVersion():
        return 'StoredSecretVersion';
      case _im62j85v.CapsuleDeploymentStatus():
        return 'CapsuleDeploymentStatus';
      case _i3wrl47t.CapsuleRevision():
        return 'CapsuleRevision';
      case _in4d44nu.CapsuleState():
        return 'CapsuleState';
      case _icnre768.CapsuleStatus():
        return 'CapsuleStatus';
      case _iov43xof.DeployAttempt():
        return 'DeployAttempt';
      case _iwfg38ma.DeployAttemptStage():
        return 'DeployAttemptStage';
      case _i7neienr.DeployProgressStatus():
        return 'DeployProgressStatus';
      case _imfv08in.DeployStageType():
        return 'DeployStageType';
      case _iz26r0wp.User():
        return 'User';
      case _iu2mqg52.UserAccountStatus():
        return 'UserAccountStatus';
      case _iptirt7i.UserLabel():
        return 'UserLabel';
      case _im281b2u.UserLabelMapping():
        return 'UserLabelMapping';
      case _ihqdfodo.EmailMethodBlockedException():
        return 'EmailMethodBlockedException';
      case _ilk02hh2.UserAccountRegistrationDeniedException():
        return 'UserAccountRegistrationDeniedException';
      case _iq25bick.AcceptedTerms():
        return 'AcceptedTerms';
      case _i8z78m78.AcceptedTermsDTO():
        return 'AcceptedTermsDTO';
      case _ic6o6jk9.AuthTokenInfo():
        return 'AuthTokenInfo';
      case _il367b51.RequiredTerms():
        return 'RequiredTerms';
      case _i5k61oox.Terms():
        return 'Terms';
      case _ih9vxrpp.BucketStorageIdentityUnavailableException():
        return 'BucketStorageIdentityUnavailableException';
      case _in5svsiw.DNSVerificationFailedException():
        return 'DNSVerificationFailedException';
      case _ia7ohsf2.CustomDomainName():
        return 'CustomDomainName';
      case _iw8cnhxy.CustomDomainNameList():
        return 'CustomDomainNameList';
      case _ii5jxrig.DnsRecordType():
        return 'DnsRecordType';
      case _i95e195t.DomainNameStatus():
        return 'DomainNameStatus';
      case _idr3lfj1.DomainNameTarget():
        return 'DomainNameTarget';
      case _ivf1sqm0.CustomDomainNameWithDefaultDomains():
        return 'CustomDomainNameWithDefaultDomains';
      case _irxldgjy.InsightsConnectionDetail():
        return 'InsightsConnectionDetail';
      case _ixr2s32y.DartSdkVersion():
        return 'DartSdkVersion';
      case _iv0kay60.DartSdkVersionPolicy():
        return 'DartSdkVersionPolicy';
      case _ib7pq1fg.ProjectConfig():
        return 'ProjectConfig';
      case _i0cd290p.ProjectInfo():
        return 'ProjectInfo';
      case _iaa2toio.Timestamp():
        return 'Timestamp';
      case _id87teh5.ProjectProfileUpdate():
        return 'ProjectProfileUpdate';
      case _iglg9o3u.CapsuleStatusUnavailableException():
        return 'CapsuleStatusUnavailableException';
      case _ivmk5dq6.CapsuleRuntimeStatus():
        return 'CapsuleRuntimeStatus';
      case _iewvz7zd.DeployAttemptSummary():
        return 'DeployAttemptSummary';
      case _iv8o207k.DartSdkUnsupportedConstraintException():
        return 'DartSdkUnsupportedConstraintException';
      case _inn0ooo2.DuplicateEntryException():
        return 'DuplicateEntryException';
      case _i8kl75v5.InvalidValueException():
        return 'InvalidValueException';
      case _ijqib2z2.NoCustomerBillingTypeException():
        return 'NoCustomerBillingTypeException';
      case _i8k8a030.NoSubscriptionException():
        return 'NoSubscriptionException';
      case _iffy9d8d.NotFoundException():
        return 'NotFoundException';
      case _iawp7ytp.PlanChangeDeniedException():
        return 'PlanChangeDeniedException';
      case _iwnitgrm.PlanChangeDeniedReason():
        return 'PlanChangeDeniedReason';
      case _ijkhxmuq.ProcurementCancellationException():
        return 'ProcurementCancellationException';
      case _iw0gwwvc.ProcurementDeniedException():
        return 'ProcurementDeniedException';
      case _iibx2ckv.ProcurementDeniedReason():
        return 'ProcurementDeniedReason';
      case _i8itwzl1.UnauthenticatedException():
        return 'UnauthenticatedException';
      case _is3nd795.UnauthorizedException():
        return 'UnauthorizedException';
      case _is21hzeq.HttpResponseClass():
        return 'HttpResponseClass';
      case _i3qziuyp.ServerpodRegion():
        return 'ServerpodRegion';
      case _i1i04ivn.PubsubEntry():
        return 'PubsubEntry';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
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
      return deserialize<_i4m2a6uw.BillingCustomerType>(data['data']);
    }
    if (dataClassName == 'BillingInfo') {
      return deserialize<_i7vhubyw.BillingInfo>(data['data']);
    }
    if (dataClassName == 'BillingMappingType') {
      return deserialize<_i0j2fm74.BillingMappingType>(data['data']);
    }
    if (dataClassName == 'Owner') {
      return deserialize<_i7df4v4i.Owner>(data['data']);
    }
    if (dataClassName == 'PaymentMethod') {
      return deserialize<_ikeafg5a.PaymentMethod>(data['data']);
    }
    if (dataClassName == 'PaymentMethodCard') {
      return deserialize<_i4cauyzh.PaymentMethodCard>(data['data']);
    }
    if (dataClassName == 'PaymentSetupIntent') {
      return deserialize<_iq0xsybs.PaymentSetupIntent>(data['data']);
    }
    if (dataClassName == 'BucketAccessRevocationReason') {
      return deserialize<_i2gsen8i.BucketAccessRevocationReason>(data['data']);
    }
    if (dataClassName == 'BucketFile') {
      return deserialize<_i8dv9s28.BucketFile>(data['data']);
    }
    if (dataClassName == 'BucketFileListing') {
      return deserialize<_ixt62bhu.BucketFileListing>(data['data']);
    }
    if (dataClassName == 'BucketProvider') {
      return deserialize<_i8eu07u2.BucketProvider>(data['data']);
    }
    if (dataClassName == 'BucketResource') {
      return deserialize<_ikzjts3s.BucketResource>(data['data']);
    }
    if (dataClassName == 'BucketServiceAccount') {
      return deserialize<_it8lkrr1.BucketServiceAccount>(data['data']);
    }
    if (dataClassName == 'BucketServiceAccountStatus') {
      return deserialize<_i3vivpe2.BucketServiceAccountStatus>(data['data']);
    }
    if (dataClassName == 'BucketStatus') {
      return deserialize<_isqha6b2.BucketStatus>(data['data']);
    }
    if (dataClassName == 'BucketVisibility') {
      return deserialize<_in5j38rp.BucketVisibility>(data['data']);
    }
    if (dataClassName == 'NoPriorDeploymentException') {
      return deserialize<_ixm27pxa.NoPriorDeploymentException>(data['data']);
    }
    if (dataClassName == 'Capsule') {
      return deserialize<_ibqxrsez.Capsule>(data['data']);
    }
    if (dataClassName == 'CapsuleResource') {
      return deserialize<_ilh5zv14.CapsuleResource>(data['data']);
    }
    if (dataClassName == 'ComputeInfo') {
      return deserialize<_i2jsgnwd.ComputeInfo>(data['data']);
    }
    if (dataClassName == 'ComputeSizeOption') {
      return deserialize<_isncq5hp.ComputeSizeOption>(data['data']);
    }
    if (dataClassName == 'DatabaseSnapshotLimitException') {
      return deserialize<_io3hi6yc.DatabaseSnapshotLimitException>(
        data['data'],
      );
    }
    if (dataClassName == 'BackupFrequency') {
      return deserialize<_ifv8l1c3.BackupFrequency>(data['data']);
    }
    if (dataClassName == 'BackupSchedule') {
      return deserialize<_iy6lcw8y.BackupSchedule>(data['data']);
    }
    if (dataClassName == 'DatabaseConnection') {
      return deserialize<_ipqxgh3i.DatabaseConnection>(data['data']);
    }
    if (dataClassName == 'DatabaseInfo') {
      return deserialize<_islskkwv.DatabaseInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseProvider') {
      return deserialize<_iptvro4o.DatabaseProvider>(data['data']);
    }
    if (dataClassName == 'DatabaseQuota') {
      return deserialize<_inz8j88p.DatabaseQuota>(data['data']);
    }
    if (dataClassName == 'DatabaseResource') {
      return deserialize<_i49mcfnh.DatabaseResource>(data['data']);
    }
    if (dataClassName == 'DatabaseScaling') {
      return deserialize<_i6xy85up.DatabaseScaling>(data['data']);
    }
    if (dataClassName == 'DatabaseSizeOption') {
      return deserialize<_ifxd5ia6.DatabaseSizeOption>(data['data']);
    }
    if (dataClassName == 'DatabaseSnapshot') {
      return deserialize<_i1q8jyc7.DatabaseSnapshot>(data['data']);
    }
    if (dataClassName == 'DatabaseUser') {
      return deserialize<_iiqkhpys.DatabaseUser>(data['data']);
    }
    if (dataClassName == 'EnvironmentVariable') {
      return deserialize<_i7s8kwes.EnvironmentVariable>(data['data']);
    }
    if (dataClassName == 'LogRecord') {
      return deserialize<_iwt7hqgw.LogRecord>(data['data']);
    }
    if (dataClassName == 'CapsuleNetworkSeries') {
      return deserialize<_izgm68si.CapsuleNetworkSeries>(data['data']);
    }
    if (dataClassName == 'DatabaseMetrics') {
      return deserialize<_ifq3txzx.DatabaseMetrics>(data['data']);
    }
    if (dataClassName == 'DatabaseMetricsStatus') {
      return deserialize<_ihqubfzc.DatabaseMetricsStatus>(data['data']);
    }
    if (dataClassName == 'MetricSample') {
      return deserialize<_ixjvnalq.MetricSample>(data['data']);
    }
    if (dataClassName == 'MetricsRange') {
      return deserialize<_igwmelc6.MetricsRange>(data['data']);
    }
    if (dataClassName == 'PodResourceSeries') {
      return deserialize<_ia30stxm.PodResourceSeries>(data['data']);
    }
    if (dataClassName == 'ResponseClassSeries') {
      return deserialize<_i9u2had9.ResponseClassSeries>(data['data']);
    }
    if (dataClassName == 'ComputeCatalogInfo') {
      return deserialize<_i6f96f3s.ComputeCatalogInfo>(data['data']);
    }
    if (dataClassName == 'ComputeProductInfo') {
      return deserialize<_ixsx3y2g.ComputeProductInfo>(data['data']);
    }
    if (dataClassName == 'ComputeScalingInfo') {
      return deserialize<_ijiweskq.ComputeScalingInfo>(data['data']);
    }
    if (dataClassName == 'ConcurrentSubscriptionUpdateException') {
      return deserialize<_ik99pp4r.ConcurrentSubscriptionUpdateException>(
        data['data'],
      );
    }
    if (dataClassName == 'DatabaseCatalogInfo') {
      return deserialize<_i1kxda18.DatabaseCatalogInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseProductInfo') {
      return deserialize<_ie5edybc.DatabaseProductInfo>(data['data']);
    }
    if (dataClassName == 'DatabaseScalingInfo') {
      return deserialize<_i7kd6f8h.DatabaseScalingInfo>(data['data']);
    }
    if (dataClassName == 'PlanInfo') {
      return deserialize<_ioxhthdl.PlanInfo>(data['data']);
    }
    if (dataClassName == 'PlanType') {
      return deserialize<_iagjhgs9.PlanType>(data['data']);
    }
    if (dataClassName == 'ProductType') {
      return deserialize<_is6epy3v.ProductType>(data['data']);
    }
    if (dataClassName == 'ProjectProductInfo') {
      return deserialize<_iwmabm4s.ProjectProductInfo>(data['data']);
    }
    if (dataClassName == 'SubscriptionInfo') {
      return deserialize<_iera5yzg.SubscriptionInfo>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_immj5l46.Project>(data['data']);
    }
    if (dataClassName == 'Role') {
      return deserialize<_iw41fb37.Role>(data['data']);
    }
    if (dataClassName == 'UserRoleMembership') {
      return deserialize<_icd2sct1.UserRoleMembership>(data['data']);
    }
    if (dataClassName == 'BuildSecretType') {
      return deserialize<_ikwy8e1b.BuildSecretType>(data['data']);
    }
    if (dataClassName == 'SecretResource') {
      return deserialize<_i3g0ekuz.SecretResource>(data['data']);
    }
    if (dataClassName == 'SecretType') {
      return deserialize<_immhj4v3.SecretType>(data['data']);
    }
    if (dataClassName == 'StoredSecretVersion') {
      return deserialize<_i7kzg109.StoredSecretVersion>(data['data']);
    }
    if (dataClassName == 'CapsuleDeploymentStatus') {
      return deserialize<_im62j85v.CapsuleDeploymentStatus>(data['data']);
    }
    if (dataClassName == 'CapsuleRevision') {
      return deserialize<_i3wrl47t.CapsuleRevision>(data['data']);
    }
    if (dataClassName == 'CapsuleState') {
      return deserialize<_in4d44nu.CapsuleState>(data['data']);
    }
    if (dataClassName == 'CapsuleStatus') {
      return deserialize<_icnre768.CapsuleStatus>(data['data']);
    }
    if (dataClassName == 'DeployAttempt') {
      return deserialize<_iov43xof.DeployAttempt>(data['data']);
    }
    if (dataClassName == 'DeployAttemptStage') {
      return deserialize<_iwfg38ma.DeployAttemptStage>(data['data']);
    }
    if (dataClassName == 'DeployProgressStatus') {
      return deserialize<_i7neienr.DeployProgressStatus>(data['data']);
    }
    if (dataClassName == 'DeployStageType') {
      return deserialize<_imfv08in.DeployStageType>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_iz26r0wp.User>(data['data']);
    }
    if (dataClassName == 'UserAccountStatus') {
      return deserialize<_iu2mqg52.UserAccountStatus>(data['data']);
    }
    if (dataClassName == 'UserLabel') {
      return deserialize<_iptirt7i.UserLabel>(data['data']);
    }
    if (dataClassName == 'UserLabelMapping') {
      return deserialize<_im281b2u.UserLabelMapping>(data['data']);
    }
    if (dataClassName == 'EmailMethodBlockedException') {
      return deserialize<_ihqdfodo.EmailMethodBlockedException>(data['data']);
    }
    if (dataClassName == 'UserAccountRegistrationDeniedException') {
      return deserialize<_ilk02hh2.UserAccountRegistrationDeniedException>(
        data['data'],
      );
    }
    if (dataClassName == 'AcceptedTerms') {
      return deserialize<_iq25bick.AcceptedTerms>(data['data']);
    }
    if (dataClassName == 'AcceptedTermsDTO') {
      return deserialize<_i8z78m78.AcceptedTermsDTO>(data['data']);
    }
    if (dataClassName == 'AuthTokenInfo') {
      return deserialize<_ic6o6jk9.AuthTokenInfo>(data['data']);
    }
    if (dataClassName == 'RequiredTerms') {
      return deserialize<_il367b51.RequiredTerms>(data['data']);
    }
    if (dataClassName == 'Terms') {
      return deserialize<_i5k61oox.Terms>(data['data']);
    }
    if (dataClassName == 'BucketStorageIdentityUnavailableException') {
      return deserialize<_ih9vxrpp.BucketStorageIdentityUnavailableException>(
        data['data'],
      );
    }
    if (dataClassName == 'DNSVerificationFailedException') {
      return deserialize<_in5svsiw.DNSVerificationFailedException>(
        data['data'],
      );
    }
    if (dataClassName == 'CustomDomainName') {
      return deserialize<_ia7ohsf2.CustomDomainName>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameList') {
      return deserialize<_iw8cnhxy.CustomDomainNameList>(data['data']);
    }
    if (dataClassName == 'DnsRecordType') {
      return deserialize<_ii5jxrig.DnsRecordType>(data['data']);
    }
    if (dataClassName == 'DomainNameStatus') {
      return deserialize<_i95e195t.DomainNameStatus>(data['data']);
    }
    if (dataClassName == 'DomainNameTarget') {
      return deserialize<_idr3lfj1.DomainNameTarget>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameWithDefaultDomains') {
      return deserialize<_ivf1sqm0.CustomDomainNameWithDefaultDomains>(
        data['data'],
      );
    }
    if (dataClassName == 'InsightsConnectionDetail') {
      return deserialize<_irxldgjy.InsightsConnectionDetail>(data['data']);
    }
    if (dataClassName == 'DartSdkVersion') {
      return deserialize<_ixr2s32y.DartSdkVersion>(data['data']);
    }
    if (dataClassName == 'DartSdkVersionPolicy') {
      return deserialize<_iv0kay60.DartSdkVersionPolicy>(data['data']);
    }
    if (dataClassName == 'ProjectConfig') {
      return deserialize<_ib7pq1fg.ProjectConfig>(data['data']);
    }
    if (dataClassName == 'ProjectInfo') {
      return deserialize<_i0cd290p.ProjectInfo>(data['data']);
    }
    if (dataClassName == 'Timestamp') {
      return deserialize<_iaa2toio.Timestamp>(data['data']);
    }
    if (dataClassName == 'ProjectProfileUpdate') {
      return deserialize<_id87teh5.ProjectProfileUpdate>(data['data']);
    }
    if (dataClassName == 'CapsuleStatusUnavailableException') {
      return deserialize<_iglg9o3u.CapsuleStatusUnavailableException>(
        data['data'],
      );
    }
    if (dataClassName == 'CapsuleRuntimeStatus') {
      return deserialize<_ivmk5dq6.CapsuleRuntimeStatus>(data['data']);
    }
    if (dataClassName == 'DeployAttemptSummary') {
      return deserialize<_iewvz7zd.DeployAttemptSummary>(data['data']);
    }
    if (dataClassName == 'DartSdkUnsupportedConstraintException') {
      return deserialize<_iv8o207k.DartSdkUnsupportedConstraintException>(
        data['data'],
      );
    }
    if (dataClassName == 'DuplicateEntryException') {
      return deserialize<_inn0ooo2.DuplicateEntryException>(data['data']);
    }
    if (dataClassName == 'InvalidValueException') {
      return deserialize<_i8kl75v5.InvalidValueException>(data['data']);
    }
    if (dataClassName == 'NoCustomerBillingTypeException') {
      return deserialize<_ijqib2z2.NoCustomerBillingTypeException>(
        data['data'],
      );
    }
    if (dataClassName == 'NoSubscriptionException') {
      return deserialize<_i8k8a030.NoSubscriptionException>(data['data']);
    }
    if (dataClassName == 'NotFoundException') {
      return deserialize<_iffy9d8d.NotFoundException>(data['data']);
    }
    if (dataClassName == 'PlanChangeDeniedException') {
      return deserialize<_iawp7ytp.PlanChangeDeniedException>(data['data']);
    }
    if (dataClassName == 'PlanChangeDeniedReason') {
      return deserialize<_iwnitgrm.PlanChangeDeniedReason>(data['data']);
    }
    if (dataClassName == 'ProcurementCancellationException') {
      return deserialize<_ijkhxmuq.ProcurementCancellationException>(
        data['data'],
      );
    }
    if (dataClassName == 'ProcurementDeniedException') {
      return deserialize<_iw0gwwvc.ProcurementDeniedException>(data['data']);
    }
    if (dataClassName == 'ProcurementDeniedReason') {
      return deserialize<_iibx2ckv.ProcurementDeniedReason>(data['data']);
    }
    if (dataClassName == 'UnauthenticatedException') {
      return deserialize<_i8itwzl1.UnauthenticatedException>(data['data']);
    }
    if (dataClassName == 'UnauthorizedException') {
      return deserialize<_is3nd795.UnauthorizedException>(data['data']);
    }
    if (dataClassName == 'HttpResponseClass') {
      return deserialize<_is21hzeq.HttpResponseClass>(data['data']);
    }
    if (dataClassName == 'ServerpodRegion') {
      return deserialize<_i3qziuyp.ServerpodRegion>(data['data']);
    }
    if (dataClassName == 'PubsubEntry') {
      return deserialize<_i1i04ivn.PubsubEntry>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('ground_control', this);
    _iacc.Protocol().registerHostProtocol('ground_control', this);
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
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
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

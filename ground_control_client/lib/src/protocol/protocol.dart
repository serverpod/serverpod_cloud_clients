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
import 'features/auth/models/required_terms.dart' as _i2;
import 'domains/billing/models/owner.dart' as _i3;
import 'domains/billing/models/subscription.dart' as _i4;
import 'domains/capsules/models/capsule.dart' as _i5;
import 'domains/logs/models/log_record.dart' as _i6;
import 'domains/status/models/deploy_attempt.dart' as _i7;
import 'domains/status/models/deploy_attempt_stage.dart' as _i8;
import 'domains/status/models/deploy_progress_status.dart' as _i9;
import 'domains/status/models/deploy_stage_type.dart' as _i10;
import 'domains/users/models/account_authorization.dart' as _i11;
import 'domains/users/models/user.dart' as _i12;
import 'domains/users/models/user_account_status.dart' as _i13;
import 'features/auth/models/accepted_terms.dart' as _i14;
import 'features/auth/models/accepted_terms_dto.dart' as _i15;
import 'domains/billing/models/billing_info.dart' as _i16;
import 'features/auth/models/terms.dart' as _i17;
import 'features/custom_domain_name/exceptions/dns_verification_failed_exception.dart'
    as _i18;
import 'features/custom_domain_name/models/custom_domain_name.dart' as _i19;
import 'features/custom_domain_name/models/custom_domain_name_list.dart'
    as _i20;
import 'features/custom_domain_name/models/dns_record_type.dart' as _i21;
import 'features/custom_domain_name/models/domain_name_status.dart' as _i22;
import 'features/custom_domain_name/models/domain_name_target.dart' as _i23;
import 'features/custom_domain_name/models/new_domain_names_event.dart' as _i24;
import 'features/custom_domain_name/models/view_models/custom_domain_name_with_default_domains.dart'
    as _i25;
import 'features/database/models/database_connection.dart' as _i26;
import 'features/database/models/database_provider.dart' as _i27;
import 'features/database/models/database_resource.dart' as _i28;
import 'features/environment_variables/models/environment_variable.dart'
    as _i29;
import 'shared/services/pubsub/registry/pubsub_entry.dart' as _i30;
import 'features/project/models/project.dart' as _i31;
import 'features/project/models/project_config.dart' as _i32;
import 'features/project/models/project_delete_call_event.dart' as _i33;
import 'features/project/models/role.dart' as _i34;
import 'features/project/models/user_role_membership.dart' as _i35;
import 'features/secret_manager/models/secret_resource.dart' as _i36;
import 'features/secret_manager/models/secret_type.dart' as _i37;
import 'shared/exceptions/models/duplicate_entry_exception.dart' as _i38;
import 'shared/exceptions/models/forbidden_exception.dart' as _i39;
import 'shared/exceptions/models/invalid_value_exception.dart' as _i40;
import 'shared/exceptions/models/not_found_exception.dart' as _i41;
import 'shared/exceptions/models/unauthenticated_exception.dart' as _i42;
import 'shared/exceptions/models/unauthorized_exception.dart' as _i43;
import 'shared/models/serverpod_region.dart' as _i44;
import 'features/project/models/address.dart' as _i45;
import 'package:ground_control_client/src/protocol/features/project/models/project.dart'
    as _i46;
import 'package:ground_control_client/src/protocol/domains/users/models/user.dart'
    as _i47;
import 'package:ground_control_client/src/protocol/features/auth/models/required_terms.dart'
    as _i48;
import 'package:ground_control_client/src/protocol/features/auth/models/accepted_terms_dto.dart'
    as _i49;
import 'package:ground_control_client/src/protocol/features/environment_variables/models/environment_variable.dart'
    as _i50;
import 'package:ground_control_client/src/protocol/features/project/models/role.dart'
    as _i51;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i52;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _i53;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i54;
export 'domains/billing/models/billing_info.dart';
export 'domains/billing/models/owner.dart';
export 'domains/billing/models/subscription.dart';
export 'domains/capsules/models/capsule.dart';
export 'domains/logs/models/log_record.dart';
export 'domains/status/models/deploy_attempt.dart';
export 'domains/status/models/deploy_attempt_stage.dart';
export 'domains/status/models/deploy_progress_status.dart';
export 'domains/status/models/deploy_stage_type.dart';
export 'domains/users/models/account_authorization.dart';
export 'domains/users/models/user.dart';
export 'domains/users/models/user_account_status.dart';
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
export 'shared/exceptions/models/forbidden_exception.dart';
export 'shared/exceptions/models/invalid_value_exception.dart';
export 'shared/exceptions/models/not_found_exception.dart';
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
    if (t == _i2.RequiredTerms) {
      return _i2.RequiredTerms.fromJson(data) as T;
    }
    if (t == _i3.Owner) {
      return _i3.Owner.fromJson(data) as T;
    }
    if (t == _i4.Subscription) {
      return _i4.Subscription.fromJson(data) as T;
    }
    if (t == _i5.Capsule) {
      return _i5.Capsule.fromJson(data) as T;
    }
    if (t == _i6.LogRecord) {
      return _i6.LogRecord.fromJson(data) as T;
    }
    if (t == _i7.DeployAttempt) {
      return _i7.DeployAttempt.fromJson(data) as T;
    }
    if (t == _i8.DeployAttemptStage) {
      return _i8.DeployAttemptStage.fromJson(data) as T;
    }
    if (t == _i9.DeployProgressStatus) {
      return _i9.DeployProgressStatus.fromJson(data) as T;
    }
    if (t == _i10.DeployStageType) {
      return _i10.DeployStageType.fromJson(data) as T;
    }
    if (t == _i11.AccountAuthorization) {
      return _i11.AccountAuthorization.fromJson(data) as T;
    }
    if (t == _i12.User) {
      return _i12.User.fromJson(data) as T;
    }
    if (t == _i13.UserAccountStatus) {
      return _i13.UserAccountStatus.fromJson(data) as T;
    }
    if (t == _i14.AcceptedTerms) {
      return _i14.AcceptedTerms.fromJson(data) as T;
    }
    if (t == _i15.AcceptedTermsDTO) {
      return _i15.AcceptedTermsDTO.fromJson(data) as T;
    }
    if (t == _i16.BillingInfo) {
      return _i16.BillingInfo.fromJson(data) as T;
    }
    if (t == _i17.Terms) {
      return _i17.Terms.fromJson(data) as T;
    }
    if (t == _i18.DNSVerificationFailedException) {
      return _i18.DNSVerificationFailedException.fromJson(data) as T;
    }
    if (t == _i19.CustomDomainName) {
      return _i19.CustomDomainName.fromJson(data) as T;
    }
    if (t == _i20.CustomDomainNameList) {
      return _i20.CustomDomainNameList.fromJson(data) as T;
    }
    if (t == _i21.DnsRecordType) {
      return _i21.DnsRecordType.fromJson(data) as T;
    }
    if (t == _i22.DomainNameStatus) {
      return _i22.DomainNameStatus.fromJson(data) as T;
    }
    if (t == _i23.DomainNameTarget) {
      return _i23.DomainNameTarget.fromJson(data) as T;
    }
    if (t == _i24.NewCustomDomainNamesEvent) {
      return _i24.NewCustomDomainNamesEvent.fromJson(data) as T;
    }
    if (t == _i25.CustomDomainNameWithDefaultDomains) {
      return _i25.CustomDomainNameWithDefaultDomains.fromJson(data) as T;
    }
    if (t == _i26.DatabaseConnection) {
      return _i26.DatabaseConnection.fromJson(data) as T;
    }
    if (t == _i27.DatabaseProvider) {
      return _i27.DatabaseProvider.fromJson(data) as T;
    }
    if (t == _i28.DatabaseResource) {
      return _i28.DatabaseResource.fromJson(data) as T;
    }
    if (t == _i29.EnvironmentVariable) {
      return _i29.EnvironmentVariable.fromJson(data) as T;
    }
    if (t == _i30.PubsubEntry) {
      return _i30.PubsubEntry.fromJson(data) as T;
    }
    if (t == _i31.Project) {
      return _i31.Project.fromJson(data) as T;
    }
    if (t == _i32.ProjectConfig) {
      return _i32.ProjectConfig.fromJson(data) as T;
    }
    if (t == _i33.ProjectDeleteCallEvent) {
      return _i33.ProjectDeleteCallEvent.fromJson(data) as T;
    }
    if (t == _i34.Role) {
      return _i34.Role.fromJson(data) as T;
    }
    if (t == _i35.UserRoleMembership) {
      return _i35.UserRoleMembership.fromJson(data) as T;
    }
    if (t == _i36.SecretResource) {
      return _i36.SecretResource.fromJson(data) as T;
    }
    if (t == _i37.SecretType) {
      return _i37.SecretType.fromJson(data) as T;
    }
    if (t == _i38.DuplicateEntryException) {
      return _i38.DuplicateEntryException.fromJson(data) as T;
    }
    if (t == _i39.ForbiddenException) {
      return _i39.ForbiddenException.fromJson(data) as T;
    }
    if (t == _i40.InvalidValueException) {
      return _i40.InvalidValueException.fromJson(data) as T;
    }
    if (t == _i41.NotFoundException) {
      return _i41.NotFoundException.fromJson(data) as T;
    }
    if (t == _i42.UnauthenticatedException) {
      return _i42.UnauthenticatedException.fromJson(data) as T;
    }
    if (t == _i43.UnauthorizedException) {
      return _i43.UnauthorizedException.fromJson(data) as T;
    }
    if (t == _i44.ServerpodRegion) {
      return _i44.ServerpodRegion.fromJson(data) as T;
    }
    if (t == _i45.Address) {
      return _i45.Address.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.RequiredTerms?>()) {
      return (data != null ? _i2.RequiredTerms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.Owner?>()) {
      return (data != null ? _i3.Owner.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Subscription?>()) {
      return (data != null ? _i4.Subscription.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Capsule?>()) {
      return (data != null ? _i5.Capsule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.LogRecord?>()) {
      return (data != null ? _i6.LogRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.DeployAttempt?>()) {
      return (data != null ? _i7.DeployAttempt.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.DeployAttemptStage?>()) {
      return (data != null ? _i8.DeployAttemptStage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.DeployProgressStatus?>()) {
      return (data != null ? _i9.DeployProgressStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.DeployStageType?>()) {
      return (data != null ? _i10.DeployStageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.AccountAuthorization?>()) {
      return (data != null ? _i11.AccountAuthorization.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.User?>()) {
      return (data != null ? _i12.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.UserAccountStatus?>()) {
      return (data != null ? _i13.UserAccountStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.AcceptedTerms?>()) {
      return (data != null ? _i14.AcceptedTerms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.AcceptedTermsDTO?>()) {
      return (data != null ? _i15.AcceptedTermsDTO.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.BillingInfo?>()) {
      return (data != null ? _i16.BillingInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.Terms?>()) {
      return (data != null ? _i17.Terms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.DNSVerificationFailedException?>()) {
      return (data != null
          ? _i18.DNSVerificationFailedException.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i19.CustomDomainName?>()) {
      return (data != null ? _i19.CustomDomainName.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.CustomDomainNameList?>()) {
      return (data != null ? _i20.CustomDomainNameList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i21.DnsRecordType?>()) {
      return (data != null ? _i21.DnsRecordType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.DomainNameStatus?>()) {
      return (data != null ? _i22.DomainNameStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.DomainNameTarget?>()) {
      return (data != null ? _i23.DomainNameTarget.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.NewCustomDomainNamesEvent?>()) {
      return (data != null
          ? _i24.NewCustomDomainNamesEvent.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i25.CustomDomainNameWithDefaultDomains?>()) {
      return (data != null
          ? _i25.CustomDomainNameWithDefaultDomains.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i26.DatabaseConnection?>()) {
      return (data != null ? _i26.DatabaseConnection.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i27.DatabaseProvider?>()) {
      return (data != null ? _i27.DatabaseProvider.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.DatabaseResource?>()) {
      return (data != null ? _i28.DatabaseResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.EnvironmentVariable?>()) {
      return (data != null ? _i29.EnvironmentVariable.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i30.PubsubEntry?>()) {
      return (data != null ? _i30.PubsubEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.Project?>()) {
      return (data != null ? _i31.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.ProjectConfig?>()) {
      return (data != null ? _i32.ProjectConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.ProjectDeleteCallEvent?>()) {
      return (data != null ? _i33.ProjectDeleteCallEvent.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i34.Role?>()) {
      return (data != null ? _i34.Role.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.UserRoleMembership?>()) {
      return (data != null ? _i35.UserRoleMembership.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i36.SecretResource?>()) {
      return (data != null ? _i36.SecretResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.SecretType?>()) {
      return (data != null ? _i37.SecretType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.DuplicateEntryException?>()) {
      return (data != null ? _i38.DuplicateEntryException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i39.ForbiddenException?>()) {
      return (data != null ? _i39.ForbiddenException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i40.InvalidValueException?>()) {
      return (data != null ? _i40.InvalidValueException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i41.NotFoundException?>()) {
      return (data != null ? _i41.NotFoundException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i42.UnauthenticatedException?>()) {
      return (data != null
          ? _i42.UnauthenticatedException.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i43.UnauthorizedException?>()) {
      return (data != null ? _i43.UnauthorizedException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i44.ServerpodRegion?>()) {
      return (data != null ? _i44.ServerpodRegion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.Address?>()) {
      return (data != null ? _i45.Address.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<_i31.Project>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i31.Project>(e)).toList()
          : null) as T;
    }
    if (t == _i1.getType<List<_i29.EnvironmentVariable>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i29.EnvironmentVariable>(e))
              .toList()
          : null) as T;
    }
    if (t == _i1.getType<List<_i19.CustomDomainName>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i19.CustomDomainName>(e))
              .toList()
          : null) as T;
    }
    if (t == _i1.getType<List<_i35.UserRoleMembership>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i35.UserRoleMembership>(e))
              .toList()
          : null) as T;
    }
    if (t == List<_i19.CustomDomainName>) {
      return (data as List)
          .map((e) => deserialize<_i19.CustomDomainName>(e))
          .toList() as T;
    }
    if (t == Map<_i23.DomainNameTarget, String>) {
      return Map.fromEntries((data as List).map((e) => MapEntry(
          deserialize<_i23.DomainNameTarget>(e['k']),
          deserialize<String>(e['v'])))) as T;
    }
    if (t == _i1.getType<List<_i34.Role>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i34.Role>(e)).toList()
          : null) as T;
    }
    if (t == _i1.getType<List<_i5.Capsule>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i5.Capsule>(e)).toList()
          : null) as T;
    }
    if (t == _i1.getType<List<_i35.UserRoleMembership>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i35.UserRoleMembership>(e))
              .toList()
          : null) as T;
    }
    if (t == List<_i46.Project>) {
      return (data as List).map((e) => deserialize<_i46.Project>(e)).toList()
          as T;
    }
    if (t == List<_i47.User>) {
      return (data as List).map((e) => deserialize<_i47.User>(e)).toList() as T;
    }
    if (t == List<_i48.RequiredTerms>) {
      return (data as List)
          .map((e) => deserialize<_i48.RequiredTerms>(e))
          .toList() as T;
    }
    if (t == List<_i49.AcceptedTermsDTO>) {
      return (data as List)
          .map((e) => deserialize<_i49.AcceptedTermsDTO>(e))
          .toList() as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i50.EnvironmentVariable>) {
      return (data as List)
          .map((e) => deserialize<_i50.EnvironmentVariable>(e))
          .toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<_i51.Role>) {
      return (data as List).map((e) => deserialize<_i51.Role>(e)).toList() as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map((k, v) =>
          MapEntry(deserialize<String>(k), deserialize<String>(v))) as T;
    }
    if (t == List<_i52.DeployAttempt>) {
      return (data as List)
          .map((e) => deserialize<_i52.DeployAttempt>(e))
          .toList() as T;
    }
    if (t == List<_i53.DeployAttemptStage>) {
      return (data as List)
          .map((e) => deserialize<_i53.DeployAttemptStage>(e))
          .toList() as T;
    }
    try {
      return _i54.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.RequiredTerms) {
      return 'RequiredTerms';
    }
    if (data is _i3.Owner) {
      return 'Owner';
    }
    if (data is _i4.Subscription) {
      return 'Subscription';
    }
    if (data is _i5.Capsule) {
      return 'Capsule';
    }
    if (data is _i6.LogRecord) {
      return 'LogRecord';
    }
    if (data is _i7.DeployAttempt) {
      return 'DeployAttempt';
    }
    if (data is _i8.DeployAttemptStage) {
      return 'DeployAttemptStage';
    }
    if (data is _i9.DeployProgressStatus) {
      return 'DeployProgressStatus';
    }
    if (data is _i10.DeployStageType) {
      return 'DeployStageType';
    }
    if (data is _i11.AccountAuthorization) {
      return 'AccountAuthorization';
    }
    if (data is _i12.User) {
      return 'User';
    }
    if (data is _i13.UserAccountStatus) {
      return 'UserAccountStatus';
    }
    if (data is _i14.AcceptedTerms) {
      return 'AcceptedTerms';
    }
    if (data is _i15.AcceptedTermsDTO) {
      return 'AcceptedTermsDTO';
    }
    if (data is _i16.BillingInfo) {
      return 'BillingInfo';
    }
    if (data is _i17.Terms) {
      return 'Terms';
    }
    if (data is _i18.DNSVerificationFailedException) {
      return 'DNSVerificationFailedException';
    }
    if (data is _i19.CustomDomainName) {
      return 'CustomDomainName';
    }
    if (data is _i20.CustomDomainNameList) {
      return 'CustomDomainNameList';
    }
    if (data is _i21.DnsRecordType) {
      return 'DnsRecordType';
    }
    if (data is _i22.DomainNameStatus) {
      return 'DomainNameStatus';
    }
    if (data is _i23.DomainNameTarget) {
      return 'DomainNameTarget';
    }
    if (data is _i24.NewCustomDomainNamesEvent) {
      return 'NewCustomDomainNamesEvent';
    }
    if (data is _i25.CustomDomainNameWithDefaultDomains) {
      return 'CustomDomainNameWithDefaultDomains';
    }
    if (data is _i26.DatabaseConnection) {
      return 'DatabaseConnection';
    }
    if (data is _i27.DatabaseProvider) {
      return 'DatabaseProvider';
    }
    if (data is _i28.DatabaseResource) {
      return 'DatabaseResource';
    }
    if (data is _i29.EnvironmentVariable) {
      return 'EnvironmentVariable';
    }
    if (data is _i30.PubsubEntry) {
      return 'PubsubEntry';
    }
    if (data is _i31.Project) {
      return 'Project';
    }
    if (data is _i32.ProjectConfig) {
      return 'ProjectConfig';
    }
    if (data is _i33.ProjectDeleteCallEvent) {
      return 'ProjectDeleteCallEvent';
    }
    if (data is _i34.Role) {
      return 'Role';
    }
    if (data is _i35.UserRoleMembership) {
      return 'UserRoleMembership';
    }
    if (data is _i36.SecretResource) {
      return 'SecretResource';
    }
    if (data is _i37.SecretType) {
      return 'SecretType';
    }
    if (data is _i38.DuplicateEntryException) {
      return 'DuplicateEntryException';
    }
    if (data is _i39.ForbiddenException) {
      return 'ForbiddenException';
    }
    if (data is _i40.InvalidValueException) {
      return 'InvalidValueException';
    }
    if (data is _i41.NotFoundException) {
      return 'NotFoundException';
    }
    if (data is _i42.UnauthenticatedException) {
      return 'UnauthenticatedException';
    }
    if (data is _i43.UnauthorizedException) {
      return 'UnauthorizedException';
    }
    if (data is _i44.ServerpodRegion) {
      return 'ServerpodRegion';
    }
    if (data is _i45.Address) {
      return 'Address';
    }
    className = _i54.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'RequiredTerms') {
      return deserialize<_i2.RequiredTerms>(data['data']);
    }
    if (dataClassName == 'Owner') {
      return deserialize<_i3.Owner>(data['data']);
    }
    if (dataClassName == 'Subscription') {
      return deserialize<_i4.Subscription>(data['data']);
    }
    if (dataClassName == 'Capsule') {
      return deserialize<_i5.Capsule>(data['data']);
    }
    if (dataClassName == 'LogRecord') {
      return deserialize<_i6.LogRecord>(data['data']);
    }
    if (dataClassName == 'DeployAttempt') {
      return deserialize<_i7.DeployAttempt>(data['data']);
    }
    if (dataClassName == 'DeployAttemptStage') {
      return deserialize<_i8.DeployAttemptStage>(data['data']);
    }
    if (dataClassName == 'DeployProgressStatus') {
      return deserialize<_i9.DeployProgressStatus>(data['data']);
    }
    if (dataClassName == 'DeployStageType') {
      return deserialize<_i10.DeployStageType>(data['data']);
    }
    if (dataClassName == 'AccountAuthorization') {
      return deserialize<_i11.AccountAuthorization>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i12.User>(data['data']);
    }
    if (dataClassName == 'UserAccountStatus') {
      return deserialize<_i13.UserAccountStatus>(data['data']);
    }
    if (dataClassName == 'AcceptedTerms') {
      return deserialize<_i14.AcceptedTerms>(data['data']);
    }
    if (dataClassName == 'AcceptedTermsDTO') {
      return deserialize<_i15.AcceptedTermsDTO>(data['data']);
    }
    if (dataClassName == 'BillingInfo') {
      return deserialize<_i16.BillingInfo>(data['data']);
    }
    if (dataClassName == 'Terms') {
      return deserialize<_i17.Terms>(data['data']);
    }
    if (dataClassName == 'DNSVerificationFailedException') {
      return deserialize<_i18.DNSVerificationFailedException>(data['data']);
    }
    if (dataClassName == 'CustomDomainName') {
      return deserialize<_i19.CustomDomainName>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameList') {
      return deserialize<_i20.CustomDomainNameList>(data['data']);
    }
    if (dataClassName == 'DnsRecordType') {
      return deserialize<_i21.DnsRecordType>(data['data']);
    }
    if (dataClassName == 'DomainNameStatus') {
      return deserialize<_i22.DomainNameStatus>(data['data']);
    }
    if (dataClassName == 'DomainNameTarget') {
      return deserialize<_i23.DomainNameTarget>(data['data']);
    }
    if (dataClassName == 'NewCustomDomainNamesEvent') {
      return deserialize<_i24.NewCustomDomainNamesEvent>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameWithDefaultDomains') {
      return deserialize<_i25.CustomDomainNameWithDefaultDomains>(data['data']);
    }
    if (dataClassName == 'DatabaseConnection') {
      return deserialize<_i26.DatabaseConnection>(data['data']);
    }
    if (dataClassName == 'DatabaseProvider') {
      return deserialize<_i27.DatabaseProvider>(data['data']);
    }
    if (dataClassName == 'DatabaseResource') {
      return deserialize<_i28.DatabaseResource>(data['data']);
    }
    if (dataClassName == 'EnvironmentVariable') {
      return deserialize<_i29.EnvironmentVariable>(data['data']);
    }
    if (dataClassName == 'PubsubEntry') {
      return deserialize<_i30.PubsubEntry>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i31.Project>(data['data']);
    }
    if (dataClassName == 'ProjectConfig') {
      return deserialize<_i32.ProjectConfig>(data['data']);
    }
    if (dataClassName == 'ProjectDeleteCallEvent') {
      return deserialize<_i33.ProjectDeleteCallEvent>(data['data']);
    }
    if (dataClassName == 'Role') {
      return deserialize<_i34.Role>(data['data']);
    }
    if (dataClassName == 'UserRoleMembership') {
      return deserialize<_i35.UserRoleMembership>(data['data']);
    }
    if (dataClassName == 'SecretResource') {
      return deserialize<_i36.SecretResource>(data['data']);
    }
    if (dataClassName == 'SecretType') {
      return deserialize<_i37.SecretType>(data['data']);
    }
    if (dataClassName == 'DuplicateEntryException') {
      return deserialize<_i38.DuplicateEntryException>(data['data']);
    }
    if (dataClassName == 'ForbiddenException') {
      return deserialize<_i39.ForbiddenException>(data['data']);
    }
    if (dataClassName == 'InvalidValueException') {
      return deserialize<_i40.InvalidValueException>(data['data']);
    }
    if (dataClassName == 'NotFoundException') {
      return deserialize<_i41.NotFoundException>(data['data']);
    }
    if (dataClassName == 'UnauthenticatedException') {
      return deserialize<_i42.UnauthenticatedException>(data['data']);
    }
    if (dataClassName == 'UnauthorizedException') {
      return deserialize<_i43.UnauthorizedException>(data['data']);
    }
    if (dataClassName == 'ServerpodRegion') {
      return deserialize<_i44.ServerpodRegion>(data['data']);
    }
    if (dataClassName == 'Address') {
      return deserialize<_i45.Address>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i54.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}

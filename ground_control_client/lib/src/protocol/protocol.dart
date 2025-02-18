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
import 'domains/capsules/models/capsule.dart' as _i2;
import 'domains/logs/models/log_record.dart' as _i3;
import 'domains/status/models/deploy_attempt.dart' as _i4;
import 'domains/status/models/deploy_attempt_stage.dart' as _i5;
import 'domains/status/models/deploy_progress_status.dart' as _i6;
import 'domains/status/models/deploy_stage_type.dart' as _i7;
import 'domains/users/models/user.dart' as _i8;
import 'features/auth/models/accepted_terms.dart' as _i9;
import 'features/auth/models/accepted_terms_dto.dart' as _i10;
import 'features/auth/models/required_terms.dart' as _i11;
import 'features/auth/models/terms.dart' as _i12;
import 'features/custom_domain_name/exceptions/dns_verification_failed_exception.dart'
    as _i13;
import 'features/custom_domain_name/models/custom_domain_name.dart' as _i14;
import 'features/custom_domain_name/models/custom_domain_name_list.dart'
    as _i15;
import 'features/custom_domain_name/models/dns_record_type.dart' as _i16;
import 'features/custom_domain_name/models/domain_name_status.dart' as _i17;
import 'features/custom_domain_name/models/domain_name_target.dart' as _i18;
import 'features/custom_domain_name/models/new_domain_names_event.dart' as _i19;
import 'features/custom_domain_name/models/view_models/custom_domain_name_with_default_domains.dart'
    as _i20;
import 'features/database/models/database_connection.dart' as _i21;
import 'features/database/models/database_provider.dart' as _i22;
import 'features/database/models/database_resource.dart' as _i23;
import 'features/environment_variables/models/environment_variable.dart'
    as _i24;
import 'features/project/models/account_authorization.dart' as _i25;
import 'features/project/models/address.dart' as _i26;
import 'features/project/models/project.dart' as _i27;
import 'features/project/models/project_config.dart' as _i28;
import 'features/project/models/project_delete_call_event.dart' as _i29;
import 'features/project/models/role.dart' as _i30;
import 'features/project/models/user_role_membership.dart' as _i31;
import 'features/secret_manager/models/secret_resource.dart' as _i32;
import 'features/secret_manager/models/secret_type.dart' as _i33;
import 'shared/exceptions/models/duplicate_entry_exception.dart' as _i34;
import 'shared/exceptions/models/forbidden_exception.dart' as _i35;
import 'shared/exceptions/models/invalid_value_exception.dart' as _i36;
import 'shared/exceptions/models/not_found_exception.dart' as _i37;
import 'shared/exceptions/models/unauthenticated_exception.dart' as _i38;
import 'shared/exceptions/models/unauthorized_exception.dart' as _i39;
import 'shared/models/serverpod_region.dart' as _i40;
import 'package:ground_control_client/src/protocol/features/auth/models/required_terms.dart'
    as _i41;
import 'package:ground_control_client/src/protocol/features/auth/models/accepted_terms_dto.dart'
    as _i42;
import 'package:ground_control_client/src/protocol/features/environment_variables/models/environment_variable.dart'
    as _i43;
import 'package:ground_control_client/src/protocol/features/project/models/project.dart'
    as _i44;
import 'package:ground_control_client/src/protocol/features/project/models/role.dart'
    as _i45;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i46;
import 'package:ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _i47;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i48;
export 'domains/capsules/models/capsule.dart';
export 'domains/logs/models/log_record.dart';
export 'domains/status/models/deploy_attempt.dart';
export 'domains/status/models/deploy_attempt_stage.dart';
export 'domains/status/models/deploy_progress_status.dart';
export 'domains/status/models/deploy_stage_type.dart';
export 'domains/users/models/user.dart';
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
export 'features/project/models/account_authorization.dart';
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
    if (t == _i2.Capsule) {
      return _i2.Capsule.fromJson(data) as T;
    }
    if (t == _i3.LogRecord) {
      return _i3.LogRecord.fromJson(data) as T;
    }
    if (t == _i4.DeployAttempt) {
      return _i4.DeployAttempt.fromJson(data) as T;
    }
    if (t == _i5.DeployAttemptStage) {
      return _i5.DeployAttemptStage.fromJson(data) as T;
    }
    if (t == _i6.DeployProgressStatus) {
      return _i6.DeployProgressStatus.fromJson(data) as T;
    }
    if (t == _i7.DeployStageType) {
      return _i7.DeployStageType.fromJson(data) as T;
    }
    if (t == _i8.User) {
      return _i8.User.fromJson(data) as T;
    }
    if (t == _i9.AcceptedTerms) {
      return _i9.AcceptedTerms.fromJson(data) as T;
    }
    if (t == _i10.AcceptedTermsDTO) {
      return _i10.AcceptedTermsDTO.fromJson(data) as T;
    }
    if (t == _i11.RequiredTerms) {
      return _i11.RequiredTerms.fromJson(data) as T;
    }
    if (t == _i12.Terms) {
      return _i12.Terms.fromJson(data) as T;
    }
    if (t == _i13.DNSVerificationFailedException) {
      return _i13.DNSVerificationFailedException.fromJson(data) as T;
    }
    if (t == _i14.CustomDomainName) {
      return _i14.CustomDomainName.fromJson(data) as T;
    }
    if (t == _i15.CustomDomainNameList) {
      return _i15.CustomDomainNameList.fromJson(data) as T;
    }
    if (t == _i16.DnsRecordType) {
      return _i16.DnsRecordType.fromJson(data) as T;
    }
    if (t == _i17.DomainNameStatus) {
      return _i17.DomainNameStatus.fromJson(data) as T;
    }
    if (t == _i18.DomainNameTarget) {
      return _i18.DomainNameTarget.fromJson(data) as T;
    }
    if (t == _i19.NewCustomDomainNamesEvent) {
      return _i19.NewCustomDomainNamesEvent.fromJson(data) as T;
    }
    if (t == _i20.CustomDomainNameWithDefaultDomains) {
      return _i20.CustomDomainNameWithDefaultDomains.fromJson(data) as T;
    }
    if (t == _i21.DatabaseConnection) {
      return _i21.DatabaseConnection.fromJson(data) as T;
    }
    if (t == _i22.DatabaseProvider) {
      return _i22.DatabaseProvider.fromJson(data) as T;
    }
    if (t == _i23.DatabaseResource) {
      return _i23.DatabaseResource.fromJson(data) as T;
    }
    if (t == _i24.EnvironmentVariable) {
      return _i24.EnvironmentVariable.fromJson(data) as T;
    }
    if (t == _i25.AccountAuthorization) {
      return _i25.AccountAuthorization.fromJson(data) as T;
    }
    if (t == _i26.Address) {
      return _i26.Address.fromJson(data) as T;
    }
    if (t == _i27.Project) {
      return _i27.Project.fromJson(data) as T;
    }
    if (t == _i28.ProjectConfig) {
      return _i28.ProjectConfig.fromJson(data) as T;
    }
    if (t == _i29.ProjectDeleteCallEvent) {
      return _i29.ProjectDeleteCallEvent.fromJson(data) as T;
    }
    if (t == _i30.Role) {
      return _i30.Role.fromJson(data) as T;
    }
    if (t == _i31.UserRoleMembership) {
      return _i31.UserRoleMembership.fromJson(data) as T;
    }
    if (t == _i32.SecretResource) {
      return _i32.SecretResource.fromJson(data) as T;
    }
    if (t == _i33.SecretType) {
      return _i33.SecretType.fromJson(data) as T;
    }
    if (t == _i34.DuplicateEntryException) {
      return _i34.DuplicateEntryException.fromJson(data) as T;
    }
    if (t == _i35.ForbiddenException) {
      return _i35.ForbiddenException.fromJson(data) as T;
    }
    if (t == _i36.InvalidValueException) {
      return _i36.InvalidValueException.fromJson(data) as T;
    }
    if (t == _i37.NotFoundException) {
      return _i37.NotFoundException.fromJson(data) as T;
    }
    if (t == _i38.UnauthenticatedException) {
      return _i38.UnauthenticatedException.fromJson(data) as T;
    }
    if (t == _i39.UnauthorizedException) {
      return _i39.UnauthorizedException.fromJson(data) as T;
    }
    if (t == _i40.ServerpodRegion) {
      return _i40.ServerpodRegion.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Capsule?>()) {
      return (data != null ? _i2.Capsule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.LogRecord?>()) {
      return (data != null ? _i3.LogRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.DeployAttempt?>()) {
      return (data != null ? _i4.DeployAttempt.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.DeployAttemptStage?>()) {
      return (data != null ? _i5.DeployAttemptStage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.DeployProgressStatus?>()) {
      return (data != null ? _i6.DeployProgressStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.DeployStageType?>()) {
      return (data != null ? _i7.DeployStageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.User?>()) {
      return (data != null ? _i8.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.AcceptedTerms?>()) {
      return (data != null ? _i9.AcceptedTerms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.AcceptedTermsDTO?>()) {
      return (data != null ? _i10.AcceptedTermsDTO.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.RequiredTerms?>()) {
      return (data != null ? _i11.RequiredTerms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Terms?>()) {
      return (data != null ? _i12.Terms.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.DNSVerificationFailedException?>()) {
      return (data != null
          ? _i13.DNSVerificationFailedException.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i14.CustomDomainName?>()) {
      return (data != null ? _i14.CustomDomainName.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.CustomDomainNameList?>()) {
      return (data != null ? _i15.CustomDomainNameList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.DnsRecordType?>()) {
      return (data != null ? _i16.DnsRecordType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.DomainNameStatus?>()) {
      return (data != null ? _i17.DomainNameStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.DomainNameTarget?>()) {
      return (data != null ? _i18.DomainNameTarget.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.NewCustomDomainNamesEvent?>()) {
      return (data != null
          ? _i19.NewCustomDomainNamesEvent.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i20.CustomDomainNameWithDefaultDomains?>()) {
      return (data != null
          ? _i20.CustomDomainNameWithDefaultDomains.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i21.DatabaseConnection?>()) {
      return (data != null ? _i21.DatabaseConnection.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i22.DatabaseProvider?>()) {
      return (data != null ? _i22.DatabaseProvider.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.DatabaseResource?>()) {
      return (data != null ? _i23.DatabaseResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.EnvironmentVariable?>()) {
      return (data != null ? _i24.EnvironmentVariable.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i25.AccountAuthorization?>()) {
      return (data != null ? _i25.AccountAuthorization.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i26.Address?>()) {
      return (data != null ? _i26.Address.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.Project?>()) {
      return (data != null ? _i27.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.ProjectConfig?>()) {
      return (data != null ? _i28.ProjectConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.ProjectDeleteCallEvent?>()) {
      return (data != null ? _i29.ProjectDeleteCallEvent.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i30.Role?>()) {
      return (data != null ? _i30.Role.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.UserRoleMembership?>()) {
      return (data != null ? _i31.UserRoleMembership.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i32.SecretResource?>()) {
      return (data != null ? _i32.SecretResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.SecretType?>()) {
      return (data != null ? _i33.SecretType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.DuplicateEntryException?>()) {
      return (data != null ? _i34.DuplicateEntryException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i35.ForbiddenException?>()) {
      return (data != null ? _i35.ForbiddenException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i36.InvalidValueException?>()) {
      return (data != null ? _i36.InvalidValueException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i37.NotFoundException?>()) {
      return (data != null ? _i37.NotFoundException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.UnauthenticatedException?>()) {
      return (data != null
          ? _i38.UnauthenticatedException.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i39.UnauthorizedException?>()) {
      return (data != null ? _i39.UnauthorizedException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i40.ServerpodRegion?>()) {
      return (data != null ? _i40.ServerpodRegion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<List<_i24.EnvironmentVariable>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i24.EnvironmentVariable>(e))
              .toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<_i14.CustomDomainName>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i14.CustomDomainName>(e))
              .toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<_i31.UserRoleMembership>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i31.UserRoleMembership>(e))
              .toList()
          : null) as dynamic;
    }
    if (t == List<_i14.CustomDomainName>) {
      return (data as List)
          .map((e) => deserialize<_i14.CustomDomainName>(e))
          .toList() as dynamic;
    }
    if (t == Map<_i18.DomainNameTarget, String>) {
      return Map.fromEntries((data as List).map((e) => MapEntry(
          deserialize<_i18.DomainNameTarget>(e['k']),
          deserialize<String>(e['v'])))) as dynamic;
    }
    if (t == _i1.getType<List<_i30.Role>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i30.Role>(e)).toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<_i2.Capsule>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i2.Capsule>(e)).toList()
          : null) as dynamic;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList()
          as dynamic;
    }
    if (t == _i1.getType<List<_i31.UserRoleMembership>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i31.UserRoleMembership>(e))
              .toList()
          : null) as dynamic;
    }
    if (t == List<_i41.RequiredTerms>) {
      return (data as List)
          .map((e) => deserialize<_i41.RequiredTerms>(e))
          .toList() as dynamic;
    }
    if (t == List<_i42.AcceptedTermsDTO>) {
      return (data as List)
          .map((e) => deserialize<_i42.AcceptedTermsDTO>(e))
          .toList() as dynamic;
    }
    if (t == List<_i43.EnvironmentVariable>) {
      return (data as List)
          .map((e) => deserialize<_i43.EnvironmentVariable>(e))
          .toList() as dynamic;
    }
    if (t == List<_i44.Project>) {
      return (data as List).map((e) => deserialize<_i44.Project>(e)).toList()
          as dynamic;
    }
    if (t == List<_i45.Role>) {
      return (data as List).map((e) => deserialize<_i45.Role>(e)).toList()
          as dynamic;
    }
    if (t == Map<String, String>) {
      return (data as Map).map((k, v) =>
          MapEntry(deserialize<String>(k), deserialize<String>(v))) as dynamic;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList()
          as dynamic;
    }
    if (t == List<_i46.DeployAttempt>) {
      return (data as List)
          .map((e) => deserialize<_i46.DeployAttempt>(e))
          .toList() as dynamic;
    }
    if (t == List<_i47.DeployAttemptStage>) {
      return (data as List)
          .map((e) => deserialize<_i47.DeployAttemptStage>(e))
          .toList() as dynamic;
    }
    try {
      return _i48.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.Capsule) {
      return 'Capsule';
    }
    if (data is _i3.LogRecord) {
      return 'LogRecord';
    }
    if (data is _i4.DeployAttempt) {
      return 'DeployAttempt';
    }
    if (data is _i5.DeployAttemptStage) {
      return 'DeployAttemptStage';
    }
    if (data is _i6.DeployProgressStatus) {
      return 'DeployProgressStatus';
    }
    if (data is _i7.DeployStageType) {
      return 'DeployStageType';
    }
    if (data is _i8.User) {
      return 'User';
    }
    if (data is _i9.AcceptedTerms) {
      return 'AcceptedTerms';
    }
    if (data is _i10.AcceptedTermsDTO) {
      return 'AcceptedTermsDTO';
    }
    if (data is _i11.RequiredTerms) {
      return 'RequiredTerms';
    }
    if (data is _i12.Terms) {
      return 'Terms';
    }
    if (data is _i13.DNSVerificationFailedException) {
      return 'DNSVerificationFailedException';
    }
    if (data is _i14.CustomDomainName) {
      return 'CustomDomainName';
    }
    if (data is _i15.CustomDomainNameList) {
      return 'CustomDomainNameList';
    }
    if (data is _i16.DnsRecordType) {
      return 'DnsRecordType';
    }
    if (data is _i17.DomainNameStatus) {
      return 'DomainNameStatus';
    }
    if (data is _i18.DomainNameTarget) {
      return 'DomainNameTarget';
    }
    if (data is _i19.NewCustomDomainNamesEvent) {
      return 'NewCustomDomainNamesEvent';
    }
    if (data is _i20.CustomDomainNameWithDefaultDomains) {
      return 'CustomDomainNameWithDefaultDomains';
    }
    if (data is _i21.DatabaseConnection) {
      return 'DatabaseConnection';
    }
    if (data is _i22.DatabaseProvider) {
      return 'DatabaseProvider';
    }
    if (data is _i23.DatabaseResource) {
      return 'DatabaseResource';
    }
    if (data is _i24.EnvironmentVariable) {
      return 'EnvironmentVariable';
    }
    if (data is _i25.AccountAuthorization) {
      return 'AccountAuthorization';
    }
    if (data is _i26.Address) {
      return 'Address';
    }
    if (data is _i27.Project) {
      return 'Project';
    }
    if (data is _i28.ProjectConfig) {
      return 'ProjectConfig';
    }
    if (data is _i29.ProjectDeleteCallEvent) {
      return 'ProjectDeleteCallEvent';
    }
    if (data is _i30.Role) {
      return 'Role';
    }
    if (data is _i31.UserRoleMembership) {
      return 'UserRoleMembership';
    }
    if (data is _i32.SecretResource) {
      return 'SecretResource';
    }
    if (data is _i33.SecretType) {
      return 'SecretType';
    }
    if (data is _i34.DuplicateEntryException) {
      return 'DuplicateEntryException';
    }
    if (data is _i35.ForbiddenException) {
      return 'ForbiddenException';
    }
    if (data is _i36.InvalidValueException) {
      return 'InvalidValueException';
    }
    if (data is _i37.NotFoundException) {
      return 'NotFoundException';
    }
    if (data is _i38.UnauthenticatedException) {
      return 'UnauthenticatedException';
    }
    if (data is _i39.UnauthorizedException) {
      return 'UnauthorizedException';
    }
    if (data is _i40.ServerpodRegion) {
      return 'ServerpodRegion';
    }
    className = _i48.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'Capsule') {
      return deserialize<_i2.Capsule>(data['data']);
    }
    if (dataClassName == 'LogRecord') {
      return deserialize<_i3.LogRecord>(data['data']);
    }
    if (dataClassName == 'DeployAttempt') {
      return deserialize<_i4.DeployAttempt>(data['data']);
    }
    if (dataClassName == 'DeployAttemptStage') {
      return deserialize<_i5.DeployAttemptStage>(data['data']);
    }
    if (dataClassName == 'DeployProgressStatus') {
      return deserialize<_i6.DeployProgressStatus>(data['data']);
    }
    if (dataClassName == 'DeployStageType') {
      return deserialize<_i7.DeployStageType>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i8.User>(data['data']);
    }
    if (dataClassName == 'AcceptedTerms') {
      return deserialize<_i9.AcceptedTerms>(data['data']);
    }
    if (dataClassName == 'AcceptedTermsDTO') {
      return deserialize<_i10.AcceptedTermsDTO>(data['data']);
    }
    if (dataClassName == 'RequiredTerms') {
      return deserialize<_i11.RequiredTerms>(data['data']);
    }
    if (dataClassName == 'Terms') {
      return deserialize<_i12.Terms>(data['data']);
    }
    if (dataClassName == 'DNSVerificationFailedException') {
      return deserialize<_i13.DNSVerificationFailedException>(data['data']);
    }
    if (dataClassName == 'CustomDomainName') {
      return deserialize<_i14.CustomDomainName>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameList') {
      return deserialize<_i15.CustomDomainNameList>(data['data']);
    }
    if (dataClassName == 'DnsRecordType') {
      return deserialize<_i16.DnsRecordType>(data['data']);
    }
    if (dataClassName == 'DomainNameStatus') {
      return deserialize<_i17.DomainNameStatus>(data['data']);
    }
    if (dataClassName == 'DomainNameTarget') {
      return deserialize<_i18.DomainNameTarget>(data['data']);
    }
    if (dataClassName == 'NewCustomDomainNamesEvent') {
      return deserialize<_i19.NewCustomDomainNamesEvent>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameWithDefaultDomains') {
      return deserialize<_i20.CustomDomainNameWithDefaultDomains>(data['data']);
    }
    if (dataClassName == 'DatabaseConnection') {
      return deserialize<_i21.DatabaseConnection>(data['data']);
    }
    if (dataClassName == 'DatabaseProvider') {
      return deserialize<_i22.DatabaseProvider>(data['data']);
    }
    if (dataClassName == 'DatabaseResource') {
      return deserialize<_i23.DatabaseResource>(data['data']);
    }
    if (dataClassName == 'EnvironmentVariable') {
      return deserialize<_i24.EnvironmentVariable>(data['data']);
    }
    if (dataClassName == 'AccountAuthorization') {
      return deserialize<_i25.AccountAuthorization>(data['data']);
    }
    if (dataClassName == 'Address') {
      return deserialize<_i26.Address>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i27.Project>(data['data']);
    }
    if (dataClassName == 'ProjectConfig') {
      return deserialize<_i28.ProjectConfig>(data['data']);
    }
    if (dataClassName == 'ProjectDeleteCallEvent') {
      return deserialize<_i29.ProjectDeleteCallEvent>(data['data']);
    }
    if (dataClassName == 'Role') {
      return deserialize<_i30.Role>(data['data']);
    }
    if (dataClassName == 'UserRoleMembership') {
      return deserialize<_i31.UserRoleMembership>(data['data']);
    }
    if (dataClassName == 'SecretResource') {
      return deserialize<_i32.SecretResource>(data['data']);
    }
    if (dataClassName == 'SecretType') {
      return deserialize<_i33.SecretType>(data['data']);
    }
    if (dataClassName == 'DuplicateEntryException') {
      return deserialize<_i34.DuplicateEntryException>(data['data']);
    }
    if (dataClassName == 'ForbiddenException') {
      return deserialize<_i35.ForbiddenException>(data['data']);
    }
    if (dataClassName == 'InvalidValueException') {
      return deserialize<_i36.InvalidValueException>(data['data']);
    }
    if (dataClassName == 'NotFoundException') {
      return deserialize<_i37.NotFoundException>(data['data']);
    }
    if (dataClassName == 'UnauthenticatedException') {
      return deserialize<_i38.UnauthenticatedException>(data['data']);
    }
    if (dataClassName == 'UnauthorizedException') {
      return deserialize<_i39.UnauthorizedException>(data['data']);
    }
    if (dataClassName == 'ServerpodRegion') {
      return deserialize<_i40.ServerpodRegion>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i48.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}

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
import 'domains/logs/models/log_record.dart' as _i2;
import 'domains/status/models/deploy_attempt.dart' as _i3;
import 'domains/status/models/deploy_attempt_stage.dart' as _i4;
import 'domains/status/models/deploy_progress_status.dart' as _i5;
import 'domains/status/models/deploy_stage_type.dart' as _i6;
import 'domains/users/models/user.dart' as _i7;
import 'features/custom_domain_name/models/custom_domain_name.dart' as _i8;
import 'features/custom_domain_name/models/custom_domain_name_list.dart' as _i9;
import 'features/custom_domain_name/models/domain_name_status.dart' as _i10;
import 'features/custom_domain_name/models/domain_name_target.dart' as _i11;
import 'features/custom_domain_name/models/new_domain_names_event.dart' as _i12;
import 'features/custom_domain_name/models/view_models/custom_domain_name_with_default_domains.dart'
    as _i13;
import 'features/database/models/database_connection.dart' as _i14;
import 'features/database/models/database_provider.dart' as _i15;
import 'features/database/models/database_resource.dart' as _i16;
import 'features/environment_variables/models/environment_variable.dart'
    as _i17;
import 'features/environments/models/environment.dart' as _i18;
import 'features/project/models/account_authorization.dart' as _i19;
import 'features/project/models/address.dart' as _i20;
import 'features/project/models/project.dart' as _i21;
import 'features/project/models/project_config.dart' as _i22;
import 'features/project/models/role.dart' as _i23;
import 'features/project/models/user_role_membership.dart' as _i24;
import 'features/secret_manager/models/secret_resource.dart' as _i25;
import 'features/secret_manager/models/secret_type.dart' as _i26;
import 'shared/exceptions/models/duplicate_entry_exception.dart' as _i27;
import 'shared/exceptions/models/forbidden_exception.dart' as _i28;
import 'shared/exceptions/models/invalid_value_exception.dart' as _i29;
import 'shared/exceptions/models/not_found_exception.dart' as _i30;
import 'shared/exceptions/models/unauthenticated_exception.dart' as _i31;
import 'shared/exceptions/models/unauthorized_exception.dart' as _i32;
import 'shared/models/serverpod_region.dart' as _i33;
import 'package:serverpod_ground_control_client/src/protocol/features/environment_variables/models/environment_variable.dart'
    as _i34;
import 'package:serverpod_ground_control_client/src/protocol/features/project/models/project.dart'
    as _i35;
import 'package:serverpod_ground_control_client/src/protocol/features/project/models/role.dart'
    as _i36;
import 'package:serverpod_ground_control_client/src/protocol/domains/status/models/deploy_attempt.dart'
    as _i37;
import 'package:serverpod_ground_control_client/src/protocol/domains/status/models/deploy_attempt_stage.dart'
    as _i38;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i39;
export 'domains/logs/models/log_record.dart';
export 'domains/status/models/deploy_attempt.dart';
export 'domains/status/models/deploy_attempt_stage.dart';
export 'domains/status/models/deploy_progress_status.dart';
export 'domains/status/models/deploy_stage_type.dart';
export 'domains/users/models/user.dart';
export 'features/custom_domain_name/models/custom_domain_name.dart';
export 'features/custom_domain_name/models/custom_domain_name_list.dart';
export 'features/custom_domain_name/models/domain_name_status.dart';
export 'features/custom_domain_name/models/domain_name_target.dart';
export 'features/custom_domain_name/models/new_domain_names_event.dart';
export 'features/custom_domain_name/models/view_models/custom_domain_name_with_default_domains.dart';
export 'features/database/models/database_connection.dart';
export 'features/database/models/database_provider.dart';
export 'features/database/models/database_resource.dart';
export 'features/environment_variables/models/environment_variable.dart';
export 'features/environments/models/environment.dart';
export 'features/project/models/account_authorization.dart';
export 'features/project/models/address.dart';
export 'features/project/models/project.dart';
export 'features/project/models/project_config.dart';
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
    if (t == _i2.LogRecord) {
      return _i2.LogRecord.fromJson(data) as T;
    }
    if (t == _i3.DeployAttempt) {
      return _i3.DeployAttempt.fromJson(data) as T;
    }
    if (t == _i4.DeployAttemptStage) {
      return _i4.DeployAttemptStage.fromJson(data) as T;
    }
    if (t == _i5.DeployProgressStatus) {
      return _i5.DeployProgressStatus.fromJson(data) as T;
    }
    if (t == _i6.DeployStageType) {
      return _i6.DeployStageType.fromJson(data) as T;
    }
    if (t == _i7.User) {
      return _i7.User.fromJson(data) as T;
    }
    if (t == _i8.CustomDomainName) {
      return _i8.CustomDomainName.fromJson(data) as T;
    }
    if (t == _i9.CustomDomainNameList) {
      return _i9.CustomDomainNameList.fromJson(data) as T;
    }
    if (t == _i10.DomainNameStatus) {
      return _i10.DomainNameStatus.fromJson(data) as T;
    }
    if (t == _i11.DomainNameTarget) {
      return _i11.DomainNameTarget.fromJson(data) as T;
    }
    if (t == _i12.NewCustomDomainNamesEvent) {
      return _i12.NewCustomDomainNamesEvent.fromJson(data) as T;
    }
    if (t == _i13.CustomDomainNameWithDefaultDomains) {
      return _i13.CustomDomainNameWithDefaultDomains.fromJson(data) as T;
    }
    if (t == _i14.DatabaseConnection) {
      return _i14.DatabaseConnection.fromJson(data) as T;
    }
    if (t == _i15.DatabaseProvider) {
      return _i15.DatabaseProvider.fromJson(data) as T;
    }
    if (t == _i16.DatabaseResource) {
      return _i16.DatabaseResource.fromJson(data) as T;
    }
    if (t == _i17.EnvironmentVariable) {
      return _i17.EnvironmentVariable.fromJson(data) as T;
    }
    if (t == _i18.Environment) {
      return _i18.Environment.fromJson(data) as T;
    }
    if (t == _i19.AccountAuthorization) {
      return _i19.AccountAuthorization.fromJson(data) as T;
    }
    if (t == _i20.Address) {
      return _i20.Address.fromJson(data) as T;
    }
    if (t == _i21.Project) {
      return _i21.Project.fromJson(data) as T;
    }
    if (t == _i22.ProjectConfig) {
      return _i22.ProjectConfig.fromJson(data) as T;
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
    if (t == _i27.DuplicateEntryException) {
      return _i27.DuplicateEntryException.fromJson(data) as T;
    }
    if (t == _i28.ForbiddenException) {
      return _i28.ForbiddenException.fromJson(data) as T;
    }
    if (t == _i29.InvalidValueException) {
      return _i29.InvalidValueException.fromJson(data) as T;
    }
    if (t == _i30.NotFoundException) {
      return _i30.NotFoundException.fromJson(data) as T;
    }
    if (t == _i31.UnauthenticatedException) {
      return _i31.UnauthenticatedException.fromJson(data) as T;
    }
    if (t == _i32.UnauthorizedException) {
      return _i32.UnauthorizedException.fromJson(data) as T;
    }
    if (t == _i33.ServerpodRegion) {
      return _i33.ServerpodRegion.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.LogRecord?>()) {
      return (data != null ? _i2.LogRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.DeployAttempt?>()) {
      return (data != null ? _i3.DeployAttempt.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.DeployAttemptStage?>()) {
      return (data != null ? _i4.DeployAttemptStage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.DeployProgressStatus?>()) {
      return (data != null ? _i5.DeployProgressStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.DeployStageType?>()) {
      return (data != null ? _i6.DeployStageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.User?>()) {
      return (data != null ? _i7.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.CustomDomainName?>()) {
      return (data != null ? _i8.CustomDomainName.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.CustomDomainNameList?>()) {
      return (data != null ? _i9.CustomDomainNameList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.DomainNameStatus?>()) {
      return (data != null ? _i10.DomainNameStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.DomainNameTarget?>()) {
      return (data != null ? _i11.DomainNameTarget.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.NewCustomDomainNamesEvent?>()) {
      return (data != null
          ? _i12.NewCustomDomainNamesEvent.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i13.CustomDomainNameWithDefaultDomains?>()) {
      return (data != null
          ? _i13.CustomDomainNameWithDefaultDomains.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i14.DatabaseConnection?>()) {
      return (data != null ? _i14.DatabaseConnection.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.DatabaseProvider?>()) {
      return (data != null ? _i15.DatabaseProvider.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.DatabaseResource?>()) {
      return (data != null ? _i16.DatabaseResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.EnvironmentVariable?>()) {
      return (data != null ? _i17.EnvironmentVariable.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.Environment?>()) {
      return (data != null ? _i18.Environment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.AccountAuthorization?>()) {
      return (data != null ? _i19.AccountAuthorization.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i20.Address?>()) {
      return (data != null ? _i20.Address.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.Project?>()) {
      return (data != null ? _i21.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.ProjectConfig?>()) {
      return (data != null ? _i22.ProjectConfig.fromJson(data) : null) as T;
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
    if (t == _i1.getType<_i27.DuplicateEntryException?>()) {
      return (data != null ? _i27.DuplicateEntryException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i28.ForbiddenException?>()) {
      return (data != null ? _i28.ForbiddenException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i29.InvalidValueException?>()) {
      return (data != null ? _i29.InvalidValueException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i30.NotFoundException?>()) {
      return (data != null ? _i30.NotFoundException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.UnauthenticatedException?>()) {
      return (data != null
          ? _i31.UnauthenticatedException.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i32.UnauthorizedException?>()) {
      return (data != null ? _i32.UnauthorizedException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i33.ServerpodRegion?>()) {
      return (data != null ? _i33.ServerpodRegion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<List<_i24.UserRoleMembership>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i24.UserRoleMembership>(e))
              .toList()
          : null) as dynamic;
    }
    if (t == List<_i8.CustomDomainName>) {
      return (data as List)
          .map((e) => deserialize<_i8.CustomDomainName>(e))
          .toList() as dynamic;
    }
    if (t == Map<_i11.DomainNameTarget, String>) {
      return Map.fromEntries((data as List).map((e) => MapEntry(
          deserialize<_i11.DomainNameTarget>(e['k']),
          deserialize<String>(e['v'])))) as dynamic;
    }
    if (t == _i1.getType<List<_i17.EnvironmentVariable>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i17.EnvironmentVariable>(e))
              .toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<_i8.CustomDomainName>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i8.CustomDomainName>(e))
              .toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<_i23.Role>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i23.Role>(e)).toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<_i18.Environment>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i18.Environment>(e)).toList()
          : null) as dynamic;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList()
          as dynamic;
    }
    if (t == _i1.getType<List<_i24.UserRoleMembership>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i24.UserRoleMembership>(e))
              .toList()
          : null) as dynamic;
    }
    if (t == List<_i34.EnvironmentVariable>) {
      return (data as List)
          .map((e) => deserialize<_i34.EnvironmentVariable>(e))
          .toList() as dynamic;
    }
    if (t == List<_i35.Project>) {
      return (data as List).map((e) => deserialize<_i35.Project>(e)).toList()
          as dynamic;
    }
    if (t == List<_i36.Role>) {
      return (data as List).map((e) => deserialize<_i36.Role>(e)).toList()
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
    if (t == List<_i37.DeployAttempt>) {
      return (data as List)
          .map((e) => deserialize<_i37.DeployAttempt>(e))
          .toList() as dynamic;
    }
    if (t == List<_i38.DeployAttemptStage>) {
      return (data as List)
          .map((e) => deserialize<_i38.DeployAttemptStage>(e))
          .toList() as dynamic;
    }
    try {
      return _i39.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.LogRecord) {
      return 'LogRecord';
    }
    if (data is _i3.DeployAttempt) {
      return 'DeployAttempt';
    }
    if (data is _i4.DeployAttemptStage) {
      return 'DeployAttemptStage';
    }
    if (data is _i5.DeployProgressStatus) {
      return 'DeployProgressStatus';
    }
    if (data is _i6.DeployStageType) {
      return 'DeployStageType';
    }
    if (data is _i7.User) {
      return 'User';
    }
    if (data is _i8.CustomDomainName) {
      return 'CustomDomainName';
    }
    if (data is _i9.CustomDomainNameList) {
      return 'CustomDomainNameList';
    }
    if (data is _i10.DomainNameStatus) {
      return 'DomainNameStatus';
    }
    if (data is _i11.DomainNameTarget) {
      return 'DomainNameTarget';
    }
    if (data is _i12.NewCustomDomainNamesEvent) {
      return 'NewCustomDomainNamesEvent';
    }
    if (data is _i13.CustomDomainNameWithDefaultDomains) {
      return 'CustomDomainNameWithDefaultDomains';
    }
    if (data is _i14.DatabaseConnection) {
      return 'DatabaseConnection';
    }
    if (data is _i15.DatabaseProvider) {
      return 'DatabaseProvider';
    }
    if (data is _i16.DatabaseResource) {
      return 'DatabaseResource';
    }
    if (data is _i17.EnvironmentVariable) {
      return 'EnvironmentVariable';
    }
    if (data is _i18.Environment) {
      return 'Environment';
    }
    if (data is _i19.AccountAuthorization) {
      return 'AccountAuthorization';
    }
    if (data is _i20.Address) {
      return 'Address';
    }
    if (data is _i21.Project) {
      return 'Project';
    }
    if (data is _i22.ProjectConfig) {
      return 'ProjectConfig';
    }
    if (data is _i23.Role) {
      return 'Role';
    }
    if (data is _i24.UserRoleMembership) {
      return 'UserRoleMembership';
    }
    if (data is _i25.SecretResource) {
      return 'SecretResource';
    }
    if (data is _i26.SecretType) {
      return 'SecretType';
    }
    if (data is _i27.DuplicateEntryException) {
      return 'DuplicateEntryException';
    }
    if (data is _i28.ForbiddenException) {
      return 'ForbiddenException';
    }
    if (data is _i29.InvalidValueException) {
      return 'InvalidValueException';
    }
    if (data is _i30.NotFoundException) {
      return 'NotFoundException';
    }
    if (data is _i31.UnauthenticatedException) {
      return 'UnauthenticatedException';
    }
    if (data is _i32.UnauthorizedException) {
      return 'UnauthorizedException';
    }
    if (data is _i33.ServerpodRegion) {
      return 'ServerpodRegion';
    }
    className = _i39.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'LogRecord') {
      return deserialize<_i2.LogRecord>(data['data']);
    }
    if (dataClassName == 'DeployAttempt') {
      return deserialize<_i3.DeployAttempt>(data['data']);
    }
    if (dataClassName == 'DeployAttemptStage') {
      return deserialize<_i4.DeployAttemptStage>(data['data']);
    }
    if (dataClassName == 'DeployProgressStatus') {
      return deserialize<_i5.DeployProgressStatus>(data['data']);
    }
    if (dataClassName == 'DeployStageType') {
      return deserialize<_i6.DeployStageType>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i7.User>(data['data']);
    }
    if (dataClassName == 'CustomDomainName') {
      return deserialize<_i8.CustomDomainName>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameList') {
      return deserialize<_i9.CustomDomainNameList>(data['data']);
    }
    if (dataClassName == 'DomainNameStatus') {
      return deserialize<_i10.DomainNameStatus>(data['data']);
    }
    if (dataClassName == 'DomainNameTarget') {
      return deserialize<_i11.DomainNameTarget>(data['data']);
    }
    if (dataClassName == 'NewCustomDomainNamesEvent') {
      return deserialize<_i12.NewCustomDomainNamesEvent>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameWithDefaultDomains') {
      return deserialize<_i13.CustomDomainNameWithDefaultDomains>(data['data']);
    }
    if (dataClassName == 'DatabaseConnection') {
      return deserialize<_i14.DatabaseConnection>(data['data']);
    }
    if (dataClassName == 'DatabaseProvider') {
      return deserialize<_i15.DatabaseProvider>(data['data']);
    }
    if (dataClassName == 'DatabaseResource') {
      return deserialize<_i16.DatabaseResource>(data['data']);
    }
    if (dataClassName == 'EnvironmentVariable') {
      return deserialize<_i17.EnvironmentVariable>(data['data']);
    }
    if (dataClassName == 'Environment') {
      return deserialize<_i18.Environment>(data['data']);
    }
    if (dataClassName == 'AccountAuthorization') {
      return deserialize<_i19.AccountAuthorization>(data['data']);
    }
    if (dataClassName == 'Address') {
      return deserialize<_i20.Address>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i21.Project>(data['data']);
    }
    if (dataClassName == 'ProjectConfig') {
      return deserialize<_i22.ProjectConfig>(data['data']);
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
    if (dataClassName == 'DuplicateEntryException') {
      return deserialize<_i27.DuplicateEntryException>(data['data']);
    }
    if (dataClassName == 'ForbiddenException') {
      return deserialize<_i28.ForbiddenException>(data['data']);
    }
    if (dataClassName == 'InvalidValueException') {
      return deserialize<_i29.InvalidValueException>(data['data']);
    }
    if (dataClassName == 'NotFoundException') {
      return deserialize<_i30.NotFoundException>(data['data']);
    }
    if (dataClassName == 'UnauthenticatedException') {
      return deserialize<_i31.UnauthenticatedException>(data['data']);
    }
    if (dataClassName == 'UnauthorizedException') {
      return deserialize<_i32.UnauthorizedException>(data['data']);
    }
    if (dataClassName == 'ServerpodRegion') {
      return deserialize<_i33.ServerpodRegion>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i39.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}

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
import 'exceptions/duplicate_entry_exception.dart' as _i2;
import 'exceptions/invalid_value_exception.dart' as _i3;
import 'exceptions/not_found_exception.dart' as _i4;
import 'exceptions/unauthenticated_exception.dart' as _i5;
import 'exceptions/unauthorized_exception.dart' as _i6;
import 'infrastructure/custom_domain_name.dart' as _i7;
import 'infrastructure/database_connection.dart' as _i8;
import 'infrastructure/database_provider.dart' as _i9;
import 'infrastructure/database_resource.dart' as _i10;
import 'infrastructure/domain_name_status.dart' as _i11;
import 'infrastructure/domain_name_target.dart' as _i12;
import 'infrastructure/environment.dart' as _i13;
import 'infrastructure/secret_resource.dart' as _i14;
import 'infrastructure/secret_type.dart' as _i15;
import 'logs/log_record.dart' as _i16;
import 'serverpod_region.dart' as _i17;
import 'tenant/account_authorization.dart' as _i18;
import 'tenant/address.dart' as _i19;
import 'tenant/environment_variable.dart' as _i20;
import 'tenant/role.dart' as _i21;
import 'tenant/tenant_project.dart' as _i22;
import 'tenant/user.dart' as _i23;
import 'tenant/user_role_membership.dart' as _i24;
import 'view_models/infrastructure/custom_domain_name_list.dart' as _i25;
import 'protocol.dart' as _i26;
import 'package:serverpod_ground_control_client/src/protocol/tenant/environment_variable.dart'
    as _i27;
import 'package:serverpod_ground_control_client/src/protocol/tenant/role.dart'
    as _i28;
import 'package:serverpod_ground_control_client/src/protocol/tenant/tenant_project.dart'
    as _i29;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i30;
export 'exceptions/duplicate_entry_exception.dart';
export 'exceptions/invalid_value_exception.dart';
export 'exceptions/not_found_exception.dart';
export 'exceptions/unauthenticated_exception.dart';
export 'exceptions/unauthorized_exception.dart';
export 'infrastructure/custom_domain_name.dart';
export 'infrastructure/database_connection.dart';
export 'infrastructure/database_provider.dart';
export 'infrastructure/database_resource.dart';
export 'infrastructure/domain_name_status.dart';
export 'infrastructure/domain_name_target.dart';
export 'infrastructure/environment.dart';
export 'infrastructure/secret_resource.dart';
export 'infrastructure/secret_type.dart';
export 'logs/log_record.dart';
export 'serverpod_region.dart';
export 'tenant/account_authorization.dart';
export 'tenant/address.dart';
export 'tenant/environment_variable.dart';
export 'tenant/role.dart';
export 'tenant/tenant_project.dart';
export 'tenant/user.dart';
export 'tenant/user_role_membership.dart';
export 'view_models/infrastructure/custom_domain_name_list.dart';
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
    if (t == _i2.DuplicateEntryException) {
      return _i2.DuplicateEntryException.fromJson(data) as T;
    }
    if (t == _i3.InvalidValueException) {
      return _i3.InvalidValueException.fromJson(data) as T;
    }
    if (t == _i4.NotFoundException) {
      return _i4.NotFoundException.fromJson(data) as T;
    }
    if (t == _i5.UnauthenticatedException) {
      return _i5.UnauthenticatedException.fromJson(data) as T;
    }
    if (t == _i6.UnauthorizedException) {
      return _i6.UnauthorizedException.fromJson(data) as T;
    }
    if (t == _i7.CustomDomainName) {
      return _i7.CustomDomainName.fromJson(data) as T;
    }
    if (t == _i8.DatabaseConnection) {
      return _i8.DatabaseConnection.fromJson(data) as T;
    }
    if (t == _i9.DatabaseProvider) {
      return _i9.DatabaseProvider.fromJson(data) as T;
    }
    if (t == _i10.DatabaseResource) {
      return _i10.DatabaseResource.fromJson(data) as T;
    }
    if (t == _i11.DomainNameStatus) {
      return _i11.DomainNameStatus.fromJson(data) as T;
    }
    if (t == _i12.DomainNameTarget) {
      return _i12.DomainNameTarget.fromJson(data) as T;
    }
    if (t == _i13.Environment) {
      return _i13.Environment.fromJson(data) as T;
    }
    if (t == _i14.SecretResource) {
      return _i14.SecretResource.fromJson(data) as T;
    }
    if (t == _i15.SecretType) {
      return _i15.SecretType.fromJson(data) as T;
    }
    if (t == _i16.LogRecord) {
      return _i16.LogRecord.fromJson(data) as T;
    }
    if (t == _i17.ServerpodRegion) {
      return _i17.ServerpodRegion.fromJson(data) as T;
    }
    if (t == _i18.AccountAuthorization) {
      return _i18.AccountAuthorization.fromJson(data) as T;
    }
    if (t == _i19.Address) {
      return _i19.Address.fromJson(data) as T;
    }
    if (t == _i20.EnvironmentVariable) {
      return _i20.EnvironmentVariable.fromJson(data) as T;
    }
    if (t == _i21.Role) {
      return _i21.Role.fromJson(data) as T;
    }
    if (t == _i22.TenantProject) {
      return _i22.TenantProject.fromJson(data) as T;
    }
    if (t == _i23.User) {
      return _i23.User.fromJson(data) as T;
    }
    if (t == _i24.UserRoleMembership) {
      return _i24.UserRoleMembership.fromJson(data) as T;
    }
    if (t == _i25.CustomDomainNameList) {
      return _i25.CustomDomainNameList.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.DuplicateEntryException?>()) {
      return (data != null ? _i2.DuplicateEntryException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i3.InvalidValueException?>()) {
      return (data != null ? _i3.InvalidValueException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.NotFoundException?>()) {
      return (data != null ? _i4.NotFoundException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.UnauthenticatedException?>()) {
      return (data != null ? _i5.UnauthenticatedException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.UnauthorizedException?>()) {
      return (data != null ? _i6.UnauthorizedException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.CustomDomainName?>()) {
      return (data != null ? _i7.CustomDomainName.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.DatabaseConnection?>()) {
      return (data != null ? _i8.DatabaseConnection.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.DatabaseProvider?>()) {
      return (data != null ? _i9.DatabaseProvider.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.DatabaseResource?>()) {
      return (data != null ? _i10.DatabaseResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.DomainNameStatus?>()) {
      return (data != null ? _i11.DomainNameStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.DomainNameTarget?>()) {
      return (data != null ? _i12.DomainNameTarget.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.Environment?>()) {
      return (data != null ? _i13.Environment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.SecretResource?>()) {
      return (data != null ? _i14.SecretResource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.SecretType?>()) {
      return (data != null ? _i15.SecretType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.LogRecord?>()) {
      return (data != null ? _i16.LogRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.ServerpodRegion?>()) {
      return (data != null ? _i17.ServerpodRegion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.AccountAuthorization?>()) {
      return (data != null ? _i18.AccountAuthorization.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.Address?>()) {
      return (data != null ? _i19.Address.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.EnvironmentVariable?>()) {
      return (data != null ? _i20.EnvironmentVariable.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i21.Role?>()) {
      return (data != null ? _i21.Role.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.TenantProject?>()) {
      return (data != null ? _i22.TenantProject.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.User?>()) {
      return (data != null ? _i23.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.UserRoleMembership?>()) {
      return (data != null ? _i24.UserRoleMembership.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i25.CustomDomainNameList?>()) {
      return (data != null ? _i25.CustomDomainNameList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<List<_i26.EnvironmentVariable>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i26.EnvironmentVariable>(e))
              .toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<_i26.CustomDomainName>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i26.CustomDomainName>(e))
              .toList()
          : null) as dynamic;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList()
          as dynamic;
    }
    if (t == _i1.getType<List<_i26.UserRoleMembership>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i26.UserRoleMembership>(e))
              .toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<_i26.Role>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i26.Role>(e)).toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<_i26.Environment>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i26.Environment>(e)).toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<_i26.UserRoleMembership>?>()) {
      return (data != null
          ? (data as List)
              .map((e) => deserialize<_i26.UserRoleMembership>(e))
              .toList()
          : null) as dynamic;
    }
    if (t == List<_i26.CustomDomainName>) {
      return (data as List)
          .map((e) => deserialize<_i26.CustomDomainName>(e))
          .toList() as dynamic;
    }
    if (t == Map<_i26.DomainNameTarget, String>) {
      return Map.fromEntries((data as List).map((e) => MapEntry(
          deserialize<_i26.DomainNameTarget>(e['k']),
          deserialize<String>(e['v'])))) as dynamic;
    }
    if (t == List<_i27.EnvironmentVariable>) {
      return (data as List)
          .map((e) => deserialize<_i27.EnvironmentVariable>(e))
          .toList() as dynamic;
    }
    if (t == List<_i28.Role>) {
      return (data as List).map((e) => deserialize<_i28.Role>(e)).toList()
          as dynamic;
    }
    if (t == List<_i29.TenantProject>) {
      return (data as List)
          .map((e) => deserialize<_i29.TenantProject>(e))
          .toList() as dynamic;
    }
    try {
      return _i30.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.DuplicateEntryException) {
      return 'DuplicateEntryException';
    }
    if (data is _i3.InvalidValueException) {
      return 'InvalidValueException';
    }
    if (data is _i4.NotFoundException) {
      return 'NotFoundException';
    }
    if (data is _i5.UnauthenticatedException) {
      return 'UnauthenticatedException';
    }
    if (data is _i6.UnauthorizedException) {
      return 'UnauthorizedException';
    }
    if (data is _i7.CustomDomainName) {
      return 'CustomDomainName';
    }
    if (data is _i8.DatabaseConnection) {
      return 'DatabaseConnection';
    }
    if (data is _i9.DatabaseProvider) {
      return 'DatabaseProvider';
    }
    if (data is _i10.DatabaseResource) {
      return 'DatabaseResource';
    }
    if (data is _i11.DomainNameStatus) {
      return 'DomainNameStatus';
    }
    if (data is _i12.DomainNameTarget) {
      return 'DomainNameTarget';
    }
    if (data is _i13.Environment) {
      return 'Environment';
    }
    if (data is _i14.SecretResource) {
      return 'SecretResource';
    }
    if (data is _i15.SecretType) {
      return 'SecretType';
    }
    if (data is _i16.LogRecord) {
      return 'LogRecord';
    }
    if (data is _i17.ServerpodRegion) {
      return 'ServerpodRegion';
    }
    if (data is _i18.AccountAuthorization) {
      return 'AccountAuthorization';
    }
    if (data is _i19.Address) {
      return 'Address';
    }
    if (data is _i20.EnvironmentVariable) {
      return 'EnvironmentVariable';
    }
    if (data is _i21.Role) {
      return 'Role';
    }
    if (data is _i22.TenantProject) {
      return 'TenantProject';
    }
    if (data is _i23.User) {
      return 'User';
    }
    if (data is _i24.UserRoleMembership) {
      return 'UserRoleMembership';
    }
    if (data is _i25.CustomDomainNameList) {
      return 'CustomDomainNameList';
    }
    className = _i30.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'DuplicateEntryException') {
      return deserialize<_i2.DuplicateEntryException>(data['data']);
    }
    if (dataClassName == 'InvalidValueException') {
      return deserialize<_i3.InvalidValueException>(data['data']);
    }
    if (dataClassName == 'NotFoundException') {
      return deserialize<_i4.NotFoundException>(data['data']);
    }
    if (dataClassName == 'UnauthenticatedException') {
      return deserialize<_i5.UnauthenticatedException>(data['data']);
    }
    if (dataClassName == 'UnauthorizedException') {
      return deserialize<_i6.UnauthorizedException>(data['data']);
    }
    if (dataClassName == 'CustomDomainName') {
      return deserialize<_i7.CustomDomainName>(data['data']);
    }
    if (dataClassName == 'DatabaseConnection') {
      return deserialize<_i8.DatabaseConnection>(data['data']);
    }
    if (dataClassName == 'DatabaseProvider') {
      return deserialize<_i9.DatabaseProvider>(data['data']);
    }
    if (dataClassName == 'DatabaseResource') {
      return deserialize<_i10.DatabaseResource>(data['data']);
    }
    if (dataClassName == 'DomainNameStatus') {
      return deserialize<_i11.DomainNameStatus>(data['data']);
    }
    if (dataClassName == 'DomainNameTarget') {
      return deserialize<_i12.DomainNameTarget>(data['data']);
    }
    if (dataClassName == 'Environment') {
      return deserialize<_i13.Environment>(data['data']);
    }
    if (dataClassName == 'SecretResource') {
      return deserialize<_i14.SecretResource>(data['data']);
    }
    if (dataClassName == 'SecretType') {
      return deserialize<_i15.SecretType>(data['data']);
    }
    if (dataClassName == 'LogRecord') {
      return deserialize<_i16.LogRecord>(data['data']);
    }
    if (dataClassName == 'ServerpodRegion') {
      return deserialize<_i17.ServerpodRegion>(data['data']);
    }
    if (dataClassName == 'AccountAuthorization') {
      return deserialize<_i18.AccountAuthorization>(data['data']);
    }
    if (dataClassName == 'Address') {
      return deserialize<_i19.Address>(data['data']);
    }
    if (dataClassName == 'EnvironmentVariable') {
      return deserialize<_i20.EnvironmentVariable>(data['data']);
    }
    if (dataClassName == 'Role') {
      return deserialize<_i21.Role>(data['data']);
    }
    if (dataClassName == 'TenantProject') {
      return deserialize<_i22.TenantProject>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i23.User>(data['data']);
    }
    if (dataClassName == 'UserRoleMembership') {
      return deserialize<_i24.UserRoleMembership>(data['data']);
    }
    if (dataClassName == 'CustomDomainNameList') {
      return deserialize<_i25.CustomDomainNameList>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i30.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}

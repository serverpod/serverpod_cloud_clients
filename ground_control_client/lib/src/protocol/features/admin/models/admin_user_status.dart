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
import 'package:ground_control_client/src/protocol/protocol.dart' as _iod2a87h;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../../features/admin/models/admin_user_owner_status.dart'
    as _iszfen3m;
import '../../../features/admin/models/admin_user_project_membership.dart'
    as _i5t901ln;

abstract class AdminUserStatus
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminUserStatus._({required this.owner, required this.projects});

  factory AdminUserStatus({
    required _iszfen3m.AdminUserOwnerStatus owner,
    required List<_i5t901ln.AdminUserProjectMembership> projects,
  }) = _AdminUserStatusImpl;

  factory AdminUserStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminUserStatus(
      owner: _iod2a87h.Protocol().deserialize<_iszfen3m.AdminUserOwnerStatus>(
        jsonSerialization['owner'],
      ),
      projects: _iod2a87h.Protocol()
          .deserialize<List<_i5t901ln.AdminUserProjectMembership>>(
            jsonSerialization['projects'],
          ),
    );
  }

  _iszfen3m.AdminUserOwnerStatus owner;

  List<_i5t901ln.AdminUserProjectMembership> projects;

  /// Returns a shallow copy of this [AdminUserStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminUserStatus copyWith({
    _iszfen3m.AdminUserOwnerStatus? owner,
    List<_i5t901ln.AdminUserProjectMembership>? projects,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminUserStatus',
      'owner': owner.toJson(),
      'projects': projects.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminUserStatus',
      'owner': owner.toJsonForProtocol(),
      'projects': projects.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AdminUserStatusImpl extends AdminUserStatus {
  _AdminUserStatusImpl({
    required _iszfen3m.AdminUserOwnerStatus owner,
    required List<_i5t901ln.AdminUserProjectMembership> projects,
  }) : super._(owner: owner, projects: projects);

  /// Returns a shallow copy of this [AdminUserStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminUserStatus copyWith({
    _iszfen3m.AdminUserOwnerStatus? owner,
    List<_i5t901ln.AdminUserProjectMembership>? projects,
  }) {
    return AdminUserStatus(
      owner: owner ?? this.owner.copyWith(),
      projects: projects ?? this.projects.map((e0) => e0.copyWith()).toList(),
    );
  }
}

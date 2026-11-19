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
import '../../../domains/projects/models/project_role.dart' as _isypcm2i;
import '../../../features/admin/models/admin_project_info.dart' as _icnx3kzo;

/// A project the user belongs to, including that project's admin status.
abstract class AdminUserProjectMembership
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminUserProjectMembership._({
    required this.userRoles,
    required this.project,
  });

  factory AdminUserProjectMembership({
    required List<_isypcm2i.ProjectRole> userRoles,
    required _icnx3kzo.AdminProjectInfo project,
  }) = _AdminUserProjectMembershipImpl;

  factory AdminUserProjectMembership.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminUserProjectMembership(
      userRoles: _iod2a87h.Protocol().deserialize<List<_isypcm2i.ProjectRole>>(
        jsonSerialization['userRoles'],
      ),
      project: _iod2a87h.Protocol().deserialize<_icnx3kzo.AdminProjectInfo>(
        jsonSerialization['project'],
      ),
    );
  }

  /// Roles the user holds on the project.
  List<_isypcm2i.ProjectRole> userRoles;

  /// The admin status of the project.
  _icnx3kzo.AdminProjectInfo project;

  /// Returns a shallow copy of this [AdminUserProjectMembership]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminUserProjectMembership copyWith({
    List<_isypcm2i.ProjectRole>? userRoles,
    _icnx3kzo.AdminProjectInfo? project,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminUserProjectMembership',
      'userRoles': userRoles.toJson(valueToJson: (v) => v.toJson()),
      'project': project.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminUserProjectMembership',
      'userRoles': userRoles.toJson(valueToJson: (v) => v.toJson()),
      'project': project.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AdminUserProjectMembershipImpl extends AdminUserProjectMembership {
  _AdminUserProjectMembershipImpl({
    required List<_isypcm2i.ProjectRole> userRoles,
    required _icnx3kzo.AdminProjectInfo project,
  }) : super._(userRoles: userRoles, project: project);

  /// Returns a shallow copy of this [AdminUserProjectMembership]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminUserProjectMembership copyWith({
    List<_isypcm2i.ProjectRole>? userRoles,
    _icnx3kzo.AdminProjectInfo? project,
  }) {
    return AdminUserProjectMembership(
      userRoles: userRoles ?? this.userRoles.map((e0) => e0).toList(),
      project: project ?? this.project.copyWith(),
    );
  }
}

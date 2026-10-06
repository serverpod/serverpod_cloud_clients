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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// The intended lifecycle status of a project.
/// The infrastructure may lag behind it.
enum ProjectLifecycleStatus implements _isc.SerializableModel {
  /// The project is live.
  active,

  /// The project's infrastructure is paused. It can be reactivated.
  suspended,

  /// The project is deleted. It cannot be reactivated.
  archived;

  static ProjectLifecycleStatus fromJson(String name) {
    switch (name) {
      case 'active':
        return ProjectLifecycleStatus.active;
      case 'suspended':
        return ProjectLifecycleStatus.suspended;
      case 'archived':
        return ProjectLifecycleStatus.archived;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "ProjectLifecycleStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

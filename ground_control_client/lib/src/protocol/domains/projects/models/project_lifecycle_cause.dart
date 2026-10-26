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

/// What happened to a project, as published on the `project-lifecycle`
/// topic.
enum ProjectLifecycleCause implements _isc.SerializableModel {
  /// The project exists and is active.
  created,

  /// The project is suspended for `suspensionReason` and its capsule paused.
  suspended,

  /// The project is still suspended, now for `suspensionReason`; its capsule
  /// stays paused.
  suspensionReasonChanged,

  /// The project is active again and its capsule resumed.
  resumed,

  /// The project is deleted.
  deleted;

  static ProjectLifecycleCause fromJson(String name) {
    switch (name) {
      case 'created':
        return ProjectLifecycleCause.created;
      case 'suspended':
        return ProjectLifecycleCause.suspended;
      case 'suspensionReasonChanged':
        return ProjectLifecycleCause.suspensionReasonChanged;
      case 'resumed':
        return ProjectLifecycleCause.resumed;
      case 'deleted':
        return ProjectLifecycleCause.deleted;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "ProjectLifecycleCause"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

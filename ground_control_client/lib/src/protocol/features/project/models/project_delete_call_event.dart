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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class ProjectDeleteCallEvent implements _i1.SerializableModel {
  ProjectDeleteCallEvent._({required this.cloudProjectId});

  factory ProjectDeleteCallEvent({required String cloudProjectId}) =
      _ProjectDeleteCallEventImpl;

  factory ProjectDeleteCallEvent.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return ProjectDeleteCallEvent(
        cloudProjectId: jsonSerialization['cloudProjectId'] as String);
  }

  String cloudProjectId;

  /// Returns a shallow copy of this [ProjectDeleteCallEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectDeleteCallEvent copyWith({String? cloudProjectId});
  @override
  Map<String, dynamic> toJson() {
    return {'cloudProjectId': cloudProjectId};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ProjectDeleteCallEventImpl extends ProjectDeleteCallEvent {
  _ProjectDeleteCallEventImpl({required String cloudProjectId})
      : super._(cloudProjectId: cloudProjectId);

  /// Returns a shallow copy of this [ProjectDeleteCallEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectDeleteCallEvent copyWith({String? cloudProjectId}) {
    return ProjectDeleteCallEvent(
        cloudProjectId: cloudProjectId ?? this.cloudProjectId);
  }
}

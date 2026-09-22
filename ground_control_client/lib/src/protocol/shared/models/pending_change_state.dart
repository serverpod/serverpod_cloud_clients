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

/// How a deployment input differs from the one the capsule is running.
enum PendingChangeState implements _isc.SerializableModel {
  /// The name does not exist in the deployed version.
  added,

  /// The name exists in both versions with a different value.
  changed,

  /// The name only exists in the deployed version.
  removed;

  static PendingChangeState fromJson(String name) {
    switch (name) {
      case 'added':
        return PendingChangeState.added;
      case 'changed':
        return PendingChangeState.changed;
      case 'removed':
        return PendingChangeState.removed;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "PendingChangeState"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

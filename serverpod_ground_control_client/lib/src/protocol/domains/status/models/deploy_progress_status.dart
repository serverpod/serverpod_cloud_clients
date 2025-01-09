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

enum DeployProgressStatus implements _i1.SerializableModel {
  unknown,
  cancelled,
  awaiting,
  running,
  success,
  failure;

  static DeployProgressStatus fromJson(String name) {
    switch (name) {
      case 'unknown':
        return unknown;
      case 'cancelled':
        return cancelled;
      case 'awaiting':
        return awaiting;
      case 'running':
        return running;
      case 'success':
        return success;
      case 'failure':
        return failure;
      default:
        throw ArgumentError(
            'Value "$name" cannot be converted to "DeployProgressStatus"');
    }
  }

  @override
  String toJson() => name;
  @override
  String toString() => name;
}

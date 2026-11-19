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

/// Why a usage cap is not allowed.
enum UsageCapDeniedReason implements _isc.SerializableModel {
  /// The plan of the project has no usage cap.
  planNotSupported,

  /// The usage cap is below the lowest one the subscription can have.
  tooLow;

  static UsageCapDeniedReason fromJson(String name) {
    switch (name) {
      case 'planNotSupported':
        return UsageCapDeniedReason.planNotSupported;
      case 'tooLow':
        return UsageCapDeniedReason.tooLow;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "UsageCapDeniedReason"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

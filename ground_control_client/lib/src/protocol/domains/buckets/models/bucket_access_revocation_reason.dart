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

/// The cap breach that caused customer access to a bucket to be revoked.
enum BucketAccessRevocationReason implements _i1.SerializableModel {
  /// The capsule's metered storage exceeded its plan's storage cap.
  storageOverage,

  /// The capsule's egress this billing period exceeded its plan's egress cap.
  egressOverage,

  /// The capsule's combined read and write operations this billing period
  /// exceeded its plan's operations cap.
  opsOverage;

  static BucketAccessRevocationReason fromJson(String name) {
    switch (name) {
      case 'storageOverage':
        return BucketAccessRevocationReason.storageOverage;
      case 'egressOverage':
        return BucketAccessRevocationReason.egressOverage;
      case 'opsOverage':
        return BucketAccessRevocationReason.opsOverage;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "BucketAccessRevocationReason"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

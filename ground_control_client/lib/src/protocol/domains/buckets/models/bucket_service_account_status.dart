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

/// The lifecycle state of a capsule's storage-identity service account,
/// recording facts that have happened rather than operations in flight.
enum BucketServiceAccountStatus implements _i1.SerializableModel {
  /// The database row exists; the service account key has not yet been
  /// delivered to the capsule's secrets.
  created,

  /// The service account key has been delivered and the identity is ready
  /// for use.
  provisioned,

  /// Deletion has been requested; removal of the service account is pending
  /// or in progress.
  deletionRequested,

  /// The service account has been removed.
  deleted;

  static BucketServiceAccountStatus fromJson(String name) {
    switch (name) {
      case 'created':
        return BucketServiceAccountStatus.created;
      case 'provisioned':
        return BucketServiceAccountStatus.provisioned;
      case 'deletionRequested':
        return BucketServiceAccountStatus.deletionRequested;
      case 'deleted':
        return BucketServiceAccountStatus.deleted;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "BucketServiceAccountStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

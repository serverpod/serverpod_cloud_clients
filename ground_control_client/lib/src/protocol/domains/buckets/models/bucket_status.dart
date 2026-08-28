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

/// The lifecycle state of a bucket resource, recording facts that have
/// happened rather than operations in flight.
enum BucketStatus implements _i1.SerializableModel {
  /// The database row exists; provisioning of the cloud bucket is pending or
  /// in progress.
  created,

  /// The cloud bucket has been provisioned and is ready for use.
  provisioned,

  /// Deletion has been requested; removal of the cloud bucket is pending or
  /// in progress.
  deletionRequested,

  /// The cloud bucket has been removed.
  deleted;

  static BucketStatus fromJson(String name) {
    switch (name) {
      case 'created':
        return BucketStatus.created;
      case 'provisioned':
        return BucketStatus.provisioned;
      case 'deletionRequested':
        return BucketStatus.deletionRequested;
      case 'deleted':
        return BucketStatus.deleted;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "BucketStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

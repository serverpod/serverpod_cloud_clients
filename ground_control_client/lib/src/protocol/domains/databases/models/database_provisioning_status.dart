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

/// The lifecycle state of a `DatabaseProvisioning` row, recording facts that
/// have happened rather than operations in flight.
///
/// There is no `ready` value here: once provisioning succeeds, the row is
/// deleted and a `DatabaseResource` row exists instead.
enum DatabaseProvisioningStatus implements _i1.SerializableModel {
  /// Provisioning has been requested; no external call has been made yet.
  pending,

  /// A worker has claimed the row and is provisioning the external database.
  provisioning,

  /// The last provisioning attempt failed. See `lastError`. Retried
  /// automatically up to the attempt limit, or manually via `enableDatabase`.
  failed,

  /// Deletion was requested while provisioning was pending or in progress.
  /// The worker (or the reconcile job) finishes cleanup and deletes the row.
  cancellationRequested;

  static DatabaseProvisioningStatus fromJson(String name) {
    switch (name) {
      case 'pending':
        return DatabaseProvisioningStatus.pending;
      case 'provisioning':
        return DatabaseProvisioningStatus.provisioning;
      case 'failed':
        return DatabaseProvisioningStatus.failed;
      case 'cancellationRequested':
        return DatabaseProvisioningStatus.cancellationRequested;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "DatabaseProvisioningStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

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

/// The provisioning state of a capsule's database, as seen by clients.
///
/// - `pending` — provisioning has been requested but has not started yet.
/// - `provisioning` — the external database is being created.
/// - `ready` — the database exists and can be used.
/// - `failed` — provisioning failed. See `DatabaseInfo.statusMessage` for a
///   user-safe description. Re-request with `enableDatabase`.
/// - `unknown` — a status value this client does not recognize. Consumers
///   must treat it as not ready.
enum DatabaseStatus implements _i1.SerializableModel {
  pending,
  provisioning,
  ready,
  failed,
  unknown;

  static DatabaseStatus fromJson(String name) {
    switch (name) {
      case 'pending':
        return DatabaseStatus.pending;
      case 'provisioning':
        return DatabaseStatus.provisioning;
      case 'ready':
        return DatabaseStatus.ready;
      case 'failed':
        return DatabaseStatus.failed;
      case 'unknown':
        return DatabaseStatus.unknown;
      default:
        return DatabaseStatus.unknown;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

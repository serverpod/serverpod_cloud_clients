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

/// The states of an app build.
/// - `queued` — waiting in Ground Control's queue, either for the upload
///   to finish or for the owner's running build to end.
/// - `waiting` — handed to the build service, waiting for a build machine.
/// - `running` — a build machine is working on it.
/// - `succeeded` — built and uploaded to the store.
/// - `failed` — ended with an error; `message` and the failed step say why.
/// - `cancelled` — cancelled by a user before it ended.
enum AppBuildStatus implements _isc.SerializableModel {
  queued,
  waiting,
  running,
  succeeded,
  failed,
  cancelled;

  static AppBuildStatus fromJson(String name) {
    switch (name) {
      case 'queued':
        return AppBuildStatus.queued;
      case 'waiting':
        return AppBuildStatus.waiting;
      case 'running':
        return AppBuildStatus.running;
      case 'succeeded':
        return AppBuildStatus.succeeded;
      case 'failed':
        return AppBuildStatus.failed;
      case 'cancelled':
        return AppBuildStatus.cancelled;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "AppBuildStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

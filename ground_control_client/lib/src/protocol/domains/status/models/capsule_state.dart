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

/// The runtime state of a capsule or its deployment.
///
/// Mirrors the state vocabulary of the capsule-status contract:
/// - `ready` — fully rolled out and serving as desired.
/// - `progressing` — a rollout is transitioning the deployment.
/// - `degraded` — serving, but with fewer ready replicas than desired.
/// - `unavailable` — replicas are desired but none are ready.
/// - `suspended` — deliberately scaled to zero (paused capsule).
/// - `notProvisioned` — the workload is not (or not correctly) in place.
/// - `unknown` — the status service reported a state this server does not
///   recognize. Consumers must treat it as not ready.
enum CapsuleState implements _i1.SerializableModel {
  ready,
  progressing,
  degraded,
  unavailable,
  suspended,
  notProvisioned,
  unknown;

  static CapsuleState fromJson(String name) {
    switch (name) {
      case 'ready':
        return CapsuleState.ready;
      case 'progressing':
        return CapsuleState.progressing;
      case 'degraded':
        return CapsuleState.degraded;
      case 'unavailable':
        return CapsuleState.unavailable;
      case 'suspended':
        return CapsuleState.suspended;
      case 'notProvisioned':
        return CapsuleState.notProvisioned;
      case 'unknown':
        return CapsuleState.unknown;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "CapsuleState"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

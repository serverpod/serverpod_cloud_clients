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

/// Why a database series may be empty over the queried window.
///
/// Emptiness is never an error and never a zero: a suspended compute stops
/// exporting entirely, and a database that does not have export enabled has no
/// series at all. Both are reported as state, so a client can say which one
/// it is looking at.
enum DatabaseMetricsStatus implements _isc.SerializableModel {
  /// The database exported at least one sample in the window.
  reporting,

  /// Export is enabled but nothing arrived for the whole window, which for a
  /// scale-to-zero database means it was suspended throughout: the provider
  /// stops exporting about five minutes after the last activity and resumes
  /// about nine seconds after wake. Strictly this is what we observe rather
  /// than what we know — a broken exporter on a running compute reads the
  /// same way.
  idle,

  /// Metrics export is not enabled on this database, so its series are not
  /// collected and the store is not queried. History only accrues from when
  /// export is switched on — the provider cannot backfill the gap before that.
  exportNotEnabled;

  static DatabaseMetricsStatus fromJson(String name) {
    switch (name) {
      case 'reporting':
        return DatabaseMetricsStatus.reporting;
      case 'idle':
        return DatabaseMetricsStatus.idle;
      case 'exportNotEnabled':
        return DatabaseMetricsStatus.exportNotEnabled;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "DatabaseMetricsStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

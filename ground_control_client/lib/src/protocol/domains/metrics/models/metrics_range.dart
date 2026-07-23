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

/// A predefined span length for pod resource metrics queries.
///
/// The span is combined with an anchor (see `until`) to form the query
/// window. Each span maps to a server-side sampling step; callers never choose
/// the granularity directly, so a query can never be oversized.
enum MetricsRange implements _i1.SerializableModel {
  oneHour,
  oneDay,
  oneWeek,
  oneMonth;

  static MetricsRange fromJson(String name) {
    switch (name) {
      case 'oneHour':
        return MetricsRange.oneHour;
      case 'oneDay':
        return MetricsRange.oneDay;
      case 'oneWeek':
        return MetricsRange.oneWeek;
      case 'oneMonth':
        return MetricsRange.oneMonth;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "MetricsRange"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

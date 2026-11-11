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

/// How many app builds the project's owner has used this month against
/// the plan's allowance. One build is one archive upload, however many
/// platforms it was built for, and counts once the store accepted it.
abstract class AppBuildUsage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppBuildUsage._({required this.used, this.limit, required this.resetsAt});

  factory AppBuildUsage({
    required int used,
    int? limit,
    required DateTime resetsAt,
  }) = _AppBuildUsageImpl;

  factory AppBuildUsage.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppBuildUsage(
      used: jsonSerialization['used'] as int,
      limit: jsonSerialization['limit'] as int?,
      resetsAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['resetsAt'],
      ),
    );
  }

  /// Builds used in the current period.
  int used;

  /// Builds the plan allows per period. Null when unlimited.
  int? limit;

  /// When the period ends and the count starts over.
  DateTime resetsAt;

  /// Returns a shallow copy of this [AppBuildUsage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppBuildUsage copyWith({int? used, int? limit, DateTime? resetsAt});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppBuildUsage',
      'used': used,
      if (limit != null) 'limit': limit,
      'resetsAt': resetsAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppBuildUsage',
      'used': used,
      if (limit != null) 'limit': limit,
      'resetsAt': resetsAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppBuildUsageImpl extends AppBuildUsage {
  _AppBuildUsageImpl({
    required int used,
    int? limit,
    required DateTime resetsAt,
  }) : super._(used: used, limit: limit, resetsAt: resetsAt);

  /// Returns a shallow copy of this [AppBuildUsage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppBuildUsage copyWith({
    int? used,
    Object? limit = _Undefined,
    DateTime? resetsAt,
  }) {
    return AppBuildUsage(
      used: used ?? this.used,
      limit: limit is int? ? limit : this.limit,
      resetsAt: resetsAt ?? this.resetsAt,
    );
  }
}

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

abstract class Timestamp implements _i1.SerializableModel {
  Timestamp._({this.timestamp});

  factory Timestamp({DateTime? timestamp}) = _TimestampImpl;

  factory Timestamp.fromJson(Map<String, dynamic> jsonSerialization) {
    return Timestamp(
        timestamp: jsonSerialization['timestamp'] == null
            ? null
            : _i1.DateTimeJsonExtension.fromJson(
                jsonSerialization['timestamp']));
  }

  DateTime? timestamp;

  /// Returns a shallow copy of this [Timestamp]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Timestamp copyWith({DateTime? timestamp});
  @override
  Map<String, dynamic> toJson() {
    return {if (timestamp != null) 'timestamp': timestamp?.toJson()};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TimestampImpl extends Timestamp {
  _TimestampImpl({DateTime? timestamp}) : super._(timestamp: timestamp);

  /// Returns a shallow copy of this [Timestamp]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Timestamp copyWith({Object? timestamp = _Undefined}) {
    return Timestamp(
        timestamp: timestamp is DateTime? ? timestamp : this.timestamp);
  }
}

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

/// A single observed sample in a pod metric series.
///
/// Gaps (pod not started, deploy boundary, terminated pod) are represented by
/// the absence of a sample at a timestamp, never by an interpolated or
/// fabricated value.
abstract class PodMetricSample implements _i1.SerializableModel {
  PodMetricSample._({required this.timestamp, required this.value});

  factory PodMetricSample({
    required DateTime timestamp,
    required double value,
  }) = _PodMetricSampleImpl;

  factory PodMetricSample.fromJson(Map<String, dynamic> jsonSerialization) {
    return PodMetricSample(
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      value: (jsonSerialization['value'] as num).toDouble(),
    );
  }

  /// When the sample was observed.
  DateTime timestamp;

  /// The observed value: CPU cores or memory bytes, depending on the series.
  double value;

  /// Returns a shallow copy of this [PodMetricSample]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PodMetricSample copyWith({DateTime? timestamp, double? value});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PodMetricSample',
      'timestamp': timestamp.toJson(),
      'value': value,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PodMetricSampleImpl extends PodMetricSample {
  _PodMetricSampleImpl({required DateTime timestamp, required double value})
    : super._(timestamp: timestamp, value: value);

  /// Returns a shallow copy of this [PodMetricSample]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PodMetricSample copyWith({DateTime? timestamp, double? value}) {
    return PodMetricSample(
      timestamp: timestamp ?? this.timestamp,
      value: value ?? this.value,
    );
  }
}

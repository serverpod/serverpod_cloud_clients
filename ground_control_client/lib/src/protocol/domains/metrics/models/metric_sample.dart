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

/// A single observed sample in a metric series, for a pod or a database alike.
///
/// Gaps — a pod not yet started, a deploy boundary, a terminated pod, a
/// suspended database compute — are represented by the absence of a sample at
/// a timestamp, never by an interpolated or fabricated value.
abstract class MetricSample
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MetricSample._({required this.timestamp, required this.value});

  factory MetricSample({required DateTime timestamp, required double value}) =
      _MetricSampleImpl;

  factory MetricSample.fromJson(Map<String, dynamic> jsonSerialization) {
    return MetricSample(
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      value: (jsonSerialization['value'] as num).toDouble(),
    );
  }

  /// When the sample was observed.
  DateTime timestamp;

  /// The observed value; the unit depends on the series.
  double value;

  /// Returns a shallow copy of this [MetricSample]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MetricSample copyWith({DateTime? timestamp, double? value});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MetricSample',
      'timestamp': timestamp.toJson(),
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MetricSample',
      'timestamp': timestamp.toJson(),
      'value': value,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MetricSampleImpl extends MetricSample {
  _MetricSampleImpl({required DateTime timestamp, required double value})
    : super._(timestamp: timestamp, value: value);

  /// Returns a shallow copy of this [MetricSample]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MetricSample copyWith({DateTime? timestamp, double? value}) {
    return MetricSample(
      timestamp: timestamp ?? this.timestamp,
      value: value ?? this.value,
    );
  }
}

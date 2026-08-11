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
import '../../../shared/models/http_response_class.dart' as _i2;
import '../../../domains/metrics/models/metric_sample.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

/// Response-rate series for a single status class of a capsule's aggregate
/// traffic.
///
/// Series are sparse: a status class the gateway never recorded over the
/// window is simply absent from the capsule's list, which is distinct from a
/// class that recorded zero. Zeros reach the wire unchanged — an
/// idle-but-deployed capsule still has its counters, so a zero is a real
/// reading.
abstract class ResponseClassSeries
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ResponseClassSeries._({
    required this.responseClass,
    required this.responsesPerSecond,
  });

  factory ResponseClassSeries({
    required _i2.HttpResponseClass responseClass,
    required List<_i3.MetricSample> responsesPerSecond,
  }) = _ResponseClassSeriesImpl;

  factory ResponseClassSeries.fromJson(Map<String, dynamic> jsonSerialization) {
    return ResponseClassSeries(
      responseClass: _i2.HttpResponseClass.fromJson(
        (jsonSerialization['responseClass'] as String),
      ),
      responsesPerSecond: _i4.Protocol().deserialize<List<_i3.MetricSample>>(
        jsonSerialization['responsesPerSecond'],
      ),
    );
  }

  /// The status class these samples belong to.
  _i2.HttpResponseClass responseClass;

  /// Response-rate samples, in requests per second.
  List<_i3.MetricSample> responsesPerSecond;

  /// Returns a shallow copy of this [ResponseClassSeries]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ResponseClassSeries copyWith({
    _i2.HttpResponseClass? responseClass,
    List<_i3.MetricSample>? responsesPerSecond,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ResponseClassSeries',
      'responseClass': responseClass.toJson(),
      'responsesPerSecond': responsesPerSecond.toJson(
        valueToJson: (v) => v.toJson(),
      ),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ResponseClassSeries',
      'responseClass': responseClass.toJson(),
      'responsesPerSecond': responsesPerSecond.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ResponseClassSeriesImpl extends ResponseClassSeries {
  _ResponseClassSeriesImpl({
    required _i2.HttpResponseClass responseClass,
    required List<_i3.MetricSample> responsesPerSecond,
  }) : super._(
         responseClass: responseClass,
         responsesPerSecond: responsesPerSecond,
       );

  /// Returns a shallow copy of this [ResponseClassSeries]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ResponseClassSeries copyWith({
    _i2.HttpResponseClass? responseClass,
    List<_i3.MetricSample>? responsesPerSecond,
  }) {
    return ResponseClassSeries(
      responseClass: responseClass ?? this.responseClass,
      responsesPerSecond:
          responsesPerSecond ??
          this.responsesPerSecond.map((e0) => e0.copyWith()).toList(),
    );
  }
}

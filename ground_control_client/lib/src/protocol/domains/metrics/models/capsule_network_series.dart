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
import 'package:ground_control_client/src/protocol/protocol.dart' as _iod2a87h;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../../domains/metrics/models/metric_sample.dart' as _ic8vhv48;
import '../../../domains/metrics/models/response_class_series.dart'
    as _itmrbcx4;

/// Aggregate network signals for a capsule over a time range.
///
/// Requests and responses share a window and step, so a client can draw them
/// on one time axis. The capsule's routers are summed into a single series
/// each — the query scopes to the capsule's own router clusters, so
/// gateway-generated traffic is never counted toward the aggregate. Series are
/// sparse: an entirely empty result reads as "no data", distinct from a series
/// that is present with zero-rate samples, which reads as "no traffic" — an
/// idle-but-deployed capsule still has its Envoy counters. The store
/// disambiguates the two, so this model carries no status flag.
abstract class CapsuleNetworkSeries
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CapsuleNetworkSeries._({
    required this.requestsPerSecond,
    required this.responses,
  });

  factory CapsuleNetworkSeries({
    required List<_ic8vhv48.MetricSample> requestsPerSecond,
    required List<_itmrbcx4.ResponseClassSeries> responses,
  }) = _CapsuleNetworkSeriesImpl;

  factory CapsuleNetworkSeries.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CapsuleNetworkSeries(
      requestsPerSecond: _iod2a87h.Protocol()
          .deserialize<List<_ic8vhv48.MetricSample>>(
            jsonSerialization['requestsPerSecond'],
          ),
      responses: _iod2a87h.Protocol()
          .deserialize<List<_itmrbcx4.ResponseClassSeries>>(
            jsonSerialization['responses'],
          ),
    );
  }

  /// Request-rate samples, in requests per second.
  List<_ic8vhv48.MetricSample> requestsPerSecond;

  /// Per-status-class response-rate series, in status-class order. A class
  /// absent from the result is absent from this list; a class with zero-rate
  /// samples is present.
  List<_itmrbcx4.ResponseClassSeries> responses;

  /// Returns a shallow copy of this [CapsuleNetworkSeries]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CapsuleNetworkSeries copyWith({
    List<_ic8vhv48.MetricSample>? requestsPerSecond,
    List<_itmrbcx4.ResponseClassSeries>? responses,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CapsuleNetworkSeries',
      'requestsPerSecond': requestsPerSecond.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'responses': responses.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CapsuleNetworkSeries',
      'requestsPerSecond': requestsPerSecond.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'responses': responses.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CapsuleNetworkSeriesImpl extends CapsuleNetworkSeries {
  _CapsuleNetworkSeriesImpl({
    required List<_ic8vhv48.MetricSample> requestsPerSecond,
    required List<_itmrbcx4.ResponseClassSeries> responses,
  }) : super._(requestsPerSecond: requestsPerSecond, responses: responses);

  /// Returns a shallow copy of this [CapsuleNetworkSeries]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CapsuleNetworkSeries copyWith({
    List<_ic8vhv48.MetricSample>? requestsPerSecond,
    List<_itmrbcx4.ResponseClassSeries>? responses,
  }) {
    return CapsuleNetworkSeries(
      requestsPerSecond:
          requestsPerSecond ??
          this.requestsPerSecond.map((e0) => e0.copyWith()).toList(),
      responses:
          responses ?? this.responses.map((e0) => e0.copyWith()).toList(),
    );
  }
}

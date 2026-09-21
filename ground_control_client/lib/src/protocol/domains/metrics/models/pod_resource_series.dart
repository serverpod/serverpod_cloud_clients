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

/// Per-pod CPU and memory series for a capsule over a time range.
///
/// CPU is measured in cores and memory in bytes. Series are sparse: a period
/// with no backend samples simply has no points, so a client can distinguish
/// "no data" from a real zero.
abstract class PodResourceSeries
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PodResourceSeries._({
    required this.podName,
    required this.cpuCores,
    required this.memoryBytes,
  });

  factory PodResourceSeries({
    required String podName,
    required List<_ic8vhv48.MetricSample> cpuCores,
    required List<_ic8vhv48.MetricSample> memoryBytes,
  }) = _PodResourceSeriesImpl;

  factory PodResourceSeries.fromJson(Map<String, dynamic> jsonSerialization) {
    return PodResourceSeries(
      podName: jsonSerialization['podName'] as String,
      cpuCores: _iod2a87h.Protocol().deserialize<List<_ic8vhv48.MetricSample>>(
        jsonSerialization['cpuCores'],
      ),
      memoryBytes: _iod2a87h.Protocol()
          .deserialize<List<_ic8vhv48.MetricSample>>(
            jsonSerialization['memoryBytes'],
          ),
    );
  }

  /// The name of the pod these series belong to.
  String podName;

  /// CPU usage samples, in cores.
  List<_ic8vhv48.MetricSample> cpuCores;

  /// Memory usage samples, in bytes.
  List<_ic8vhv48.MetricSample> memoryBytes;

  /// Returns a shallow copy of this [PodResourceSeries]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PodResourceSeries copyWith({
    String? podName,
    List<_ic8vhv48.MetricSample>? cpuCores,
    List<_ic8vhv48.MetricSample>? memoryBytes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PodResourceSeries',
      'podName': podName,
      'cpuCores': cpuCores.toJson(valueToJson: (v) => v.toJson()),
      'memoryBytes': memoryBytes.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PodResourceSeries',
      'podName': podName,
      'cpuCores': cpuCores.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'memoryBytes': memoryBytes.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _PodResourceSeriesImpl extends PodResourceSeries {
  _PodResourceSeriesImpl({
    required String podName,
    required List<_ic8vhv48.MetricSample> cpuCores,
    required List<_ic8vhv48.MetricSample> memoryBytes,
  }) : super._(podName: podName, cpuCores: cpuCores, memoryBytes: memoryBytes);

  /// Returns a shallow copy of this [PodResourceSeries]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PodResourceSeries copyWith({
    String? podName,
    List<_ic8vhv48.MetricSample>? cpuCores,
    List<_ic8vhv48.MetricSample>? memoryBytes,
  }) {
    return PodResourceSeries(
      podName: podName ?? this.podName,
      cpuCores: cpuCores ?? this.cpuCores.map((e0) => e0.copyWith()).toList(),
      memoryBytes:
          memoryBytes ?? this.memoryBytes.map((e0) => e0.copyWith()).toList(),
    );
  }
}

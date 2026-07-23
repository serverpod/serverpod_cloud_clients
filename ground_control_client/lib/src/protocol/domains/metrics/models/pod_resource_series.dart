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
import '../../../domains/metrics/models/pod_metric_sample.dart' as _i2;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i3;

/// Per-pod CPU and memory series for a capsule over a time range.
///
/// CPU is measured in cores and memory in bytes. Series are sparse: a period
/// with no backend samples simply has no points, so a client can distinguish
/// "no data" from a real zero.
abstract class PodResourceSeries implements _i1.SerializableModel {
  PodResourceSeries._({
    required this.podName,
    required this.cpuCores,
    required this.memoryBytes,
  });

  factory PodResourceSeries({
    required String podName,
    required List<_i2.PodMetricSample> cpuCores,
    required List<_i2.PodMetricSample> memoryBytes,
  }) = _PodResourceSeriesImpl;

  factory PodResourceSeries.fromJson(Map<String, dynamic> jsonSerialization) {
    return PodResourceSeries(
      podName: jsonSerialization['podName'] as String,
      cpuCores: _i3.Protocol().deserialize<List<_i2.PodMetricSample>>(
        jsonSerialization['cpuCores'],
      ),
      memoryBytes: _i3.Protocol().deserialize<List<_i2.PodMetricSample>>(
        jsonSerialization['memoryBytes'],
      ),
    );
  }

  /// The name of the pod these series belong to.
  String podName;

  /// CPU usage samples, in cores.
  List<_i2.PodMetricSample> cpuCores;

  /// Memory usage samples, in bytes.
  List<_i2.PodMetricSample> memoryBytes;

  /// Returns a shallow copy of this [PodResourceSeries]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PodResourceSeries copyWith({
    String? podName,
    List<_i2.PodMetricSample>? cpuCores,
    List<_i2.PodMetricSample>? memoryBytes,
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
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PodResourceSeriesImpl extends PodResourceSeries {
  _PodResourceSeriesImpl({
    required String podName,
    required List<_i2.PodMetricSample> cpuCores,
    required List<_i2.PodMetricSample> memoryBytes,
  }) : super._(podName: podName, cpuCores: cpuCores, memoryBytes: memoryBytes);

  /// Returns a shallow copy of this [PodResourceSeries]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PodResourceSeries copyWith({
    String? podName,
    List<_i2.PodMetricSample>? cpuCores,
    List<_i2.PodMetricSample>? memoryBytes,
  }) {
    return PodResourceSeries(
      podName: podName ?? this.podName,
      cpuCores: cpuCores ?? this.cpuCores.map((e0) => e0.copyWith()).toList(),
      memoryBytes:
          memoryBytes ?? this.memoryBytes.map((e0) => e0.copyWith()).toList(),
    );
  }
}

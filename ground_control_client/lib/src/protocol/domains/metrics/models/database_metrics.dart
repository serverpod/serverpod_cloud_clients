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
import '../../../domains/metrics/models/database_metrics_status.dart' as _i2;
import '../../../domains/metrics/models/metric_sample.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

/// Database signals for a capsule over a time range.
///
/// The four series answer the questions an operator can act on: is the
/// compute saturated (CPU, memory), is the database running out of
/// connections, and is storage growing. Series are sparse and share the
/// window and step of the pod metrics for the same capsule, so both can be
/// drawn on one time axis.
abstract class DatabaseMetrics
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  DatabaseMetrics._({
    required this.status,
    required this.cpuCores,
    required this.memoryBytes,
    required this.connections,
    required this.storageBytes,
  });

  factory DatabaseMetrics({
    required _i2.DatabaseMetricsStatus status,
    required List<_i3.MetricSample> cpuCores,
    required List<_i3.MetricSample> memoryBytes,
    required List<_i3.MetricSample> connections,
    required List<_i3.MetricSample> storageBytes,
  }) = _DatabaseMetricsImpl;

  factory DatabaseMetrics.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseMetrics(
      status: _i2.DatabaseMetricsStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      cpuCores: _i4.Protocol().deserialize<List<_i3.MetricSample>>(
        jsonSerialization['cpuCores'],
      ),
      memoryBytes: _i4.Protocol().deserialize<List<_i3.MetricSample>>(
        jsonSerialization['memoryBytes'],
      ),
      connections: _i4.Protocol().deserialize<List<_i3.MetricSample>>(
        jsonSerialization['connections'],
      ),
      storageBytes: _i4.Protocol().deserialize<List<_i3.MetricSample>>(
        jsonSerialization['storageBytes'],
      ),
    );
  }

  /// Whether the database was reporting, idle, or does not have export enabled.
  /// Series are empty for every state except `reporting`.
  _i2.DatabaseMetricsStatus status;

  /// Compute CPU usage samples, in cores.
  List<_i3.MetricSample> cpuCores;

  /// Compute memory in active use, in bytes.
  List<_i3.MetricSample> memoryBytes;

  /// Open client connections across all logical databases, in count.
  List<_i3.MetricSample> connections;

  /// Total size of all logical databases, in bytes.
  List<_i3.MetricSample> storageBytes;

  /// Returns a shallow copy of this [DatabaseMetrics]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseMetrics copyWith({
    _i2.DatabaseMetricsStatus? status,
    List<_i3.MetricSample>? cpuCores,
    List<_i3.MetricSample>? memoryBytes,
    List<_i3.MetricSample>? connections,
    List<_i3.MetricSample>? storageBytes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseMetrics',
      'status': status.toJson(),
      'cpuCores': cpuCores.toJson(valueToJson: (v) => v.toJson()),
      'memoryBytes': memoryBytes.toJson(valueToJson: (v) => v.toJson()),
      'connections': connections.toJson(valueToJson: (v) => v.toJson()),
      'storageBytes': storageBytes.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DatabaseMetrics',
      'status': status.toJson(),
      'cpuCores': cpuCores.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'memoryBytes': memoryBytes.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'connections': connections.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'storageBytes': storageBytes.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DatabaseMetricsImpl extends DatabaseMetrics {
  _DatabaseMetricsImpl({
    required _i2.DatabaseMetricsStatus status,
    required List<_i3.MetricSample> cpuCores,
    required List<_i3.MetricSample> memoryBytes,
    required List<_i3.MetricSample> connections,
    required List<_i3.MetricSample> storageBytes,
  }) : super._(
         status: status,
         cpuCores: cpuCores,
         memoryBytes: memoryBytes,
         connections: connections,
         storageBytes: storageBytes,
       );

  /// Returns a shallow copy of this [DatabaseMetrics]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseMetrics copyWith({
    _i2.DatabaseMetricsStatus? status,
    List<_i3.MetricSample>? cpuCores,
    List<_i3.MetricSample>? memoryBytes,
    List<_i3.MetricSample>? connections,
    List<_i3.MetricSample>? storageBytes,
  }) {
    return DatabaseMetrics(
      status: status ?? this.status,
      cpuCores: cpuCores ?? this.cpuCores.map((e0) => e0.copyWith()).toList(),
      memoryBytes:
          memoryBytes ?? this.memoryBytes.map((e0) => e0.copyWith()).toList(),
      connections:
          connections ?? this.connections.map((e0) => e0.copyWith()).toList(),
      storageBytes:
          storageBytes ?? this.storageBytes.map((e0) => e0.copyWith()).toList(),
    );
  }
}

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

class DatabaseMetricsBuilder {
  DatabaseMetricsStatus _status;
  List<MetricSample> _cpuCores;
  List<MetricSample> _memoryBytes;
  List<MetricSample> _connections;
  List<MetricSample> _storageBytes;

  DatabaseMetricsBuilder()
    : _status = DatabaseMetricsStatus.reporting,
      _cpuCores = [MetricSampleBuilder().withValue(0.1).build()],
      _memoryBytes = [MetricSampleBuilder().withValue(128000000).build()],
      _connections = [MetricSampleBuilder().withValue(5).build()],
      _storageBytes = [MetricSampleBuilder().withValue(64000000).build()];

  /// The database was suspended for the whole window, so it exported nothing.
  DatabaseMetricsBuilder withIdleDatabase() {
    _status = DatabaseMetricsStatus.idle;
    return _withoutSamples();
  }

  /// Metrics export is not enabled on the database.
  DatabaseMetricsBuilder withExportNotEnabled() {
    _status = DatabaseMetricsStatus.exportNotEnabled;
    return _withoutSamples();
  }

  DatabaseMetricsBuilder withCpuCores(List<MetricSample> cpuCores) {
    _cpuCores = cpuCores;
    return this;
  }

  DatabaseMetricsBuilder withConnections(List<MetricSample> connections) {
    _connections = connections;
    return this;
  }

  DatabaseMetricsBuilder _withoutSamples() {
    _cpuCores = [];
    _memoryBytes = [];
    _connections = [];
    _storageBytes = [];
    return this;
  }

  DatabaseMetrics build() {
    return DatabaseMetrics(
      status: _status,
      cpuCores: _cpuCores,
      memoryBytes: _memoryBytes,
      connections: _connections,
      storageBytes: _storageBytes,
    );
  }
}

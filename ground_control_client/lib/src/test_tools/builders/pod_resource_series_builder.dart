import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

class PodResourceSeriesBuilder {
  String _podName;
  List<MetricSample> _cpuCores;
  List<MetricSample> _memoryBytes;

  PodResourceSeriesBuilder()
    : _podName = 'test-pod-0',
      _cpuCores = [MetricSampleBuilder().withValue(0.25).build()],
      _memoryBytes = [MetricSampleBuilder().withValue(256000000).build()];

  PodResourceSeriesBuilder withPodName(String podName) {
    _podName = podName;

    return this;
  }

  PodResourceSeriesBuilder withCpuCores(List<MetricSample> cpuCores) {
    _cpuCores = cpuCores;

    return this;
  }

  PodResourceSeriesBuilder withMemoryBytes(List<MetricSample> memoryBytes) {
    _memoryBytes = memoryBytes;

    return this;
  }

  PodResourceSeries build() {
    return PodResourceSeries(
      podName: _podName,
      cpuCores: _cpuCores,
      memoryBytes: _memoryBytes,
    );
  }
}

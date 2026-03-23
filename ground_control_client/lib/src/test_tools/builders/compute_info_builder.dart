import 'package:ground_control_client/ground_control_client.dart';

class ComputeInfoBuilder {
  String _cloudCapsuleId;
  ComputeSizeOption _size;
  int _minInstances;
  int _maxInstances;
  int _memoryMb;

  ComputeInfoBuilder()
    : _cloudCapsuleId = 'test',
      _size = ComputeSizeOption.small,
      _minInstances = 1,
      _maxInstances = 2,
      _memoryMb = 512;

  ComputeInfoBuilder withCloudCapsuleId(final String cloudCapsuleId) {
    _cloudCapsuleId = cloudCapsuleId;
    return this;
  }

  ComputeInfoBuilder withSize(final ComputeSizeOption size) {
    _size = size;
    return this;
  }

  ComputeInfoBuilder withMinInstances(final int minInstances) {
    _minInstances = minInstances;
    return this;
  }

  ComputeInfoBuilder withMaxInstances(final int maxInstances) {
    _maxInstances = maxInstances;
    return this;
  }

  ComputeInfoBuilder withMemoryMb(final int memoryMb) {
    _memoryMb = memoryMb;
    return this;
  }

  ComputeInfo build() {
    return ComputeInfo(
      cloudCapsuleId: _cloudCapsuleId,
      size: _size,
      minInstances: _minInstances,
      maxInstances: _maxInstances,
      memoryMb: _memoryMb,
    );
  }
}

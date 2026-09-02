import 'package:ground_control_client/ground_control_client.dart';

class DatabaseInfoBuilder {
  String _cloudCapsuleId;
  DatabaseSizeOption _size;
  double? _minCu;
  double? _maxCu;
  int _memoryMb;
  int? _storageLimitGB;
  int? _computeHoursLimit;

  DatabaseInfoBuilder()
    : _cloudCapsuleId = 'test',
      _size = DatabaseSizeOption.small,
      _minCu = 1,
      _maxCu = 2,
      _memoryMb = 512,
      _storageLimitGB = 2,
      _computeHoursLimit = 100;

  DatabaseInfoBuilder withCloudCapsuleId(String cloudCapsuleId) {
    _cloudCapsuleId = cloudCapsuleId;
    return this;
  }

  DatabaseInfoBuilder withSize(DatabaseSizeOption size) {
    _size = size;
    return this;
  }

  DatabaseInfoBuilder withMinCu(double? minCu) {
    _minCu = minCu;
    return this;
  }

  DatabaseInfoBuilder withMaxCu(double? maxCu) {
    _maxCu = maxCu;
    return this;
  }

  DatabaseInfoBuilder withMemoryMb(int memoryMb) {
    _memoryMb = memoryMb;
    return this;
  }

  DatabaseInfoBuilder withStorageLimitGB(int? storageLimitGB) {
    _storageLimitGB = storageLimitGB;
    return this;
  }

  DatabaseInfoBuilder withComputeHoursLimit(int? computeHoursLimit) {
    _computeHoursLimit = computeHoursLimit;
    return this;
  }

  DatabaseInfo build() {
    return DatabaseInfo(
      cloudCapsuleId: _cloudCapsuleId,
      size: _size,
      minCu: _minCu,
      maxCu: _maxCu,
      memoryMb: _memoryMb,
      storageLimitGB: _storageLimitGB,
      computeHoursLimit: _computeHoursLimit,
    );
  }
}
